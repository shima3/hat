(include "util.sch")

(defineCPS main ^($args)
  (print "args=" $args)^()
  list_car $args ^($file_name)
  open_input_file_port $file_name ^($port)
  port_line_seq $port ^(seq) ; print("main 3\n")^()
  seq_count raw: seq 1 ($file_name)^(seq) ; print("main 2\n")^()
  seq_tokenize_block_comment "#\\|" "\\|#" seq ^(seq) ; print("main 4\n")^()
  seq_tokenize_line_comment ";" seq ^(seq) ; print("main 1")^()
  seq_tokenize_line_comment "#!" seq ^(seq)
  seq_tokenize_quote "\"" seq ^(seq)
  seq_tokenize_quote "\\|" seq ^(seq)
  seq_tokenize_delimit "[\\(\\)]" seq ^(seq)
  seq_skip_space "\\s+" seq ^(seq)
  seq_skip_empty_string seq ^(seq)
  seq_print seq ^()
  port_close $port ^()
  (print "end")^()
  exit 0)

(defineCPS char_seq ^(in)
  (seq_empty? in) empty_seq
  (^(out)
    seq_pop in ^($pair in2)
    list_pop $pair ^($no $str)
    string_end_cursor $str ^($end)
    fix
    (^(loop cur out . break)
      cur ^($cur)
      when(string_cursor>=? $cur $end)(break out)^()
      string_ref $str $cur ^($ch)
      out ($no . $ch)^(out2)
      loop (string_next_cursor $str $cur) out2 . break
      )(string_start_cursor $str) out ^(out2)
    out2 ($no . #\newline)^(out3)
    char_seq in2 out3))

(defineCPS char_line_seq ^(char_in $line_no out)
  ;;  I ($line_no)^($tail)
  fix
  (^(loop in out . break)
    when(seq_empty? in) empty_seq ^()
    seq_pop in ^($ch in2)
;;    out ($ch . $tail)^(out2)
    out ($line_no . $ch)^(out2)
    when(char=? $ch #\newline)(break in2 out2)^()
    loop in2 out2 . break
    ) char_in out ^(in2 out2)
  + $line_no 1 ^($line_no+1)
  char_line_seq in2 $line_no+1 out2)

(defineCPS tokenize ^(in out . return)
  when(seq_empty? in) return ^()
  seq_parse_comment "#|" "|#" in out tokenize ^()
  ;; S式コメントは字句解析の後、処理する。seq_parse_sexp_comment seq "#;" ^(seq)
  ;; seq_parse_comment "#!" "\n" seq ^(seq)
  ;; seq_parse_comment ";" "\n" seq ^(seq)
  ;; seq_pop seq ^($ch rest)
  ;; print("ch=" ch "\n")^()
  seq_pop in ^($list in2)
  list_pop $list ^($no $ch)
  out ($no char $ch)^(out2)
  tokenize in2 out2 . return)
