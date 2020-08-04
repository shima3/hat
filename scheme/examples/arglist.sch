(defineCPS main ^(args)
  #|
  makeList 3 nil ^(list)
  makeList 2 list ^(list)
  makeList 1 list ^(list)
  |#
  (^(f) f 1 2 3 . nil) ^(list)
  print("list=" list "\n") ^()
  get2list list ^(a b)
  print("a=" a " b=" b "\n") ^()
  splitList list ^(el list)
  print("el=" el "\n") ^()
  print("list=" list "\n") ^()
  isNil list ^(flag)
  print("isNil " flag "\n") ^()
  splitList list ^(el list)
  print("el=" el "\n") ^()
  print("list=" list "\n") ^()
  isNil list ^(flag)
  print("isNil " flag "\n") ^()
  splitList list ^(el list)
  print("el=" el "\n") ^()
  print("list=" list "\n") ^()
  isNil list ^(flag)
  print("isNil " flag "\n"))

(defineCPS nil ^(f . return) return #t)

(defineCPS makeList ^(first rest . return)
  return (^(f) f first . rest))

(defineCPS isNil ^(list . return)
  list (^() return #f))

(defineCPS getFirst ^(list . return)
  list (^(first) return first))

(defineCPS getRest ^(list . return)
  list (^(first . rest) rest . return))

(defineCPS splitList ^(list . return)
  list (^(first . rest) rest ^(rest) return first rest))

(defineCPS #t ^(then else . return) return then)
(defineCPS #f ^(then else . return) return else)

(defineCPS print ^(list . return)
  (lambda(list)
    ;; (display (string-append (string-concatenate (map x->string list))))
    (display (string-concatenate (map x->string list)))
    ) list ^(dummy)
  return)

(defineCPS get2list ^(list . return)
  list (^(a b) return a b))

(defineCPS get3list ^(a b c . return)
  list (^(a b c) return a b c))

(defineCPS get4list ^(a b c d . return)
  list (^(a b c d) return a b c d))
