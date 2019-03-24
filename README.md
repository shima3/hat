# The Hat Programming Language

Hat is a programming language that supports functional programming, lambda calculus, continuation passing style, and the actor model.

## Terms
<dl>
<dt>Functional programming</dt><dd>A programming paradigm that treats computation as the evaluation of mathematical functions.</dd>
<dt>Lambda calculus</dt><dd>A formal system in mathematical logic for expressing computation based on function abstraction and application using variable binding and substitution.</dd>
<dt>Continuation Passing Style (CPS)</dt><dd>A style of programming in which control is passed explicitly in the form of a continuation.</dd>
<dt>Actor model</dt><dd>A mathematical model of concurrent computation that treats "actors" as the universal primitives of concurrent computation.</dd>
</dl>
<!-- <dt>Variable</dt><dd>A storage location paired with an associated symbolic name, which contains quantity of information referred to as a value.</dd>
<dt>Bound variable</dt><dd></dd>
<dt>Free variable</dt><dd></dd>
<!-- dt></dt><dd></dd>
-->

## Informal Description
この言語では次の形式で関数を定義します。

    (define 関数名 無名関数)

<dl>
<dt>関数</dt>
<dd>0個以上の通常の引数と一つの継続の引数をとり、その継続に戻り値を渡す式です。</dd>
<dt>関数名</dt>
<dd>一つ以上の英数字（大文字、小文字、数字）からなる文字列です。</dd>
<dt>無名関数</dt>
<dd>ハット、ヘッダ、ボディからなる式です。</dd>
<dd>名前を付けずに関数の処理を定義します。</dd>
<dd><dl>
<dt>ハット（Hat）</dt>
<dd>一つの記号<code>^</code>です。</dd>
<dd>無名関数の先頭を示します。</dd>
<dt>ヘッダ（Header）</dt>
<dd>0個以上の変数名が空白で区切られ、丸括弧で囲まれた列です。</dd>
<dd>無名関数の仮引数を示します。</dd>
<dt>ボディ（Body）</dt>
<dd>一つの関数呼び出しです。</dd>
<dd>無名関数が呼び出されたときに実行する処理を示します。</dd>
</dl></dd>
<dt>関数呼び出し</dt>
<dd>一つ以上の式からなる列です。</dd>
<dd>先頭の式の値を関数とし、2つ目以降の式を実引数として関数の処理を実行することを示します。</dd>
<dt>式の値</dt>
<dd>式が丸括弧で囲まれた無名関数ならば、その値はその無名関数そのものです。</dd>
<dd>式が関数の名ならば、その値はdefineで定義された無名関数です。</dd>    
<dd>式が丸括弧で囲まれた関数呼び出しならば、その値はその関数呼び出しの戻り値です。</dd>
<dt></dt>
<dd></dd>
</dl>
