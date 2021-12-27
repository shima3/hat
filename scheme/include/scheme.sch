#|
Scheme依存の関数群
|#

;; ( defineCPS #t ^($x $y . $return) $return $x )
;; ( defineCPS #f ^($x $y . $return) $return $y )
(defineCPS #t true)
(defineCPS #f false)

;; debug ----------------------------------

#; (defineCPS print ^($list . return)
  (lambda(list)
    (let( [list2 (tail-first list)] )
      (let( [tail (car list2)]
            [list3 (cdr list2)] )
        (apply print list3)
        (if(null? tail)
          (newline)
          (display tail))))
) $list ^($dummy)
return)

#; (defineCPS print ^($list . return)
  (lambda(list)
    (apply print list)
    ) $list ^($dummy)
  return)

(defineCPS newline ^ return
;;;  (lambda(dummy)(newline)) "dummy" ^(dummy)
  (lambda()(newline))^(dummy)
  return)

#|
引数を出力した後、改行を出力する。
改行を出力したくない場合、displayを用いる。
(print "Hello," " World")^()
|#
;;; (defineCPS print~ ^ cont
(defineCPS print ^ cont
  cont_pop cont ^(seq return)
  seq_join seq empty_seq ^(seq)
  seq_list seq ^($list)
  display $list ^()
  newline . return)
#|
  cont_pop cont ^(seq return)
  seq display ^()
  newline . return)
|#
#|
  (lambda(list)
    (print list)
    ) $list . return)
|#

#|
引数を出力するが、自動的には改行を出力しない。
改行を出力したい場合はprintを用いるか、引数に"\n"を追加する。
display("Hello," " World\n")^()
|#
(defineCPS display ^()
  stdout_port ^($port)
  port_display $port)

#|  
(defineCPS display ^($list)
  stdout_port ^($port)
  port_display $port $list)
|#

;;;  print("seq=" seq "\n")^()
  #|
  fix
  (^(loop seq . break)
    when(seq_empty? seq) break ^()
    seq_pop seq ^(first rest)
    print(first)^()
    loop rest . break) seq ^()
  
  newline . return)
|#
;;;  seq_list seq ^(list)
;;;  print list ^()

( defineCPS debug_print ^(tag value . return)
  ( lambda(T V)
    (display T)
    (write V)
    (newline) ) tag value ^(dummy)
  return )

#|
列の要素を出力する。
seq 列
delimit 境界
|#
(defineCPS seq_print ^(seq . return)
  when(seq_empty? seq) return ^()
  seq_pop seq ^(first rest)
  print(first)^()
  seq_print rest . return
  )
#|
(defineCPS seq_print ^(seq delimit . return)
  ;; print("seq_print 1\n")^()
  when(seq_empty? seq) return ^() ; print("seq_print 2\n")^()
  fix
  (^(loop seq . break)
    seq_pop seq ^(first rest) ; print("seq_print 4: ")^()
    print(first)^()
    loop rest . break
    ) seq . return)
|#

;; char --------------------------------

(defineCPS char_whitespace? ^($ch)
  (lambda(ch)
    (char-whitespace? ch)
    ) $ch)

(defineCPS char=? ^($c1 $c2)
  (lambda(c1 c2)
    (char=? c1 c2)
    ) $c1 $c2)

;; (defineCPS char_seq_stdin ^ $return
(defineCPS stdin_char_seq ^ $return
  stdin_port ^($port)
;;;  port_stdin ^($port)
  port_char_seq $port ^($in)
  $return $in ^()
  print("close\n"))

#|
char_seq_stdout ^(out . close)
|#
(defineCPS stdout_char_seq ^ $return
  stdout_port ^($port) ; port_stdout ^($port)
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

;; list -----------------------------------

#|
(defineCPS nil #f)
(defineCPS isnil ^(s) s (^(x y d) #f) #t)
|#

(defineCPS list_empty? ^($list)
  (lambda(list)
    ;; (print "list_empty? " (null? list))
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

(defineCPS list_reverse ^(list tail . return)
  when(list_empty? list)(return tail)^()
  list_pop list ^(el rest)
  list_cons el tail ^(tail)
  list_reverse rest tail . return)

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

(defineCPS object_equal? ^($a $b)
  (lambda(a b)
    (equal? a b)
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

;;; (defineCPS port_stdin ^()
(defineCPS stdin_port ^()
  (lambda()
;;;    (standard-input-port)))
    (current-input-port)))

;;; (defineCPS port_stdout ^()
(defineCPS stdout_port ^()
  (lambda()
;;;    (standard-output-port)))
    (current-output-port)))

(defineCPS port_char_seq ^(port)
  port ^($port)
  delay
  ( port_read_char $port ^($ch)
    (object_eof? $ch)
    ( port_close $port ^()
      empty_seq)
    (^(out)
      port_char_seq $port ^(seq)
      out $ch . seq)
    ) )

(defineCPS port_write ^($port $obj . $return)
  (lambda(obj port)
    (write obj port)
    ) $obj $port ^($dummy)
  $return)

#|
(defineCPS port_display ^($port . cont)
  cont_pop cont ^(seq return)
  seq_join seq empty_seq ^(args)
  fix
  (^(loop seq . break)
    when(seq_empty? seq) break ^()
    seq_pop seq ^($obj rest)
    (lambda(obj port)
      (if(string? obj)
        (display obj port)
        (write obj port))
      ) $obj $port ^($dummy)
    loop rest . break)^(loop)
  loop args . return)
|#

(defineCPS port_display ^($port $list . return)
  (lambda(port list)
    (map
      (lambda(obj)
        (if(string? obj)
          (display obj port)
          (write obj port)))
      list)
    ) $port $list ^($dummy)
  return)

(defineCPS port_read_line ^($port)
  (lambda(port)
    (port-read-line port)
    ) $port)

(defineCPS port_line_seq ^($port)
  delay
  (^ return
    port_read_line $port ^($line) ; print("port_line_seq 2\n")^()
    when(object_eof? $line)
    ( ; print("close 1\n")^()
      port_close $port ^()
      return empty_seq )^()
    port_line_seq $port ^(rest) ; print("port_line_seq 1\n")^()
    return
    (^(out . return2) ; print("port_line_seq 3\n")^()
      when(list_empty? out)
      ( ; print("close 2\n")^()
        port_close $port . return2 )^()
      out $line ^(out2) ; print("port_line_seq 4\n")^()
      rest out2 ; bug . return2
      )
    ))

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
    (port-close port)
;;    (close-port port)
    ) $port ^(dummy)
  return)

(defineCPS open_output_string_port ^()
  (lambda()
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

#|
strのstart番目の文字(これを含む)から、end番目の文字(これを含まない)までの部分文字列を返す。
endが-1の場合、strの終端を意味する。
|#
(defineCPS substring ^(str start end)
  str ^($str) start ^($start) end ^($end)
  (lambda(str start end)
;;    (if(< end 0)(set! end (string-length str)))
    (string_substring str start end)
;;    (substring/shared str start end)
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

#|
 (defineCPS string-set! ^(str index char . return) index ^(index)
  (lambda(S I C)(string-set! S I C)) str index char ^(dummy)
  return)
  |#
  
(defineCPS string_number ^(str)
  str ^($str)
  (lambda(S)
    (string->number S)
    ) $str)

#|
(defineCPS string_concat ^(str_list)
  (lambda(list)
    ))
|#

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

(defineCPS string_seq ^(str)
  str ^($str)
  string_end_cursor $str ^($end)
  fix
  (^(loop cur out . break)
    cur ^($cur)
    when(string_cursor>=? $cur $end) break ^()
    string_ref $str $cur ^($ch)
    out $ch ^(out2)
    loop (string_next_cursor $str $cur) out2 . break
    )^(loop)
  loop (string_start_cursor $str))

(defineCPS string_concatenate ^($list)
  (lambda(list)
    (string-cat list)
;;    (string-concatenate list)
    ) $list)

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

(defineCPS cont_first ^(cont . return)
  (lambda(C)
    (cadr C)
    ) cont)

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

(defineCPS cont? ^(cont)
  (lambda(C)
    (and(pair? C)(eq? (car C) 'F.C))
    ) cont)

(defineCPS cont_print ^(msg cont . return)
  ifelse(cont? cont)
  (cont_first cont)(I cont)^(cont)
  print(msg cont) . return)

;; 正規表現 regexp -----------------------------

(defineCPS string_regexp ^(str)
  str ^($str)
  (lambda(str)
;;    (regexp str)
    (string->regexp str)
    ) $str)

#|
正規表現regexpに一致する部分を文字列strから探す。
一致する部分が見つかった場合、#tと開始位置と終了位置を返す。
見つからなかった場合、#fを返す。
使用例：
ifelse(regexp_search regexp str start)
(^(start end) 見つかった場合の処理)
(見つからなかった場合の処理)^()
|#
(defineCPS regexp_search ^(regexp str . return)
  regexp ^($regexp) str ^($str) ; start ^($start) end ^($end)
  (lambda(regexp str)
;;    (rxmatch regexp str start)
;;    (rxmatch regexp (substring str start (string-length str)))
;;    (rxmatch regexp (substring str start -1))
;;    (define pos (regexp-search regexp str))
;;    (define pos (string-search-positions regexp str))
;;    (define pos (string-match-positions regexp str))
    ;; (display "pos=")(write pos)(newline)
    ;;    (if pos (cons #t (car pos))(cons #f '()))
    (regexp-search regexp str)
    ;;    (rxmatch regexp str)
    ) $regexp $str ^($result)
  ;; when(object_eq? $result #f)(return #f)^()
  ;; print("match result=" $result "\n")^()
  list_values $result . return)
  ;; return #t $result)
