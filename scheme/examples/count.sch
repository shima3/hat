(defineCPS main ^(args)
  makeActor (up 0) ^(A)
  sendRplySync A (^(b) b) ^(N1)
  print(N1 "\n") ^()
  sendRplySync A (^(b) b) ^(N2)
  print(N2 "\n"))

(defineCPS up ^(N . cont)
  + N 1 ^(NextN)
  actorBecome (up NextN) ^()
  actorNext ^()
  cont NextN)

(defineCPS print ^(list . return)
  (lambda (list)
    (display (string-append (string-concatenate (map x->string list))))
    ) list ^(dummy)
  return)

(defineCPS #t ^(then else . cont) cont then)
(defineCPS #f ^(then else . cont) cont else)

(defineCPS + ^(a b)
  (lambda (a b)(+ a b)) a b)

(defineCPS nop ^ cont cont)

(defineCPS if ^(condition then)
  condition then nop ^(action)
  action)

(defineCPS sendRplySync ^(actor message)
  sendSync actor (RplyRqstd message))

(defineCPS sendSync ^(actor message . return)
  currentActor ^(from)
  sendAsync actor (message from return) ^()
  nop . end)

(defineCPS RplyRqstd ^(message from return behavior)
  message behavior ^ reply
  let from (reply return))

(defineCPS sendAsync ^(actor message)
  let actor
  (mailboxAdd message ^(isFirst)
    if isFirst
    (getBehavior ^(behavior)
      message behavior)))
