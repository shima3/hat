#!/LINE: 3
(include "util.sch")
#,(FILE test.sch)
(defineCPS main ^()
  display("hello" 1)^()
  display("world" 2 "\n")^()
  seq_empty? empty_seq ^($flag)
  display("flag=" $flag "\n")^()
  display("hoge " #f "\n")^()
  (print "Hello" #t)^()
  (print " world" #f)^()
  exit 0)
