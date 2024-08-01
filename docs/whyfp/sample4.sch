(include "util.sch")
(include "whyfp.sch")

(defineCPS add ^(a b)
  print("(" a ")+(" b ")\n")^()
  + a b)

(defineCPS sum ^(list)
  reduce add 0 list)

(defineCPS main ^()
  ;;  (^(out) out 2 3 4)^(list)
  cons 2 (cons 3 (cons 4 nil))^(list)
  sum list ^(result)
  print("総和：" result "\n")^()
  exit 0)
