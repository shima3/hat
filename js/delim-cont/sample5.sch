(include "util.sch")

(defineCPS main ^()
  start
  (1 (2 3) 4 (5 6) 7)
  ^(nk)
  loop nk ^()
  exit 0)

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

(defineCPS loop ^(nk . return)
  when(list_empty? nk) return ^()
  list_get_first nk ^(n)
  print(n "\n")^()
  list_get_second nk ^(k)
  k()^(next)
  loop next . return)
