(include "util.sch")

( defineCPS sendAsync ^(actor message)
  let actor
  ( mailboxAdd message ^(isFirst)
    when isFirst
    ( getBehavior ^(behavior)
      message behavior
      ) ) )

( defineCPS sendSync ^(actor message . return)
  currentActor ^(from)
  sendAsync actor ( message from return ) ^()
  nop . stop )

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

( defineCPS counter ^(count arg . return)
  + count 1 ^(count)
  (print~ arg " Start " count) ^()
  sleepSec 1 ^()
  actorBecome (counter count) ^()
  actorNext ^()
  sleepSec 1 ^()
  (print~ arg " End " count) ^()
  return count ^()
  nop )

( defineCPS print.reply ^(reply)
  (print~ "reply=" reply) )

( defineCPS main ^(args)
  makeActor ( counter 0 ) ^(a)
  (print~ "main 1") ^()
  sendAsync a (^(b) b "Async") ^()
  (print~ "main 2") ^( )
  sendAckSync a (^(b) b "AckSync") ^()
  (print~ "main 3") ^( )
  sendAckSync a (^(b) b "AckSync") ^()
  (print~ "main 4") ^( )
  sendRplySync a (^(b) b "RplySync") ^(r)
  (print~ "main 5 reply=" r) ^()
  sendRplySync a (^(b) b "RplySync") ^(r)
  (print~ "main 6 reply=" r)
  )

(defineCPS main1 ^(args)
  (print~ "main 1") ^()
  makeActor ( counter 0 ) ^(a)
  (print~ "main 2") ^()
  sendRplySync a (^(b) b "RplySync") ^(r)
  (print~ "main 3") )

(defineCPS main2 ^(args)
  counter 0 "Async")

(defineCPS main3 ^(args)
  (print~ "a") ^( )
  (print~ "b") ^( )
  (print~ "c"))

(defineCPS main4 ^(args)
  main3 ( ) ^( )
  (print~ "d"))

(defineCPS beforeTime ^(time)
  (lambda(time)
    (time<? (current-time) time)) time)

;;  (lambda (condition then else)(if condition then else)) condition then else
;;  ^(thenorelse) thenorelse)

(defineCPS sleepUntil ^(timeout)
  when(beforeTime timeout)(sleepUntil timeout))

(defineCPS sleepSec ^(sec) sec ^(sec)
  (lambda (sec)(add-duration (current-time)(seconds->duration sec)))
  sec ^(timeout)
  sleepUntil timeout)
