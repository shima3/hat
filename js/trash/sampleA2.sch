(include "util.sch")

(defineCPS draw ^(x y dx dy . ret)
  canvas_size ^(w h)
  10 ^(m)
  w - m ^(mx)
  h - m ^(my)
  fill_rgb 0 150 0 ^()
  rect m m (mx - m)(my - m)^()

  fill_rgb 250 250 0 ^()
  ellipse x y 9 9 0 360 ^()
  wait_disp ^(dt)

  x + dx ^(x2)
  if(or(x2 < m)(x2 > mx))
  (0 - dx) dx ^(dx2)

  y + dy ^(y2)
  if(or(y2 < m)(y2 > my))
  (0 - dy) dy ^(dy2)

  draw x2 y2 dx2 dy2 . ret)

(defineCPS main ^()
  draw 100 150 3 4 ^()
  exit 0)
