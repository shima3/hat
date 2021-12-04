(include "util.sch")

(defineCPS main ^()
  same_fringe
  (1 (2 3) 4 (5 6) 7)
  ((1 2) 3 (4 5) 6 7)
  ^(flag)
  if flag (print("同じ\n"))
  (print("違う\n"))^()
  exit 0)

(defineCPS same_fringe ^(list1 list2)
  start list1 ^(nk1)
  start list2 ^(nk2)
  loop nk1 nk2)

(defineCPS loop ^(nk1 nk2 . return)
  list_empty? nk1 ^(flag1)
  list_empty? nk2 ^(flag2)
  when(and flag1 flag2)(return true)^()
  if flag1 "無"
  (list_get_first nk1)^(n1)
  if flag2 "無"
  (list_get_first nk2)^(n2)
  print(n1 "=" n2 "?\n")^()
  unless(equal? n1 n2)(return false)^()
  list_get_second nk1 ^(k1)
  list_get_second nk2 ^(k2)
  k1()^(next1)
  k2()^(next2)
  loop next1 next2 . return)
  
(defineCPS start ^(list)
  reset(walk list ^() I()))

(defineCPS walk ^(list . return)
  when(list_empty? list) return ^()
  list_get_first list ^(n)
  if(list? n)(walk n)
  (yield n)^()
  list_get_rest list ^(rest)
  walk rest)

(defineCPS yield ^(n . return)
  shift(^(k) I(n k))^(d)
  return)
