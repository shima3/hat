#!/usr/local/bin/hat
(include "util.sch") ; aho

(defineCPS main7 ^()
  ;; boke
  substring "abc" 1 -1 ^($str)
  print("\"" $str "\"\n")^()
  exit 0)
;;; hoge
(defineCPS |main 6| ^(args)
  string_concatenate args ^(str)
  print(str "\n")^()
  exit 0)

(defineCPS main ^(args)
  print("args=" args "\n")^()
  list_pop args ^(restr args)
  list_pop args ^(str args)
  print("re=" restr "\n")^()
  print("str=" str "\n")^()
  string_regexp restr ^(regexp)
  (^(msg)
    print("Error: " msg "\n")^()
    exit 1)^(error)
  unless(regexp_match regexp str)
  (error "not match")^(match)
  regexp_start match ^(start)
  print("start=" start "\n")^()
  regexp_end match ^(end)
  print("end=" end "\n")^()
  exit 0)
#|
  ^ result
  seq_pop result ^(flag rest)
  print("flag=" flag "\n")^()
  ifelse flag
  ( seq_pop rest 
|#

(defineCPS main4 ^()
  string_seq "Hello" ^(seq)
  seq_print seq "\n" ^()
  exit 0)

(defineCPS main3 ^()
  (^(out) out 1 2 3)^(seq)
  (^(out) out 4 5)^(seq2)
  seq_join seq seq2 ^(seq)
  seq_print seq "\n" ^()
  print("\nend\n")^()
  exit 0)

(defineCPS main2 ^()
  (lambda(d)
    (cons 'quote 'b))()^($z)
  print("z=" $z "\n")^()
  (lambda(y)
    (set-cdr! y 'd)
    ) $z ^(dummy)
  print("z=" $z "\n")^()
  (lambda(x)
    (set-car! x 'c)
    ) $z ^(dummy)
  print("z=" $z "\n")^()
  exit 0)
