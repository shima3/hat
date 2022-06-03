(include "util.sch")

(defineCPS draw ^(x . ret)
  canvas_size ^(w h)
  fill_rgb 0 150 0 ^()
  rect 0 0 w h ^()
  h / 2 ^(y)
  fill_rgb 250 250 0 ^()
  circle x y 9 ^()
  wait_disp ^(dt)
  if(x < w)(x + 1) 0 ^(x2)
  draw x2 . ret)

(defineCPS main ^()
  draw 0 ^()
  exit 0)