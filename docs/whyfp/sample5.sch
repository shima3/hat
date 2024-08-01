(include "util.sch")
(include "whyfp.sch")

(defineCPS square ^(x)
  x ^(x)
  * x x)

(defineCPS listPrint ^(list . return)
  if(isNil list) return
  ( getFirst list ^(first)
    print(first "\n")^()
    getRest list ^(rest)
    listPrint rest . return ))

(defineCPS main ^()
  (^(out) out 2 3 4)^(list)
  map square list ^(result)
  listPrint result ^()
  exit 0)
