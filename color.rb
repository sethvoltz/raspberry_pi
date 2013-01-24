# Normalize and supporting code in Color module from https://github.com/halostatue/color
module Color
  # The maximum "resolution" for colour math; if any value is less than or
  # equal to this value, it is treated as zero.
  COLOR_EPSILON = 1e-5

  # The tolerance for comparing the components of two colours. In general,
  # colours are considered equal if all of their components are within this
  # tolerance value of each other.
  COLOR_TOLERANCE = 1e-4

  class << self
    # Returns +true+ if the value is less than COLOR_EPSILON.
    def near_zero?(value)
      (value.abs <= COLOR_EPSILON)
    end

    # Returns +true+ if the value is within COLOR_EPSILON of zero or less than
    # zero.
    def near_zero_or_less?(value)
      (value < 0.0 or near_zero?(value))
    end

    # Returns +true+ if the value is within COLOR_EPSILON of one.
    def near_one?(value)
      near_zero?(value - 1.0)
    end

    # Returns +true+ if the value is within COLOR_EPSILON of one or more than
    # one.
    def near_one_or_more?(value)
      (value > 1.0 or near_one?(value))
    end

    # Normalizes the value to the range (0.0) .. (1.0).
    def normalize(value)
      return 0.0 if near_zero_or_less? value
      return 1.0 if near_one_or_more? value
      value
    end

    def normalize_to_range(value, range)
      range = (range.end..range.begin) if (range.end < range.begin)

      return range.begin if value <= range.begin
      return range.end   if value >= range.end
      value
    end
  end
end

require 'color/rgb'
require 'color/hsv'
