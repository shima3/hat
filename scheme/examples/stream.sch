(include "util.sch")

(defineCPS contend ^ return
  return ^(first . rest)
  rest
  )

(defineCPS contend? ^(cont . return)
  cont ^ cont2
  cont2 (return #f)^()
  return #t
  )

(defineCPS contpush ^(rest first . return)
  return
  (^ args
    args first . rest
    )
  )

(defineCPS contpop ^(cont . return)
  cont ^(first . rest)
  return first rest
  )

(defineCPS cont1 ^ return
  return (print("hello "))^ return
  return (print("world\n")).
  contend)

(defineCPS contexec ^(cont . return)
  when(contend? cont) return ^()
  contpop cont ^(first rest)
  first ^()
  contexec rest . return
  )

(defineCPS main10 ^()
  contend? (print("hello")) ^(flag)
  print("flag=" flag "\n")^()
  exit 0)

(defineCPS main2 ^()
  contend? cont1 ^(flag)
  print("flag=" flag "\n")^()
  contpop cont1 ^(first rest)
  contend? rest ^(flag)
  print("flag=" flag "\n")^()
  contpop rest ^(first rest)
  print("rest=" rest "\n")^()
  contend? rest ^(flag)
  print("flag=" flag "\n")^()
  contpop rest ^(first rest)
  contend? rest ^(flag)
  print("flag=" flag "\n")^()
  contpop rest ^(first rest)
  contend? contend ^(flag)
  print("flag=" flag "\n")^()
  exit 0)

(defineCPS main ^()
;;  seq_arith 0 1 ^(s) s ^
  fibonacci 0 1 ^(s)
  seq_pop s ^(e s)
  (print~ "e=" e)^()
  seq_pop s ^(e s)
  (print~ "e=" e)^()
  seq_pop s ^(e s)
  (print~ "e=" e)^()
  seq_pop s ^(e s)
  (print~ "e=" e)^()
  seq_pop s ^(e s)
  (print~ "e=" e)^()
  seq_pop s ^(e s)
  (print~ "e=" e)^()
  exit 0)

(defineCPS main3 ^()
  char_seq_stdout ^($out . $close)
  $out "hello world\n" ^($out)
  $out "hello " ^($out)
  $out "world\n" ^($out)
  $out "hello " "world\n" ^($out)
  $close ^()
  print("bye\n"))

(defineCPS main4 ^()
  char_seq_stdin ^($in . $close)
  char_seq_tokenize $in char_whitespace? ^($token $in)
  print("token=" $token "\n")^()
  char_seq_tokenize $in char_whitespace? ^($token $in)
  print("token=" $token "\n")^()
  $close ^()
  exit 0)

(defineCPS main5 ^()
  char_seq_stdin ^($in . $close)
  char_seq_count_lines $in 1 ^($seq)
  seq_print $seq "\n" ^()
  exit 0)

(defineCPS main6 ^()
  seq_stdin_line ^($seq . $close)
;;  seq_tokenize_line $seq ^($seq)
  seq_print $seq "\n" ^()
  $close ^()
  exit 0)

(defineCPS main7 ^()
  list_seq(1 2 3) end ^($seq1)
;;;  list_seq(1 2 3) empty_seq ^($seq1)
  print("seq1=" $seq1 "\n")^()
  seq_append $seq1 seq456 ^($seq2)
  print("seq2=" $seq2 "\n")^()
  seq_print $seq2 "\n" ^()
  exit 0)

(defineCPS finish ^()
  print("finish\n")^()
  exit 0)

(defineCPS handler ^ S
  stack_pop S ^(S R)
  print("S=" S "\n")^()
  end? S ^(flag)
  print("flag=" flag "\n")^()
  seq_print S "\n" . R)

(defineCPS main72 ^()
  seq_print (^ R R 1 ^ R R 2 ^ R R 3 . end) "\n" ^()
;;;  (handler 1 2 3 . end)^()
;;;  (handler 1 2 3 . end)^()
  print("End\n"))

(defineCPS main73 ^()
  seq_empty? (^ R R 1 ^ R R 2 ^ R R 3 . end)^(flag)
  (print~ flag)^()
  stop)

(defineCPS main8 ^()
  I #f ^($flag)
  $flag "true" "false" ^($str)
  print("answer=" $str "\n")^()
  exit 0)

(defineCPS main9 ^()
  #|
  seq_stdin_line ^($seq . $close)
  seq_tokenize_line $seq ^($seq)
  seq_pop $seq ^($first $rest)
  print("first=" $first "\n")^()
  |#
  case (object_eq? 2 2)
  (then
    print("true\n"))
  ((1 3 5 7 8 10 12)
    print("31\n"))
  ((4 6 9 11)
    print("30\n"))
  ((2)
    print("28\n"))
  (else
    print("?\n"))^()
  print("end\n")
  )

(defineCPS fibonacci ^($a $b $out)
  $out $a ^($out2)
  + $a $b ^($c)
  fibonacci $b $c $out2
  )

(defineCPS tokenizeCLNSeq ^(seq . return)
  when(seq_empty? in)(return empty_seq)^()
  seq_pop in ^(ch in2)
  when(char=? ch #\n)
  ( + line_no 1 ^(line_no2)
    tokenizeIn in2 line_no2 . return
    )^()
  when(char=? ch #\Space)
  (tokenizeIn in2 line_no . return)^()
  
  )

#|
matchPrefix prefix in ^(flag in2)
文字列 in の前置詞が prefix に等しければ、flag は #t、
等しくなければ、flag は #f、
in2 は一致しない文字以降の文字列
|#
(defineCPS matchPrefix ^(prefix in . return)
  string-length prefix ^(len)
  fix
  (^(loop idx in)
    when(>= idx len)(return #t in)^()
    when(seq_empty? in)(return #f in)^()
    string-ref prefix idx ^(ch)
    seq_pop in ^(ch2 in2)
    unless(char=? ch ch2)(return #f in)^()
    + idx 1 ^(idx2)
    loop idx2 in2
    ) 0 in)

(defineCPS seq456 ^($out)
  $out 4 5 6 . empty_seq)

;; (defineCPS char2sexpSeq ^(char_seq))

;;; 未完成
;; on_empty 入力の終わりで、これ以上読めないとき、呼び出す関数
;; on_fail 構文の推定に失敗したが、別の構文に合う可能性があるとき、呼び出す関数
;; on_error 構文エラーのとき、呼び出す関数
#; (defineCPS seq_read_sexp ^($in $on_empty on_fail on_error . return)
  seq_skip_spaces $in char_space? ^($in)
  when(seq_empty? $in)($on_empty . end)^()
  seq_pop $in ^($ch $in2)
  case $ch
  (() )
  ^($)
  when(char=? $ch #\()
  (fix
    (^($loop)
      ) seq_pop $in2 ^(ch $in3)
    if(char=? ch #\))
    )
  )
