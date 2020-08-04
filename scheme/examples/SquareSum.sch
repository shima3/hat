(defineCPS squareSum ^(x y . c)
  makeActor square ^(a1)
  makeActor square ^(a2)
  sendAsync a1 (^(b) b 1) ^()
  )

(defineCPS main ^(args)
  squareSum 1 2 ^(r)
  print(r "\n"))
