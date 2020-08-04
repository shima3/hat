;; 二分法 Bisection method

(include "util.sch")

(defineCPS find_opposite_sign ^(sgnf0 f x . return)
  x ^(px)
  f px ^(fpx)
  if(=(sgn fpx) sgnf0)nop(return px)^()
  - 0 x ^(mx)
  f mx ^(fmx)
  if(=(sgn fmx) sgnf0)nop(return mx)^()
  find_opposite_sign sgnf0 f (+ x 1) . return)

#|
bisection e f a b ^(x)
事前条件：
and((f a)< 0)((f b)> 0)
事後条件：
((((a + b)/ 2)= x)and((a = x)or(b = x)))or((abs(f x))<= e)
|#
(defineCPS bisection ^(e f a b . return)
  / (+ a b) 2 ^(c)
  if(or(= a c)(= b c))(return c) nop ^()
  f c ^(fc)
  if(<=(abs fc) e)(return c) nop ^()
  if(> fc 0)
  (bisection e f a c . return)
  (bisection e f c b . return))

(defineCPS find_root ^(e f . return)
  f 0 ^(f0)
  if(= f0 0)(return 0)nop ^()
  sgn f0 ^(sgnf0)
  find_opposite_sign sgnf0 f 1 ^(x0)
  if(< sgnf0 0)
  (bisection e f 0 x0)
  (bisection e f x0 0)^(x)
  return x)

(defineCPS inverse_function ^(e f fx)
  find_root e (^(x)(-(f x) fx)))

(defineCPS main ^()
  2 ^(fx)
  inverse_function 0.00000001 (^(x)(* x x)) fx ^(x)
  print("f(" x ")=" fx "\n")^()
  exit 0)
