#|
Hat言語のユーティリティ関数
|#
#|
(include "native/char.sch")
(include "native/list.sch")
(include "native/number.sch")
(include "native/object.sch")
(include "native/port.sch")
(include "native/string.sch")
(include "hat/seq.sch")
(include "hat/stack.sch")
(include "../include/scheme.sch")
(include "../include/hat.sch")
|#
(include "scheme.sch")
(include "hat.sch")

#; ( defineCPS print ^(list . return)
  ( lambda (list)
    (display (string-append (string-concatenate (map x->string list))))
    ) list ^(dummy)
  return )

#|
and_begin test1 test2 ... testN end ^(bool)
|#
(defineCPS and_begin ^ $tests
  seq_pop $tests ^($first $rest)
  when(object_eq? end $first)($rest #t)^()
  when $first (and_begin . $rest)^()
  seq_find $rest (object_eq? End)^($last)
  seq_rest $last ^($rest)
  $rest #f
  )

#|
or_begin test1 test2 ... testN end ^(bool)
|#
(defineCPS or_begin ^ $tests
  seq_pop $tests ^($first $rest)
  when(object_eq? end $first)($rest #f)^()
  unless $first (or_begin . $rest)^()
  seq_find $rest (object_eq? end)^($last)
  seq_rest $last #t
  )

#|
cond
(test1 then1-app ...)
(test2 then2-app ...)
...
(else else-app ...)
|#
(defineCPS cond ^ $clauses
  seq_pop $clauses ^($first $rest)
  list_pop $first ^($head $body)
  when(object_eq? else $head)($body . $rest)^()
  unless $head ($rest cond)^()
  seq_find $rest
  (^($clause)
    list_car $clause ^($head)
    object_eq? else $head)^($last)
  seq_rest $last ^($rest)
  $body . $rest
  )

(defineCPS case ^($key . $clauses)
  $key ^(key)
  fix
  (^($loop $seq . $break)
    seq_pop $seq ^($first $rest)
    list_pop $first ^($head $body)
    when(list_or
	( (list_and
	    ( (object_eq? $head then)
	      (object_eq? key #t)
	      ))
	  (object_eq? $head else)
	  (list_contains? $head key)
	  ))
    (
      $body ^()
      $break $seq
      )^()
    $loop $rest . $break
    ) $clauses ^($clauses)
  fix
  (^($loop $seq . $break)
    seq_pop $seq ^($first $rest)
    list_pop $first ^($head $body)
    when(object_eq? $head else)($break $rest)^()
    $loop $rest . $break
    ) $clauses ^($rest)
  $rest
  )

#; ( defineCPS ifThenElse ^(condition then else)
  condition then else ^(action)
  action )

#; ( defineCPS not ^(condition then else)
  condition else then )

#; ( defineCPS moveAll ^(back rest . return)
  unless(list_pair? back)(return rest)^()
  list_pop back ^(el back)
  list_cons el rest ^(rest)
  moveAll back rest)

#|
list の各要素を一つずつ選び、その要素を第1引数、
それ以外の要素からなるリストを第2引数とし、
action を呼び出す。
|#
( defineCPS forEach ^($list action . return)
  fix
  (^(loop $head $tail . break)
    when(list_empty? $tail) return ^()
    list_pop $tail ^($el $tail)
    list_reverse $head $tail ^($others)
    action $el $others ^()
    list_cons $el $head ^($head)
    loop $head $tail . break)^(loop)
  loop () $list . return)
;;  ( ) list . end ) 2019/7/10 修正

#|
list の要素を非決定的に一つ選び、その要素を第1戻り値、
それ以外の要素からなるリストを第2戻り値として返す。
|#
( defineCPS amb ^(list . cont)
  forEach list cont )

#|
整数aとbの最大公約数を返す関数
|#
(defineCPS gcd ^(a b) a ^(a) b ^(b)
  ifelse(= b 0) a (gcd b (modulo a b)))

;; test ---------------------------------

(defineCPS hoge ^(a . c)
  (print~ "a=" a)^()
  (print~ "c=" c))

(defineCPS test1sub ^(test)
  (print~ "if1 ")^()
  (if~ test (print~ "then1"))^()
  (print~ "if2 ")^()
  (if~ test (print~ "then2")(print~ "else2"))^()
  (print~ "if3 ")^()
  (if~ test (print~ "then3")else(print~ "else3")))

(defineCPS test1util ^(args)
  (print~ "if true")^()
  test1sub true ^()
  (print~ "if false")^()
  test1sub false ^()
  (print~ "End"))

;; 字句解析 ------------------------------

#|
複数行コメントを字句解析する。
$start_str コメントの開始記号
$end_str コメントの終了記号
in 入力 (各行の文字列 行番号 ファイル名) の列
out 出力 (トークンの型 トークンの文字列 行番号 ファイル名) の列
トークンの型は RAW または COMMENT
|#
(defineCPS seq_tokenize_block_comment ^($start_str $end_str in . return)
  string_regexp $start_str ^($start_regexp)
  string_regexp $end_str ^($end_regexp)
  fix
  (^(loop in out . break)
    when(seq_empty? in) break ^()
    seq_pop in ^($list in2)
    list_pop $list ^($type $tail)
    list_pop $tail ^($line $tail)
    ifelse(and(object_eq? $type RAW)(regexp_match $start_regexp $line))
    (^($start_match) ; then
      regexp_start $start_match ^($start_start) ; 開始記号の開始位置
      regexp_end $start_match ^($start_end) ; 開始記号の終了位置
      ifelse(> $start_start 0)
      ( ; then
        substring $line 0 $start_start ^($str)
        out (RAW $str . $tail)
        )(I out)^(out2) ;else
      substring $line $start_end -1 ^($str)
      ifelse(regexp_match $end_regexp $str)
      ;; ifelse(regexp_match $end_regexp $line $start_end)
      (^($end_match) ; then 開始記号と同じ行に終了記号がある場合
        regexp_end $end_match ^($end_end) ; 終了記号の終了位置
        substring $line $start_start $end_end ^($str)
        out2 (COMMENT $str . $tail)^(out3)
        substring $line $end_end -1 ^($str)
        string_length $str ^($len)
        ;; ifelse(> $len 0)(seq_push ($str . $tail) in2)(I in2)^(in3)
        seq_push (RAW $str . $tail) in2 ^(in3)
        loop in3 out3 . break )
      ( ; else 開始記号と異なる行に終了記号がある場合
        open_output_string_port ^($buf)
        substring $line $start_start -1 ^($str)
        port_display $buf $str ^()
        port_display $buf "\n" ^()
        seq_read_string $end_regexp in2 $buf ^($comment in3)
        out2 (COMMENT $comment . $tail)^(out3)
        loop in3 out3 . break )
      )
    ( ; else
      out (RAW $line . $tail)^(out2)
      loop in2 out2 . break )
    )^(loop)
  loop in ^(loop_in)
  return loop_in)

(defineCPS seq_read_string ^($end_regexp in $buf . return)
  seq_pop in ^($list in2)
  list_pop $list ^($type $tail)
  list_pop $tail ^($line $tail)
  unless(and(object_eq? $type RAW)(regexp_match $end_regexp $line))
  (
    port_display $buf $line ^()
    port_display $buf "\n" ^()
    seq_read_string $end_regexp in2 $buf ^ result
    result return )^($end_match)
  regexp_end $end_match ^($end_end) ; 終了記号の終了位置
  substring $line 0 $end_end ^($str)
  port_display $buf $str ^()
  port_get_output_string $buf ^($comment)
  substring $line $end_end -1 ^($str)
  seq_push (RAW $str . $tail) in2 ^(in3)
  return $comment in3)

#|
seq_tokenize_line_comment $start_str in ^(in2)
開始記号$start_strで始まる一行コメントを字句解析する。
|#
(defineCPS seq_tokenize_line_comment ^($start_str)
  string_regexp $start_str ^($start_regexp)
  fix
  (^(loop in)
    (seq_empty? in) empty_seq
    (^(out . break)
      seq_pop in ^($list in2)
      list_pop $list ^($type $tail)
      list_pop $tail ^($line $tail)
      ifelse(object_eq? $type RAW)
      ( ; then
        ifelse(regexp_match $start_regexp $line)
        (^($match) ; then
          regexp_start $match ^($start)
          substring $line 0 $start ^($str)
          out (RAW $str . $tail)^(out2)
          substring $line $start -1 ^($str)
          out2 (COMMENT $str . $tail)^(out3)
          loop in2 out3 . break)
        ( ; else
          out $list ^(out2)
          loop in2 out2 . break) )
      ( ; else
        out $list ^(out2)
        loop in2 out2 . break) )
    ))

(defineCPS seq_tokenize_quote ^($delim)
  string_regexp $delim ^($start_regexp)
  string_concatenate ("(?!\\\\)" $delim)^($end_delim)
  string_regexp $end_delim ^($end_regexp)
  fix
  (^(loop in)
    (seq_empty? in) empty_seq
    (^(out . break)
      seq_pop in ^($list in2)
      list_pop $list ^($type $tail)
      list_pop $tail ^($line $tail)
      ifelse(and(object_eq? $type RAW)(regexp_match $start_regexp $line))
      (^($match) ; then
        regexp_start $match ^($start)
        regexp_end $match ^($end)
        substring $line 0 $start ^($str)
        out (RAW $str . $tail)^(out2)
        open_output_string_port ^($buf)
        substring $line $start $end ^($str)
        port_display $buf $str ^()
        substring $line $end -1 ^($str)
        seq_push (RAW $str . $tail) in2 ^(in3)
        seq_read_string $end_regexp in3 $buf ^($str in4)
        out2 (QUOTE $str . $tail)^(out3)
        loop in4 out3 . break)
      ( ; else
        out $list ^(out2)
        loop in2 out2 . break )
      )))
