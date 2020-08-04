#|
非決定性計算を用いて四天王問題を解くHat言語サンプルコード
A「Dがやられたようだな…」
B「ククク…奴は我ら四天王の中でも最弱…」
C「私はBよりも弱い…」
A「そして私は最強ではない…」
B「四天王の中に私よりも弱いものが最低でも二人いる…」
C「私はAよりも強い…」
※以上の条件から四天王を強い順に並べよ（5点）
「もうふ@WeAreFloating」より引用
https://twitter.com/WeAreFloating/status/22896320134
|#
(include "util.sch")
( defineCPS main ^(args . return)
  print("begin\n") ^()
  ( amb (1 2 3 4) ^(a r1)   ; a: Aの順位, r1: 残り３つのリスト
    amb r1 ^(b r2)          ; b: Bの順位, r2: 残り２つのリスト
    amb r2 ^(c r3)          ; c: Cの順位, r3: 残り一つのリスト
    amb r3 ^(d r4 . back)   ; d: Dの順位, back: バックトラック
    unless (= d 4) back ^() ; B「ククク…奴は我ら四天王の中でも最弱…」
    unless (> c b) back ^() ; C「私はBよりも弱い…」
    unless (> a 1) back ^() ; A「そして私は最強ではない…」
    unless (< b 3) back ^() ; B「四天王の中に私よりも弱いものが最低でも二人いる…」
    unless (< c a) back ^() ; C「私はAよりも強い…」
    setProperty a "A" ^()   ; a番目に"A"を設定
    setProperty b "B" ^()   ; b番目に"B"を設定
    setProperty c "C" ^()   ; c番目に"C"を設定
    setProperty d "D" ^()   ; d番目に"D"を設定
    getProperty 1 "?" ^(no1); no1: 1番目の値（なければ"?"）
    getProperty 2 "?" ^(no2); no2: 2番目の値（なければ"?"）
    getProperty 3 "?" ^(no3); no3: 3番目の値（なければ"?"）
    getProperty 4 "?" ^(no4); no4: 4番目の値（なければ"?"）
    print(no1 no2 no3 no4 "\n") )^(); no1,no2,no3,no4を出力
  print("end\n") )
