(include "util.sch")

(defineCPS main ^()
  start(1 (2 3) 4 (5 6) 7)^(r)
  fix
  (^(loop r . break)
    if(list_empty? r) break
    ( list_get_first r ^(n)
      list_get_rest r ^(rest)
      list_get_first rest ^(k)
      print(" " n)^()
      k 0 ^(r)
      loop r . break ) ) r ^()
  print("\nEnd")^()
  exit 0)

(defineCPS start ^(list)
  reset
  (^ c
    walk list ^()
    c ( ) ) )

(defineCPS walk ^(list . return)
  if(list_empty? list) return
  ( list_get_first list ^(n)
    if(list? first)(walk first)
    (yield n)^()
    list_get_rest list ^(rest)
    walk rest ) )

(defineCPS yield ^(n . return)
  shift(^(k . c) c (n k))^(dummy)
  return)

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

(defineCPS main3 ^()
  list? 1 ^(flag)
  print("flag=" flag "\n")^()
  list_push (1 2) 3 ^(list)
  print("list=" list "\n")^()
  list_append (1 2)(3 4)^(list)
  print("list=" list "\n")^()
  list_flat (1 (2 3) 4 (5 6) 7)^(list)
  print("list=" list "\n")^()
  exit 0)

(defineCPS list_flat ^(list . return)
  if(list_empty? list)(return list)
  ( list_get_first list ^(first)
    list_get_rest list ^(rest)
    list_flat rest ^(rest)
    if(list? first)
    ( list_flat first ^(first)
      list_append first rest . return )
    ( list_push rest first . return )
    ) )

(defineCPS list_append ^(list1 list2 . return)
  if(list_empty? list1)(return list2)
  ( list_get_first list1 ^(first)
    list_get_rest list1 ^(rest)
    list_append rest list2 ^(rest2)
    list_push rest2 first ^(list3)
    return list3 ) )

(defineCPS main2 ^()
  set meta_continuation (^(v) print("error\n"))^()
  + 1 (reset(+ (+ 3 (shift(^(k)(* 3 (k 2))))) 1))^(result)
  print("result=" result "\n")^()
  printev(+ 1 (reset 3))^()
  printev(+ 1 (reset(* 2 (shift(^(k) 4)))))^()
  printev(+ 1 (reset(* 2 (shift(^(k)(k 4))))))^()
  printev(+ 1 (reset(* 2 (shift(^(k)(k (k 4)))))))^()
  exit 0)

(defineCPS abort ^(exp) exp ^(v)
  get meta_continuation ^(mc)
  mc v)

(defineCPS reset ^(exp . return)
  get meta_continuation ^(mc)
  set meta_continuation
  (^(v)
    set meta_continuation mc ^()
    return v)^()
  abort exp)

(defineCPS shift ^(f . return)
  (^(exp) reset
    ( exp ^(v)
      return v ))^(k)
  abort(f k))

;; (defineCPS + ^(a b . return) a ^(a) b ^(b)
;;  JavaScript "(function(a, b){ return a+b; })" a b ^(result)
;;  return result)

(defineCPS printev ^(exp)
  exp ^(v)
  print(exp " -> " v "\n"))
