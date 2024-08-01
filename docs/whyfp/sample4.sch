(include "util.sch")
(include "whyfp.sch")

(defineCPS sum ^(list)
  reduce + 0 list)

(defineCPS main ^()
  cons 2 (cons 3 (cons 4 nil))^(list)
  sum list ^(result)
  print("総和：" result "\n")^()
  exit 0)
