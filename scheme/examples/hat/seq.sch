#| 数列関連
与えられた関数に０個以上の項を渡す関数を数列という。
項は数値に限らず任意のデータである。
2019/11/13 作成開始
|#

#|
数列の終端
例：(^(out) out 1 2 3 . seq_end)
|#
(defineCPS seq_end ^(out . return)
  return #t . end)
#; ( defineCPS seqEnd ^(R) R seqEnd . seqEnd )
#; ( defineCPS seqEnd ^(a) seqEnd )

#|
seq_end? seq ^(flag)
数列seqが空ならばflagは真 #t、
そうでなければflagは偽 #f
|#
(defineCPS seq_end? ^(seq . return)
  seq (return #f) . return)
#; ( defineCPS seqEnd? ^(seq . return)
  ( lambda(S)
    (eq? (if (eq? (car S) 'F.C)
             (car (cdr S)) S)
         'seqEnd)
    ) seq ^(flag)
  return flag
)

#|
seq_get seq ^(first rest)
数列seqの先頭firstと残りの数列restを返す。
|#
(defineCPS seq_get ^(seq . return)
  seq
  (^(first . rest)
;    rest ^(rest)
    return first rest
    ) ; . end
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
(^ cont
  seq_get_ex seq (print("empty\n"). cont)^(a1 a2 . rest)
  print(a1 ", " a2 "\n"). cont)
|#
(defineCPS seq_enum ^(ex seq . return)
  seq return ^(flag) ex)
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
       if(seq_end? S)(seq_end R)^()
       seq_get S ^(v s)
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
  ( ^(loop an rn) an ^(an)
    rn an ^(rn+1)    ; n番目の項を渡す
    loop (+ an d) rn+1
    ) a0 r0
  )

#|
seqのN個までの数列を返す。
|#
( defineCPS seq_finite ^(seq n r . return)
  if(<= n 0)(seq_end r . return)^()
  seq_enum (seq_end r) seq ^(first . rest)
  r first ^(r)
  - n 1 ^(n)
  seq_finite rest n r . return )

#|
$seqの先頭から条件$skip?を満たす要素を読み飛ばし、
$skip?を満たさない要素を先頭とする列を返す。
|#
(defineCPS seq_skip ^($seq $skip? . $return)
  if(seq_end? $seq)($return $seq)^()
  seq_get $seq ^($ch $rest)
  unless($skip? $ch)($return $seq)^()
  seq_skip $rest $skip? . $return
  )

#|
列$seqの先頭から条件$match?を満たす要素を探す。
条件を満たす要素が見つかったとき、その要素を先頭とする残りの列を返す。
条件を満たす要素が見つからなかったとき、列の終端を返す。
|#
(defineCPS seq_find ^($seq $match? . $return)
  if(seq_end? $seq)($return seq_end)^()
  seq_get $seq ^($el $rest)
  if($match? $el)($return $seq)^()
  seq_find $rest $match? . $return
  )

(defineCPS seq_count ^($seq $no $up?)
  (seq_end? $seq) seq_end
  (^($out)
    seq_get $seq ^($el $seq2)
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
    seq_get $in ^($ch $in2)
    $no ^(no)
    $out ($ch . no)^($out2)
    (char=? $ch #\newline)(+ no 1) no ^($no2)
    seq_count_lines $in2 $no2 ^($seq)
    $seq $out2
    )
  )

(defineCPS seq_print ^($seq $sep . $return)
  seq_enum $return $seq ^($first . $rest)
  port_stdout ^($port)
  port_write $port $first ^()
  port_display $port $sep ^()
;;  print($first $sep)^()
  seq_print $rest $sep . $return)

(defineCPS string_no_seq_stdin_line ^ $return
  port_stdin ^($port)
  port_line_seq $port 1 ^($seq)
  $return $seq ^()
  print("close\n"))

(defineCPS seq_tokenize_line ^($seq . $return)
  if(seq_end? $seq)($return seq_end)^()
  seq_get $seq ^($line $seq2)
  list_split $line ^($str $no)
  string_tokenize $str ^($list)
  fix
  (^($loop $list)
    (list_pair? $list)
    (^($out)
      list_split $list ^($first $rest)
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
  if(seq_end? $seq)($return () $seq)^()
  seq_get $seq ^($first $rest)
  if($end? $first)($return () $seq . $end)^()
  seq_get_list $rest $end? ^($list $rest)
  list_cons $first $list ^($list)
  $return $list $rest
  )

(defineCPS seq_list ^($seq . $return)
  if(seq_end? $seq)($return '())^()
  seq_get $seq ^($first $seq2)
  seq_list $seq2 ^($list)
  list_cons $first $list ^($list2)
  $return $list2)

(defineCPS seq_string ^($seq)
  seq_list $seq ^($list)
  list_string $list)

(defineCPS seq_append ^($seq1 $seq2 $out . $return)
  (seq_end? $seq1)($seq2 $out)
  (
    seq_get $seq1 ^($first $rest1)
    $out $first ^($out2)
    seq_append $rest1 $seq2 ^($rest2)
    $rest2 $out2
    ) . $return
  )
