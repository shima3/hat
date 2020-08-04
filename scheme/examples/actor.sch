(defineCPS #t ^(then else) then)
(defineCPS #f ^(then else) else)

(defineCPS nop ^ cont cont)

( defineCPS if ^(condition then)
  condition then nop
  )

( defineCPS println ^(list . return)
  ( lambda (list)
    (display (string-append (string-concatenate (map x->string list)) "\n"))
    ) list ^(dummy)
  return
  )

( defineCPS print ^(value . return)
  ( lambda(value)
    (display value)
    ) value ^(dummy)
  return
  ;; nop
  )

( defineCPS sendAsync ^(actor message)
  let actor
  ( mailboxAdd message ^(isFirst)
    if isFirst
    ( getBehavior ^(behavior)
      message behavior
      ) ) )

( defineCPS sendSync ^(actor message . return)
  currentActor ^(from)
  sendAsync actor ( message from return ) ^()
  nop . stop )
;;;  nop . end )

( defineCPS RplyRqstd ^(message from return behavior)
  message behavior ^ reply
  let from ( reply return )
  )

( defineCPS sendRplySync ^(actor message)
  sendSync actor ( RplyRqstd message )
  )

( defineCPS AckRqstd ^(message from return behavior)
  start ( message behavior ) ^( )
  let from ( return )
  )

( defineCPS sendAckSync ^(actor message)
  sendSync actor ( AckRqstd message )
  )

( defineCPS + ^(a b)
  (lambda (a b)(+ a b)) a b )

( defineCPS counter ^(count arg . return)
  + count 1 ^(count)
  println(arg " Start " count) ^()
  sleepSec 1 ^()
  actorBecome (counter count) ^()
  actorNext ^()
  sleepSec 1 ^()
  println(arg " End " count) ^()
  return count ^()
  nop )

( defineCPS print.reply ^(reply)
  println("reply=" reply) )

( defineCPS main ^(args)
  makeActor ( counter 0 ) ^(a)
  ;; sendAsync a {^(b) println("Async") ^() actorNext} ^()
  println("main 1") ^()
  sendAsync a (^(b) b "Async") ^()
  println("main 2") ^( )
  sendAckSync a (^(b) b "AckSync") ^()
  println("main 3") ^( )
  sendAckSync a (^(b) b "AckSync") ^()
  println("main 4") ^( )
  sendRplySync a (^(b) b "RplySync") ^(r)
  println("main 5 reply=" r) ^()
  sendRplySync a (^(b) b "RplySync") ^(r)
  println("main 6 reply=" r)
  )

( defineCPS main1 ^(args)
  println("main 1") ^()
  makeActor ( counter 0 ) ^(a)
  println("main 2") ^()
  ;; sendAsync a {^(b) b "Async"} ^( )
  ;; sendAckSync a {^(b) b "AckSync"} ^( )
  sendRplySync a (^(b) b "RplySync") ^(r)
  println("main 3")
  )

( defineCPS main2 ^(args)
  counter 0 "Async"
  )

( defineCPS main3 ^(args)
  println("a") ^( )
  println("b") ^( )
  println("c")
  )

( defineCPS main4 ^(args)
  main3 ( ) ^( )
  print "d"
)

(defineCPS beforeTime ^(time)
  (lambda (time)(time<? (current-time) time)) time)

;;  (lambda (condition then else)(if condition then else)) condition then else
;;  ^(thenorelse) thenorelse)

(defineCPS sleepUntil ^(timeout)
  (beforeTime timeout)(sleepUntil timeout)( ))
  ;; if (beforeTime timeout)(sleepUntil timeout))

(defineCPS sleepSec ^(sec) sec ^(sec)
  (lambda (sec)(add-duration (current-time)(seconds->duration sec)))
  sec ^(timeout)
  sleepUntil timeout)
