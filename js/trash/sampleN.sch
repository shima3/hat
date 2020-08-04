(include "util.sch")

(defineCPS abs ^(x)
  x ^(x)
  if(x < 0)(x * -1) x)

(defineCPS newton ^(f x dx me . return)
  f x ^(fx)
  f(x + dx) - fx ^(dy)
  dy / dx ^(fd)
  fx / fd ^(e)
  x - e ^(x)
  if((abs e) < me)(return x)
  (newton f x dx me . return))

(defineCPS newton2 ^(f x dx me . return)
  print("x=" x "\n")^()
  f x ^(fx)
  print("fx=" fx "\n")^()
  f(x + dx) - fx ^(dy)
  print("dy=" dy "\n")^()
  dy / dx ^(fd)
  print("fd=" fd "\n")^()
  fx / fd ^(e)
  print("e=" e "\n")^()
  x - e)

(defineCPS f ^(a x)
  a ^(a) x ^(x)
  (x * x) - a)

(defineCPS main ^()
  newton2 (f 2) 0 1 0.01 ^(x)
  print(x "\n")^()
  exit 0)