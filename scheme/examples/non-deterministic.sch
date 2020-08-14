(include "util.sch")

#|
(defineCPS fix ^(f) f (fix f))

(defineCPS #t ^(then else . return)
  return then)
(defineCPS #f ^(then else . return)
  return else)

(defineCPS < ^(a b) a ^(a) b ^(b)
  (lambda (A B)(< A B)) a b)

(defineCPS > ^(a b) a ^(a) b ^(b)
  (lambda (A B)(> A B)) a b)

(defineCPS = ^(a b) a ^(a) b ^(b)
  (lambda (A B)(= A B)) a b)

(defineCPS not ^(condition then else) condition else then)
|#

#; (defineCPS isPair ^(exp)
  (lambda (exp)(pair? exp)) exp)
;; (defineCPS isPair lambda (exp)(pair? exp))

#; (defineCPS makePair ^(left right)
  (lambda (left right)(cons left right)) left right)

#; (defineCPS splitPair ^(pair . return)
  (lambda (pair)(car pair)) pair ^(left)
  (lambda (pair)(cdr pair)) pair ^(right)
  return left right . end)

#; (defineCPS cons ^(el list)
  (lambda (el list)(cons el list)) el list)
#; (defineCPS cons lambda (el list)(cons el list))

#; (defineCPS getFirst ^(list)
  (lambda (list)(car list)) list)
#; (defineCPS getFirst lambda (list)(car list))

#; (defineCPS getRest ^(list)
  (lambda (list)(cdr list)) list)
#; (defineCPS getRest lambda (list)(cdr list))

#; (defineCPS eq? ^(a b)
  (lambda (a b)(eq? a b)) a b)

#; (defineCPS if ^(condition action . return)
  condition action return ^(action)
  action)

#; (defineCPS unless ^(condition action . return)
  condition return action ^(action)
  action)

#; ( defineCPS print ^(list . return)
  ( lambda (list)
    (display (string-append (string-concatenate (map x->string list))))
    ) list ^(dummy)
  return )

#; (defineCPS print ^(value)
  (lambda (value)(display value)) value ^(dummy)())

#; (defineCPS newline ^()
  (lambda ()(newline)) ^(dummy)())

#; (defineCPS nop ^ cont cont)

#; (defineCPS println ^(value)
  (lambda (value)(display value)(newline)) value ^(dummy) nop)

#; (defineCPS moveAll ^(back rest . return)
  unless(list_pair? back)(return rest) ^()
  list_split back ^(el back)
  list_cons el rest ^(rest)
  moveAll back rest)

;; list から要素を1つ選び、第1引数とし、残りを第2引数とし action を呼び出す。
#; (defineCPS forEach ^(list action . return)
  fix
  (^(loop back rest)
    unless(list_pair? rest) return ^()
    list_split rest ^(el rest)
    moveAll back rest ^(others)
    action el others ^()
    list_cons el back ^(back)
    loop back rest)
  () list . end)

( defineCPS main1 ^(args)
  print("begin\n") ^()
  forEach (1 2 3 4 5)
  ( ^(someone others . return)
    print(someone " " others "\n") ^()
    return ) ^()
  print("end\n") )

( defineCPS forAnyOrder ^(list action)
  fix
  ( ^(loop selected candidate . break)
    (list_pair? candidate)
    ( forEach candidate
      ( ^(someone others)
	list_cons someone selected ^(selected)
	loop selected others ) )
    ( moveAll selected () ^(selected)
      action selected ) )
  () list )

( defineCPS main2 ^(args)
  print("begin\n") ^()
  forAnyOrder (1 2 3 4)
  ( ^(selected . break)
    print(selected "\n") ) ^()
  print("end\n") )

(defineCPS amb ^(list cont . k)
  forEach list k . cont)

;;  k 1 (2 3) ^()
;;  k 2 (1 3) ^()
;;  k 3 (1 2) . cont)

( defineCPS main3 ^(args)
  print("begin\n") ^()
  ( ^ cont
    amb (1 2 3 4) cont ^(a rest . cont)
    amb rest cont ^(b rest . cont)
    amb rest cont ^(c rest . cont)
    amb rest cont ^(d rest . cont)
    print(a b c d "\n") . cont ) ^()
  print("end\n") )

( defineCPS sendAsync ^(actor message)
  let actor
  ( mailboxAdd message ^(isFirst)
    when isFirst
    ( getBehavior ^(behavior)
      message behavior
      ) ) )

(defineCPS sendSync ^(actor message . return)
  currentActor ^(from)
  sendAsync actor (message from return) . end)

#; (defineCPS RplyRqstd ^(message from return context . cont)
  message context ^ reply
  sendAsync from (actorNext ^() reply return . end) . end)

( defineCPS RplyRqstd ^(message from return context)
  message context ^ reply
  let from ( reply return ) )

(defineCPS sendRplySync ^(actor message)
  sendSync actor (RplyRqstd message))

(defineCPS makeStack ^()
  makeActor ())

( defineCPS stackIsEmpty ^(stack . return)
  sendRplySync stack
  ( ^(list)
    list_pair? list ^(flag)
    actorNext ^()
    not flag ^(flag)
    return flag ) )

( defineCPS stackPush ^(stack value)
  sendRplySync stack
  ( ^(list)
    list_cons value list ^(list)
    actorBecome list ^()
    actorNext ) )

( defineCPS stackPop ^(stack)
  sendRplySync stack
  ( ^(list . return)
    list_pop list ^(value list)
    actorBecome list ^()
    actorNext ^()
    return value ) )

(defineCPS reset ^(exp . cont)
  makeStack ^(stack)
  stackPush stack cont ^()
  (^(exp2 . cont2)
    (^(exp3 . cont3)
      stackPush stack cont3 ^()
      cont2 exp3 . end) ^(k)
    exp2 k ^(v)
    stackPop stack ^(cont4)
    cont4 v . end) ^(shift)
  exp shift ^(v)
  stackPop stack ^(cont5)
  cont5 v . end)

#; (defineCPS reset ^(exp . cont)
  exp (^(exp2) exp2 (^ cont3 exp (^(exp2 . cont2) cont3 cont2)) . cont) . end)

#|
listから１つ要素を選び、その要素と残りのリストを返す。
|#
( defineCPS amb2 ^(shift list . return)
  ;; print("amb2 1\n") ^()
  shift
  ( ^(k . return2)
    ;; print("amb2 2\n") ^()
    forEach list
    ( ^(first rest)
      ;; print("amb2 3\n") ^()
      list_cons first rest ^(p)
      ;; print("amb2 4\n") ^()
      k p ) ^()
    ;; print("amb2 5\n") ^()
    return2 "dummy" ) ^(p)
  ;; print("amb2 6\n") ^()
  list_pop p ^(first rest)
  return first rest )

( defineCPS main4 ^(args)
  ;; print("main 1\n") ^()
  reset
  ( ^(shift . return)
    ;; print("main 2\n") ^()
    amb2 shift (1 2 3 4) ^(a r)
    ;; print("main 3\n") ^()
    amb2 shift r ^(b r)
    ;; print("main 4\n") ^()
    amb2 shift r ^(c r)
    ;; print("main 5\n") ^()
    amb2 shift r ^(d r)
    ;; print("main 6\n") ^()
    print(a b c d "\n") ^()
    return "dummy2" ) ^(dummy)
  print("main 7") )

( defineCPS makeAmb ^(exp)
  reset
  ( ^(shift . return)
    exp (amb2 shift) ^(value)
    return value ) )

( defineCPS main5 ^(args)
  ;; print("main 1\n") ^()
  makeAmb
  ( ^(amb)
    ;; print("main 2\n") ^()
    amb (1 2 3 4) ^(a r)
    ;; print("main 3\n") ^()
    amb r ^(b r)
    ;; print("main 4\n") ^()
    amb r ^(c r)
    ;; print("main 5\n") ^()
    amb r ^(d r)
    ;; print("main 6\n") ^()
    print(a b c d "\n") ) ^()
  ;; print("main 7\n") ^()
  nop )

( defineCPS amb3 ^(list . cont)
  forEach list cont )

( defineCPS main ^(args)
  print("begin\n")^()
  ( amb3 (1 2 3 4) ^(a r1)
    amb3 r1 ^(b r2)
    amb3 r2 ^(c r3)
    amb3 r3 ^(d r4 . back)
    unless(= d 4) back ^()
    unless(> c b) back ^()
    unless(not (= a 1)) back ^()
    unless(< b 3) back ^()
    unless(< c a) back ^()
    print(a b c d "\n") ) ^()
  print("end\n") )
