const HatInterpreter=(function( ){
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
            let filename = __STACK__[1].getFileName().
		replace(location.origin, "").
		replace(window.location.search, "");
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
	obj.actor=actor;
	obj.fun=fun;
	obj.args=args;
	obj.stack=stack;
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
	this.source=source; // ソースファイル名と行番号
    }
    
    /* 変数 */
    function Var(name, source){
	HatExp.call(this, source);
	this.name=name;
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
	Var.call(this, "JavaScript", source);
    }
    /* 文字列 */
    function Str(string, source){
	HatExp.call(this, source);
	this.string=string;
	// console.log(this);
    }
    
    /* ハット関数 */
    function HatFun(pars, contpar, funcall, source){
	// var obj=HatExp(source);
	// Object.assign(obj, HatFun.prototype);
	HatExp.call(this, source);
	this.pars=pars;
	this.contpar=contpar;
	this.funcall=funcall;
	// return obj;
    }
    
    /* JavaScript関数 */
    function JSFun(code, source){
	HatExp.call(this, source);
	this.string=code.string;
	this.fun=eval(code.string);
    }
    
    /* 関数呼び出し */
    function FunCall(fun, args, contarg, assignment, source){
	var obj=HatExp(source);
	Object.assign(obj, FunCall.prototype);
	obj.fun=fun;
	obj.args=args;
	obj.contarg=contarg;
	obj.assignment=assignment;
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
	while(start>=array.length){
	    if(tail==null) return null;
	    if(tail.type!="List") return tail.subst(assignment);
	    start=start-array.length+tail.start;
	    array=tail.array;
	    Object.assign(assignment, tail.assignment);
	    tail=tail.tail;
	}
	if(source==null) source=array[start].source;
	HatExp.call(this, source);
	// var obj=HatExp(source);
	var obj=this;
	// Object.assign(obj, List.prototype);
	obj.array=array;
	obj.start=start;
	obj.tail=tail;
	obj.assignment=Object.keys(assignment).length>0? assignment: null;
	// return obj;
    }
    
    /* 継続スタック */
    function ContStack(first, rest){
	HatExp.call(this, first.source);
	this.first=first;
	this.rest=rest;
    }
    
    /* スクリプト */
    function Script(path){
	this.path=path;
	this.included=[ ];
	this.defined={ };
	this.dictionary=null;
    }

    /** トップレベル **/
    
    setTimeout(performTasks, 0);
    
    function performTasks( ){
	var task=TaskQ.shift( );
	if(task){
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
	    /*
	    console.log(cont.toString( ));
	    console.log(cont);
	    console.trace( );
	    */
	    this.stack=new ContStack(cont, this.stack);
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
	    var t=Task(this, fun, [args], null);
	    if(loading>0) pending.push(t);
	    else TaskQ.push(t);
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
    function hoge(){
	//　Object||ArrayならリストにINして循環参照チェック
	var checkList = [];
	return function(key,value){
            // 初回用
            if( key==='' ){
		checkList.push(value);
		return value;
            }
            // Node,Elementの類はカット
            if( value instanceof Node ){
		return undefined;
            }
            // Object,Arrayなら循環参照チェック
            if( typeof value==='object' && value!==null ){
		return checkList.every(function(v,i,a){
                    return value!==v;
		}) ? value: undefined;
            }
            return value;       
	}
    }
    function toString(obj){
	return JSON.stringify(obj, hoge( ));
    }
    Var.prototype={
	__proto__: HatExp.prototype,
	step(task){
	    task.fun=task.actor.script.getDictionary( )[this.name];
	},
	subst(assignment){
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
	toString( ){
	    return this.name;
	},
	type: "Var"
    };
    
    JSVar.prototype={
	__proto__: Var.prototype,
	step(task){
	    var args=task.args;
	    if(args.length>0){
		task.fun=new JSFun(args[0], this.source);
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
	__proto__: HatExp.prototype,
	step(task){
	    if(this.fun==null) this.fun=eval(this.string);
	    task.fun=task.popCont( );
	    task.args=[this.fun(task.args)];
	},
	toString( ){
	    return this.string;
	},
	type: "Str"
    };
    
    HatFun.prototype={
	__proto__: HatExp.prototype,
	step(task){
	    var assignment={ }; // 変数に対する値の割当
	    var pars=task.assignArgs(this.pars, assignment);
	    if(pars!=null){
		task.fun=task.popCont( );
		task.args=[new HatFun(
		    pars, this.contpar, this.funcall, this.source)];
		return;
	    }
	    // console.log(this.contpar);
	    if(this.contpar!=null)
		this.contpar.assignValue(assignment, task.stack);
	    // console.log(assignment);
	    var fun=this.funcall;
	    if(fun!=null) fun=fun.subst(assignment);
	    // console.log(fun);
	    task.fun=fun;
	},
	subst(assignment){
	    // console.log(assignment);
	    // assignment=Object.create(assignment);
	    assignment=Object.assign({ }, assignment);
	    for(var par of this.pars){
		// console.log(par.toString( ));
		par.remove(assignment);
	    }
	    // console.log(assignment);
	    var funcall=this.funcall;
	    if(funcall!=null) funcall=funcall.subst(assignment);
	    return new HatFun(this.pars, this.contpar, funcall, this.source);
	},
	toString( ){
	    var str='^', pars=this.pars;
	    if(pars!=null && pars.length>0){
		str+='('+pars[0];
		for(var i=1; i<pars.length; ++i)
		    str+=' '+pars[i];
		if(this.contpar!=null)
		    str+=' . '+this.contpar;
		str+=')';
	    }else if(this.contpar!=null)
		str+=' '+contpar;
	    else str+='()';
	    return str+this.funcall;
	},
	type: "HatFun"
    };
    
    JSFun.prototype={
	__proto__: HatExp.prototype,
	step(task){
	    task.fun=task.popCont( );
	    task.args=[this.fun.apply(this, task.args)];
	},
	toString( ){
	    return 'JavaScript '+this.string;
	},
	type: "JSFun"
    };
    
    function substArray(array, start, assignment){
	var array2=[ ];
	for(let i=start, n=array.length; i<n; ++i)
	    array2.push(array[i].subst(assignment));
	return array2;
    }

    /*
    FunCall.prototype={
	step(task){
	    task.pushCont(this.makeArgFun(task.args));
	    if(this.assignment!=null){
		if(Object.keys(this.assignment).length>0){
		    this.fun=this.fun.subst(this.assignment);
		    this.args=substArray(this.args, 0, this.assignment);
		    if(this.contarg!=null)
			this.contarg=this.contarg.subst(this.assignment);
		}
		this.assignment=null;
	    }
	    task.fun=this.fun;
	    task.args=this.args;
	    task.pushCont(this.contarg);
	},
	makeArgFun(args){
	    if(args==null || args.length==0) return null;
	    var fc=FunCall(tmpVar, args, null, { }, this.source);
	    return new HatFun([tmpVar], null, fc, this.source);
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
    */
    
    List.prototype={
	__proto__: HatExp.prototype,
	step(task){
	    task.pushCont(this.makeArgFun(task.args));
	    task.fun=this.getFirst( );
	    var list=this.getRest( ), args=[ ];
	    // while(list!=null && list.type=='List'){
	    while(list!=null && list instanceof List){
		args.push(list.getFirst( ).subst(this.assignment));
		list=list.getRest( );
	    }
	    task.args=args;
	    /*
	    console.log(this.toString( ));
	    console.log(this.assignment);
	    */
	    if(list!=null) task.pushCont(list.subst(this.assignment));
	},
	getFirst( ){
	    // console.log(this.array[this.start]);
	    return this.array[this.start].subst(this.assignment);
	},
	getRest( ){
	    var a=this.array, s=this.start+1;
	    if(s<a.length)
		return new List(a, s, this.tail, this.assignment, null);
	    var t=this.tail;
	    return t!=null? t.subst(this.assignment): null;
	},
	makeArgFun(args){
	    if(args==null || args.length==0) return null;
	    var source=args[0].source;
	    var list=new List(args, 0, null, null, source);
	    var fc=new List([tmpVar], 0, list, null, source);
	    return new HatFun([tmpVar], null, fc, source);
	},
	subst(assignment){
	    /*
	    console.log(assignment);
	    console.trace( );
	    */
	    if(isEmpty(assignment)) return this;
	    var a=Object.assign({ }, assignment);
	    // console.log(a);
	    if(this.assignment!=null) Object.assign(a, this.assignment);
	    // console.log(a);
	    return new List(this.array, this.start, this.tail, a, this.source);
	},
	toString( ){
	    // console.log(this);
	    var first=this.getFirst( );
	    if(first!=null)
		first=first instanceof Var? first.toString( ): '('+first+')';
	    var rest=this.getRest( );
	    if(rest==null) return first;
	    if(rest instanceof Var) return first+' . '+rest;
	    return first+' '+rest;
	},
	type: "List"
    };
    
    ContStack.prototype={
	__proto__: HatExp.prototype,
	step(task){
	    task.fun=this.first;
	    task.stack=this.rest;
	},
	toString( ){
	    var s='(ContStack ';
	    for(var list=this; list!=null; list=list.rest)
		s+='('+list.first+')';
	    return s+')';
	},
	type: "ContStack"
    };

    function arrayUnion(array, array2){
	for(let el of array2)
	    if(!array.includes(el)) array.push(el);
	return array;
    }
    function arrayDifference(array, array2){
	for(let el of array2)
	    if(array.includes(el)) array.delete(el); // bug
	return array;
    }

    Script.prototype={
	parse(code){
	    code=code.replace(/#\|[^|]*\|#/gu, function(str){
		return str.replace(/[^\n]/gu, "");
	    });
	    for(let sexp of parse(code)){
		let first=sexp.content[0], second=sexp.content[1];
		switch(first.content){
		case "defineCPS":
		    this.defined[second.content]=
			Array2HatExp(sexp.content, 2, this.path);
		    break;
		case "include":
		    this.included.push(getScript(second.content));
		    break;
		}
	    }
	},
	loaded( ){
	    if(--this.loading>0) return;
	    for(let callback of this.callbacks)
		callback( );
	},
	includeScript(script){
	    for(let [key, value] of Object.entries(script.dictionary)){
		if(this.dictionary[key]){
		    console.log('Warning: '+key+' is defined in '+
				script.name+' and '+this.name+'.');
		}else this.dictionary[key]=value;
	    }
	},
	getClosure( ){
	    let closure=[ ];
	    for(let addition=this.included; addition.length>0;){
		Array.prototype.push.apply(closure, addition);
		let children=[ ];
		for(let script of addition)
		    arrayUnion(children, script.included);
		arrayDifference(children, closure);
		addition=children;
	    }
	    return closure;
	},
	getDictionary( ){
	    if(this.dictionary) return this.dictionary;
	    let dictionary=Object.assign({ }, this.defined);
	    for(let script of this.getClosure( )){
		for(let [key, value] of Object.entries(script.defined)){
		    let value2=dictionary[key];
		    if(value2){
			console.log("Warning: "+key+" at "+value.source+
				    " is ignored because it is defined at "+
				   value2.source+" already.");
		    }else dictionary[key]=value;
		}
	    }
	    this.dictionary=dictionary;
	    return dictionary;
	},
	type: "Script"
    };
    
    // 関数
    function getScript(path){
	let script=scriptTable[path];
	if(script) return script;
	++loading;
	script=new Script(path);
	scriptTable[path]=script;
	httpGet(path, function(text){
	    script.parse(text);
	    if(--loading>0) return;
	    Array.prototype.push.apply(TaskQ, pending);
	    pending=[ ];
	});
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
	return new Var(sexp.content, source);
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
	var source=Source(path, sexp.location.start.line);
	switch(sexp.type){
	case 'list':
	    return Array2HatExp(sexp.content, 0, path);
	case 'atom':
	    if(isAtom(sexp, 'JavaScript'))
		return new JSVar(source);
	    return SExp2Var(sexp, path);
	case 'string':
	    return new Str(sexp.content, source);
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
	return new HatFun(pars, contpar, fc, source);
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
	return FunCall(SExp2HatExp(list[start], path),
		       args, contarg, null, source);
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
	return new List(array2, 0, tail, null, source);
    }
    
    function readHatCode(code, script, path){
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
		script.dictionary[second.content]=
		    Array2HatExp(sexp.content, 2, path);
		break;
	    case "include":
		++script.loading;
		path2=second.content;
		httpGet(path2, function(text){
		    readHatCode(text, script, path2);
		});
		break;
	    }
	}
	if(--script.loading<=0){
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
	if(task.fun){
	    // console.log(task.fun);
	    // if(task.stack!=null) console.log(task.stack.toString( ));
	    task.fun.step(task);
	}
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
	    var task=Task(currentActor( ), null,
			  [new Str(text, source)], stack);
	    task.fun=task.popCont( );
	    TaskQ.push(task);
	});
    }
    
    /** モジュール内変数 **/
    let tmpVar="__TMP__";
    let TaskQ=[ ]; // タスクが実行順に並ぶ待ち行列
    let currentTask=null; // 現在インタプリタが実行しているタスク
    let scriptTable={ }; // path から ScriptRecord への連想配列
    let parse=require("sexpr-plus").parse;
    let mainVar=new Var('main', Source(__FILE__, __LINE__));
    let loading=0; // 読込中のスクリプト数
    let pending=[ ]; // スクリプト読込待ちのタスク集合
    /*
      Hat言語のスクリプトpathで定義された関数mainに引数argsを与えて実行する。
      path: スクリプトのパス
      command: コマンド
    */
    return{
	run: function(path, command){
	    var caller=__STACK__[1];
	    var source=Source(caller.getFileName( ), caller.getLineNumber( ));
	    var a=command.split(/\s/);
	    var fun=new Var(a[0], source), args=[ ];
	    for(var i=1, n=a.length; i<n; ++i)
		args.push(new Str(a[i], source));
	    var list=new List(args, 0, null, null, source);
	    Actor(getScript(path)).start(fun, list);
	}
    }
})();
