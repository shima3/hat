#|
Hat用ユーティリティ関数の定義
|#
( defineCPS fix ^(f) f (fix f) )

( defineCPS #t ^(x y . return)
  return x )

( defineCPS #f ^(x y . return)
  return y )

( defineCPS ifthenelse ^(condition then else)
  condition then else ^(action)
  action )

( defineCPS not ^(condition then else)
  condition else then )

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

#|
list の各要素を一つずつ選び、その要素を第1引数、
それ以外の要素からなるリストを第2引数とし、
action を呼び出す。
( defineCPS forEach ^(list action . return)
  fix
  ( ^(loop back rest)
    unless (isPair rest) return ^()
    splitPair rest ^(el rest)
    moveAll back rest ^(others)
    action el others ^()
    makePair el back ^(back)
    loop back rest )
  ( ) list )
|#

#|
list の要素を非決定的に一つ選び、その要素を第1戻り値、
それ以外の要素からなるリストを第2戻り値として返す。
|#
( defineCPS amb ^(list . cont)
  forEach list cont )

#|
( defineCPS readLine ^()
  (lambda()(read-line)) )

( defineCPS stringPort ^(string)
  (lambda(S)(open-input-string S)) string )

( defineCPS portRead ^(port)
  (lambda(P)(read P)) port )

( defineCPS portClose ^(port . return)
  (lambda(P)(close-port P)) port ^(dummy)
  return )

( defineCPS eof? ^(object)
  (lambda(Obj)(eof-object? Obj)) object )
|#

#|
( defineCPS seqReverse ^(seq . return)
  seqReverseList seq () ^(list)
  listSeq list )

( defineCPS listReverse ^(list)
  (lambda(L)(reverse L)) list )

( defineCPS seqList ^(seq)
  seqReverseList seq () ^(list)
  listReverse list )
|#

#|
listを数列として返す。
( defineCPS listSeq ^(end list)
  (lambda(E L)(append '(^(R) R) L '(^(R)) (list E) '(R))) end list )
|#

( defineCPS and ^(a b)
  a b #f ^(c)
  c )
