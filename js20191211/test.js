var x=3;
console.log("1: eval(x+2)="+eval("x+2"));

for(var el of document.getElementsByTagName("script")){
    if(el.type=="text/hat"){
	if(el.src!=""){
	    console.log("3: el.src="+el.src);
	    ++loadingProgramCount;
	    loadFile(el.src, loadHatText);
	}
	HatArgs.push(el.innerText);
    }
}

loadFile("a.txt", function(text){
    console.log("5: text="+text);
});
console.log("6: new Function()()"+new Function("a", "return a+3;")(5));
fetch("a.txt").then(response => {
    return response.text( );
}).then(body => {
    document.write("Hello world!! 3 "+body);
});
