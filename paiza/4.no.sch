#|
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
( defineCPS main ^(args)
  print("begin\n") ^()
  makeString 4 ^(answer)
  ( amb (0 1 2 3) ^(a r1)
    amb r1 ^(b r2)
    amb r2 ^(c r3)
    amb r3 ^(d r4 . back)
    unless (= d 3) back ^()
    unless (> c b) back ^()
    unless (> a 0) back ^()
    unless (< b 2) back ^()
    unless (< c a) back ^()
    stringSet! answer a #\A ^()
    stringSet! answer b #\B ^()
    stringSet! answer c #\C ^()
    stringSet! answer d #\D ^()
    print(answer "\n") )^()
  print("end\n") )
