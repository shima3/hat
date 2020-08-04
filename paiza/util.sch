( defineCPS print ^(list . return)
  ( lambda (list)
    (display (string-concatenate (map x->string list)))
    ) list ^(dummy)
  return )

( defineCPS fix ^(f) f (fix f) )

( defineCPS #t ^(x y . return)
  return x )

( defineCPS #f ^(x y . return)
  return y )

( defineCPS < ^(a b) a ^(a) b ^(b)
  (lambda (A B)(< A B)) a b )

( defineCPS > ^(a b) a ^(a) b ^(b)
  (lambda (A B)(> A B)) a b )

( defineCPS = ^(a b) a ^(a) b ^(b)
  (lambda (A B)(= A B)) a b )

( defineCPS + ^(a b) a ^(a) b ^(b)
  (lambda (A B)(+ A B)) a b )

( defineCPS - ^(a b) a ^(a) b ^(b)
  (lambda (A B)(- A B)) a b )

( defineCPS * ^(a b) a ^(a) b ^(b)
  (lambda (A B)(* A B)) a b )

( defineCPS remainder ^(a b) a ^(a) b ^(b)
  (lambda (A B)(remainder A B)) a b )

( defineCPS ifthenelse ^(condition then else)
  condition then else )

( defineCPS not ^(condition then else)
  condition else then )

( defineCPS isPair ^(exp)
  (lambda (exp)(pair? exp)) exp )

( defineCPS makePair ^(left right)
  (lambda (left right)(cons left right)) left right )

( defineCPS splitPair ^(pair . return)
  (lambda (pair)(car pair)) pair ^(left)
  (lambda (pair)(cdr pair)) pair ^(right)
  return left right . end )

( defineCPS getFirst ^(list)
  (lambda (list)(car list)) list )

( defineCPS getRest ^(list)
  (lambda (list)(cdr list)) list )

( defineCPS if ^(condition action . return)
  condition action return ^(action)
  action )

( defineCPS unless ^(condition action . return)
  condition return action ^(action)
  action )

( defineCPS moveAll ^(back rest . return)
  unless (isPair back)(return rest) ^()
  getFirst back ^(el)
  getRest back ^(back)
  makePair el rest ^(rest)
  moveAll back rest )

;; list から要素を1つ選び、第1引数とし、残りを第2引数とし action を呼び出す。
( defineCPS forEach ^(list action . return)
  fix
  (^(loop back rest)
    unless (isPair rest) return ^()
    splitPair rest ^(el rest)
;;    getFirst rest ^(el)
;;    getRest rest ^(rest)
    moveAll back rest ^(others)
    action el others ^()
    makePair el back ^(back)
    loop back rest)
  () list . end )

( defineCPS amb ^(list . cont)
  forEach list cont )

( defineCPS makeString ^(len) len ^(len)
  (lambda (len)(make-string len)) len )

( defineCPS stringSet! ^(str index char . return) index ^(index)
  (lambda (S I C)(string-set! S I C)) str index char ^(dummy)
  return )
