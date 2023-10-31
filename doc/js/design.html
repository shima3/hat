<h1>The Design of js-hat</h1>
The js-hat is a Hat interpreter written in JavaScript.

<h2>Data types</h2>
This interpreter uses the following data in JavaScript.
<dl>
<dt>タスク Task</dt>
<dd>実行中の処理を表すデータです。<br/>
次のプロパティを持ちます。<code>actor, call, stack</code></dd>
<dd>Actor、<a href="../index.html#function call">関数呼び出し</a>、ContStack からなります。</dd>
<dd>そのアクターは、このタスクを実行しているアクターです。</dd>
<dd>その関数呼び出しは、このタスクの手順を示します。</dd>
<dd>その ContStack は、その関数呼び出しから戻ったときに実行すべき継続を示します。</dd>
<dt><a href="../index.html#actor">アクター Actor</a></dt>
<dd>メールボックス、プログラム、PropList からなります。</dd>

<dt>ContStack (Continuation Stack) </dt>
<dd>継続を要素として持つ単一方向の連結リストです。</dd>
<dd>要素が0個の場合、null です。</dd>

<dt>メールボックス Mailbox</dt>
<dd>アクターが受け取ったメッセージのFIFOキューです。</dd>
      
<dt>プログラム Program</dt>
<dd>ファイル名と、そのファイルで定義された FuncList からなる組です。</dd>

<dt>FuncList (List of Functions)</dt>
<dd>関数の名前に対応する無名関数を記憶し、検索できる連想配列です。</dd>
<dd>ファイルから読み込まれた後はプログラムの実行中に変更できません。</dd>
      
<dt>PropList (List of Properties)</dt>
<dd>名前に対応する値を記憶し、検索できる連想配列です。</dd>
<dd>プログラムの実行中に変更できます。</dd>

<dt>構文木（Syntax Tree）</dt>
<dd>S式を構文解析した結果を木構造で表すデータです。</dd>
<dd>SList, SAtom, SString の３種のノードで構成されます。</dd>
<dd>各ノードはプロパティ type, content, start, end を持ちます。</dd>

<dd><dl>
<dt>SList (List of S-expression)</dt>
<dd>S式のリストを示すノードです。</dd>
<dd>type の値は "list" です。</dd>
<dd>content は構文木の配列です。</dd>
	  
<dt>SAtom (Atom of S-expression)</dt>
<dd>S式のアトムを示すノードです。</dd>
<dd>type の値は "atom" です。</dd>
<dd>content はアトムの名前を示す文字列です。</dd>
	  
<dt>SString (String of S-expression)</dt>
<dd>S式の文字列を示すノードです。</dd>
<dd>type の値は "string" です。</dd>
<dd>content は、前後のダブルクォートを含まず、エスケープシーケンスを変換済みの文字列です。</dd>
</dl></dd>

</dl>

<h2>Global variables</h2>
This interpreter uses the following global variables in JavaScript.
<dl>
<dt>TaskQ (Task Queue)</dt>
<dd>タスクが実行順に並んだ待ち行列です。</dd>
<dt></dt><dd></dd>
</dl>

<h2>Functions of JavaScript</h2>
This interpreter uses the following functions in JavaScript.
<dl>
<dt></dt>
<dd></dd>
<dt>execute(P, A)</dt>
<dd>プログラム P に文字列の配列 A を与えて実行します。</dd>
<dd>具体的には、P を持つアクターを生成し、そのアクターへメッセージ <code>(main A)</code> を送信します。</dd>
<dt>new Program(F)</dt>
<dd>ファイル名 F のファイルを読み、そこで定義された関数からなるプログラムを生成し、戻り値として返します。</dd>
<dt>new Actor(P)</dt>
<dd>プログラム P を持つアクターを生成し、戻り値として返します。</dd>
<dt>new Task(A, C, S)</dt>
<dd>アクター A、関数呼び出し C、ContStack S からなるタスクを生成し、戻り値として返します。</dd>
      
<dt>new ContStack(C, S)</dt>
<dd>継続 C を ContStack S の前に追加した ContStack を生成し、戻り値として返します。</dd>
<dt>parse(E)</dt>
<dd>S式 E を構文解析し、木構造の配列を戻り値として返します。</dd>
<dd><a href="https://github.com/anko/sexpr-plus">sexpr-plus</a> を使用しています。</dd>
<dt>stepTask(T)</dt>
<dd>タスク T を一段階実行し、戻り値として以下を返します。<ul>
<li>T が完了したならば true</li>
<li>T の処理が残っていれば false<br/>
この場合、残った処理は T に入っています。</li>
</ul></dd>
<dd>具体的には以下の手順を実行します。<ol>
<li>現在タスクを T に変更します。</li>
<li>T が持つアクターを A とおきます。</li>
<li>T が持つ関数呼び出しを C とおきます。</li>
<li>T が持つ ContStack を S とおきます。</li>
<li>A が持つプログラムの FuncList を FL とおきます。</li>
<li>A が持つ VarList を VL とおきます。</li>
<li>C の先頭の式を F とおきます。</li>
<li>C の先頭を除く残りの式からなる列を R とおきます。</li>
<li>F を VL で検索し、もし F が</li>
<ul>
<li>見つかれば、それに対応する式を F とおきます。</li>
<li>見つからなければ、次に進みます。</li>
</ul>
<li>F を FL で検索し、もし F が</li>
<ul>
<li>見つかれば、それに対応する無名関数を F とおきます。</li>
<li>見つからなければ、次に進みます。</li>
</ul>
<li>もし F が</li>
<ul>
<li>無名関数ならば、</li>
<ol>
<li>passArgs(F, R, S) を呼び出し、その戻り値を C とおきます。</li>
<li>もし C が
<ul>
<li>null ならば、戻り値として true を返します。</li>
<li>null でなければ、</li>
<ol>
<li>T の関数呼び出しを C に置き換えます。</li>
<li>戻り値として false を返します。</li>
</ol>
</ul>
</ol>
<li>関数呼び出しならば、</li>
<ol>
<li>T の関数呼び出しを F に置き換えます。</li>
<li>makeArgFunc(R) を呼び出し、その戻り値を S の先頭に追加します。</li>
<li>戻り値として false を返します。</li>
</ol>
<li>ContStack ならば</li>
<ol>
<li>F の先頭を除く残りを S とおきます。</li>
<li>T の ContStack を S に置き換えます。</li>
<li>makeFuncCall(F の先頭の継続, R) を呼び出し、その戻り値を C とおきます。</li>
<li>T の関数呼び出しを C に置き換えます。</li>
<li>戻り値として false を返します。</li>
</ol>
</ul>
</ol></dd>
<dt>passArgs(F, R, S)</dt>
<dd>無名関数 F の仮引数にリスト R を実引数として渡します。</dd>
<dd>R が継続の実引数を持つとき、それを ContStack S の先頭に追加した ContStack を継続の実引数として渡します。</dd>
<dd>R が継続の実引数を持たないとき、ContStack S を継続の実引数として渡します。</dd>
<dt>makeArgFunc(R)</dt>
<dd>引数として受け取った関数に R を引数として与える無名関数を作り、戻り値として返します。</dd>
<dd>具体的には、R の前に <code>^(F) F</code> を追加した式を返します。</dd>

<dt>makeFuncCall(F, R)</dt>
<dd>F を関数、R を実引数の列とする関数呼び出しを作り、戻り値として返します。</dd>

<dt>stepTaskQueue( )</dt>
<dd>TaskQ の先頭のタスクを一段階実行します。</dd>
<dd>具体的には以下の手順を実行します。<ol>
<li>TaskQ の先頭のタスクを取り出し、T とおきます。</li>
<li>T に従って以下を判定します。<ul>
<li>タスクを取り出せたならば、stepTask(T) を呼び出し、その戻り値に従って以下を判定します。<ul>
<li>T が完了したならば、この関数から戻ります。</li>
<li>そうでなければ、T を TaskQ に追加します。</li>
</ul></li>
<li>（TaskQ が空で）タスクを取り出せなければ、この関数から戻ります。</li>
</ul></li>
</ol></dd>

<dt>sendMessage(A, M)</dt>
<dd>アクター A へメッセージ M を送ります。</dd>
<dd>具体的には、以下の手順を実行します。<ol>
<li></li>
</ol></dd>
<dd>具体的には、A のメールボックスに M を追加します。</dd>

<dt>readyActor(A)</dt>
<dd>アクター A が Mailbox の次のメッセージの処理を始めます。</dd>
<dd>具体的には、以下の手順を実行します。<ol>
<li>Mailbox の先頭のメッセージを取り除きます。</li>
<li>もし Mailbox にメッセージが残っていれば、先頭のメッセージの処理を開始します。</li>
<li>残っていなければ、何もしません。</li>
</ol></dd>

<dt>getFirst(L)</dt>
<dd>SList L の先頭の要素を戻り値として返します。</dd>

<dt>getRest(L)</dt>
<dd>SList L の先頭を除く残りの SList を戻り値として返します。</dd>

<dt></dt>
<dd></dd>
</dl>

<h2>Functions of Hat</h2>
This interpreter supports the following functions in Hat.

<dl>
<dt>getProgram ^(p)</dt>
<dd>現在のアクターが持つプログラムを変数 p に渡します。</dd>
<dt>newActor p ^(a)</dt>
<dd>プログラム p を持つアクターを新たに生成し、変数 a に渡します。</dd>
<dt></dt><dd></dd>
</dl>

<h2>検討事項</h2>
<dl>
<dt>一つのアクターは複数のメッセージを並行処理するか？</dt>
<dd>並行処理する場合、競合状態が起こるという問題がある。</dd>
<dd>並行処理しない場合、デッドロックが生じるという問題がある。<br/>
例えば、一つのメッセージの処理中に、そのアクター自身または他のアクターへメッセージを送信し、返信を待つと生じる。</dd>
<dt>変数に値をどのように代入するか？</dt>
<dd>全ての変数を値に置き換えた式を生成する。</dd>
<dd>必要な変数のみ値に置き換えた式を生成する。</dd>
<dt></dt><dd></dd>
</dl>

<h2>References</h2>
<ul>
<li>MDN web docs<ul>
<li><a href="https://developer.mozilla.org/ja/docs/Web/API/XMLHttpRequest">XMLHttpRequest</a></li>
<li><a href="https://developer.mozilla.org/ja/docs/Web/API/Document/getElementsByTagName">Document.getElementsByTagName()</a></li>
</ul></li>
<li>Node.js入門<ul>
<li><a href="https://www.sejuku.net/blog/77966">requireの使い方とモジュールの作り方まとめ！</a></li>
<li><a href="https://www.sejuku.net/blog/75691">npmの使い方とパッケージ管理の方法まとめ！</a></li>
</ul></li>
<li><a href="https://javascript.programmer-reference.com/js-array-slice/">配列内の要素を範囲指定で取り出す</a> コピペで使える JavaScript逆引きリファレンス</li>
<li><a href="https://www.infoscoop.org/blogjp/2012/05/17/javascript%E3%81%AE%E3%83%87%E3%83%90%E3%83%83%E3%82%B0%E3%81%A7object%E3%81%AE%E4%B8%AD%E8%BA%AB%E3%82%92%E6%96%87%E5%AD%97%E5%88%97%E3%81%A8%E3%81%97%E3%81%A6%E5%B1%95%E9%96%8B%E3%81%99%E3%82%8B/">javascriptのデバッグでobjectの中身を文字列として展開する方法</a> infoScoop開発者ブログ</li>
<li><a href="https://www.sejuku.net/blog/31671">function(関数)の使い方、呼び出し・戻り値など総まとめ！</a>【JavaScript入門】</li>
<li><a href="https://qiita.com/butchi_y/items/d6024f81a9eda826fea0">Functionによるevalの代替</a>@butchi_y, Qiita</li>
<li><a href="https://www.ipentec.com/document/javascript-xmlhttprequest-multi-connect-problem">[JavaScript] XMLHttpRequestで複数のファイルにアクセスしたがレスポンスが1度しかない</a>iPentec</li>
<li><a href="https://jmatsuzaki.com/archives/16866">JavaScriptで配列やオブジェクトを比較して等しいかチェックする方法</a> jMatsuzaki</li>
<li><a href="http://www.ituore.com/entry/javascript-for">JavaScriptの色々なfor文｜for・for-each・for-in・for-of</a> いつ俺</li>
<li><a href="https://pyteyon.hatenablog.com/entry/2018/11/22/184751">JavaScript：同期 / 非同期な読み込みの注意点 - スクリプトの依存関係</a> mathnukoの雑記帳</li>
<li><a href="http://home.a00.itscom.net/hatada/js-tips/loadserverfile.html">Serverファイルの読み込み</a></li>
<li><a href="http://tacamy.hatenablog.com/entry/2016/10/16/182658">jQuery.ajax()の代替としてFetch APIをざっくり使ってみる</a> tacamy--log</li>
<li><a href="https://www.catch.jp/wiki/index.php?javascript_file">Javascriptでファイル読み込みについて調べてみた。</a> catch.jp-wiki</li>
<li><a href="https://qiita.com/DNA1980/items/11fdb7233fc288ac3502">Node.jsで、存在するはずのmoduleがrequireでエラーになることについて</a> @DNA1980, Qiita</li>
<li><a href="http://www.tohoho-web.com/js/start.htm">まずは始めてみよう</a></li>
<li><a href="https://github.com/anko/sexpr-plus">sexpr-plus</a> anko</li>
<li><a href="https://webbibouroku.com/Blog/Article/js-obj-has-property">オブジェクトのプロパティ判定</a></li>
<li><a href="https://techacademy.jp/magazine/5541">JavaScriptでsetTimeoutを使う方法【初心者向け】</a></li>
<li><a href="http://d.hatena.ne.jp/mindcat/20091018/1255889695">JavaScriptのsetIntervaｌ関数の意味を正確に理解するための１つの説明</a></li>
<li><a href="https://maku77.github.io/js/array/slice.html">配列から部分配列を取得する</a></li>
<!--
<li><a href=""></a></li>
-->
</ul>
