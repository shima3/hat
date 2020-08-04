( defineCPS print ^(list . return)
  ( lambda (list)
    (display (string-append (string-concatenate (map x->string list))))
    ) list ^(dummy)
  return )

( defineCPS f ^ return
  print("f 1\n")^()
  (^ c return . c) ^()
  print("f 2\n")^ return2
  return2 ^()
  print("f 3\n")
  )

( defineCPS main ^(args)
  print("main 1\n")^()
  f ^ f2
  print("main 2\n")^()
  f2 ^ f3
  print("main 3\n")^()
  f3
  )
