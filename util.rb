class Numeric
  def scale_between(from_min, from_max, to_min, to_max)
    ((to_max - to_min) * (self - from_min)) / (from_max - from_min) + to_min
  end
end
