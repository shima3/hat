#| スタック関連
要素の集まりとして機能し，以下の2つの操作を持つ抽象データ型をスタックという。
push: 要素を追加する。
pop: 要素を削除する。
2020/8/4 作成開始
|#

(defineCPS stack_end ^ R
  R ^(F . C)
  C)

#; (defineCPS stack_end ^(F . C) C)

(defineCPS stack_empty ^(S . R)
  S ^ C
  C (R false)^()
  R true)

(defineCPS stack_push ^(S E . R)
  R (^ C C E . S))

(defineCPS stack_pop ^(S . R)
  S ^(F . C)
  R F C)

(defineCPS stack_print ^(S . R)
  if(stack_empty S) R ^()
  stack_pop S ^(E S2)
  print(E "\n")^()
  stack_print S2)
