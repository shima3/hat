(include "util.sch")

#; (defineCPS True ^(Op)
  Op #t)

#; (defineCPS False ^(Op)
  Op #f)

#; (defineCPS Not ^(Flag)
  Flag (^(flag) flag False True))

(defineCPS And ^(flag Flag)
  flag Flag False)

(defineCPS Or ^(flag Flag)
  flag True Flag)

(defineCPS b2B ^(flag)
  flag True False)

(defineCPS B2b ^(Flag)
  Flag (^(flag) flag))

(defineCPS infix_begin ^($value1 $operator)
  (object_eq? end $operator) $value1
  (^($value2)
    $operator $value1 $value2 ^($value)
    infix_begin $value)
  )

(defineCPS main ^()
  and_begin #t #f #t end ^($flag)
  print("flag=" $flag "\n")^()
  or_begin #t #f #f end ^($flag)
  print("flag=" $flag "\n")^()
  exit 0)

(defineCPS main2 ^()
  cond
  ((infix_begin #t and #t and #t end)
    print("Then\n"))
  (else
    print("Else\n"))^()
  print("exit\n")^()
  exit 0)

(defineCPS main3 ^()
  (and~ true true true)^(flag)
  print("flag=" flag "\n"))

(defineCPS main4 ^()
  (when true ^(out) print("hello\n") ^() out 1 2)^(flag . seq)
  print("flag=" flag "\n")^()
  print("seq=" seq "\n")^()
  if flag
  (seq
    (^(value1 value2)
      print("value1=" value1 "\n")^()
      print("value2=" value2 "\n")
      )
    )^()
  print("End\n"))
