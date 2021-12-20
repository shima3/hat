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
;;    unless(list_pair? rest) return ^()
    list_pop $tail ^($el $tail)
    ;;    moveAll back rest ^(others)
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
