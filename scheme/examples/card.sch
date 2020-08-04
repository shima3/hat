#|
赤いカード２枚と黒いカード２枚がある。
４枚のうち２枚をランダムに選んだとき、
同じ色になる確率と異なる色になる確率は、どちらが高いか？
|#
(defineCPS main ^(args . cont)
  amb ("red" "red" "black" "black") cont ^(first rest . cont)
  amb rest cont ^(second rest . cont)
  print(first " " second "\n") . cont)

{ defineCPS print ^(list . return)
  { lambda (list)
    (display (string-append (string-concatenate (map x->string list))))
    } list ^(dummy)
  return }

(defineCPS amb ^(list cont . k)
  forEach list k . cont)

;; list から要素を1つ選び、第1引数とし、残りを第2引数とし action を呼び出す。
(defineCPS forEach ^(list action . return)
  fix
  (^(loop back rest)
    unless (isPair rest) return ^()
    splitPair rest ^(el rest)
    moveAll back rest ^(others)
    action el others ^()
    makePair el back ^(back)
    loop back rest)
  () list . end)

(defineCPS fix ^(f) f (fix f))

(defineCPS #t ^(then else) then)
(defineCPS #f ^(then else) else)

(defineCPS eq? ^(a b)
  (lambda (a b)(eq? a b)) a b)

(defineCPS if ^(condition action . return)
  condition action return)

(defineCPS unless ^(condition action . return)
  condition return action)

(defineCPS isPair ^(exp)
  (lambda (exp)(pair? exp)) exp)

(defineCPS splitPair ^(pair . return)
  (lambda (pair)(car pair)) pair ^(left)
  (lambda (pair)(cdr pair)) pair ^(right)
  return left right . end)

(defineCPS moveAll ^(back rest . return)
  unless (isPair back)(return rest) ^()
  getFirst back ^(el)
  getRest back ^(back)
  makePair el rest ^(rest)
  moveAll back rest)

(defineCPS makePair ^(left right)
  (lambda (left right)(cons left right)) left right)

(defineCPS getFirst ^(list)
  (lambda (list)(car list)) list)

(defineCPS getRest ^(list)
  (lambda (list)(cdr list)) list)
