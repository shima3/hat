(include "util.sch")

(defineCPS list2stack ^(list . return)
  cond
  ((list_pair? list)
    list_split list ^(first rest)
    return first ^()
    list2stack rest
    )
  (else
    stack_end
    )
  )

(defineCPS stack_push2 ^($stack $element . $return)
  $return
  (^ $return2
    $return2 $element . $stack
    )
  )

(defineCPS stack1 ^ $r
  $r 1 ^ $r
  $r 2 ^ $r
  $r 3 . stack_end)

(defineCPS stack2 list2stack (1 2 3))

(defineCPS stack3 ^ $r
  $r 1 ^ $r
  $r 2 ^ $r
  $r 3)

(defineCPS main2 ^()
  fix
  (^(loop S . break)
    stack_empty S ^(P)
    ;; S が空のとき，stack_pop S ^(el S2) すると loop を抜ける。
    if P
    ( print("(break)")^()
      break
      )^()
    stack_pop S ^(E S2)
    print(E "\n")^()
    loop S2
    ) stack1 ^()
  print("End\n")^()
  exit 0)

(defineCPS main3 ^ R
  stack_push R "hoge" ^(R)
  print("Start\n")^()
  stack_print R ^()
  print("End\n")^()
  exit 0)

(defineCPS test ^ cont
  stack_pop cont ^(el cont)
  print("el=" el "\n")^()
  stack_pop cont ^(el cont)
  print("el=" el "\n")^()
  stack_pop cont ^(el cont)
  print("el=" el "\n")^()
  stack_pop cont ^(el cont)
  print("el=" el "\n")^()
  print("cont=" cont "\n")^()
  exit 0
  )

(defineCPS main4 ^()
  (test 1 2 3) 4 5
  )

(defineCPS main5 ^()
  stack_pop stack3 ^(el stack)
  print("el=" el "\n")^()
  print("stack=" stack "\n")^()
  stack_pop stack ^(el stack)
  print("el=" el "\n")^()
  print("stack=" stack "\n")^()
  stack_pop stack ^(el stack)
  print("el=" el "\n")^()
  print("stack=" stack "\n")^()
  exit 0)

(defineCPS seq1 ^(H)
  H 1 2 3 . stack_end)

(defineCPS seq_print2 ^(S . R)
  ;; print("seq_print2 S=" S "\n")^()
  if(stack_empty S)(print("stack_empty\n")^() R)^()
  seq_pop S ^(E S)
  print(E "\n")^()
  seq_print2 S . R)

(defineCPS main6 ^()
  print("Start\n")^()
  fix
  (^(L S . break)
    if(stack_empty S) break ^()
    seq_pop S ^(E S)
    print(E "\n")^()
    L S) seq1 ^()
  print("End\n")^()
  exit 0)

(defineCPS stack4 ^ R
  R 1 ^ R
  R 2 ^ R
  R 3 . stack_end)

(defineCPS main7 ^()
  print("Start\n")^()
  stack_print stack4 ^()
  print("End\n")^()
  exit 0)

(defineCPS hoge ^ R
  stack_pop R ^(S R)
  print("S=" S "\n")^()
  seq_pop S ^(E S)
  print("E1=" E "\n")^()
  seq_pop S ^(E S)
  print("E2=" E "\n")^()
  seq_pop S ^(E S)
  print("E3=" E "\n")^()
  print("S=" S "\n") . R)

(defineCPS hoge2 ^ R
  stack_pop R ^(S R)
  seq_print2 S ^()
  R)

(defineCPS main8 ^()
  print("Begin\n")^()
  (hoge2 1 2 3 . stack_end)^()
  print("End\n")^()
  ;; exit 0
  )

(defineCPS isPair lambda (exp)(pair? exp))

(defineCPS makePair lambda (left right)(cons left right))

( defineCPS splitPair ^(pair . return)
  ( lambda(pair)(car pair) ) pair ^(left)
  ( lambda(pair)(cdr pair) ) pair ^(right)
  return left right )

#; ( defineCPS sendAsync ^(actor message)
  let actor
  ( mailboxAdd message ^(isFirst)
    if isFirst
    ( getBehavior ^(behavior)
      message behavior
      ) ) )

( defineCPS sendAsync ^(actor message)
  ;; println("sendAsync 1") ^()
  let actor
  ( mailboxAdd message ^(isFirst)
    ;; println("sendAsync 2") ^()
    if isFirst
    (
      ;; println("sendAsync 3 message=" message) ^()
      getBehavior ^(behavior)
      ;; println("sendAsync 4 behavior=" behavior) ^()
      message behavior
      )
    )
  ;; println("sendAsync 7") ^()
  ;; return
  )

( defineCPS sendSync ^(actor message . return)
  ;; println("sendSync 1 message=" message) ^()
  ;; println("sendSync 2 return=" return) ^()
  currentActor ^(from)
  ;; println("sendSync 2 from=" from) ^()
  sendAsync actor ( message from return ) ^()
  ;; println("sendSync 3") ^()
  nop . stop )
;;;  nop . end )

( defineCPS RplyRqstd ^(message from return context)
  ;; println("RplyRqstd 1 message=" message) ^()
  ;; println("RplyRqstd 2 context=" context) ^()
  message context ^ reply
  ;; println("RplyRqstd 3 reply=" reply) ^()
  let from
  ( 
    ;; println("RplyRqstd 4 return=" return) ^()
    reply return ) ) ; ^()
    ;; println("RplyRqstd 4") ^()
    ;; nop ) ^()
  ;; println("RplyRqstd 5") ^()
  ;; nop )

( defineCPS sendRplySync ^(actor message . return)
  ;; println("sendRplySync 1 return=" return) ^()
  sendSync actor ( RplyRqstd message ) )

( defineCPS #t ^(then else) then )

( defineCPS #f ^(then else) else )

( defineCPS not ^(condition then else)
  condition else then )

( defineCPS makeStack ^() makeActor () )

( defineCPS stackIsEmpty ^(stack)
  ;; println("stackIsEmpty 1") ^()
  sendRplySync stack
  ( ^(list)
    ;; println("stackIsEmpty 2") ^()
    isPair list ^(flag)
    ;; println("stackIsEmpty 3 flag=" flag) ^()
    actorNext ^()
    ;; println("stackIsEmpty 4") ^()
    not flag ;; ^(flag)
    ;; println("stackIsEmpty 5 flag=" flag) ^()
    ;; return flag
    )
  )

( defineCPS stackPush ^(stack value . return)
  ;; println("stackPush 1 return=" return) ^()
  sendRplySync stack
  ( ^(list)
    ;; println("stackPush 2 list=" list) ^()
    makePair value list ^(list)
    ;; println("stackPush 3 list=" list) ^()
    actorBecome list ^()
    ;; println("stackPush 4") ^()
    actorNext ^()
    ;; println("stackPush 5 return=" return)^()
    return
    ;; ^(c) c
    )
  )

( defineCPS stackPop ^(stack)
  ;; println("stackPop 1") ^()
  sendRplySync stack
  ( ^(list)
    ;; println("stackPop 2") ^()
    splitPair list ^(value list)
    ;; println("stackPop 3") ^()
    actorBecome list ^()
    ;; println("stackPop 4") ^()
    actorNext ^()
    ;; println("stackPop 5") ^()
    value
    )
  )

( defineCPS main ^(args)
  makeStack ^(stack)
  (^(a) b) ^(c)
  stackPush stack (a) ^( )
  stackPush stack (^(a) b) ^( )
  stackPush stack c ^( )
  stackIsEmpty stack ^(flag)
  println("main 1 flag=" flag) ^()
  stackPop stack ^(value)
  println("main 2 value=" value) ^()
  stackIsEmpty stack ^(flag)
  println("main 3 flag=" flag) ^()
  stackPop stack ^(value)
  println("main 4 value=" value) ^()
  stackIsEmpty stack ^(flag)
  println("main 5 flag=" flag) ^()
  stackPop stack ^(value)
  println("main 6 value=" value) ^()
  stackIsEmpty stack ^(flag)
  println("main 7 flag=" flag) ;; ^()
  ;; nop
  )

( defineCPS println ^(list . return)
  ( lambda (list)
    ; (display (string-append (string-concatenate (map x->string list)) "\n"))
    ; (map write list)(newline)
    (print (string-concatenate (map x->string list)))
    ) list ^(dummy)
  return ;; バグ . end　混入日不明、2019/7/8発見
  )

(defineCPS nop ^ cont cont)
