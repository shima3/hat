#|
Hat言語のみで定義された関数群
これらの関数は処理系に依存せず、異なる処理系でも利用できる。
|#

( defineCPS fix ^(f) f (fix f) )

( defineCPS true ^(x y . return)
  return x )

( defineCPS false ^(x y . return)
  return y )

(defineCPS and ^(p q . return)
  p q false ^(r)
  return r)

(defineCPS or ^(p q . return)
  p true q ^(r)
  return r)

( defineCPS not ^(condition then else)
  condition else then )

( defineCPS nop ^ return return )

(defineCPS if ^(condition then else)
  condition then else ^(action)
  action)

( defineCPS unless ^(condition action . return)
  condition return action ^(action)
  action )

( defineCPS gcd ^(a b . return) a ^(a) b ^(b)
  if (= b 0) (return a) ^()
  gcd b (mod a b) . return )

( defineCPS I ^(x . r) r x)

#| 数列関連
与えられた関数に０個以上の項を渡す関数を数列という。
項は数値に限らず任意のデータである。
|#

#|
空列
|#
(defineCPS seq_empty ^(R . return)
  return true)

#|
seq_empty? seq ^(flag)
数列seqが空ならばflagは真 true、
そうでなければflagは偽 false
|#
(defineCPS seq_empty? ^(seq . return)
  seq (return false). return)

#|
seq_get_ex seq ex ^(first rest)
数列seqの先頭firstと残りの数列restを返す。
ただし、seqが空数列の場合、exを呼び出す。
|#
(defineCPS seq_get_ex ^(seq ex . return)
  seq (^(first . rest)
	return first rest)^()
  ex)

#|
seq_get seq ^(first rest)
数列seqの先頭firstと残りの数列restを返す。
ただし、seqが空数列の場合、エラーを出力し、終了する。
|#
(defineCPS seq_get ^(seq)
  seq_get_ex seq (print("Error: seq_get empty\n")^() exit 1))

(defineCPS seq_infinite ^(x r)
  r x ^(r)
  seq_infinite x r)

;; ---------------------------

( defineCPS filterSeq ^(filter seq r)
  fix( ^(loop S R . c)
       seqGet S ^(v s)
       if(seqEnd? s)(c seqEnd)^()
       filter v ^(V)
       R V ^(r . c)
       loop s r . c
       ) seq r )

( defineCPS portSeq ^(end port r)
  fix
  ( ^(loop R . C)
    portRead port ^($1)
    if(eof? $1)(end . C)^()
    R $1 ^(nextR . cont)
    loop nextR . cont
    ) r
  )

( defineCPS portSeqClose ^(port action . return)
  portSeq (^(r) debugPrint "r=" r ^() portClose port)^(seq)
  action seq ^(result)
  portClose port ^()
  return result )

( defineCPS seqReverseList ^(seq tail . return)
  seqGetEx (return tail) seq ^(first rest)
  makePair first tail ^(list)
  seqReverseList rest list . return )

#|
数列seqの項を返す。
seqGetCont seq ^(a1 a2 ... an . rest)
  a1, a2, ..., an: 先頭のn項
  rest: 残りの項からなる数列
のように一度に複数の項を取り出せる。
ただし、これ以降、継続の実引数を省略するとrestになる。
このため、呼び出し元に戻れない場合がある。
（戻れる場合もある。）
以下のように括弧内で継続を保存してから、この関数を呼び出し、
保存した継続を呼び出して括弧内から脱出する方法がある。
( ^ break
  ...
  seqGetCont seq ^(a1 a2 . rest)
  ...
  . break )
|#
( defineCPS seqGetCont ^(seq . return)
  return . seq )

( defineCPS seqEnd ^(a) seqEnd )

#|
seqGetEx ex seq ^(first rest)
  ex: seqが空のとき実行する処理
  seq: 元の数列
  first: 先頭の項
  rest: 残りの項からなる数列
seqが空ならばexを実行し、空でなければfirstとrestを返す。
|#
( defineCPS seqGetEx ^(ex seq . return)
  seq ( ^(V . S) return V S ) ^(seqend) ex )

#|
数列seqの項を返す。
seqGet seq ^(a rest)
のように一度に一つの項しか取り出せない。
rest: 残りの項からなる数列
省略時の継続は元のままなので、通常の関数と同様に使える。
|#
( defineCPS seqGet ^(seq . return)
;;  seq( ^(V . S) return V S ) )
  seq( ^(V . S) return V S )^(seqend)
  return seqEnd seqEnd )

( defineCPS seqEnd? ^(seq . return)
  ( lambda(S)
    ( if(pair? S)
      ( case (car S)
;;        ([F.C] (cons 'seqEnd? (list (car (cdr S)))))
        ([^] (eq? (car (cdr (cdr S))) 'seqEnd))
        (else false)
        )
    (eq? S 'seqEnd) )
) seq )

( defineCPS readLineSeq ^(R . C)
  readLine ^(line)
  if(eof? line)(C endSeq)^()
  R line ^(nextR . nextC)
  readLineSeq nextR . nextC
)

#|
数列の各項間に二項演算を適用した結果を返す。
seq: 数列
f: 二項演算
v0: 初項
つまり、seqを a1, a2, ... とすると
((...(f (f v0 a1) a2)...))
の結果を返す。
|#
( defineCPS seqReduce ^(seq f v0 . return)
  seqGetEx (return v0) seq ^(a1 rest)
  f v0 a1 ^(v1)
  seqReduce rest f v1 . return )

(defineCPS abs ^(x) x ^(x)
  if(< x 0)(- 0 x) x)

(defineCPS sgn ^(x) x ^(x)
  if(< x 0) -1
  (if(> x 0) 1 0))
