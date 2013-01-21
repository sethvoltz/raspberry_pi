#!/usr/bin/env ruby

$: << File.expand_path(File.dirname __FILE__)
require 'util'
require 'gpio'

module GPIO
  class ShiftBrite
    attr_reader :data_pin, :latch_pin, :enable_pin, :clock_pin, :current, :num_pixels

    def initialize data_pin, latch_pin, enable_pin, clock_pin, num_pixels
      @data_pin   = GPIO::Pin.new data_pin,   :out
      @latch_pin  = GPIO::Pin.new latch_pin,  :out
      @enable_pin = GPIO::Pin.new enable_pin, :out
      @clock_pin  = GPIO::Pin.new clock_pin,  :out
      @num_pixels = num_pixels

      # Set proper pins low before writes
      @latch_pin.set  :low
      @enable_pin.set :low
    end

    def sendPacket commandMode, redCommand, greenCommand, blueCommand
      # Construct packet
      commandPacket = commandMode & 0b11
      commandPacket = (commandPacket << 10) | (blueCommand & 1023)
      commandPacket = (commandPacket << 10) | (redCommand & 1023)
      commandPacket = (commandPacket << 10) | (greenCommand & 1023)
      puts "Packet: #{commandPacket.to_s(2).rjust(32, '0')}\r"

      # Write packet, byte by byte
      GPIO.shift_out @data_pin, @clock_pin, (commandPacket >> 24) & 255, :msb_first
      GPIO.shift_out @data_pin, @clock_pin, (commandPacket >> 16) & 255, :msb_first
      GPIO.shift_out @data_pin, @clock_pin, (commandPacket >> 8)  & 255, :msb_first
      GPIO.shift_out @data_pin, @clock_pin,  commandPacket        & 255, :msb_first

      # Delay adjustment may be necessary depending on chain length
      @latch_pin.pulse 0.01, true
    end

    def pixels
      @pixels.reverse
    end

    def pixels= pixels
      @pixels = pixels[0..num_pixels-1].reverse # Last module gets first color in array.
    end

    def current= current
      @current = [0, [127, current].min].max
    end

    def write_pixels
      sendPacket 0b01, current, current, current # Write current control
      num_pixels.times do |index|
        sendPacket 0b00, *pixels[index] # Write color
      end
    end

    def cleanup
      num_pixels.times { sendPacket 0b00, 0, 0, 0 }
    end
  end
end

class LightShow
  attr_accessor :speed

  def initialize
    # https://projects.drogon.net/raspberry-pi/wiringpi/pins/
    @shift_brite = GPIO::ShiftBrite.new 12, 3, 2, 14
    @key_thread = Thread.new key_catcher
    @shift_brite.pixels = [[1023, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]]
    @speed = 50 # percent
    @shift_brite.current = 64

    puts "Colors are:"
    for color in @shift_brite.pixels
      puts " - #{color.collect{|c| c.to_s.rjust(4)}.join ', '}"
    end
  end

  def run
    @running = true
    loop do
      unless @running
        # Cleanup
        puts "Stopping..."
        @shift_brite.cleanup
        break
      end

      @shift_brite.pixels << @shift_brite.pixels.shift # Cycle the color array
      sleep @speed.scale_between 0, 100, 1.0, 0.01 # Inverted for proper semantic
    end
  end

  def shift_color length
    bits = 10
    @pixels.collect! { |pixel|
      pixel.collect { |color|
        color.to_s(2).rjust(bits,'0')
      }.join.split('').rotate(length).join.scan(/.{#{bits}}/).collect{ |n|
        n.to_i(2)
      }
    }
  end

  def set_speed speed
    @speed = [0, [100, speed].min].max
    puts "speed: #{@speed}"
  end

  def set_current current
    @shift_color.current = current.scale_between 0, 9, 0, 127
  end

  def key_catcher
    proc do
      loop do
        system("stty raw -echo")
        char = $stdin.getc
        system("stty -raw echo")
        case char
        when 'q'
          @running = false
          break
        when 'z' then slow_down
        when 'x' then speed_up
        when 'a' then shift_color  1
        when 'A' then shift_color  10
        when 's' then shift_color -1
        when 'S' then shift_color -10
        when '0'..'9' then set_current char.to_i
        end
      end
    end
  end
end

light_show = LightShow.new.run
