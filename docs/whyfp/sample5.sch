(include "util.sch")
(include "whyfp.sch")

(defineCPS square ^(x)
  x ^(x)
  * x x)

(defineCPS listPrint ^(list . return)
  list ^(list)
  if(isNil list) return
  ( getFirst list ^(first)
    print(first "\n")^()
    getRest list ^(rest)
    listPrint rest . return ))

(defineCPS main ^()
  cons 2 (cons 3 (cons 4 nil))^(list)
  map square list ^(result)
  listPrint result ^()
  exit 0)
