(include "util.sch")

(defineCPS main ^()
  (^(h) h 2 3 . empty_seq)^(seq)
  seq_push 1 seq ^(seq)
  seq_print seq ", " ^()
  print("\n")^()
  exit 0)
