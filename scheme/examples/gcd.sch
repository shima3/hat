(include "util.sch")

#|
aとbの最大公約数を返す関数
|#
( defineCPS gcd ^(a b . return) a ^(a) b ^(b)
  if( = b 0 )( return a )^()
  gcd b ( modulo a b ) . return )

#|
aとbの最大公約数を返す関数
|#
( defineCPS gcd2 ^(a b) b ^(b)
  ifthenelse(= b 0) a
  (gcd2 b (modulo a b) ) )

#|
15と6の最大公約数を出力するプログラム
|#
( defineCPS main ^()
  memory_gc ^()
  memory_used ^(size0)
  print("memory used " size0 "\n")^()
  15 ^(a) 6 ^(b)
  gcd a b ^(c)
  memory_gc ^()
  memory_used ^(size1)
  print("memory used " size1 "\n")^()
  - size1 size0 ^(size2)
  print("memory increase = " size2 "\n")^()
  print(a "と" b "の最大公約数は" c "です。\n")^()
  exit 0)

#|
15と6の最大公約数を出力するプログラム
|#
( defineCPS main2 ^(args)
  15 ^(a) 6 ^(b)
  fix( ^(loop n . break)
       gcd2 a b ^(c)
       + n 1 ^(n)
       if(= n 4000)(break c)^()
       loop n
       ) 0 ^(c)
  print(a "と" b "の最大公約数は" c "です。\n") )
