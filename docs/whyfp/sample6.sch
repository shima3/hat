(include "util.sch")
(include "whyfp.sch")

(defineCPS square ^(x)
  x ^(x)
  print("square x=" x "\n")^()
  * x x)

(defineCPS listPrint ^(list . return)
  if(isNil list) return
  ( getFirst list ^(first)
    print(first "\n")^()
    getRest list ^(rest)
    listPrint rest . return ))

(defineCPS main ^()
  ;; (^(out) out 2 3 4 5)^(list)
  cons 2 (cons 3 (cons 4 nil))^(list)
  print("main 1\n")^()
  map square list ^(result)
  print("main 2\n")^()
  listPrint result ^()
  print("main 3\n")^()
  exit 0)
