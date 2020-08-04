#|
関数型プログラミング言語 Hat のインタプリタ

入力の1行目はコマンドライン代わり
先頭　Hatのソースファイル名
2番目以降　コマンド引数

Hat のソースファイル .sch
util.sch ユーティリティ関数の定義
hello.sch 定番 Hello World のサンプルコード
4.no.sch 四天王問題のサンプルコード

Scheme のソースファイル .scm
schi.scm インタプリタ本体
wrapper.scm Scheme処理系依存を吸収するための関数群
|#
(add-load-path ".")
(load "wrapper.scm")
(let ((args (cons "schi.scm" (string-tokenize (read-line)))))
  (load (car args))
  (apply main-proc args))
