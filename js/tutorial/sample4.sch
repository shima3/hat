(include "util.sch")

(defineCPS main ^()
  fill_rgb 0 255 0 ^()
  begin_path ^()
  arc 40 50 10 135 360 ^()
  arc 60 50 10 180 45 ^()
  line_to 50 75 ^()
  close_path ^()
  exit 0)
