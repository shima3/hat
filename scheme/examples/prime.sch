(include "util.sch")

(defineCPS main ^()
  test("2") ^()
  test("3") ^()
  test("4") ^()
  test("5") ^()
  test("6") ^()
  test("7") ^()
  test("8") ^()
  test("9") ^()
  exit 0)

( defineCPS test ^(args)
  list_car args ^(first)
;;;  print("first=" first "\n")^()
  string_to_number first ^(n)
;;;  print("n=" n "\n")^()
  find_divisor n 2 ^(d)
;;;  print("d=" d "\n")^()
  (= n d)
  ( print(n " is a prime number.\n") )
  ( print(n " can be divied by " d ".\n") ) )

(defineCPS main1 ^(args)
  print(args "\n"))

(defineCPS main2 ^(args)
  get_first args ^(first)
  print(first "\n"))

(defineCPS main3 ^(args)
  get_first args ^(first)
  string_to_number first ^(n)
  print(n "\n"))

(defineCPS main4 ^(args)
  get_first args ^(first)
  string_to_number first ^(n)
  n ^(n)
  print(n "\n"))

(defineCPS main5 ^(args)
  < 13 4 ^(f)
  print(f "\n"))

(defineCPS main6 ^(args)
  ifthenelse (< 13 4) "aho" "boke" ^(msg)
  print(msg "\n"))

(defineCPS main7 ^(args)
  find_divisor 13 2 ^(d)
  print(d "\n"))

(defineCPS main8 ^(args)
  car args ^(first)
  string_to_number first ^(n)
  find_divisor n 2 ^(d)
  print(d "\n"))

(defineCPS #t ^(a b) a)
(defineCPS #f ^(a b) b)

#; (defineCPS println ^(value)
  (lambda (value)(display value)(newline)) value ^(dummy)( ))

#; ( defineCPS print ^(list . return)
  ( lambda (list)
    (display (string-concatenate (map x->string list)))
    ;; (display (string-append (string-concatenate (map x->string list))))
    ) list ^(dummy)
  return )

#; (defineCPS println ^(value)
  (lambda (value)
    (display value)
    (newline)) value)

#; (defineCPS < ^(a b) a ^(a) b ^(b)
  (lambda (A B)(< A B)) a b)

#; (defineCPS = ^(a b) a ^(a) b ^(b)
  (lambda (A B)(= A B)) a b)

#; (defineCPS + ^(a b) a ^(a) b ^(b)
  (lambda (A B)(+ A B)) a b)

#; (defineCPS * ^(a b) a ^(a) b ^(b)
  (lambda (A B)(* A B)) a b)

#; (defineCPS remainder ^(a b) a ^(a) b ^(b)
  (lambda (A B)(remainder A B)) a b)

#; (defineCPS ifthenelse ^(condition then else)
  condition then else)

#; (defineCPS if ^(condition then else) condition ^(condition)
  (lambda (condition then else)(if condition then else)) condition then else
  ^(thenorelse) thenorelse)

(defineCPS find_divisor ^(n d) d ^(d)
  cond((< n (* d d)) n)
  (else cond((= (remainder n d) 0) d)
    (else find_divisor n (+ d 1))
    )
  )

#; (defineCPS string_to_number ^(str)
  (lambda (str)(string->number str)) str)

#; (defineCPS car ^(list)
  (lambda (list)(car list)) list)
