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
|#
(include "../include/scheme.sch")
(include "../include/hat.sch")

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
  if(object_eq? end $first)($rest #t)^()
  if $first (and_begin . $rest)^()
  seq_find $rest (object_eq? End)^($last)
  seq_rest $last ^($rest)
  $rest #f
  )

#|
or_begin test1 test2 ... testN end ^(bool)
|#
(defineCPS or_begin ^ $tests
  seq_pop $tests ^($first $rest)
  if(object_eq? end $first)($rest #f)^()
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
  list_split $first ^($head $body)
  if(object_eq? else $head)($body . $rest)^()
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
    list_split $first ^($head $body)
    if(list_or
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
    list_split $first ^($head $body)
    if(object_eq? $head else)($break $rest)^()
    $loop $rest . $break
    ) $clauses ^($rest)
  $rest
  )

( defineCPS ifThenElse ^(condition then else)
  condition then else ^(action)
  action )

( defineCPS not ^(condition then else)
  condition else then )

( defineCPS moveAll ^(back rest . return)
  unless (isPair back)(return rest) ^()
  getFirst back ^(el)
  getRest back ^(back)
  makePair el rest ^(rest)
  moveAll back rest )

#|
list の各要素を一つずつ選び、その要素を第1引数、
それ以外の要素からなるリストを第2引数とし、
action を呼び出す。
|#
( defineCPS forEach ^(list action . return)
  fix
  ( ^(loop back rest)
    unless (isPair rest) return ^()
    splitPair rest ^(el rest)
;;    getFirst rest ^(el)
;;    getRest rest ^(rest)
    moveAll back rest ^(others)
    action el others ^()
    makePair el back ^(back)
    loop back rest)
  ( ) list )
;;  ( ) list . end ) 2019/7/10 修正

#|
list の要素を非決定的に一つ選び、その要素を第1戻り値、
それ以外の要素からなるリストを第2戻り値として返す。
|#
( defineCPS amb ^(list . cont)
  forEach list cont )

( defineCPS makeString ^(len) len ^(len)
  (lambda (len)(make-string len)) len )

( defineCPS stringSet! ^(str index char . return) index ^(index)
  (lambda (S I C)(string-set! S I C)) str index char ^(dummy)
  return )

( defineCPS string_to_number ^(str)
  (lambda (str)(string->number str)) str )

( defineCPS listToValues ^(list . return)
  (lambda(L R) (cons R L)) list return ^(exp)
  exp )

( defineCPS gcd ^(a b . return) a ^(a) b ^(b)
  if (= b 0) (return a) ^()
  gcd b (modulo a b) . return )
