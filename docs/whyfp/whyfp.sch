#|
Why Functional Programming Matters のサンプルコードを Hat 言語で実装するための関数群
|#

;;; リスト関係

(defineCPS cons ^(first rest get)
  get first rest)

(defineCPS nil ^(get . return) return)

(defineCPS getFirst ^(list . return)
  list (^(first rest) return first))

;; (defineCPS getRest ^(list out)
;;  list (^(first . rest) rest out))
(defineCPS getRest ^(list . return)
  list (^(first rest) return rest))

(defineCPS isNil ^(list . return)
  list (^(first rest) return false) ^()
  return true)

;;; 高階関数

(defineCPS reduce ^(f x list)
  if(isNil list) x
  (f (getFirst list) (reduce f x (getRest list))))
;;  ( reduce f x (getRest list)^(y)
;;    f (getFirst list) y ))

(defineCPS compose ^(f g x)
  g x ^(y)
  f y)

(defineCPS map ^(f)
  reduce (compose cons f) nil)
