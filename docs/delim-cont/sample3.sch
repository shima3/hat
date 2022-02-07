(include "util.sch")

(defineCPS main ^()
  print("main1\n")^()
  f ^(v)
  print("main2 v=" v "\n")^()
  exit 0)

(defineCPS f ^ return
  print("f1\n")^()
  call/cc g ^(v)
  print("f2 v=" v "\n")^()
  return 1)

(defineCPS g ^(k . return)
  print("g1\n")^()
  k 3 ^(v)
  print("g2 v=" v "\n")^()
  return 2)
