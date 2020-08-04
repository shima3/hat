;; (include "../hat/seq.sch")

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
