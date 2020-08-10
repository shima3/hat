(include "util.sch")

(defineCPS main ^()
  (print~ "Start")^()
  port_stdin ^($port)
  seq_repeat (port_read_line $port) object_eof? ^(seq)
  fix
  (^(loop seq . break)
    when(seq_end? seq) break ^()
    seq_pop seq ^(first rest)
    (print~ first)^()
    loop rest . break
    ) seq ^()
  fix
  (^(loop2 seq . break)
    when(seq_end? seq) break ^()
    seq_pop seq ^(first rest)
    (print~ first)^()
    loop2 rest . break
    ) seq ^()
  (print~ "End")^()
  exit 0)

(defineCPS main1 ^(args)
  delay (^ return
	  print("Hello\n")^()
	  return 1 2)^(P)
  P ^(v1 v2)
  print("v1=" v1 "\n")^()
  print("v2=" v2 "\n")^()
  P ^(v1 v2)
  print("v1=" v1 "\n")^()
  print("v2=" v2 "\n")^()
  nop )

#; (defineCPS seq_end? ^(aSeq . return)
  aSeq (return #f) . return)

#; (defineCPS seq_get ^(aSeq . return)
  aSeq
  (^(first . restSeq)
    return first restSeq
    ) . end
  )

(defineCPS seq_repeat ^(get end?)
  delay
  ( get ^(value)
    seq_repeat get end? ^(next)
    (end? value) seq_end
    (^(R) R value . next)
    )
  )
