module GPIO
  class Pin
    EXPORT="/sys/class/gpio/export"
    UNEXPORT="/sys/class/gpio/unexport"
    VALUE="/sys/class/gpio/gpio%d/value"
    DIRECTION="/sys/class/gpio/gpio%d/direction"
    ALIAS = { high: 1, low: 0, on: 1, off: 0, "1" => 1, "0" => 0 }
    GPIO_PINS = [ 17, 18, 27, 22, 23, 24, 25, 4, 2, 3, 8, 7, 10, 9, 11, 14, 15 ]

    attr_reader :direction

    def initialize(pin, direction)
      raise "Pin number must be between 0 and 16 inclusive." if pin > 16 or pin < 0

      @pin = GPIO_PINS[pin]
      export
      ObjectSpace.define_finalizer(self, self.class.finalizer(@pin))
      set_direction direction
    end

    def export
      self.class.export @pin
    end

    def unexport
      self.class.unexport @pin
    end

    def set_direction direction
      @direction = direction
      self.class.set_direction @pin, direction
    end

    def set value
      value = dealias value
      return if @value == value

      begin
        @descriptor.seek(0)
        @descriptor.write(value)
      rescue NoMethodError, Errno::ENODEV
        @descriptor = open(VALUE % @pin, "w")
        @descriptor.sync = true
        retry
      end
      @value = value
    end

    def pulse delay = nil, pre_sleep = false
      set :high if delay and pre_sleep
      sleep delay if sleep
      set :low
    end

    def pin
      GPIO_PINS.index @pin
    end

    def dealias value
      return value if value.is_a? Integer
      raise "Can not set pin to #{value}" unless ALIAS.include? value
      ALIAS[value]
    end

    def self.finalizer pin
      proc do
        unexport pin
      end
    end

    def self.export pin
      IO.write EXPORT, pin.to_s
    end

    def self.unexport pin
      IO.write UNEXPORT, pin.to_s
    end

    def self.set_direction pin, direction
      raise "Unsupported direction #{direction}" unless %w[ in out ].include? direction.to_s
      IO.write DIRECTION % pin, direction.to_s
    end
  end

  def self.shift_out data_pin, clock_pin, data, direction = :msb_first
    raise "Data pin must be a GPIO::Pin object" unless data_pin.is_a? GPIO::Pin
    raise "Clock pin must be a GPIO::Pin object" unless clock_pin.is_a? GPIO::Pin

    data_array = data.to_s(2).rjust(8, '0')
    data_array.reverse! if direction == :lsb_first

    data_pin.set :off # Initialize stream
    data_array.split('').each do |bit|
      clock_pin.set :off
      data_pin.set  bit
      clock_pin.set :on  # Register shifts bits on leading high edge
      data_pin.set  :off # Zero data to prevent bleed through
    end
    clock_pin.set :off # Finish shifting.
  end
end
