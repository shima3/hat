(defineCPS main ^(args)
  makeActor (up 0) ^(a)
  print "main 1" ^()
  sendRplySync a (^(b) b) ^(r)
  print "main 2 r=" r ^()
  sendRplySync a (^(b) b) ^(r)
  print "main 3 r=" r)

(defineCPS up ^(c . return)
  print "up 1 c=" c ^()
  makeActor add ^(a)
  sendRplySync a (^(b) b c 1) ^(c)
  actorBecome (up c) ^()
  actorNext ^()
  print "up 2 c=" c ^()
  return c . end)

(defineCPS add ^(a b . return)
  + a b ^(c)
  actorNext ^()
  return c . end)

(defineCPS + ^(a b)
  (lambda (a b)(+ a b)) a b)

(defineCPS print lambda args
  (apply print args))

(defineCPS #t ^(then else) then)

(defineCPS #f ^(then else) else)

(defineCPS if ^(condition then)
  condition then ( ) ; ^(action) action
  )

[defineCPS sendAsync ^(actor message)
  let actor
  { mailboxAdd message ^(isFirst)
    if isFirst
    { getBehavior ^(behavior)
      message behavior }}]

[defineCPS sendSync ^(actor message . return)
  currentActor ^(from)
  sendAsync actor { message from return } . end]

[defineCPS RplyRqstd ^(message from return behavior)
  message behavior ^ reply
  let from
  { reply return . end }]

[defineCPS sendRplySync ^(actor message)
  sendSync actor { RplyRqstd message }]

[defineCPS AckRqstd ^(message from return behavior)
  start { message behavior } ^( )
  let from { return }]

[defineCPS sendAckSync ^(actor message)
  sendSync actor { AckRqstd message }]
