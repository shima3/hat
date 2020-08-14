(include "util.sch")

(defineCPS main ^(args)
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
  string->number first ^(n)
;;;  (print~ "n=" n)^()
  find_divisor n 2 ^(d)
;;;  (print~ "d=" d)^()
  if(= n d)
  (print~ n " is a prime number.")
  (print~ n " can be divied by " d ".") )

(defineCPS main1 ^(args)
  print(args "\n"))

(defineCPS main2 ^(args)
  get_first args ^(first)
  print(first "\n"))

(defineCPS main3 ^(args)
  get_first args ^(first)
  string->number first ^(n)
  print(n "\n"))

(defineCPS main4 ^(args)
  get_first args ^(first)
  string->number first ^(n)
  n ^(n)
  print(n "\n"))

(defineCPS main5 ^(args)
  < 13 4 ^(f)
  print(f "\n"))

(defineCPS main6 ^(args)
  (< 13 4) "aho" "boke" ^(msg)
  print(msg "\n"))

(defineCPS main7 ^(args)
  find_divisor 13 2 ^(d)
  print(d "\n"))

(defineCPS main8 ^(args)
  car args ^(first)
  string->number first ^(n)
  find_divisor n 2 ^(d)
  print(d "\n"))

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

(defineCPS find_divisor ^(n d . return) d ^(d)
  when(< n (* d d))(return n)^()
  when(= (remainder n d) 0)(return d)^()
  find_divisor n (+ d 1). return)

#; (defineCPS string_to_number ^(str)
  (lambda (str)(string->number str)) str)

#; (defineCPS car ^(list)
  (lambda (list)(car list)) list)
