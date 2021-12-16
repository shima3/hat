(include "util.sch")

( defineCPS main ^(args)
  start ( repeat_at_interval ( print~ "a" ) 1 ) ^()
  start ( repeat_at_interval ( print~ "b" ) 2 ) ^()
  wait)

(defineCPS main1 ^(args)
  repeat_at_interval (print~ "a") 1)

(defineCPS main2 ^(args)
  print~ "a" ^( )
  print~ "b")

( defineCPS main3 ^(args)
  start ( print~ "a" ) ^()
  wait )

( defineCPS main4 ^(args)
  makeQueue ^(queue)
  repeatConcurrentStep queue ( print~ "a" ) )

( defineCPS main5 ^(args)
  stepCommand ( print~ "a" ) ^(value)
  print("main5 value=" value "\n") )

( defineCPS main6 ^(args)
  stepCommand ( print~ "a" ) ^(value)
  isCommand value ^(flag)
  print("main6 flag=" flag "\n") )

( defineCPS main7 ^(args)
  repeatStep
  ( print("main7 1\n") ^()
    print("main7 2\n") ) )

( defineCPS main8 ^(args)
  makeQueue ^(queue)
  repeatConcurrentStep queue
  ( enqueue queue
    ( (print~ "a")^()
      (print~ "b")^()
      (print~ "c") ) ^()
    enqueue queue
    ( (print~ "d")^()
      (print~ "e")^()
      (print~ "f") ) ) )

( defineCPS repeatStep ^(command)
  stepCommand command ^(value)
  ;; isCommand value ^(flag)
  when( isCommand value )( repeatStep value ) )

( defineCPS repeatConcurrentStep ^(queue command . return)
  stepCommand command ^(value)
  ;; isCommand value ^(flag)
  when( isCommand value )( enqueue queue value ) ^()
  ;; isEmptyQueue queue ^(flag)
  when( isEmptyQueue queue ) return ^()
  dequeue queue ^(command)
  repeatConcurrentStep queue command )

( defineCPS makeQueue lambda()
  (cons 'quote (make-queue)) )

( defineCPS stepCommand lambda(command)
  (step-app command 'end) )

( defineCPS isCommand lambda(value)
  (not (null? value)) )

( defineCPS enqueue ^(queue value . return)
  (lambda(queue value)
    (enqueue! (cdr queue) value)) queue value ^(dummy)
  return )

( defineCPS isEmptyQueue lambda(queue)
  (queue-empty? (cdr queue)) )

( defineCPS dequeue lambda(queue)
  (dequeue! (cdr queue)) )

;; for multi-thread
#; ( defineCPS start ^(command . return)
  ( lambda(cmd)
    (fork-thread
      ( lambda()
	(set! interpreter-count (+ interpreter-count 1))
	(step-loop2 cmd)
	(set! interpreter-count (- interpreter-count 1))
	))) command ^(thread)
  return )

;; for multi-thread
#; ( defineCPS wait ^ return
  ( lambda()
    (sleep duration100ms)
    (> interpreter-count 0) ) ^(flag)
  flag ( wait . return ) return )

( defineCPS wait ^ return
  return )

(defineCPS = ^(a b) a ^(a) b ^(b)
  (lambda (a b)(= a b)) a b)

(defineCPS - ^(a b) a ^(a) b ^(b)
  (lambda (a b)(- a b)) a b)

( defineCPS repeat_at_interval_duration ^(exp duration count) count ^(count)
  (print~ count)^( )
  when(= count 0) stop ^( )
  (lambda (d)(add-duration (current-time) d)) duration ^(timeout)
  exp ^( )
  sleep_until timeout ^( )
  repeat_at_interval_duration exp duration (- count 1)
  )

(defineCPS repeat_at_interval ^(exp sec)
  #; (lambda (sec)
    (let ((s (floor sec)))
      (let ((ns (- sec s)))
	(set! ns (floor (* ns 1000000000)))
  (make-time 'time-duration ns s))))
  (lambda (sec)(seconds->duration sec)) sec ^(duration)
  repeat_at_interval_duration exp duration 10)

#; (defineCPS println ^(value . return)
  (lambda(value)(display value)(newline)) value ^(dummy)
  return)

#; (defineCPS println lambda (value)
  (display value)
  (newline)
  '( ))

#; (defineCPS if ^(condition then else) condition ^(condition)
  (lambda (condition then else)(if condition then else)) condition then else
  ^(thenorelse) thenorelse)

( defineCPS before_time ^(time)
  (lambda (time)(time<? (current-time) time)) time)

( defineCPS sleep_until ^(timeout)
  before_time timeout ^(flag)
  when flag ( sleep_until timeout )
  )

(defineCPS sleep_sec ^(sec) sec ^(sec)
  (lambda (sec)(add-duration (current-time)(seconds->duration sec)))
  sec ^(timeout)
  sleep_until timeout)
