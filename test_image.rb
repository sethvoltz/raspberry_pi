#!/usr/bin/env ruby

$:.unshift '.'
require 'rmagick'
require 'color'

canvas = Magick::Image.new(360, 100)
gc = Magick::Draw.new
gc.fill_opacity 1

(0..359).each do |hue|
  (0...50).each do |saturation|
    hsv = Color::HSV.new hue, saturation * 2, 100
    rgb = hsv.to_rgb
    gc.fill "rgb(#{rgb.r * 100}%, #{rgb.g * 100}%, #{rgb.b * 100}%)"
    gc.rectangle hue, saturation, hue + 1, saturation + 1
  end

  (0...50).each do |value|
    hsv = Color::HSV.new hue, 100, 100 - value * 2
    rgb = hsv.to_rgb
    gc.fill "rgb(#{rgb.r * 100}%, #{rgb.g * 100}%, #{rgb.b * 100}%)"
    gc.rectangle hue, value + 50, hue + 1, value + 51
  end
end

gc.draw canvas
canvas.write 'output.png'
