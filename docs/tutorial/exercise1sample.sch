(include "util.sch")

(defineCPS main ^()
  fill_rgb 255 255 255 ^()
  rect 100 100 114 178 ^()
  ;; この行以上は書き換えない。

  ;; 中心のハート
  fill_rgb 255 0 0 ^()
  begin_path ^()
  arc 152 188 5 135 360 ^()
  arc 162 188 5 180 45 ^()
  line_to 157 201 ^()
  close_path ^()
  
  ;;左上１
  fill_rgb 255 0 0 ^()
  begin_path ^()
  arc 125.5 122 5 135 360 ^()
  arc 135.5 122 5 180 45 ^()
  line_to 130.5 135 ^()
  close_path ^()

  ;;左上２
  fill_rgb 255 0 0 ^()
  begin_path ^()
  arc 125.5 156 5 135 360 ^()
  arc 135.5 156 5 180 45 ^()
  line_to 130.5 169 ^()
  close_path ^()

  ;;右上１
  fill_rgb 255 0 0 ^()
  begin_path ^()
  arc 178.5 122 5 135 360 ^()
  arc 188.5 122 5 180 45 ^()
  line_to 183.5 135 ^()
  close_path ^()

  ;;右上２
  fill_rgb 255 0 0 ^()
  begin_path ^()
  arc 178.5 156 5 135 360 ^()
  arc 188.5 156 5 180 45 ^()
  line_to 183.5 169 ^()
  close_path ^()

  ;;左下1
  fill_rgb 255 0 0 ^()
  begin_path ^()
  arc 125.5 252 -5  225 360    ^()
  arc 135.5 252 -5  180 315   ^()
  line_to 130.5 239 ^()
  close_path ^()


  ;;左下２
  fill_rgb 255 0 0 ^()
  begin_path ^()
  arc 125.5 220 -5  225 360    ^()
  arc 135.5 220 -5  180 315   ^()
  line_to 130.5 207 ^()
  close_path ^()

  ;;右下1
  fill_rgb 255 0 0 ^()
  begin_path ^()
  arc 178.5 252 -5  225 360    ^()
  arc 188.5 252 -5  180 315   ^()
  line_to 183.5 239 ^()
  close_path ^()

  ;;右下２
  fill_rgb 255 0 0 ^()
  begin_path ^()
  arc 178.5 220 -5  225 360    ^()
  arc 188.5 220 -5  180 315   ^()
  line_to 183.5 207 ^()
  close_path ^()

  ;;左上隅
  fill_rgb 255 0 0 ^()
  begin_path ^()
  arc 106.5 125 3 135 360 ^()
  arc 112.5 125 3 180 45 ^()
  line_to 109.5 134 ^()
  close_path ^()

  ;;右下隅
  fill_rgb 255 0 0 ^()
  begin_path ^()
  arc 202.5 248 -3  225 360    ^()
  arc 208.5 248 -3  180 315   ^()
  line_to 205.5 239 ^()
  close_path ^()

  ;;左上９
  text_size 23 ^()
  text_align "left" ^()
  draw_text "9" 103 120 ^()

  ;;右下９
  rotate 214 278 180 ^()
  text_size 23 ^()
  text_align "left" ^()
  draw_text "9" 216 300 ^()
  
  ;; この行以下は書き換えない。
  exit 0)
