(include "util.sch")

(defineCPS draw ^(x y vx vy dt . ret)
  canvas_size ^(w h) ; Canvasの幅w、高さh
  10 ^(m) ; 上下左右の余白
  w - m ^(mx) ; x座標の最大値
  h - m ^(my) ; y座標の最大値
  fill_rgb 0 150 0 ^() ; 緑色に設定する
  rect m m (mx - m)(my - m)^() ; 塗りつぶす

  x +(vx * dt)^(x) ; x座標更新
  if(or(x < m)(x > mx)) ; 左右の衝突判定
  (0 - vx) vx ^(vx) ; x軸方向の速度反転
  if(x < m) ; 左に衝突
  (m + (m - x)) x ^(x) ; x座標補正
  if(x > mx) ; 右に衝突
  (mx - (x - mx)) x ^(x) ; x座標補正

  y +(vy * dt)^(y) ; xy座標更新
  if(or(y < m)(y > my)) ; 上下の衝突判定
  (0 - vy) vy ^(vy) ; y軸方向の速度反転
  if(y < m) ; 上に衝突
  (m + (m - y)) y ^(y) ; y座標補正
  if(y > my) ; 下に衝突
  (my - (y - my)) y ^(y) ; y座標補正

  fill_rgb 250 250 0 ^() ; 黄色に設定する
  ellipse x y 9 9 0 360 ^() ; 円を表示する
  wait_disp ^(dt) ; 表示待ち
  draw x y vx vy dt . ret) ; 再帰で繰返し

(defineCPS main ^()
  draw 100 150 90 120 0 ^()
  exit 0)
