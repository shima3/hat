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
  port_char_seq $port ^($in)
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

(defineCPS list_empty? ^($list)
  (lambda(list)
    (null? list)
    ) $list)

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

(defineCPS list_pop ^($list . return)
  (lambda(L)(car L)) $list ^(first)
  (lambda(L)(cdr L)) $list ^(rest)
  return first rest)

(defineCPS list_values ^($list . return)
  list_cons return $list ^(values) ; print("values=" values "\n")^()
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

(defineCPS port_write_char ^($ch $port)
  (lambda(ch port)
    (write-char ch port)
    ) $ch $port)

(defineCPS port_stdin ^()
  (lambda()
    (standard-input-port)))
;;;    (current-input-port)))

(defineCPS port_stdout ^()
  (lambda()
    (standard-output-port)))
;;;    (current-output-port)))

(defineCPS port_char_seq ^($port)
  delay
  (
    port_read_char $port ^($ch)
    port_char_seq $port ^($in)
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
    when(object_eof? $line)
    ( print("close 1\n")^()
      port_close $port ^()
      return empty_seq)^()
    port_line_seq $port ^(rest)
    return
    (^(out . return2)
      when(list_empty? out)
      ( print("close 2\n")^()
        port_close $port . return2 )^()
      out $line ^(out2)
      rest out2 . return2
      )
    )
#;
  (^ return
    port_read_line $port ^($line)
    when(object_eof? $line)(return empty_seq)^()
    port_line_seq $port ^(rest)
    return (^(out) out $line ^(out2) rest out2)
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
  (lambda(port) ; (display "port_close ")(write port)(newline)
    (close-port port)
    ) $port ^(dummy)
  return)

(defineCPS open_output_string_port ^()
  (labmda()
    (open-output-string)))

(defineCPS port_get_output_string ^($port)
  (lambda(port)
    (get-output-string port)
    ) $port)

;; string ----------------------

(defineCPS string? ^(str)
  str ^($str)
  (lambda(S)
    (string? S)
    ) $str)

(defineCPS substring/shared ^(str start end)
  str ^($str) start ^($start) end ^($end)
  (lambda(str start end)
    (substring/shared str start end)
    ) $str $start $end)

(defineCPS string_tokenize ^(str)
  str ^($str)
  (lambda(str)
    (string-tokenize str)
    ) $str)

(defineCPS string_ref ^(str idx)
  str ^($str) idx ^($idx)
  (lambda(S I)
    (string-ref S I)
    ) $str $idx)

(defineCPS string_length ^(str)
  str ^($str)
  (lambda(S)
    (string-length S)
    ) $str)

(defineCPS make_string ^(len)
  len ^($len)
  (lambda(L)
    (make-string L)
    ) $len)

#; (defineCPS string-set! ^(str index char . return) index ^(index)
  (lambda(S I C)(string-set! S I C)) str index char ^(dummy)
  return)

(defineCPS string_number ^(str)
  str ^($str)
  (lambda(S)
    (string->number S)
    ) $str)

#; (defineCPS string_concat ^(str_list)
  (lambda(list)
    ))

(defineCPS string_start_cursor ^(str)
  str ^($str)
  (lambda(str)
    (string-cursor-start str)
    ) $str)

(defineCPS string_end_cursor ^(str)
  str ^($str)
  (lambda(str)
    (string-cursor-end str)
    ) $str)

(defineCPS string_next_cursor ^(str cur)
  str ^($str) cur ^($cur)
  (lambda(str cur)
    (string-cursor-next str cur)
    ) $str $cur)

(defineCPS string_cursor<? ^($cur1 $cur2)
  (lambda(cur1 cur2)
    (string-cursor<? cur1 cur2)
    ) $cur1 $cur2)

(defineCPS string_cursor>=? ^($cur1 $cur2)
  (lambda(cur1 cur2)
    (string-cursor>=? cur1 cur2)
    ) $cur1 $cur2)

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


;; cont ----------------------------------

(defineCPS cont_push ^(cont func)
  (lambda(C F)
    (func-with-cont F C)
    ) cont func)

(defineCPS cont_rest ^(cont . return)
  (lambda(C)
    (cddr C)
    ) cont)

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
