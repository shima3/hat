(defineCPS isPair lambda (exp)(pair? exp))

(defineCPS makePair lambda (left right)(cons left right))

(defineCPS splitPair ^(pair . return)
  (lambda (pair)(car pair)) pair ^(left)
  (lambda (pair)(cdr pair)) pair ^(right)
  return left right)

(defineCPS sendSync ^(actor message . return)
  currentActor ^(from)
  ;; sendAsync from (^(c) debugPrint "sendSync 1" ^() actorNext . end) ^()
  ;; debugPrint "sendSync 2" ^()
  sendAsync actor (message from return) . end)

#; (defineCPS RplyRqstd ^(message from return context . cont)
  message context ^ reply
  sendAsync from
  (;; debugPrint "RplyRqstd 2" ^()
    actorNext ^()
    reply return . end) . end)

{ defineCPS RplyRqstd ^(message from return context)
  ;; println("RplyRqstd 1 message=" message " context=" context) ^()
  message context ^ reply
  ;; println("RplyRqstd 2 reply=" reply) ^()
  let from
  { 
    ;; println("RplyRqstd 3 return=" return) ^()
    reply return } }

(defineCPS sendRplySync ^(actor message)
  sendSync actor (RplyRqstd message))

(defineCPS #t ^(then else) then)

(defineCPS #f ^(then else) else)

(defineCPS not ^(condition then else)
  condition else then)

(defineCPS makeStack ^()
  makeActor ())

{ defineCPS stackIsEmpty ^(stack)
  sendRplySync stack
  { ^(list)
    isPair list ^(flag)
    actorNext ^()
    not flag } }

{ defineCPS stackPush ^(stack value)
  ;; println "stackPush 1" ^()
  sendRplySync stack
  { ^(list)
    ;; println "stackPush 2" ^()
    makePair value list ^(list)
    ;; println "stackPush 3" ^()
    actorBecome list ^()
    ;; println "stackPush 4" ^()
    actorNext } }

{ defineCPS stackPop ^(stack)
  ;; println("stackPop 1") ^()
  sendRplySync stack
  { ^(list . return)
    ;; println("stackPop 2") ^()
    splitPair list ^(value list)
    ;; println("stackPop 3 value=" value) ^()
    actorBecome list ^()
    ;; println("stackPop 4") ^()
    actorNext ^()
    ;; println("stackPop 5") ^()
    return value
    }
  }

(defineCPS reset1 ^(exp . cont)
  exp (^(exp2) exp2 (^(par . cont3) exp (^(exp2 . cont2) cont2 par . cont3)) . cont) . end)
;;  exp (^(exp2) exp2 (^(par) exp (^(exp2 . cont2) exp2 cont2 . end)) . cont) . end)

(defineCPS reset2 ^(exp . cont)
  (^(exp2 . cont2)
    (^(exp3 . cont3) cont2 exp3 . cont3) ^(k)
    exp2 k . cont) ^(shift)
  exp shift . cont)

(defineCPS returnShift ^(stack v)
  stackIsEmpty stack ^(flag)
  flag v (stackPop stack ^(cont) cont v . end))

(defineCPS reset ^(exp . cont)
  makeStack ^(stack)
  ;; println("reset 1 cont=" cont) ^()
  stackPush stack cont ^()
  (^(exp2 . cont2)
    (^(exp3 . cont3)
      ;; println("reset 2 cont3=" cont3) ^()
      stackPush stack cont3 ^()
      cont2 exp3) ^(k)
    ;; println("reset 3 exp2=" exp2) ^()
    ;; println("reset 3 k=" k) ^()
    exp2 k ^(v)
    ;; println("reset 4 v=" v) ^()
    stackPop stack ^(cont4)
    cont4 v) ^(shift)
  ;; println("reset 5 shift=" shift) ^()
  exp shift ^(v)
  ;; println("reset 6 v=" v) ^()
  stackPop stack ^(cont5)
  ;; println("reset 7 cont5=" cont5) ^()
  cont5 v)

#; (defineCPS reset ^(exp . cont)
  (^(exp2 . cont2) debugPrint "exp2a=" exp2 ^() exp2 cont2) ^(shift2)
  debugPrint "shift2=" shift2 ^()
  (^(par) exp shift2) ^(k)
  debugPrint "k=" k ^()
  (^(exp2) debugPrint "exp2b=" exp2 ^() exp2 k . cont) ^(shift)
  debugPrint "shift=" shift ^()
  exp shift)

(defineCPS + ^(left right . return) left ^(left) right ^(right)
  ;; println("+ left=" left " right=" right) ^()
  (lambda (left right)(+ left right)) left right ^(value)
  ;; println("+ value=" value) ^()
  return value)

(defineCPS * ^(left right) left ^(left) right ^(right)
  ;; println("* left=" left " right=" right) ^()
  (lambda (left right)(* left right)) left right)

#; (defineCPS debugPrint lambda args
  (for-each display args)(newline) '())

;;  (lambda (tag value)(display tag)(display value)(newline))
;;  tag value ^(dummy)( ))

{ defineCPS main ^(args)
  ;; println("main 1") ^()
  ;; * 2 (reset (^(shift) + 1 (shift (^(k) k 5)))) ^(value)
  + 1 { reset
	{ ^(shift)
	  ;; println("main 2 shift=" shift) ^()
	  + 4
	  { shift
	    { ^(k)
	      ;; println("main 3 k=" k) ^()
	      * 3 (k 2)
	      }}}} ^(value)
  ;; + (+ 1 (reset (^(shift) * (* 2 (shift (^(k) 3))) 4))) 5 ^(value)
  println("value=" value) ; ^() nop
  }

{ defineCPS sendAsync ^(actor message)
  let actor
  { mailboxAdd message ^(isFirst)
    if isFirst
    { getBehavior ^(behavior)
      message behavior
      } } }

{ defineCPS if ^(condition then)
  condition then nop
  }

{ defineCPS println ^(list . return)
  { lambda (list)
    (display (string-append (string-concatenate (map x->string list)) "\n"))
    } list ^(dummy)
  return
  }

(defineCPS nop ^ cont cont)

#; (defineCPS println ^(value)
  (lambda (value)(display value)(newline)'( )) value)
