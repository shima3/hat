#|
Why Functional Programming Matters のサンプルコードを Hat 言語で実装するための関数群
|#

;;; リスト関係

(defineCPS cons ^(first rest get)
  get first rest)

(defineCPS nil ^(get . return) return)

(defineCPS getFirst ^(list . return)
  list (^(first rest) return first))

(defineCPS getRest ^(list . return)
  list (^(first rest) return rest))

(defineCPS isNil ^(list . return)
  list (^(first rest) return false) ^()
  return true)

#|
(defineCPS makeList ^ return
  return (^(first . cont)
           cont makeList ^(rest)
           cons first rest ^(list)
           return list)^(return)
  )

(defineCPS cons ^(first rest out)
  out first ^(out)
  rest out)

(defineCPS nil ^(out . return) return)

(defineCPS getFirst ^(list . return)
  list (^(first . rest) return first))

(defineCPS getRest ^(list . return)
  list (^(first . rest) return rest))

(defineCPS isNil ^(list . return)
  list (^(first . rest) return false)^()
  return true)
|#

;; (defineCPS getRest ^(list out)
;;  list (^(first . rest) rest out))

;;; 高階関数

(defineCPS reduce ^(f x list)
  list ^(list)
  if(isNil list) x
  (f (getFirst list) (reduce f x (getRest list))))
;;  ( reduce f x (getRest list)^(y)
;;    f (getFirst list) y ))

(defineCPS compose ^(f g x)
  g x ^(y)
  f y)

(defineCPS map ^(f list)
  reduce (compose cons f) nil list)
#|
(defineCPS map ^(f list . return)
  print("map 1 list=" list "\n")^()
  if(isNil list)(return nil)
  ( list ^(list)
    getFirst list ^(first)
    getRest list ^(rest)
    print("map 2 first=" first "\n")^()
    f first ^(first)
    cons first (map f rest) ^(list)
    return list ))
|#
