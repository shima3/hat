#|
Hat言語のみで定義された関数群
|#

(defineCPS I ^(x . r) r x)

;; seq ------------------------------------

#| 数列関連
与えられた関数に０個以上の項を渡す関数を数列という。
項は数値に限らず任意のデータである。
2019/11/13 作成開始
|#

#|
数列の終端
例：(^(handler) handler 1 2 3 . seq_end)
|#
(defineCPS seq_end ^(handler . return)
  return)

#|
seq_end? seq ^(flag)
数列seqが空ならばflagは真 #t、
そうでなければflagは偽 #f
|#
(defineCPS seq_end? ^(seq . return)
  seq (return false)^()
  return true)

#| seq_endとseq_end?のその他の定義

(defineCPS seq_end ^(out . return)
  return true . end)

(defineCPS seq_end? ^(seq . return)
  seq (return false) . return)

(defineCPS seq_end ^(func1 func2)
  func2)

(defineCPS seq_end? ^(seq . return)
  seq(return false)(return true))

(defineCPS seq_end ^ return
  return ^(func . cont)
  cont)

(defineCPS seq_end? ^(seq . return)
  seq ^ cont
  cont (return false)^()
  return true)
|#

#|
seq_end?(^(handler) handler 1 . seq_end)
(^(handler) handler 1 . seq_end)^ seq seq (return false)^() return true
(^ seq seq (return false)^() return true)(^(handler) handler 1 . seq_end)
(^(I$0) I$0 (^(handler) handler 1 . seq_end))

seq_end? seq_end
seq_end (return false)(return true)
(^ return return ^(func1 func2) func2)(return false)(return true)
(^(H)H(return false)(return true))^(func1 func2)func2

|#

#|
seq_pop seq ^(first rest)
数列seqの先頭firstと残りの数列restを返す。
|#
(defineCPS seq_pop ^(seq . return)
  seq
  (^(first . rest)
;;;  (^(first . cont) cont_pop cont ^(rest cont) ; bug
    return first rest
    ) ; . end ; bug
  )

(defineCPS seq_first ^(seq . return)
  seq
  (^(first . rest)
    return first
    ) ; . end
  )

(defineCPS seq_rest ^(seq . return)
  seq
  (^(first . rest)
;    rest ^(rest)
    return rest
    ) ;  . end
  )

#|
数列seqの項を返す。
seqGet seq ^(a rest)
のように一度に一つの項しか取り出せない。
a: 取り出した項
rest: 残りの項からなる数列
省略時の継続は元のままなので、通常の関数と同様に使える。
|#
#; (defineCPS seqGet ^(seq . return)
  seq (^(V . S) return V S)^()
  return seqEnd seqEnd)

#|
seq_enum ex seq ^(a1 a2 ・・・ an . rest)
  ex: seqが空のとき呼び出される関数
  seq: 数列
  a1, a2, ・・・, an: 先頭からn個の項
  rest: 残りの項からなる数列
注意：継続がrestになるので、このままでは元の継続に戻れなくなる。
　　　元の継続を事前に確保しておき、明示的に呼び出す必要がある。
例：数列seqの先頭から2個の要素を表示する。
|#
(defineCPS seq_enum ^(ex seq . return)
  seq return . ex)
;;;  seq ^ C print("seq_num C=" C "\n") . ex)
;;;  seq return ^(flag) ex)
#|
seqGetCont ifend seq ^(a1 a2 ・・・ an . rest)
  ifend: seqが末尾のとき呼び出される関数
  seq: 数列
  a1, a2, ・・・, an: 取り出した項
  rest: 残りの項からなる数列
ただし、継続がrestになるので元の継続に戻れなくなる。
よって、元の継続を事前に確保しておき、呼び出す必要がある。
|#
#; (defineCPS seqGetCont ^(ifend seq . return)
  seq return . ifend)

#|
( defineCPS seqList ^(list . return)
  ( lambda(L)
    (cons '^ (cons '(R) (cons (cons 'R L) '(^(R) seqEnd R))))
    ) list ^(seq)
  return seq )
|#

#|
seq_map convert seq ^(seq2)
seqの各要素をconvertの引数として与え、その戻り値からなる数列seq2を返す。
|#
( defineCPS seq_map ^(convert seq return)
  fix( ^(loop S R)
       (when(seq_end? S) seq_end R)^()
       seq_pop S ^(v s)
       convert v ^(V)
       R V ^(r)
       loop s r
       ) seq return )

( defineCPS seq_fold ^(f x0 seq . return)
  seq_enum (return x0) seq ^(first . rest)
  f x0 first ^(x1)
  seq_fold f x1 rest . return )

#|
無限数列の例
等差数列
a0: 初項
d: 公差
r0: 数列を受け取る関数
|#
(defineCPS seq_arith ^(a0 d r0)
  fix
  (^(loop an rn) an ^(an)
    rn an ^(rn+1)    ; n番目の項を渡す
    loop (+ an d) rn+1
    ) a0 r0
  )

#|
seqのN個までの数列を返す。
|#
( defineCPS seq_finite ^(seq n r . return)
  (when(<= n 0) seq_end r . return)^()
  seq_enum (seq_end r) seq ^(first . rest)
  r first ^(r)
  - n 1 ^(n)
  seq_finite rest n r . return )

#|
$seqの先頭から条件$skip?を満たす要素を読み飛ばし、
$skip?を満たさない要素を先頭とする列を返す。
|#
(defineCPS seq_skip ^($seq $skip? . $return)
  when(seq_end? $seq)($return $seq)^()
  seq_pop $seq ^($ch $rest)
  unless($skip? $ch)($return $seq)^()
  seq_skip $rest $skip? . $return)

#|
列$seqの先頭から条件$match?を満たす要素を探す。
条件を満たす要素が見つかったとき、その要素を先頭とする残りの列を返す。
条件を満たす要素が見つからなかったとき、列の終端を返す。
|#
(defineCPS seq_find ^($seq $match? . $return)
  (when(seq_end? $seq) $return seq_end)^()
  seq_pop $seq ^($el $rest)
  (when($match? $el) $return $seq)^()
  seq_find $rest $match? . $return
  )

(defineCPS seq_count ^($seq $no $up?)
  (seq_end? $seq) seq_end
  (^($out)
    seq_pop $seq ^($el $seq2)
    $no ^(no)
    $out ($el . no)^($out2)
    ($up? $el)(+ no 1) no ^($no2)
    seq_count $seq2 $no2 $up? ^($seq)
    $seq $out2
    )
  )

#; (defineCPS seq_count_lines ^($in $no)
  (seq_end? $in) seq_end
  (^($out)
    seq_pop $in ^($ch $in2)
    $no ^(no)
    $out ($ch . no)^($out2)
    (char=? $ch #\newline)(+ no 1) no ^($no2)
    seq_count_lines $in2 $no2 ^($seq)
    $seq $out2
    )
  )

(defineCPS string_no_seq_stdin_line ^ $return
  port_stdin ^($port)
  port_line_seq $port 1 ^($seq)
  $return $seq ^()
  print("close\n"))

(defineCPS seq_tokenize_line ^($seq . $return)
  (when(seq_end? $seq) $return seq_end)^()
  seq_pop $seq ^($line $seq2)
  list_pop $line ^($str $no)
  string_tokenize $str ^($list)
  fix
  (^($loop $list)
    (list_pair? $list)
    (^($out)
      list_pop $list ^($first $rest)
      $out ($first . $no)^($out2)
      $loop $rest $out2
      )
    (seq_tokenize_line $seq2)
    ) $list ^($seq3)
  $return $seq3
  )

#|
$seqの先頭から条件$end?を満たさない要素からなるリストと、
$end?を満たす要素を先頭とする列を返す。
|#
(defineCPS seq_get_list ^($seq $end? . $return)
  (when(seq_end? $seq) $return () $seq)^()
  seq_pop $seq ^($first $rest)
  (when($end? $first) $return () $seq . $end)^()
  seq_get_list $rest $end? ^($list $rest)
  list_cons $first $list ^($list)
  $return $list $rest
  )

(defineCPS seq_list ^($seq . $return)
  (when(seq_end? $seq) $return ())^()
  seq_pop $seq ^($first $seq2)
  seq_list $seq2 ^($list)
  list_cons $first $list ^($list2)
  $return $list2)

(defineCPS seq_string ^($seq)
  seq_list $seq ^($list)
  list_string $list)

(defineCPS seq_append ^($seq1 $seq2 $out . $return)
  (seq_end? $seq1)($seq2 $out)
  (
    seq_pop $seq1 ^($first $rest1)
    $out $first ^($out2)
    seq_append $rest1 $seq2 ^($rest2)
    $rest2 $out2
    ) . $return
  )

(defineCPS seq_join ^(seq1 seq2 . return)
  return (^(handler) seq1 handler . seq2))

(defineCPS seq~ ^ cont
  cont_pop cont ^(seq return)
  seq_join seq seq_end ^(seq)
  return seq)

;; 列の先頭の要素を関数，残りの要素を引数として関数適用を実行する
(defineCPS seq_app ^(seq . return)
  seq (^(f) f). return)

;; stack ---------------------------------

#| スタック関連
要素の集まりとして機能し，以下の2つの操作を持つ抽象データ型をスタックという。
push: 要素を追加する。
pop: 要素を削除する。
2020/8/4 作成開始
|#

(defineCPS stack_end ^ R
  R ^(F . C)
  C)

#; (defineCPS stack_end ^(F . C) C)

(defineCPS stack_empty ^(S . R)
  S ^ C
  C (R false)^()
  R true)

(defineCPS stack_push ^(S E . R)
  R (^ C C E . S))

(defineCPS stack_pop ^(S . R)
  S ^(F . C)
  R F C)

(defineCPS stack_print ^(S . R)
  (when(stack_empty S) R)^()
  stack_pop S ^(E S2)
  print(E "\n")^()
  stack_print S2)

;; cont ----------------------------------

(defineCPS cont_push ^(cont func)
  (lambda(C F)
    (func-with-cont F C)
    ) cont func)

(defineCPS cont_pop ^(cont . return)
  (lambda(C)
    (cadr C)
    ) cont ^(first)
  (lambda(C)
    (cddr C)
    ) cont ^(rest)
  return first rest)

(defineCPS cont_end ())

(defineCPS cont_end? ^(cont)
  (lambda(C)
    (null? C)
    ) cont)

#; (defineCPS cont_push ^(cont func . return)
  return(^ seq seq func . cont))

#; (defineCPS cont_pop ^(cont . return)
  cont ^(func . cont)
  return func cont)

#; (defineCPS cont_end ^ return
  return . seq_end)

#; (defineCPS cont_end? ^(cont . return)
  cont ^ seq
  seq_end? seq . return)

#; (defineCPS test ^ cont
  print("cont=" cont "\n")^()
  cont_pop cont ^(first rest)
  print("first=" first "\n")^()
  print("rest=" rest "\n")^()
  + 1 2 ^(a)
  print("a=" a "\n")^()
  exit 0)

#| cont_end, cont_end? のその他の定義

(defineCPS cont_end ^ return
  return ^(return_false . return_true)
  return_true)

(defineCPS cont_end? ^(cont . return)
  cont ^ seq
  seq (return false)^()
  return true)

(defineCPS cont_end? ^(cont . return)
  cont ^ seq
  seq(return false)(return true))

(defineCPS cont_end ^ return
  return ^(func1 func2)
  func2)

(defineCPS cont_end? seq_end?)
(defineCPS cont_end seq_end)
|#

;; logic ----------------------------------

(defineCPS true ^(then else . return)
  return then)

(defineCPS false ^(then else . return)
  return else)

(defineCPS and ^(test1 test2)
  test1 test2 false)
;;;  test1 test2 false ^(test) test)

(defineCPS or ^(test1 test2)
  test1 true test2)

(defineCPS not ^(test then else)
  test else then)

(defineCPS and~ ^(test1 . cont)
  fold_left~ and test1 . cont)

;; control --------------------------------

(defineCPS fix ^(f) f (fix f))

(defineCPS nop ^ return return)

(defineCPS if ^(test then else)
  test then else ^(action)
  action)

(defineCPS when ^(test body . return)
  test body return ^(action)
  action)

(defineCPS unless ^(test body . return)
  test return body ^(action)
  action)

(defineCPS when~ ^(test . cont)
  cont_pop cont ^(seq return)
  test (seq_app seq) return ^(action)
  action)

(defineCPS unless~ ^(test . cont)
  cont_pop cont ^(seq return)
  test return (seq_app seq)^(action)
  action)

(defineCPS if~ ^(test . cont)
;;;  (print~ "cont=" cont)^()
  cont_pop cont ^(seq return)
  seq_join seq seq_end ^(seq)
;;;  (print~ "seq=" seq)^()
  seq_pop seq ^(then seq)
;;;  (print~ "test=" test)^()
;;;  (print~ "then=" then)^()
;;;  (print~ "return=" return)^()
  when test (then . return)^()
;;;  (print~ "seq=" seq)^()
  when(seq_end? seq) return ^()
  seq_pop seq ^(first rest)
;;;  (print~ "first=" first)^()
  unless(object_eq? first else)(first . return)^()
;;;  (print~ "rest=" rest)^()
  seq_app rest . return)

#; (defineCPS if ^(test body . return)
  test body return ^(action)
  action)

(defineCPS fold_left ^(f z seq . return)
  when(seq_end? seq)(return z)^()
;;;  if(seq_end? seq)(return z)^()
;;;  print("seq=" seq)^()
  seq_pop seq ^(first rest)
  f z first ^(z2)
  fold_left f z2 rest)

(defineCPS fold_left~ ^(f z . cont)
  cont_pop cont ^(seq return)
;;;  print("seq=" seq)^()
;;;  print("return=" return)^()
  fold_left f z seq . return)

;; test ------------------------------------

(defineCPS hat_test1 ^()
  if~ true (print~"then1")^()
  if~ true (print~"then2") else (print~"else2")^()
  print("End\n"))

(defineCPS hat_test2 ^(args)
  when true (print~ "hi true")^()
  (print~ "end"))

(defineCPS hat_test3 ^(args)
  (print~ "Begin")^()
  if true (print~ "then")#;else(print~ "else")^()
;;;  if false (print~ "then")(print~ "else")^()
  (print~ "End"))

(defineCPS hat_test4 ^(args)
  list_car args ^(arg1)
  str_num arg1 ^(year)
  (^ break
    when(= (modulo year 400) 0)(break "400で割り切れる" true)^()
    when(= (modulo year 100) 0)(break "100で割り切れる" false)^()
    when(= (modulo year 4) 0)(break "4で割り切れる" true)^()
    break "4で割り切れない" false
    )^(reason leap?)
  leap? "です" "ではありません" ^(ending)
  print(year "年は" reason "ので，うるう年" ending "\n"))
