(include "util.sch")

( defineCPS seq1 ^(r)
  r 3 1 4 . endSeq )

(defineCPS seq2 ^(r)
  r 3 1 4
  )

(defineCPS main7 ^(args)
  seq_get seq2 ^(el seq)
  print("el=" el "\n")^()
  seq_get seq ^(el seq)
  print("el=" el "\n")^()
  seq_get seq ^(el seq)
  print("el=" el "\n")^()
  print("seq=" seq "\n")^()
  print("End\n"))

( defineCPS printSeq4 ^(seq . break)
  if(emptySeq seq1) break ^()
  splitSeq seq1 ^(el rest)
  print(el "\n")^()
  if(emptySeq rest) break ^()
  splitSeq rest ^(el rest)
  print(el "\n")^()
  if(emptySeq rest) break ^()
  splitSeq rest ^(el rest)
  print(el "\n")^()
  if(emptySeq rest) break ^()
  splitSeq rest ^(el rest)
  print(el "\n") )

( defineCPS printSeq ^(seq . break)
  fix(^(loop seq)
       if(emptySeq seq) break ^()
       splitSeq seq ^(el rest)
       print(el "\n")^()
       loop rest) seq )

( defineCPS printSeq2x2 ^(seq . break)
  enumSeq break seq ^(e1 e2 . rest)
  print(e1 ", " e2 "\n")^()
  enumSeq break rest ^(e1 e2 . rest)
  print(e1 ", " e2 "\n") . break )

( defineCPS main ^(args)
  printSeq4 seq1 ^()
  print("end\n") )

( defineCPS main2 ^(args)
  printSeq seq1 ^()
  print("end\n") )

( defineCPS main3 ^(args)
  printSeq2x2 seq1 ^()
  print("end\n") )

( defineCPS main4 ^(args)
  mapSeq (^(x) * x 2) seq1 ^(seq)
  printSeq seq ^()
  print("end\n") )

( defineCPS main5 ^(args)
  foldSeq + 0 seq1 ^(result)
  print(result "\n") )

( defineCPS main6 ^(args)
  arithSeq 1 2 ^(seq)
  finiteSeq seq 5 ^(seq)
  printSeq seq ^()
  print("end\n") )
