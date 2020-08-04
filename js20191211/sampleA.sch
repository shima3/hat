(include "util.sch")

(defineCPS draw ^(x y vx vy)
  canvas_size ^(w h) ; Canvasの幅をw、高さをhに渡す
  fill_rgb 0 0 0 ^() ; 色を黒に設定する
  rect 0 0 w h ^() ; 背景を黒で塗りつぶす
  x + vx ^(x) y + vy ^(y) ; 座標更新
  if(or(x < 0)(x > w)) ; Canvasの左右の端に当たったら
  (vx * -1) vx ^(vx) ; 速度のX軸成分を反転する
  if(or(y < 0)(y > h)) ; Canvasの上下の端に当たったら
  (vy * -1) vy ^(vy) ; 速度のY軸成分を反転する
  fill_rgb 50 150 255 ^() ; 円の色を設定する
  ellipse x y 10 10 0 360 ^() ; 円を表示する
;;  wait 0.003 ^() ; ちょっと待つ
  draw x y vx vy . end) ; 再帰呼び出しで繰り返す

(defineCPS main ^()
  draw 200 150 3.0 4.0 ^()
  exit 0)
