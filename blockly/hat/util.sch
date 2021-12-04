#|
ユーティリティ関数群
|#

;; ハット言語純関数（pure functions）
(include "hat.sch")

#| 共通関数（common functions）
純関数ではないが、ラッパー関数を用いることで処理系に依存せずに定義できる。
|#

;; リスト

(defineCPS list_get_second ^(list)
  list_get_rest list ^(rest)
  list_get_first rest)

(defineCPS list_pop ^(list . return)
  list_get_first list ^(first)
  list_get_rest list ^(rest)
  return rest first)

(defineCPS list_append ^(list1 list2 . return)
  if(list_empty? list1)(return list2)
  ( list_get_first list1 ^(first)
    list_get_rest list1 ^(rest)
    list_append rest list2 ^(rest2)
    list_push rest2 first ^(list3)
    return list3 ) )

;; 継続と限定継続

(defineCPS call/cc ^(exp . return)
  exp return . end)

(defineCPS abort ^(exp) exp ^(v)
  get meta_continuation ^(mc)
  mc v)

(defineCPS reset ^(exp . return)
  if(property? meta_continuation)
  (get meta_continuation)
  (^(v) print("error\n"))^(mc)
  set meta_continuation
  (^(v)
    set meta_continuation mc ^()
    return v)^()
  abort exp)

(defineCPS shift ^(f . return)
  (^(v) reset(return v))^(k)
  abort(f k))

;; ラッパー関数（wrapper functions）
(include "javascript.sch")
