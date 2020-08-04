#|
サンプルコード集
|#
(include "util.sch")

#|
定番 hello, world
上のCommand:の右の枠にsample1と入力し、Terminal:の右のRunボタンを押して実行してください。
Terminal:の下の枠内に
hello,
 world
と出力します。

Commandのsample1は関数の名前です。
下記のdefineCPSで関数sample1を定義しています。
print関数で文字列を出力します。
ダブルクォートで挟まれた部分が文字列です。
文字列中に改行コード\nがあると改行します。
改行コードがなければ、そのまま右に続けて出力します。

"hello,\n"の改行コードを削除してから、もう一度、Runボタンを押してみてください。
hello, world
と出力します。
もし書き換えておかしくなった場合、リロードすれば元に戻ります。

print関数の行末の^()は次の行が別の関数呼び出しであることを意味します。
これがないと引数が続いているとみなされ、正しく実行できません。
exit関数でプログラムを終了します。
引数が0のときは正常終了、0以外のときは異常終了を意味します。
|#
(defineCPS sample1 ^()
  print("hello,\n")^()
  print(" world\n")^()
  exit 0)

#|
四則演算と数値出力
Commandにsample2と入力し、実行してください。
2つの数値3, 2の加減乗除を出力します。

下記のdefineCPSで関数sample2を定義しています。
^(変数 ...)は変数に値を渡すことを意味します。
3 2 ^(a b)は数値3を変数aに渡し、数値2を変数bに渡します。
a + b ^(c)はaとbの和を変数cに渡し、- * / についても同様です。
C言語とは異なり、整数同士の除算 / でも実数になります。

変数、数値、演算子は空白で区切る必要があります。
カッコの前後は空白で区切る必要はありません。

printの後のカッコ内に変数と文字列を並べると連結して出力します。
変数や文字列の間にカンマなどは入れてはいけません。
3や2の数値を適当に書き換えて実行し、出力に反映されることを確認してください。
|#
(defineCPS sample2 ^()
  3 2 ^(a b)
  a + b ^(c)
  a - b ^(d)
  a * b ^(e)
  a / b ^(f)
  print(a "+" b "=" c "\n")^()
  print(a "-" b "=" d "\n")^()
  print(a "*" b "=" e "\n")^()
  print(a "/" b "=" f "\n")^()
  exit 0)

#|
比較演算子と選択処理
Commandにsample3と入力し、実行してください。
xと0との大小関係を出力します。

比較演算子として <, >, =, <>, <=, >= が使えます。
等号 = と不等号 <> がC言語と異なります。

if文は3つの引数をとり、第1引数が真のときは第2引数を実行し、第1引数が偽のときは第3引数を実行します。
実行すべき処理がない場合は nop とします。
unless文は2つの引数をとり、第1引数が真のときは何もせず、偽のときは第2引数を実行します。

-1を別の値に書き換えて実行し、出力が正しいか確認してください。
|#
(defineCPS sample3 ^()
  -1 ^(x)
  if(x < 0)(print("0より小さい\n"))(print("0以上\n"))^()
  if(x > 0)(print("0より大きい\n"))(print("0以下\n"))^()
  if(x = 0)(print("0と等しい\n")) nop ^()
  if(x <> 0)(print("0と異なる\n")) nop ^()
  unless(x <= 0)(print("0以下ではない\n")) ^()
  unless(x >= 0)(print("0以上ではない\n")) ^()
  exit 0)

#|
関数定義と関数呼び出し

defineCPSを使って関数を定義することができます。

|#

(defineCPS square ^(x)
  x * x)

#|
コマンド引数の例
Commandにsample2 na giと入力してRunボタンを押して実行してください。
ただし、sample2とnaとgiの間に空白を入れてください。
Terminalにgi, naとカンマで区切って出力します。

Commandの先頭のsample2は関数名、その後のnaやgiなどはコマンド引数です。
naやgiを他の適当な文字列に置き換えて実行し、出力に反映されることを確認してください。

下記のdefineCPSで関数sample2を定義しています。

のように複数の変数を並べると複数の引数を一度に取得できます。
|#
(defineCPS sampleX ^(a1 a2)
  print(a2 ", " a1 "\n")^()
  exit 0)

#|
リストの多値返却
1つ目の引数をa、2つ目の引数をbに渡し、出力します。
上の Command: の右の枠に sample3 1 2 と入力し、Run ボタンを押すと実行できます。
|#
(defineCPS sampleY ^(args . return)
  print("aho\n")^()
  list2values args ^ rest
  print(rest)^()
#|
  print(a "\n") ^()
  print(b "\n") ^()
  print(c "\n") ^()
  print(rest "\n")^()
|#
  return)

#|
コマンド引数の例

上の Command: の右の枠に sample7 1 2 3 da と入力し、Run ボタンを押すと実行できます。
|#
(defineCPS sample7 ^(args . return)
  print(args "\n")^()
  return)

#|
多値返却（複数の戻り値）の例
5を2で割った商dと余りmを求めて表示します。
上の Command: の右の枠に sample6 と入力し、Run ボタンを押すと実行できます。
|#
(defineCPS sample6 ^(args . return)
  div_mod 5 2 ^(d m)
  print(d " ... " m "\n")^()
  return)

#|
文字列から数値への変換と四則演算
2つの引数と加減乗除を出力します。
上の Command: の右の枠に sample3 1 2 と入力し、Run ボタンを押すと実行できます。
|#
(defineCPS sample4 ^(args . return)
  list2values args ^(a b)
  print(a ", " b "\n")^( )
  string2number a ^(a)
  string2number b ^(b)
  + a b ^(c)
  - a b ^(d)
  * a b ^(e)
  div_mod a b ^(f g)
  print(a "+" b "=" c "\n")^()
  print(a "-" b "=" d "\n")^()
  print(a "*" b "=" e "\n")^()
  print(a "/" b "=" f " ... " g "\n")^()
  return)
