(include "util.sch")

#|
(defineCPS fix ^(f) f (fix f))

(defineCPS + ^(left right) left ^(left) right ^(right)
  (lambda (left right)(+ left right)) left right)

(defineCPS #t ^(then else) then)
(defineCPS #f ^(then else) else)

(defineCPS not ^(condition then else) condition else then)

(defineCPS eq? ^(a b)
  (lambda (a b)(eq? a b)) a b)

(defineCPS pair? ^(list)
  (lambda (list)(pair? list)) list)

(defineCPS cons ^(el list)
  (lambda (el list)(cons el list)) el list)

(defineCPS getFirst ^(list)
  (lambda (list)(car list)) list)

(defineCPS getRest ^(list)
  (lambda (list)(cdr list)) list)

(defineCPS moveAll ^(back rest . return)
  unless (pair? back) (return rest) ^()
  getFirst back ^(el)
  getRest back ^(back)
  cons el rest ^(rest)
  moveAll back rest . return)

(defineCPS if ^(condition action) condition ^(condition)
  condition action ())

(defineCPS unless ^(condition action . return)
  condition return action)

(defineCPS isEmpty ^(list . return)
  list (^ c eq? c end ^(flag) return flag) ^(a) a . end)

(defineCPS getFirst ^(list . return) list (^(a . c) return a))

(defineCPS getRest ^(list) (^(a2 . c2) list (^(a . c) c a2 . c2)))

(defineCPS append ^(list1 list2)
  (^(a . c) list1 a ^(a2) list2 a2 . c))

(defineCPS add ^(list el)
  (^(a . c) list a ^(f) f el . c))

( defineCPS print ^(list . return)
  ( lambda (list)
    (display (string-append (string-concatenate (map x->string list))))
    ) list ^(dummy)
  return )

(defineCPS newline ^()
  (lambda ()(newline)) ^(dummy)())

(defineCPS println ^(value)
  (lambda (value)(display value)(newline)) value ^(dummy)())

(defineCPS I ^(x . return) return x)
|#

( defineCPS main ^(args)
  I () ^(list)
  list_cons 1 list ^(list)
  list_cons 2 list ^(list)
  list_cons 3 list ^(list)
  print(list "\n") ^()
  moveAll list () ^(list)
  print(list "\n")^()
  exit 0)

( defineCPS main1 ^(args)
  I (1) ^(list)
  print(list "\n")
  )
