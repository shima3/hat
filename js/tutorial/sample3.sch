(include "util.sch")

(defineCPS main ^()
  text_size 50 ^()
  text_align "left" ^()
  draw_text "hello" 100 100 ^()
  text_align "center" ^()
  draw_text "world" 200 150 ^()
  exit 0)
