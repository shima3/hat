(defineCPS #t ^(a b) a)
(defineCPS #f ^(a b) b)

#; (defineCPS println ^(value)
  (lambda (value)(display value)(newline)) value ^(dummy)( ))

(defineCPS println lambda (value)
  (display value)
  (newline)
  '( ))

(defineCPS < ^(a b) a ^(a) b ^(b)
  (lambda (A B)(< A B)) a b)

(defineCPS = ^(a b) a ^(a) b ^(b)
  (lambda (A B)(= A B)) a b)

(defineCPS + ^(a b) a ^(a) b ^(b)
  (lambda (A B)(+ A B)) a b)

(defineCPS * ^(a b) a ^(a) b ^(b)
  (lambda (A B)(* A B)) a b)

(defineCPS remainder ^(a b) a ^(a) b ^(b)
  (lambda (A B)(remainder A B)) a b)

(defineCPS ifthenelse ^(condition then else)
  condition then else)

#; (defineCPS if ^(condition then else) condition ^(condition)
  (lambda (condition then else)(if condition then else)) condition then else
  ^(thenorelse) thenorelse)

(defineCPS find_divisor ^(n d) d ^(d)
  ifthenelse (< n (* d d)) n
  ( ifthenelse (= (remainder n d) 0) d
    ( find_divisor n (+ d 1) ) ))

(defineCPS string_to_number ^(str)
  (lambda (str)(string->number str)) str)

(defineCPS car ^(list)
  (lambda (list)(car list)) list)

(defineCPS main ^(args)
  car args ^(first)
  string_to_number first ^(n)
  find_divisor n 2 ^(d)
  println d)
