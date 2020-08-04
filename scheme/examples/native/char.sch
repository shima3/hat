
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
