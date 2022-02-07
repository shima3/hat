
(defineCPS seq_flat_list ^(list seq)
  if(list_empty? list) seq
  (^(out . cont)
    list_get_first list ^(first)
    list_get_rest list ^(rest)
    seq_flat_list rest seq ^(seq)
    if(list? first)(seq_flat_list first seq out . cont)
    (out first ^(out) seq out) ) )

(defineCPS main4 ^()
  seq_flat_list (1 (2 3) 4 (5 6) 7) seq_empty ^(seq)
  fix
  (^(loop seq . break)
    if(seq_empty? seq) break
    ( seq_get seq ^(first rest)
      print(" " first)^()
      loop rest . break )
    ) seq ^()
  exit 0)
