#|
Scheme依存の関数群
|#

;; ( defineCPS #t ^($x $y . $return) $return $x )
;; ( defineCPS #f ^($x $y . $return) $return $y )
(defineCPS #t true)
(defineCPS #f false)

;; debug ----------------------------------

(defineCPS print ^(list . return)
  (lambda(L)
    (apply print L)) list ^(dummy)
  return)

(defineCPS newline ^ return
;;;  (lambda(dummy)(newline)) "dummy" ^(dummy)
  (lambda()(newline))^(dummy)
  return)

(defineCPS print~ ^ cont
  cont_pop cont ^(seq return)
  seq_join seq empty_seq ^(seq)
;;;  print("seq=" seq "\n")^()
  fix
  (^(loop seq . break)
    when(seq_empty? seq) break ^()
    seq_pop seq ^(first rest)
    print(first)^()
    loop rest . break) seq ^()
  newline . return)
;;;  seq_list seq ^(list)
;;;  print list ^()

( defineCPS debug_print ^(tag value . return)
  ( lambda(T V)
    (display T)
    (write V)
    (newline) ) tag value ^(dummy)
  return )

#; (defineCPS seq_print ^($seq $sep . $return)
  seq_enum $return $seq ^($first . $rest)
  port_stdout ^($port)
  port_write $port $first ^()
  port_display $port $sep ^()
;;  print($first $sep)^()
  seq_print $rest $sep . $return)

#|
列の要素を出力する。
seq 列
delimit 境界
|#
(defineCPS seq_print ^(seq delimit . return)
  when(seq_empty? seq) return ^()
  fix
  (^(loop seq)
    seq_pop seq ^(first rest)
    print(first)^()
    when(seq_empty? rest) return ^()
    print(delimit)^()
    loop rest
    ) seq)

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
  port_seq $port ^($in)
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

(defineCPS list_pop ^(list . return)
  (lambda(L)(car L)) list ^(first)
  (lambda(L)(cdr L)) list ^(rest)
  return first rest)

(defineCPS list_values ^(list . return)
  (lambda(L R)
    (cons R L)
    ) list return ^(values)
  values)

;; 文字のリスト ls を文字列に変換します。
(defineCPS list_string ^($list)
  (lambda(list)
    (list->string list)
    ) $list)

(defineCPS list_seq ^($list $tail)
  (list_pair? $list)
  (^($out)
    list_pop $list ^($first $rest)
    list_seq $rest $tail ^($seq)
    $out $first . $seq)
  $tail)

(defineCPS list_and ^($list . $return)
  unless(list_pair? $list)($return #t)^()
  list_pop $list ^($first $rest)
  unless($first)($return #f)^()
  list_and $rest . $return
  )

(defineCPS list_or ^($list . $return)
  unless(list_pair? $list)($return #f)^()
  list_pop $list ^($first $rest)
  when($first)($return #t)^()
  list_or $rest . $return
  )

(defineCPS list_contains? ^($list $obj . $return)
  unless(list_pair? $list)($return #f)^()
  list_pop $list ^($first $rest)
  when(object_eq? $first $obj)($return #t)^()
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

(defineCPS modulo ^(dividend divisor)
  dividend ^(a) divisor ^(b)
  (lambda(A B)(modulo A B)) a b)

(defineCPS div-and-mod ^(dividend divisor)
  dividend ^(a) divisor ^(b)
  (lambda(A B)
    (div-and-mod A B)
    ) a b)

;; object ---------------------------------

(defineCPS object_eof? ^($obj)
  (lambda(obj)
    (eof-object? obj)
    ) $obj)

(defineCPS object_eq? ^($a $b)
  (lambda(a b)
    (eq? a b)
    ) $a $b)

(defineCPS object_print ^(obj . return)
  (lambda(Obj)
    (ifelse(string? Obj)
      (display Obj)
      (write Obj))) obj ^(dummy)
  return)

;; port -----------------------------------

(defineCPS port_read_char ^($port)
  (lambda(port)
    (read-char port)
    ) $port)

(defineCPS port_stdin ^()
  (lambda()
    (standard-input-port)))
;;;    (current-input-port)))

(defineCPS port_stdout ^()
  (lambda()
    (standard-output-port)))
;;;    (current-output-port)))

(defineCPS port_seq ^($port)
  delay
  (
    port_read_char $port ^($ch)
    port_seq $port ^($in)
    (object_eof? $ch) empty_seq
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

(defineCPS port_line_seq ^($port)
  delay
  (^ return
    port_read_line $port ^($line)
    (object_eof? $line) empty_seq
    ( port_line_seq $port $next ^(rest)
      (^(out) out $line . rest)
      )^(seq)
    return seq
    )
  )

(defineCPS open_input_file_port ^(file_name)
  file_name ^($file_name)
  (lambda(file_name)
    (open-input-file file_name)
    ) $file_name)

(defineCPS open_output_file_port ^(file_name)
  file_name ^($file_name)
  (lambda(file_name)
    (open-output-file file_name)
    ) $file_name)

(defineCPS port_close ^($port . return)
  (lambda(port)
    (close-port port)
    ) $port ^(dummy)
  return)

;; string ----------------------

(defineCPS string? ^(str)
  (lambda(S)(string? S)) str)

(defineCPS substring/shared ^(s start end)
  start ^(start) end ^(end)
  (lambda(s start end)
    (substring/shared s start end)
    ) s start end)

(defineCPS string-tokenize ^($s)
  (lambda(s)
    (string-tokenize s)
    ) $s)

(defineCPS string-ref ^(s idx)
  idx ^(idx)
  (lambda(S I)
    (string-ref S I)
    ) s idx)

(defineCPS string-length ^(s)
  (lambda(S)
    (string-length S)
    ) s)

(defineCPS make-string ^(len) len ^(len)
  (lambda(L)(make-string L)) len)

(defineCPS string-set! ^(str index char . return) index ^(index)
  (lambda(S I C)(string-set! S I C)) str index char ^(dummy)
  return)

(defineCPS string->number ^(str)
  (lambda(S)(string->number S)) str)

#; ( defineCPS stringToNumber ^(str)
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
