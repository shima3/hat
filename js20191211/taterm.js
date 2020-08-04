function TATerm(textAreaId){
    var obj=Object.create(TATerm.prototype);
    var terminal=document.getElementById(textAreaId);
    var inputStart=0;
    
    obj.print=function(str){
	terminal.value=terminal.value.substr(0, inputStart)+str+
	    terminal.value.substr(inputStart);
	inputStart+=str.length;
	terminal.setSelectionRange(inputStart, inputStart);
    }

    function moveCursorToLast( ){
	var len=terminal.value.length;
	terminal.setSelectionRange(len, len);
    }

    terminal.onkeypress=function(ev){
	if(ev.metaKey){
	    switch(ev.code){
	    case "KeyX":
		ev.preventDefault( );
		break;
	    }
	    return;
	}
	switch(ev.code){
	case "Backspace":
	    if(terminal.selectionStart<=inputStart)
		ev.preventDefault( );
	    break;
	case "Enter":
	    ev.preventDefault( );
	    var inputString=terminal.value.substr(inputStart);
	    terminal.value+="\n";
	    inputStart=terminal.value.length;
	    obj.onInput(inputString);
	    break;
	default:
	    if(terminal.selectionStart<inputStart && ev.code.startsWith("Key"))
		moveCursorToLast( );
	}
    };

    terminal.onpaste=function(ev){
	if(terminal.selectionStart<inputStart)
	    moveCursorToLast( );
	setTimeout(function(){
	    var str=terminal.value;
	    var start=inputStart;
	    for(;;){
		var i=str.indexOf('\n', start);
		if(i<0) break;
		var len=i-start;
		inputStart+=len+1;
		obj.onInput(str.substr(start, len));
		start=i+1;
	    }
	}, 0);
    };

    return obj;
}

TATerm.prototype={
    onInput(str){
	console.log(str);
    },
    type: "TATerm"
};
