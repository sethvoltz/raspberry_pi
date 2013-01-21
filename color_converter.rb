def hsv_to_rgb h, s, v
  h = [0, [360, h].min].max
  s = [0, [100, s].min].max / 100.0
  v = [0, [100, v].min].max / 100.0

  if s == 0
    v = (v * 255).round
    return [v, v, v]
  end

  h /= 60.0

  i = h.floor
  f = h - i

  p = (v * (1 - s) * 255).round
  q = (v * (1 - s * f) * 255).round
  t = (v * (1 - s * (1 - f)) * 255).round
  v = (v * 255).round

  case i
  when 0 then [v, t, p]
  when 1 then [q, v, p]
  when 2 then [p, v, t]
  when 3 then [p, q, v]
  when 4 then [t, p, v]
  else
    [v, p, q]
  end
end

def rgb_to_hsv r, g, b
  r = [0, [255, r].min].max / 255.0
  g = [0, [255, g].min].max / 255.0
  b = [0, [255, b].min].max / 255.0

  min = [r, g, b].min.to_f
  max = [r, g, b].max.to_f

  v = max
  delta = max - min

  return [0, 0, 0] if max == 0

  s = delta / max

  h = if r == max
    ( g - b ) / delta
  elsif( g == max )
    2 + ( b - r ) / delta
  else
    4 + ( r - g ) / delta
  end * 60

  h += 360 if h < 0

  [h.round, (s * 100).round, (v * 100).round]
end
