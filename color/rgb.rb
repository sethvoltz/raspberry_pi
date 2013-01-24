module Color
  class RGB
    COMPONENTS = [ :r, :g, :b ]
    attr_accessor *COMPONENTS

    class << self
      def from_fraction r = 0.0, g = 0.0, b = 0.0
        color = new
        color.r = r
        color.g = g
        color.b = b
        color
      end
    end

    def initialize r = 0, g = 0, b = 0
      @r = r / 255.0
      @g = g / 255.0
      @b = b / 255.0
    end

    def == other
      other = other.to_rgb
      other.kind_of? self.class and COMPONENTS.select do |component|
        ((self.send component) - (other.send component)).abs <= Color::COLOR_TOLERANCE
      end.length == COMPONENTS.length
    end

    def to_rgb
      self
    end

    def to_hsv
      min = [@r, @g, @b].min.to_f
      max = [@r, @g, @b].max.to_f

      return Color::HSV.from_fraction if max == 0

      v = max
      delta = max - min
      s = delta / max

      h = if @r == max
        ( @g - @b ) / delta
      elsif( @g == max )
        2 + ( @b - @r ) / delta
      else
        4 + ( @r - @g ) / delta
      end * 60

      h += 360 if h < 0

      Color::HSV.from_fraction h, s, v
    end

    def inspect
      "RGB [%.2f%%, %.2f%%, %.2f%%]" % [ @r * 255.0, @g * 255.0, @b * 255.0 ]
    end
  end
end

