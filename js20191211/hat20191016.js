/*
  Hat言語のスクリプトpathで定義された関数mainに引数argsを与えて実行する。
  path: スクリプトのパス
  command: コマンド
*/
function runHat(path, command){
    var caller=__STACK__[1];
    var source=Source(caller.getFileName( ), caller.getLineNumber( ));
    var a=command.split(/\s/);
    var fun=Var(a[0], source), args=[ ];
    for(var i=1, n=a.length; i<n; ++i)
	args.push(Str(a[i], source));
    var list=List(args, 0, null, null, source);
    console.log(args);
    Actor(getScript(path)).start(fun, list);
}

/** デバッグ用 **/

/* ログ出力 */
function log(tag, obj){
    console.log(tag+JSON.stringify(obj));
}

Object.defineProperty(window, '__STACK__', {
    get: function(){
        let origin = Error.prepareStackTrace;
        Error.prepareStackTrace = function(_, stack){ return stack; };
        let err = new Error;
        Error.captureStackTrace(err, arguments.callee);
        let stack = err.stack;
        Error.prepareStackTrace = origin;
        return stack;
    }
});

Object.defineProperty(window, '__FILE__', {
    get: function(){
        let filename = __STACK__[1].getFileName().replace(location.origin, "").replace(window.location.search, "");
        if(!filename) filename = "/";
        return filename;
    }
});

Object.defineProperty(window, '__LINE__', {
    get: function(){
        return __STACK__[1].getLineNumber();
    }
});

/** データ構造とコンストラクタ **/

/* タスク
   actor: Actor
   fun: HatExp
   args: 配列
   stack: ContStack
 */
function Task(actor, fun, args, stack){
    var obj=Object.create(Task.prototype);
    console.log(obj);
    obj.actor=actor;
    console.log(obj);
    obj.fun=fun;
    console.log(obj.fun);
    obj.args=args;
    console.log(obj.args);
    obj.stack=stack;
    console.log(obj.stack);
    return obj;
}

/* アクター */
function Actor(script){
    var obj=Object.create(Actor.prototype);
    obj.mailbox=[ ];
    obj.script=script;
    obj.plist=[ ];
    return obj;
}

/* ソースファイル名と行番号 */
function Source(filename, lineno){
    var src=Object.create(Source.prototype);
    src.filename=filename;
    src.lineno=lineno;
    return src;
}

/* ハット式 */
function HatExp(source){
    var exp=Object.create(HatExp.prototype);
    exp.source=source; // ソースファイル名と行番号
    return exp;
}

/* 変数 */
function Var(name, source){
    var obj=HatExp(source);
    Object.assign(obj, Var.prototype);
    obj.name=name;
    return obj;
}

/* JavaScript変数
   以下の書式によって、JavaScriptで定義された関数を実行する。
   JavaScript 関数定義 引数 ・・・ ^(戻り値)
   以下の書式によって、JavaScriptで定義された関数を返す。
   JavaScript 関数定義 ^(関数)
   以下の書式によって、JavaScript関数を実行する。
   関数 引数 ・・・ ^(戻り値)
*/
function JSVar(source){
    var obj=Var("JavaScript", source);
    Object.assign(obj, JSVar.prototype);
    return obj;
}

/* 文字列 */
function Str(string, source){
    var obj=HatExp(source);
    Object.assign(obj, Str.prototype);
    obj.string=string;
    return obj;
}

/* ハット関数 */
function HatFun(pars, contpar, funcall, source){
    var obj=HatExp(source);
    Object.assign(obj, HatFun.prototype);
    obj.pars=pars;
    obj.contpar=contpar;
    obj.funcall=funcall;
    return obj;
}

/* JavaScript関数 */
function JSFun(code, source){
    var obj=HatExp(source);
    Object.assign(obj, JSFun.prototype);
    obj.string=code.string;
    obj.fun=eval(code.string);
    return obj;
}

/* 関数呼び出し */
function FunCall(fun, args, contarg, assignment, source){
    var obj=HatExp(source);
    Object.assign(obj, FunCall.prototype);
    obj.fun=fun;
    obj.args=args;
    obj.contarg=contarg;
    obj.assignment=assignment;
    console.log(obj);
    return obj;
}

/* リスト
   (array[start] array[start+1] ・・・ . tail)
   array: 配列
   start: 配列の添字
   tail: リストの末尾
   assignment: 変数への値の割当
   source: ソースファイル中の位置
 */
function List(array, start, tail, assignment, source){
    assignment=Object.assign({ }, assignment);
    console.log(array);
    while(start>=array.length){
	if(tail==null) return null;
	console.log(start);
	console.log(tail);
	if(tail.type!="List") return tail.subst(assignment);
	start=start-array.length+tail.start;
	array=tail.array;
	Object.assign(assignment, tail.assignment);
	tail=tail.tail;
    }
    if(source==null) source=array[start].source;
    var obj=HatExp(source);
    Object.assign(obj, List.prototype);
    obj.array=array;
    obj.start=start;
    obj.tail=tail;
    obj.assignment=Object.keys(assignment).length>0? assignment: null;
    return obj;
}

/* 継続スタック */
function ContStack(first, rest){
    var obj=HatExp(first.source);
    Object.assign(obj, ContStack.prototype);
    obj.first=first;
    obj.rest=rest;
    return obj;
}

/* スクリプト */
function Script(path){
    var r=Object.create(Script.prototype);
    r.path=path;
    r.dictionary={ };
    r.loading=1;
    r.tasks=[ ];
    return r;
}

/** トップレベル **/

setTimeout(performTasks, 0);

function performTasks( ){
    var task=TaskQ.shift( );
    if(task){
	console.log('stepTask');
	console.log(task.fun);
	console.log(task.args);
	stepTask(task);
	if(task.fun) TaskQ.push(task);
	setTimeout(performTasks, 0);
    }else{
	setTimeout(performTasks, 100);
    }
}

/** プロトタイプ **/

Task.prototype={
    assignArgs(pars, assignment){
	if(this.args==null) return pars;
	var args=this.args;
	var np=pars.length, na=args.length;
	var n=np<na? np: na;
	for(var i=0; i<n; ++i) pars[i].assignValue(assignment, args[i]);
	this.args=np<na? args.slice(np): null;
	return np>na? pars.slice(na): null;
    },
    pushCont(cont){
	if(cont==null) return;
	this.stack=ContStack(cont, this.stack);
    },
    popCont( ){
	if(this.stack==null) return null;
	var cont=this.stack.first;
	this.stack=this.stack.rest;
	return cont;
    },
    type: "Task"
};

Actor.prototype={
    start(fun, args){
	console.log(args);
	var t=Task(this, fun, [args], null);
	console.log(t);
	if(this.script.loading>0){
	    console.log(t);
	    this.script.tasks.push(t);
	}else TaskQ.push(t);
    },
    type: "Actor"
};

Source.prototype={
    error( ){
	console.log(this.filename+" "+this.lineno+": Error");
    },
    type: "Source"
};

HatExp.prototype={
    subst(assignment){
	return this;
    },
    substAll( ){
	return this;
    },
    type: "HatExp"
};

function toString(obj){
    return JSON.stringify(obj);
}

Var.prototype={
    step(task){
	console.log('Var.prototype this.name='+this.name);
	console.log(toString(this));
	task.fun=task.actor.script.dictionary[this.name];
    },
    subst(assignment){
	console.log(this.name);
	console.log(assignment);
	if(assignment==null) return this;
	var undefined;
	if(assignment===undefined) return this;
	if(this.name in assignment) return assignment[this.name];
	return this;
    },
    assignValue(assignment, value){
	assignment[this.name]=value;
    },
    remove(assignment){
	delete assignment[this.name];
    },
    type: "Var"
};

JSVar.prototype={
    step(task){
	var args=task.args;
	if(args.length>0){
	    task.fun=JSFun(args[0], this.source);
	    task.args=args.slice(1);
	}else{
	    task.fun=popCont( );
	    task.args=[this];
	}
	return task;
    },
    type: "JSVar"
};

Str.prototype={
    step(task){
	if(this.fun==null) this.fun=eval(this.string);
	task.fun=task.popCont( );
	task.args=[this.fun(task.args)];
    },
    type: "Str"
};

HatFun.prototype={
    step(task){
	console.log('HatFun.prototype step 1');
	console.log(this.funcall);
	var assignment={ }; // 変数に対する値の割当
	var pars=task.assignArgs(this.pars, assignment);
	if(pars!=null){
	    console.log('pars='+pars[0].name);
	    task.fun=task.popCont( );
	    task.args=[HatFun(pars, this.contpar, this.funcall, this.source)];
	    return;
	}
	console.log(assignment);
	/*
	if(task.args!=null){
	    console.log(task.args);
	    var a=Object.assign({ }, assignment);
	    tmpVar.remove(a);
	    var args=List(task.args, 0, null, );
	    var fc=List([tmpVar], 0, args, a, this.source);
	    pushCont(HatFun([tmpVar], null, fc, this.source));
	    task.args=null;
	}
	*/
	console.log(this.contpar);
	if(this.contpar!=null) this.contpar.assignValue(assignment, task.stack);
	console.log(assignment);
	console.log(this.funcall);
	var fun=this.funcall;
	if(fun!=null) fun=fun.subst(assignment);
	console.log(fun);
	task.fun=fun;
    },
    subst(assignment){
	assignment=Object.create(assignment);
	for(var par of this.pars) par.remove(assignment);
	var funcall=this.funcall;
	if(funcall!=null) funcall=funcall.subst(assignment);
	return HatFun(this.pars, this.contpar, funcall, this.source);
    },
    type: "HatFun"
};

JSFun.prototype={
    step(task){
	task.fun=task.popCont( );
	console.log('task.args.length='+task.args.length);
	console.log('task.args[0]='+task.args[0].name);
	task.args=[this.fun.apply(this, task.args)];
    },
    type: "JSFun"
};

function substArray(array, start, assignment){
    console.log(assignment);
    var array2=[ ];
    for(let i=start, n=array.length; i<n; ++i)
	array2.push(array[i].subst(assignment));
    return array2;
}

/*
function copyAssignment(dst, src){
    console.log('copyAssignment 1');
    for(var key in src){
	console.log(key);
	dst[key]=src[key];
    }
    console.log('copyAssignment 2');
    return dst;
}
*/

FunCall.prototype={
    step(task){
	console.log('FunCall step');
	task.pushCont(this.makeArgFun(task.args));
	console.log(this.assignment);
	if(this.assignment!=null){
	    if(Object.keys(this.assignment).length>0){
		console.log(this.fun);
		console.log(this.assignment);
		this.fun=this.fun.subst(this.assignment);
		console.log(this.fun);
		console.log(this.assignment);
		this.args=substArray(this.args, 0, this.assignment);
		console.log(this.args);
		if(this.contarg!=null)
		    this.contarg=this.contarg.subst(this.assignment);
	    }
	    this.assignment=null;
	}
	task.fun=this.fun;
	task.args=this.args;
	task.pushCont(this.contarg);
	console.log(task.fun);
    },
    makeArgFun(args){
	if(args==null || args.length==0) return null;
	var fc=FunCall(tmpVar, args, null, { }, this.source);
	return HatFun([tmpVar], null, fc, this.source);
    },
    subst(assignment){
	if(isEmpty(assignment)) return this;
	var a=Object.assign({ }, assignment);
	// var a=Object.create(assignment);
	if(this.assignment!=null) Object.assign(a, this.assignment);
	return FunCall(this.fun, this.args, this.contarg, a, this.source);
    },
    substAll( ){
	this.fun=this.fun.subst(this.assignment).substAll( );
	var args=[ ];
	for(var arg of this.args)
	    args.push(arg.subst(this.assignment).substAll( ));
	this.args=args;
	this.contarg=this.contarg.subst(this.assignment).substAll( );
	return this;
    },
    type: "FunCall"
};

List.prototype={
    step(task){
	task.pushCont(this.makeArgFun(task.args));
	task.fun=this.getFirst( );
	var args=[ ];
	for(var i=this.start+1, n=this.array.length; i<n; ++i)
	    args.push(this.array[i].subst(this.assignment));
	task.args=args;
    },
    getFirst( ){
	return this.array[this.start].subst(this.assignment);
    },
    getRest( ){
	var a=this.array, s=this.start+1;
	if(s<a.length)
	    return List(a, s, this.tail, this.assignment, null);
	var t=this.tail;
	return t!=null? t.subst(this.assignment): null;
    },
    makeArgFun(args){
	if(args==null || args.length==0) return null;
	var source=args[0].source;
	var list=List(args, 0, null, null, source);
	var fc=List([tmpVar], 0, list, null, source);
	return HatFun([tmpVar], null, fc, source);
    },
    subst(assignment){
	if(isEmpty(assignment)) return this;
	var a=Object.assign({ }, assignment);
	if(this.assignment!=null) Object.assign(a, this.assignment);
	return List(this.array, this.start, this.tail, a, this.source);
    },
    /*
    substAll( ){
	this.fun=this.fun.subst(this.assignment).substAll( );
	var args=[ ];
	for(var arg of this.args)
	    args.push(arg.subst(this.assignment).substAll( ));
	this.args=args;
	this.contarg=this.contarg.subst(this.assignment).substAll( );
	return this;
    },
    */
    type: "List"
};

ContStack.prototype={
    step(task){
	task.fun=this.first;
	task.stack=this.rest;
    },
    type: "ContStack"
};

Script.prototype={
};

// 関数

function getScript(path){
    var script=scriptTable[path];
    if(!script){
	script=httpGetScript(path);
	scriptTable[path]=script;
    }
    return script;
}

/*
function newActor(script, args){
    var m=script.dictionary['main'];
    if(!m) return null;
    var a=Actor(script);
    var t=Task(a, m, args, null);
    if(script.loading>0) script.tasks.push(t);
    else TaskQ.push(t);
}
*/

function currentActor( ){
    if(currentTask==null) return null;
    return currentTask.actor;
}

function isAtom(sexp, atom){
    return sexp.type=='atom' && sexp.content==atom;
}

function SExp2Var(sexp, path){
    var source=Source(path, sexp.location.start.line);
    return Var(sexp.content, source);
}

function SExp2String(sexp){
    switch(sexp.type){
    case 'list':
	var list=sexp.content;
	var len=list.length;
	if(len==0) return "( )";
	var buf="("+SExp2String(list[0]);
	for(var i=1; i<len; ++i)
	    buf+=SExp2String(list[i]);
	return buf+")";
    default:
	return sexp.content;
    }
}

function SExp2HatExp(sexp, path){
    console.log("at "+path+":"+sexp.location.start.line);
    var source=Source(path, sexp.location.start.line);
    switch(sexp.type){
    case 'list':
	return Array2HatExp(sexp.content, 0, path);
    case 'atom':
	if(isAtom(sexp, 'JavaScript'))
	    return JSVar(source);
	return SExp2Var(sexp, path);
    case 'string':
	return Str(sexp.content, source);
    default:
	throw new Error(source.toString( )+": Error "+sexp);
    }
}

function Array2HatExp(array, start, path){
    if(isAtom(array[start], '^'))
	return Array2HatFun(array, start, path);
    return Array2List(array, start, path);
}

function Array2HatFun(array, start, path){
    var head=array[start+1];
    var pars=[ ], contpar=null;
    switch(head.type){
    case 'list':
	var list2=head.content;
	var len=list2.length;
	for(var i=0; i<len; ++i){
	    if(isAtom(list2[i], '.')) break;
	    pars.push(SExp2Var(list2[i], path));
	}
	if(++i<len) contpar=SExp2Var(list2[i], path);
	break;
    case 'atom':
	contpar=SExp2Var(head, path);
	break;
    }
    var fc=Array2List(array, start+2, path);
    var source=Source(path, array[start].location.start.line);
    return HatFun(pars, contpar, fc, source);
}

function Array2FunCall(list, start, path){
    var len=list.length;
    var args=[ ];
    var contarg=null;
    for(var i=start+1; i<len; ++i){
	if(isAtom(list[i], '.')){
	    contarg=SExp2HatExp(list[++i], path);
	    break;
	}
	if(isAtom(list[i], '^')){
	    contarg=Array2HatFun(list, i, path);
	    break;
	}
	args.push(SExp2HatExp(list[i], path));
    }
    var source=Source(path, list[start].location.start.line);
    return FunCall(SExp2HatExp(list[start], path), args, contarg, null, source);
}

function Array2List(array, start, path){
    var len=array.length;
    var array2=[ ];
    var tail=null;
    for(var i=start; i<len; ++i){
	if(isAtom(array[i], '.')){
	    tail=SExp2HatExp(array[++i], path);
	    break;
	}
	if(isAtom(array[i], '^')){
	    tail=Array2HatFun(array, i, path);
	    break;
	}
	array2.push(SExp2HatExp(array[i], path));
    }
    var source=Source(path, array[start].location.start.line);
    return List(array2, 0, tail, null, source);
}

function httpGetScript(path){
    var script=Script(path);
    httpGet(path, function(text){
	readHatCode(text, script, path);
    });
    return script;
}

function readHatCode(code, script, path){
    console.log("path="+path);
    // console.log("readHatCode 1: code="+code);
    // code=code.replace(/#\|([^|]*\|[^#])*\|#/gu, function(str){
    code=code.replace(/#\|[^|]*\|#/gu, function(str){
	// console.log("readHatCode 3: str="+str);
	return str.replace(/[^\n]/gu, "");
    });
    // console.log("readHatCode 2: code="+code);
    for(var sexp of parse(code)){
	// console.log("sexp="+sexp);
	var first=sexp.content[0];
	// console.log("readHatCode 2: first="+JSON.stringify(first));
	var second=sexp.content[1];
	// console.log("readHatCode 3: second="+JSON.stringify(second));
	switch(first.content){
	case "defineCPS":
	    // var rest=sexp.content.slice(2);
	    // console.log("8: rest="+JSON.stringify(rest));
	    console.log(second.content)
	    script.dictionary[second.content]=
		Array2HatExp(sexp.content, 2, path);
	    // console.log("dictionary["+second.content+"]="+script.dictionary[second.content]);
	    console.log("number of keys hoge="+Object.keys(script.dictionary).length);
	    break;
	case "include":
	    ++script.loading;
	    path2=second.content;
	    console.log("include "+path2);
	    httpGet(path2, function(text){
		readHatCode(text, script, path2);
	    });
	    break;
	}
    }
    if(--script.loading<=0){
	console.log('task push '+script.tasks.length);
	Array.prototype.push.apply(TaskQ, script.tasks);
    }
}

function httpGet(path, callback){
    var request=new XMLHttpRequest( );
    request.onreadystatechange=function( ){
	if( request.readyState==4 && request.status==200 ){
	    callback(request.responseText);
	    // callback(httpObj.responseURL);
	}
    }
    /*
    var date=new Date( );
    request.open('GET', path+'?'+date.getTime( ), true);
    */
    request.open('GET', path+'?', true);
    request.send( );
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

HatExp.isExp=function(obj, type){
    if(!HatExp.prototype.isPrototypeOf(obj))
	return false;
    return type? obj.type===type: true;
};

function isEmpty(obj){
    return obj==null || Object.keys(obj).length==0;
}

function stepTask(task){
    currentTask=task;
    console.log(task.fun);
    console.log(task.args);
    if(task.fun) task.fun.step(task);
}

/** JavaScript関数
    Hat式から呼び出される関数
 **/

/*
  Str path
  ContStack stack
 */
function httpGetHatExp(path, stack){
    httpGet(path.string, function(text){
	var source=Source(path.string, 1);
	var task=Task(currentActor( ), null, [Str(text, source)], stack);
	task.fun=task.popCont( );
	TaskQ.push(task);
    });
}

/** 大域変数 **/

tmpVar="__TMP__";
TaskQ=[ ]; // タスクが実行順に並ぶ待ち行列
currentTask=null; // 現在インタプリタが実行しているタスク
scriptTable={ }; // path から ScriptRecord への連想配列
parse=require("sexpr-plus").parse;
mainVar=Var('main', Source(__FILE__, __LINE__));
