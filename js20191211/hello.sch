#|
定番 Hello World のHat言語サンプルコード
|#
( include "util.sch" )

(defineCPS main ^(args)
  print("Hello World!!\n")
  )

(defineCPS main2 ^(args)
  print("Hello\n")^()
  print("World!!\n")
  )
