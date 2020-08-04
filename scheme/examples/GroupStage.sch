#|
2018ロシアWC
グループH
P ポーランド
S セネガル
C コロンビア
J 日本
|#

(defineCPS + ^(a b) a ^(a) b ^(b . c)
  (lambda (A B)(+ A B)) a b . c)

(defineCPS plus ^(a b) a ^(a) b ^(b)
  (lambda (A B)(+ A B)) a b)

;; pに勝ち点３を与える。
(defineCPS win-lose ^(p q . c)
  + p 3 ^(p . c2)
  c p q . c2)

;; qに勝ち点３を与える。
(defineCPS lose-win ^(p q . c)
  + q 3 ^(q)
  c p q)

;; pとqに勝ち点１を与える。
(defineCPS draw ^(p q . c)
  + p 1 ^(p)
  + q 1 ^(q)
  c p q)

;; pが勝った場合、qが勝った場合、引き分けた場合について非決定的に返す。
(defineCPS match ^(p q . c)
  (^ c2 win-lose p q . c) ^()
  (^ c3 lose-win p q ^(p2 q2) c p2 q2 . c3) ^()
  (^ c3 draw p q ^(p2 q2) c p2 q2 . c3) . c )

(defineCPS #t ^(a b) a)
(defineCPS #f ^(a b) b)

(defineCPS < ^(a b) a ^(a) b ^(b)
  (lambda (A B)(< A B)) a b)

(defineCPS = ^(a b) a ^(a) b ^(b)
  (lambda (A B)(= A B)) a b)

( defineCPS print ^(list . return)
  ( lambda (list)
    (display (string-concatenate (map x->string list)))
    ) list ^(dummy)
  return )

(defineCPS isEmpty ^(list)
  (lambda (list)(null? list)) list)

(defineCPS getFirst ^(list)
  (lambda (list)(car list)) list)

(defineCPS getRest ^(list)
  (lambda (list)(cdr list)) list)

(defineCPS rank ^(list el)
  (isEmpty list) 11
  ( getRest list ^(rest)
    rank rest el ^(ranking)
    getFirst list ^(first)
    (< el first)(+ ranking 11)
    ( (= el first)(+ ranking 1)
      ranking ) ^(ranking)
    ranking ))

(defineCPS main ^(args)
  print("start\n")^()
  ( 
    lose-win 0 0 ^(C J)
    lose-win 0 0 ^(P S)
    ;; match J S ^(J S)
    draw J S ^(J S)
    lose-win P C ^(P C)
    match J P ^(J P)
    match S C ^(S C)
    rank (S C P) J ^(ranking)
    print("R" ranking " J" J " S" S " C" C " P" P "\n")
    )^()
  print("end\n"))

( defineCPS I2 ^(x y . c)
  print("I2 c=" c "\n")^()
  c x y )

( defineCPS ndf ^ (break . cont)
  ;; print("ndf cont=" cont "\n")^()
  I2 1 2 F.C cont ^()
  I2 3 4 F.C cont break )

( defineCPS test ^(args)
  I2 11 12 ^(p q . c2)
  print(p ", " q ", " c2 "\n")^()
  0 )

( defineCPS test2 ^(args)
  (^ break
    ndf break ^(p q . c)
    print(p ", " q ", " c "\n") . c )^()
  print("end\n") )

( defineCPS nop ^ c
  print("nop c=" c "\n") ^()
  c )

( defineCPS test3 ^(args . return)
  nop ^ c
  print("test3 2 c=" c "\n") . return )

