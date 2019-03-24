/*
  デバッグ用
*/
function log(tag, obj){
    console.log(tag+JSON.stringify(obj));
}

/*
  Var: 変数
  Abs: 関数抽出
  App: 関数適用
  Exp: Var または Abs または App
  DfCnt: 省略時継続
 */

/*
  Appを一段階計算する。
function stepApp(
    app, // App
    dfcnt // DfCnt
){
    
}
var a=parse("(a)");
console.log("2: a[0].type="+a[0].type);

*/

/*
  アクターを生成する。
  script: スクリプトで定義されたアクターの振る舞い
 */
function Actor(script){
    this.mailbox=[ ];
    this.script=script;
    this.behavior={ };
    this.nextBehavior={ };
    // 振る舞いの変更
    this.behavior=Object.assign(this.behavior, this.nextBehavior);
    this.nextBehavior={ };
}

function loadHatFile(fileName){
    var script={ loading: 1 };
    loadFile(fileName, function(text){
	readHatCode(text, script);
    });
}

function readHatCode(code, script){
    console.log("loadHatText 1: code="+code);
    for(var exp of parse(code)){
	var first=exp.content[0];
	console.log("loadHatText 2: first="+JSON.stringify(first));
	var second=exp.content[1];
	console.log("loadHatText 3: second="+JSON.stringify(second));
	switch(first.content){
	case "defineCPS":
	    var rest=exp.content.slice(2);
	    // console.log("8: rest="+JSON.stringify(rest));
	    script[second.content]=rest;
	    break;
	case "include":
	    ++script.loading;
	    loadFile(second.content, function(text){
		readHatCode(text, script);
	    });
	    break;
	}
    }
    --script.loading;
}

function loadFile(fileName, callback){
    var httpObj=new XMLHttpRequest( );
    httpObj.onreadystatechange=function( ){
	if ((httpObj.readyState==4)&&(httpObj.status==200)){
	    callback(httpObj.responseText);
	    // callback(httpObj.responseURL);
	}
    }
    httpObj.open('GET',fileName+"?"+(new Date()).getTime(),true);
    // ?以降はキャッシュされたファイルではなく、毎回読み込むためのもの
    // httpObj.send(null);
    httpObj.send( );
}
