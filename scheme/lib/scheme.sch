#|
Scheme依存の関数群
|#

;; ( defineCPS #t ^($x $y . $return) $return $x )
;; ( defineCPS #f ^($x $y . $return) $return $y )
( defineCPS #t true)
( defineCPS #f false)

(defineCPS print ^($list . $return)
  (lambda (list)
    (display (string-concatenate (map x->string list)))
    ) $list ^($dummy)
  $return)

( defineCPS debug_print ^(tag value . return)
  ( lambda(T V)
    (display T)
    (write V)
    (newline) ) tag value ^(dummy)
  return )

;; char --------------------------------

(defineCPS char_whitespace? ^($ch)
  (lambda(ch)
    (char-whitespace? ch)
    ) $ch)

#; (defineCPS isSpace ^(ch)
  (lambda(ch)
    (char=? ch #\Space)
    ) ch)

(defineCPS char=? ^($c1 $c2)
  (lambda(c1 c2)
    (char=? c1 c2)
    ) $c1 $c2)

#|
char_seq_stdin ^(in . close)
|#
(defineCPS char_seq_stdin ^ $return
  port_stdin ^($port)
  port_in $port ^($in)
  $return $in ^()
  print("close\n"))

#|
char_seq_stdout ^(out . close)
|#
(defineCPS char_seq_stdout ^ $return
  port_stdout ^($port)
  fix
  (^($out $obj . $ret)
    port_display $port $obj ^()
    $ret $out
    )^($out)
  $return $out ^()
  print("close\n"))

(defineCPS char_seq_tokenize ^($in $space? . $return)
  seq_skip $in $space? ^($in)
  seq_get_list $in $space? ^($list $in)
  list_string $list ^($token)
  $return $token $in)

(defineCPS char_seq_count_lines ^($in $no)
  seq_count $in $no (^($ch) char=? $ch #\newline)
  )

;; list -----------------------------------

#; (defineCPS nil #f)
#; (defineCPS isnil ^(s) s (^(x y d) #f) #t)

(defineCPS list_pair? ^($list)
  (lambda(list)
    (pair? list)
    ) $list)

#|
(defineCPS car ^(s) s #t)
( defineCPS getFirst ^(list)
|#
(defineCPS list_car ^($list)
  (lambda(list)
    (car list)
    ) $list)

#|
(defineCPS cdr ^(s) s #f)
( defineCPS getRest ^(list)
|#
(defineCPS list_cdr ^($list)
  (lambda(list)
    (cdr list)
    ) $list)

#|
(defineCPS cons ^(x y f) f x y)
(defineCPS makePair ^(left right)
|#
(defineCPS list_cons ^($obj1 $obj2)
  (lambda(obj1 obj2)
    (cons obj1 obj2)
    ) $obj1 $obj2)

(defineCPS list_split ^($list . $return)
  (lambda(list)(car list)) $list ^($obj1)
  (lambda(list)(cdr list)) $list ^($obj2)
  $return $obj1 $obj2)

(defineCPS list_values ^($list . $return)
  (lambda(list return)
    (cons return list)
    ) $list $return ^($values)
  $values)

;; 文字のリスト ls を文字列に変換します。
(defineCPS list_string ^($list)
  (lambda(list)
    (list->string list)
    ) $list)

(defineCPS list_seq ^($list $tail)
  (list_pair? $list)
  (^($out)
    list_split $list ^($first $rest)
    list_seq $rest $tail ^($seq)
    $out $first . $seq)
  $tail)

(defineCPS list_and ^($list . $return)
  unless(list_pair? $list)($return #t)^()
  list_split $list ^($first $rest)
  unless($first)($return #f)^()
  list_and $rest . $return
  )

(defineCPS list_or ^($list . $return)
  unless(list_pair? $list)($return #f)^()
  list_split $list ^($first $rest)
  if($first)($return #t)^()
  list_or $rest . $return
  )

(defineCPS list_contains? ^($list $obj . $return)
  unless(list_pair? $list)($return #f)^()
  list_split $list ^($first $rest)
  if(object_eq? $first $obj)($return #t)^()
  list_contains? $rest $obj . $return
  )

;; number ------------------------------

(defineCPS < ^(a b)
  a ^($a) b ^($b)
  (lambda(A B)
    (< A B)
    ) $a $b )

(defineCPS <= ^(a b)
  a ^($a) b ^($b)
  (lambda(A B)
    (<= A B)
    ) $a $b)

(defineCPS > ^(a b)
  a ^($a) b ^($b)
  (lambda(A B)
    (> A B)
    ) $a $b)

(defineCPS >= ^(a b)
  a ^($a) b ^($b)
  (lambda(A B)
    (>= A B)
    ) $a $b)

(defineCPS = ^(a b)
  a ^($a) b ^($b)
  (lambda(A B)
    (= A B)
    ) $a $b)

(defineCPS <> ^(a b)
  a ^($a) b ^($b)
  (lambda(A B)
    (not (= A B))
    ) $a $b)

(defineCPS + ^(a b)
  a ^($a) b ^($b)
  (lambda(A B)
    (+ A B)
    ) $a $b)

(defineCPS - ^(a b)
  a ^($a) b ^($b)
  (lambda(A B)
    (- A B)
    ) $a $b)

(defineCPS * ^(a b)
  a ^($a) b ^($b)
  (lambda(A B)
    (* A B)
    ) $a $b)

(defineCPS remainder ^(a b)
  a ^($a) b ^($b)
  (lambda(A B)
    (remainder A B)
    ) $a $b)

(defineCPS modulo ^(a b)
  a ^($a) b ^($b)
  (lambda(A B)
    (modulo A B)
    ) $a $b)

(defineCPS div-and-mod ^(a b)
  a ^($a) b ^($b)
  (lambda(A B)
    (div-and-mod A B)
    ) $a $b)

;; object ---------------------------------

(defineCPS object_eof? ^($obj)
  (lambda(obj)
    (eof-object? obj)
    ) $obj)

(defineCPS object_eq? ^($a $b)
  (lambda(a b)
    (eq? a b)
    ) $a $b)

;; port -----------------------------------

(defineCPS port_read_char ^($port)
  (lambda(port)
    (read-char port)
    ) $port)

(defineCPS port_stdin ^()
  (lambda()
    (standard-input-port)))

(defineCPS port_stdout ^()
  (lambda()
    (standard-output-port)))

(defineCPS port_in ^($port)
  delay
  (
    port_read_char $port ^($ch)
    port_in $port ^($in)
    (object_eof? $ch) seq_end
    (^($out) $out $ch . $in)
    )
  )

(defineCPS port_write ^($port $obj . $return)
  (lambda(obj port)
    (write obj port)
    ) $obj $port ^($dummy)
  $return)

(defineCPS port_display ^($port $obj . $return)
  (lambda(obj port)
    (display obj port)
    ) $obj $port ^($dummy)
  $return)

(defineCPS port_read_line ^($port)
  (lambda(port)
    (read-line port)
    ) $port)

(defineCPS port_line_seq ^($port $start)
  delay
  (^ $return
    port_read_line $port ^($line)
    (object_eof? $line) seq_end
    ( + $start 1 ^($next)
      port_line_seq $port $next ^($seq)
      (^($out) $out ($line . $start) . $seq)
      )^($seq)
    $return $seq
    )
  )

;; string ----------------------

(defineCPS substring/shared ^(s start end)
  start ^(start) end ^(end)
  (lambda(s start end)
    (substring/shared s start end)
    ) s start end)

(defineCPS string_tokenize ^($s)
  (lambda(s)
    (string-tokenize s)
    ) $s)

(defineCPS string-ref ^(s idx)
  idx ^(idx)
  (lambda(S Idx)
    (string-ref S Idx)
    ) s idx)

(defineCPS string-length ^(s)
  (lambda(S)
    (string-length S)
    ) s)

( defineCPS makeString ^(len) len ^(len)
  (lambda (len)(make-string len)) len )

( defineCPS stringSet! ^(str index char . return) index ^(index)
  (lambda (S I C)(string-set! S I C)) str index char ^(dummy)
  return )

( defineCPS stringToNumber ^(str)
  (lambda (str)(string->number str)) str )

;; memory ------------------------------

(defineCPS memory_gc ^ return
  (lambda()
    (gc)
    )^(dummy)
  return)

(defineCPS memory_used ^ return
  (lambda()
    (let([stat (gc-stat)])
      (- (cadr (assq :total-heap-size stat))
	(cadr (assq :free-bytes stat))
	))))
