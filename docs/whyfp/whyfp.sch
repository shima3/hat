#|
Why Functional Programming Matters のサンプルコードを Hat 言語で実装するための関数群
|#

(defineCPS isObject ^(value)
  JavaScript "(function(v){return typeof v === 'object';})" value)

(defineCPS isAtom ^(value)
  JavaScript "(function(v){return v.isAtom && v.isAtom();})" value)

;;; 数列関係

(defineCPS emptySeq ^(out) out)

(defineCPS pushSeq ^(first rest out)
  out first ^(out)
  rest out)

(defineCPS popSeq ^(seq ifEmpty . return)
  seq (^(first . rest) return first rest)^(dummy)
  ifEmpty ^()
  print("Warning: popSeq")^()
  exit 1)

;; (defineCPS seq_empty emptySeq)
;; (defineCPS seq_empty ^(out) out)

;;; リスト関係

#|
(defineCPS cons ^(first rest get)
  list_push rest first)

(defineCPS nil ())

(defineCPS getFirst list_get_first)

(defineCPS getRest list_get_rest)

(defineCPS isNil list_empty?)

(defineCPS makeList I)
|#

#|
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

;; makeList 1 2 3 ... ^(dummy list)
(defineCPS makeList ^ cont
  cont
  (^(first . cont2)
    cont2 makeList ^(dummy rest . return)
    cons first rest ^(list)
    return dummy list)^(return2)
  return2 nil)
|#

#|
(defineCPS cons ^(first rest)
  print("cons first=" first "\n")^()
  ;; first ^(first)
  pushSeq first rest)
|#

(defineCPS nil emptySeq)

(defineCPS getFirst ^(list . return)
  popSeq list
  ( print("Error: getFirst")^()
    exit 1 )^(first rest)
  if(isAtom first)(I first) first ^(first)
  ;; first ^(first)
  return first)

(defineCPS getRest ^(list . return)
  popSeq list
  ( print("Error: getRest")^()
    exit 1 )^(first rest)
  return rest)

(defineCPS isNil ^(list . return)
  popSeq list (return true)^(first rest)
  return false)

#|
(defineCPS cons ^(first rest)
  JavaScript "(function(f, r){return { first: f, rest: r, evaluated: false };})" first rest ^(cell)
  (^(out)
    JavaScript "(function(c){ return c.first; })" cell ^(first)
    JavaScript "(function(c){ return c.rest; })" cell ^(rest)
    JavaScript "(function(c){ return c.evaluated; })" cell ^(evaluated)
    if evaluated
    ( out first ^(out)
      rest out )
    ( first ^(first)
      rest ^(rest)
      JavaScript "(function(c, f, r){ c.first=f; c.rest=r; c.evaluated=true; })" cell first rest ^(dummy)
      out first ^(out)
      rest out )
))
|#

(defineCPS list2string ^(list)
  if(list_empty? list) ""
  ( list_get_first list ^(first)
    list_get_rest list ^(rest)
    JavaScript "HatInterpreter.valueString" first ^(first)
    list2string rest ^(rest)
    + first rest))

(defineCPS log ^(list . return)
  list2string list ^(str)
  JavaScript "(function(s){ console.log(s); })" str ^(dummy)
  return)

#|
https://ja.wikipedia.org/wiki/%E3%83%A1%E3%83%A2%E5%8C%96#:~:text=%EF%BC%88Wikipedia%EF%BC%89%E3%80%8F-,%E3%83%A1%E3%83%A2%E5%8C%96%EF%BC%88%E8%8B%B1%3A%20memoization%EF%BC%89,-%E3%81%A8%E3%81%AF%E3%80%81%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%A0&
メモ化 - Wikipedia
メモ化（英: memoization）
|#
(defineCPS memoize ^(exp . return)
  JavaScript "(function(){ return [ null ]; })" ^(memo)
  return
  (if(JavaScript "(function(m){ return m[0]==null; })" memo)
    ( exp ^(value)
      JavaScript "(function(m, v){ m[0]=v; })" memo value ^(dummy)
      value )
    ( JavaScript "(function(m){ return m[0]; })" memo )
    ))

(defineCPS cons ^(first rest)
  memoize first ^(first)
  memoize rest ^(rest)
  pushSeq first rest)

;;; 高階関数

(defineCPS reduce ^(f x list)
  list ^(list)
  if(isNil list) x
  (f (getFirst list) (reduce f x (getRest list))))

#|
(defineCPS reduce ^(f x seq . return)
  popSeq seq (return x) ^(first rest)
  ;;  f first (reduce f x rest) ^(result)
  print("reduce 1\n")^()
  rest ^(rest)
  reduce f x rest ^(rest)
  f first rest ^(result)
  return result)
|#

#|
(defineCPS reduce ^(f x list)
  list ^(list)
  if(isNil list) x
  ( list
    (^(first . rest)
      f first (reduce f x rest)
      )))
|#

;;    getRest list ^(rest)
;;    f first (reduce f x rest)
;;  (f (getFirst list) (reduce f x (getRest list))))

#|
  ( getFirst list ^(first)
    getRest list ^(rest)
    f first (reduce f x rest)
))
|#
;;  ( reduce f x (getRest list)^(y)
;;    f (getFirst list) y ))

#|
(defineCPS map ^(f seq . return)
  print("map 1\n")^()
  popSeq seq (return nil)^(first rest)
  ;; cons (f first) (map f rest))
  print("map 2\n")^()
  cons (f first) (map f rest))
  ;; map f rest ^(rest)
  ;; cons (f first) rest)
|#

#|
(defineCPS map ^(f list out . return)
  list
  (^(first . rest)
    ;; f first ^(first)
    ;; out first ^(out)
    out (f first)^(out)
    map f rest out . return
    )^(dummy)
  out . return)
|#

#|
;; print("map 1\n")^()
  list ^(list)
  if(isNil list)(return nil)
  ( getFirst list ^(first)
    getRest list ^(rest)
    ;; print("map 2 first=" first "\n")^()
    f first ^(first)
    ;; cons first (map f rest)^(list)
    map f rest ^(rest)
    cons first rest ^(list)
    return list
    ))
|#

(defineCPS makePair ^(first second out)
  out first second)

(defineCPS splitPair ^(pair . return)
  pair (^(first rest) return first rest))

(defineCPS arrayLength ^(array)
  JavaScript "(function(a){return a.length;})" array)

(defineCPS arrayGet ^(array index)
  JavaScript "(function(a, i){return a[i];})" array index)

(defineCPS arraySubList ^(array start end out)
  start ^(start) end ^(end)
  if(< start end)
  ( arrayGet array start ^(first) out first ^(out)
    arraySubList (+ start 1) end out)
  nil)

(defineCPS arrayList ^(array)
  arraySubList array 0 (arrayLength array))

(defineCPS initPosition ^(board turn)
  JavaScript "initPosition" board turn)

(defineCPS printPosition ^(pos)
  JavaScript "getBoard" pos ^(board)
  JavaScript "getMark" pos ^(turn)
  print(board "\nTurn: " turn "\n"))

#|
(defineCPS printPosSeq ^(seq . return)
  popSeq seq return ^(first rest)
  ;; first ^(first)
  if(isAtom first)(I first) first ^(first)
  printPosition first ^()
  printPosSeq rest)
|#

#|
(defineCPS moves ^(pos)
  JavaScript "(function(p){
    let list1=moves(p.board, p.turn);
    let list2=[];
    let next=!p.turn;
    for(let i=0; i<list1.length; ++i)
      list2.push({
        pos: list1[i],
        turn: next,
        subst: function(f){return this;}
      });
    return list2;
  })" board)
|#
(defineCPS quoteSeq ^(seq out)
  popSeq seq out ^(first rest)
  out (memoize (I first)) ^(out)
  rest out)

(defineCPS moves ^(pos . return)
  JavaScript "moves" pos ^(seq)
  return seq)

;; whyfp p.5 add
(defineCPS add ^(x y)
  + x y)

;; whyfp p.5 append
(defineCPS append ^(a b)
  reduce cons b a)

#|
whyfp p.6 function composition
Hat言語ではピリオドが別の意味になるので、f . g の代わりに compose f g とする。
|#
(defineCPS compose ^(f g x) f (g x))

(defineCPS map ^(f list)
  reduce (compose cons f) nil list)

;; whyfp p.7 node
(defineCPS node ^(label subtrees get)
  get label subtrees)

(defineCPS getNodeLabel ^(tree)
  tree (^(pos subtrees . return) return pos))

(defineCPS getSubtrees ^(tree)
  tree (^(pos subtrees . return) return subtrees))

;; whyfp p.7 の redtree
(defineCPS redtree ^(f g a tree)
  getNodeLabel tree ^(label)
  getSubtrees tree ^(subtrees)
  f label (redtrees f g a subtrees))

;; whyfp p.7 の redtree'
;; Hat言語では ' を関数名に使えないので redtrees とする。
(defineCPS redtrees ^(f g a trees)
  if(isNil trees) a
  ( getFirst trees ^(first)
    getRest trees ^(rest)
    g (redtree f g a first)(redtrees f g a rest)
    ))

;; whyfp p.8 の maptree
(defineCPS maptree ^(f)
  redtree (compose node f) cons nil)

;; whyfp p.16 の reptree と gametree
;; Mirandaとほぼ同じ。
(defineCPS reptree ^(f a)
  node a (map (reptree f) (f a)))

(defineCPS gametree ^(pos)
  reptree moves pos)

;; whyfp p.16 の static
;; 盤面posを評価し、コンピュータに有利（ユーザに不利）なほど大きい（負の数も含む）数値を返す。
;; Mirandaのコードは示されていない。
(defineCPS static ^(pos . return)
  JavaScript "staticEvaluation" pos ^(num)
  return num)

;; whyfp p.18
;; max: 数値リストの最大値を返す。
;; min: 数値リストの最小値を返す。
;; Mirandaのコードは示されていない。
(defineCPS max ^(nums)
  getFirst nums ^(first)
  getRest nums ^(rest)
  if(isNil rest) first
  ( max rest ^(maxrest)
    if(> first maxrest) first maxrest))

(defineCPS min ^(nums)
  getFirst nums ^(first)
  getRest nums ^(rest)
  if(isNil rest) first
  ( min rest ^(minrest)
    if(> first minrest) first minrest))

;; whyfp p.18 の maximise と minimise
;; Hat言語にはパターンマッチがないので、treeからラベルと部分木を取得し、条件分岐している。
(defineCPS maximise ^(tree)
  getSubtrees tree ^(sub)
  if(isNil sub)(getNodeLabel tree)
  (max (map minimise sub)))

(defineCPS minimise ^(tree)
  getSubtrees tree ^(sub)
  if(isNil sub)(getNodeLabel tree)
  (min (map maximise sub)))

;; whyfp p.18 の３段落目と４段落目の間の evaluate
;; 分かりやすくするため、composeを使わずに定義した。
(defineCPS evaluate ^(pos)
  maximise (maptree static (gametree pos)))
