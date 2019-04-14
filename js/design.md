<!----- Conversion time: 1.414 seconds.


Using this Markdown file:

1. Cut and paste this output into your source file.
2. See the notes and action items below regarding this conversion run.
3. Check the rendered output (headings, lists, code blocks, tables) for proper
   formatting and use a linkchecker before you publish this page.

Conversion notes:

* Docs to Markdown version 1.0β17
* Sun Apr 14 2019 04:45:57 GMT-0700 (PDT)
* Source doc: https://docs.google.com/open?id=1xkKfu4NZlP6MVn5jYriGAZygmM4TgBfXN6PLrsldMIU
----->



# **The Design of js-hat**

This page describes the design of [js-hat](index.html) that is a Hat interpreter written in JavaScript.


## **Data types**

This interpreter uses the following data of JavaScript.


```
タスク Task
```



    実行中の処理を表すデータです。 \
次のプロパティを持ちます。actor, call, stack \
Actor、[関数呼び出し](http://localhost/nagisa/hat/index.html#function%20call)、ContStack からなります。 \
そのアクターは、このタスクを実行しているアクターです。 \
その関数呼び出しは、このタスクの手順を示します。 \
その ContStack は、その関数呼び出しから戻ったときに実行すべき継続を示します。


```
アクター Actor
```



    メールボックス、プログラム、PropList からなります。


```
ContStack (Continuation Stack)
```



    継続を要素として持つ単一方向の連結リストです。 \
要素が0個の場合、null です。


```
メールボックス Mailbox
```



    アクターが受け取ったメッセージのFIFOキューです。

プログラム `Program`


    ファイル名と、そのファイルで定義された FuncList からなる組です。

`FuncList` (List of Functions)


    関数の名前に対応する無名関数を記憶し、検索できる連想配列です。 \
ファイルから読み込まれた後はプログラムの実行中に変更できません。

`PropList `(List of Properties)


    名前に対応する値を記憶し、検索できる連想配列です。 \
プログラムの実行中に変更できます。

構文木（Syntax Tree）


    S式を構文解析した結果を木構造で表すデータです。 \
SList, SAtom, SString の３種のノードで構成されます。 \
各ノードはプロパティ type, content, start, end を持ちます。

`SList` (List of S-expression)


    S式のリストを示すノードです。 \
type の値は "list" です。 \
content は構文木の配列です。

`SAtom` (Atom of S-expression)


    S式のアトムを示すノードです。 \
type の値は "atom" です。 \
content はアトムの名前を示す文字列です。

`SString` (String of S-expression)


    S式の文字列を示すノードです。 \
type の値は "string" です。 \
content は、前後のダブルクォートを含まず、エスケープシーケンスを変換済みの文字列です。


## **Global variables**

This interpreter uses the following global variables in JavaScript.

`TaskQ` (Task Queue)


    タスクが実行順に並んだ待ち行列です。


## **Functions of JavaScript**

This interpreter uses the following functions in JavaScript.


```
execute(P, A)
```



    プログラム P に文字列の配列 A を与えて実行します。 \
具体的には、P を持つアクターを生成し、そのアクターへメッセージ` (main A)` を送信します。


```
new Program(F)
```



    ファイル名 F のファイルを読み、そこで定義された関数からなるプログラムを生成し、戻り値として返します。


```
new Actor(P)
```



    プログラム P を持つアクターを生成し、戻り値として返します。


```
new Task(A, C, S)
```



    アクター A、関数呼び出し C、ContStack S からなるタスクを生成し、戻り値として返します。


```
new ContStack(C, S)
```



    継続 C を ContStack S の前に追加した ContStack を生成し、戻り値として返します。


```
parse(E)
```



    S式 E を構文解析し、木構造の配列を戻り値として返します。


    [sexpr-plus](https://github.com/anko/sexpr-plus) を使用しています。


```
stepTask(T)
```



    タスク T を一段階実行し、戻り値として以下を返します。



*   T が完了したならば true
*   T の処理が残っていれば false \
この場合、残った処理は T に入っています。

    具体的には以下の手順を実行します。

1. 現在タスクを T に変更します。
2. T が持つアクターを A とおきます。
3. T が持つ関数呼び出しを C とおきます。
4. T が持つ ContStack を S とおきます。
5. A が持つプログラムの FuncList を FL とおきます。
6. A が持つ VarList を VL とおきます。
7. C の先頭の式を F とおきます。
8. C の先頭を除く残りの式からなる列を R とおきます。
9. F を VL で検索し、もし F が
    *   見つかれば、それに対応する式を F とおきます。
    *   見つからなければ、次に進みます。
10. F を FL で検索し、もし F が
    *   見つかれば、それに対応する無名関数を F とおきます。
    *   見つからなければ、次に進みます。
11. もし F が
    *   無名関数ならば、
        1. passArgs(F, R, S) を呼び出し、その戻り値を C とおきます。
        2. もし C が
            *   null ならば、戻り値として true を返します。
            *   null でなければ、
                1. T の関数呼び出しを C に置き換えます。
                2. 戻り値として false を返します。
    *   関数呼び出しならば、
        3. T の関数呼び出しを F に置き換えます。
        4. makeArgFunc(R) を呼び出し、その戻り値を S の先頭に追加します。
        5. 戻り値として false を返します。
    *   ContStack ならば
        6. F の先頭を除く残りを S とおきます。
        7. T の ContStack を S に置き換えます。
        8. makeFuncCall(F の先頭の継続, R) を呼び出し、その戻り値を C とおきます。
        9. T の関数呼び出しを C に置き換えます。
        10. 戻り値として false を返します。

                ```
passArgs(F, R, S)
```



    無名関数 F の仮引数にリスト R を実引数として渡します。


    R が継続の実引数を持つとき、それを ContStack S の先頭に追加した ContStack を継続の実引数として渡します。


    R が継続の実引数を持たないとき、ContStack S を継続の実引数として渡します。


    ```
makeArgFunc(R)
```



    引数として受け取った関数に R を引数として与える無名関数を作り、戻り値として返します。


    具体的には、R の前に` ^(F) F `を追加した式を返します。


    ```
makeFuncCall(F, R)
```



    F を関数、R を実引数の列とする関数呼び出しを作り、戻り値として返します。


    ```
stepTaskQueue( )
```



    TaskQ の先頭のタスクを一段階実行します。


    具体的には以下の手順を実行します。

1. TaskQ の先頭のタスクを取り出し、T とおきます。
2. T に従って以下を判定します。
    *   タスクを取り出せたならば、stepTask(T) を呼び出し、その戻り値に従って以下を判定します。
        *   T が完了したならば、この関数から戻ります。
        *   そうでなければ、T を TaskQ に追加します。
    *   （TaskQ が空で）タスクを取り出せなければ、この関数から戻ります。

            ```
sendMessage(A, M)
```



    アクター A へメッセージ M を送ります。


    具体的には、以下の手順を実行します。

1. 

    具体的には、A のメールボックスに M を追加します。


    ```
readyActor(A)
```



    アクター A が Mailbox の次のメッセージの処理を始めます。


    具体的には、以下の手順を実行します。

1. Mailbox の先頭のメッセージを取り除きます。
2. もし Mailbox にメッセージが残っていれば、先頭のメッセージの処理を開始します。
3. 残っていなければ、何もしません。

        ```
getFirst(L)
```



    SList L の先頭の要素を戻り値として返します。


    ```
getRest(L)
```



    SList L の先頭を除く残りの SList を戻り値として返します。



## **Functions of Hat**

This interpreter supports the following functions in Hat.


```
getProgram ^(p)
```



    現在のアクターが持つプログラムを変数 p に渡します。


```
newActor p ^(a)
```



    プログラム p を持つアクターを新たに生成し、変数 a に渡します。


## **検討事項**

_一つのアクターは複数のメッセージを並行処理するか？_


    並行処理する場合、競合状態が起こるという問題がある。 \
並行処理しない場合、デッドロックが生じるという問題がある。 \
例えば、一つのメッセージの処理中に、そのアクター自身または他のアクターへメッセージを送信し、返信を待つと生じる。

_変数に値をどのように代入するか？_


    全ての変数を値に置き換えた式を生成する。


    必要な変数のみ値に置き換えた式を生成する。


## **References**



*   MDN web docs
    *   [XMLHttpRequest](https://developer.mozilla.org/ja/docs/Web/API/XMLHttpRequest)
    *   [Document.getElementsByTagName()](https://developer.mozilla.org/ja/docs/Web/API/Document/getElementsByTagName)
*   Node.js入門
    *   [requireの使い方とモジュールの作り方まとめ！](https://www.sejuku.net/blog/77966)
    *   [npmの使い方とパッケージ管理の方法まとめ！](https://www.sejuku.net/blog/75691)
*   [配列内の要素を範囲指定で取り出す](https://javascript.programmer-reference.com/js-array-slice/) コピペで使える JavaScript逆引きリファレンス
*   [javascriptのデバッグでobjectの中身を文字列として展開する方法](https://www.infoscoop.org/blogjp/2012/05/17/javascript%E3%81%AE%E3%83%87%E3%83%90%E3%83%83%E3%82%B0%E3%81%A7object%E3%81%AE%E4%B8%AD%E8%BA%AB%E3%82%92%E6%96%87%E5%AD%97%E5%88%97%E3%81%A8%E3%81%97%E3%81%A6%E5%B1%95%E9%96%8B%E3%81%99%E3%82%8B/) infoScoop開発者ブログ
*   [function(関数)の使い方、呼び出し・戻り値など総まとめ！](https://www.sejuku.net/blog/31671)【JavaScript入門】
*   [Functionによるevalの代替](https://qiita.com/butchi_y/items/d6024f81a9eda826fea0)@butchi_y, Qiita
*   [[JavaScript] XMLHttpRequestで複数のファイルにアクセスしたがレスポンスが1度しかない](https://www.ipentec.com/document/javascript-xmlhttprequest-multi-connect-problem)iPentec
*   [JavaScriptで配列やオブジェクトを比較して等しいかチェックする方法](https://jmatsuzaki.com/archives/16866) jMatsuzaki
*   [JavaScriptの色々なfor文｜for・for-each・for-in・for-of](http://www.ituore.com/entry/javascript-for) いつ俺
*   [JavaScript：同期 / 非同期な読み込みの注意点 - スクリプトの依存関係](https://pyteyon.hatenablog.com/entry/2018/11/22/184751) mathnukoの雑記帳
*   [Serverファイルの読み込み](http://home.a00.itscom.net/hatada/js-tips/loadserverfile.html)
*   [jQuery.ajax()の代替としてFetch APIをざっくり使ってみる](http://tacamy.hatenablog.com/entry/2016/10/16/182658) tacamy--log
*   [Javascriptでファイル読み込みについて調べてみた。](https://www.catch.jp/wiki/index.php?javascript_file) catch.jp-wiki
*   [Node.jsで、存在するはずのmoduleがrequireでエラーになることについて](https://qiita.com/DNA1980/items/11fdb7233fc288ac3502) @DNA1980, Qiita
*   [まずは始めてみよう](http://www.tohoho-web.com/js/start.htm)
*   [sexpr-plus](https://github.com/anko/sexpr-plus) anko
*   [オブジェクトのプロパティ判定](https://webbibouroku.com/Blog/Article/js-obj-has-property)
*   [JavaScriptでsetTimeoutを使う方法【初心者向け】](https://techacademy.jp/magazine/5541)
*   [JavaScriptのsetIntervaｌ関数の意味を正確に理解するための１つの説明](http://d.hatena.ne.jp/mindcat/20091018/1255889695)
*   [配列から部分配列を取得する](https://maku77.github.io/js/array/slice.html)

<!-- Docs to Markdown version 1.0β17 -->
