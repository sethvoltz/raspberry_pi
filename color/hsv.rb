module Color
  class HSV
    COMPONENTS = [ :h, :s, :v ]
    attr_accessor *COMPONENTS

    class << self
      def from_fraction h = 0.0, s = 0.0, v = 0.0
        color = new
        color.h = h
        color.s = s
        color.v = v
        color
      end
    end

    def initialize h = 0, s = 0, v = 0
      @h = h
      @s = s / 100.0
      @v = v / 100.0
    end

    def == other
      other = other.to_rgb
      other.kind_of? self.class and COMPONENTS.select do |component|
        ((self.send component) - (other.send component)).abs <= Color::COLOR_TOLERANCE
      end.length == COMPONENTS.length
    end

    def to_rgb
      return Color::RGB.from_fraction @v, @v, @v if s == 0

      @h /= 60.0

      i = @h.floor
      f = @h - i

      p = @v * (1 - @s)
      q = @v * (1 - @s * f)
      t = @v * (1 - @s * (1 - f))

      colors = case i
      when 0 then [@v, t, p]
      when 1 then [q, @v, p]
      when 2 then [p, @v, t]
      when 3 then [p, q, @v]
      when 4 then [t, p, @v]
      else
        [@v, p, q]
      end

      Color::RGB.from_fraction *colors
    end

    def to_hsv
      self
    end

    def inspect
      "HSV [%.2f deg, %.2f%%, %.2f%%]" % [ @h, @s * 100.0, @v * 100.0 ]
    end
  end
end
