#|
Hat言語のサンプルコード集
それぞれの入力例に従って実行してください。
|#
( include "util.sch" )

#|
コマンド引数の出力
入力例
3ple.sch 7 3
|#
( defineCPS main ^(args)
  print(args "\n") )

#|
リストの多値返却
入力例
-e main2 3ple.sch 7 3
|#
( defineCPS main2 ^(args)
  print("Start\n")^()
  fix( ^(loop seq . break)
       if(seqEnd? seq) break ^()
       seqGet seq ^(a rest)
       print(a "\n")^()
       loop rest
       )(listSeq args)^()
   print("End\n")
)

#|
文字列から数値への変換
入力例
-e main3 3ple.sch 7 3
|#
( defineCPS main3 ^(args)
  listToValues args ^(a)
  stringToNumber a ^(a)
  stringToNumber b ^(b)
  gcd a b ^(c)
  print(c "\n") )

( defineCPS main6 ^(args)
  print("Start\n")^()
  fix( ^(loop S sum . break) sum ^(sum)
       ;; debugPrint "break=" break ^()
       ;; debugPrint "sum=" sum ^()
       seqGet S ^(v s)
       ;; debugPrint "s=" s ^()
       seqEnd? s ^(flag)
       ;; debugPrint "flag=" flag ^()
       if flag (break sum)^()
       ;; debugPrint "v=" v ^()
       loop s (+ sum v)
       )(filterSeq
            stringToNumber
            (listSeq args)) 0 ^(sum)
        print("Sum=" sum "\n")^()
        print("End\n")
)

#|
多値返却（複数の戻り値）の例
商と余りを求める。
-e main4 3ple.sch
|#
( defineCPS main4 ^(args)
  listToValues args ^(a b)
  stringToNumber a ^(a)
  stringToNumber b ^(b)
  divMod a b ^(d m)
  print(d " ... " m "\n") )

#|
多値を一つずつ取り出す例
|#

( defineCPS main5 ^(args)
  listToValues args ^(a b)
  stringToNumber a ^(a)
  stringToNumber b ^(b)
  divMod a b ^(d . r)
  seqGet r ^(m)
  print(d " ... " m "\n") )
