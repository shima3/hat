const workspace = Blockly.inject(
  'blocklyDiv',
  {
    toolbox: document.getElementById('toolbox'),
    trashcan: true,
  },
);
function showCode() {
  Blockly.JavaScript.INFINITE_LOOP_TRAP = null;
  const pre = document.getElementById('jsCode');
  pre.innerHTML = Blockly.JavaScript.workspaceToCode(workspace);
}

function runCode() {
  let maxSteps = 10000;
  const code = Blockly.JavaScript.workspaceToCode(workspace);

  function initialize(interpreter, scope) {
    function alertWrapper(text) {
      const msg = text ? text.toString() : '';
      return interpreter.createPrimitive(window.alert(msg));
    }

    interpreter.setProperty(scope, 'alert', interpreter.createNativeFunction(alertWrapper));
  }

  const jsInterpreter = new Interpreter(code, initialize);
  while (jsInterpreter.step() && maxSteps) {
    maxSteps -= 1;
  }
  if (!maxSteps) {
    throw EvalError('Infinite loop.');
  }
  jsInterpreter.run();
}

document.getElementById('showCode').addEventListener('click', showCode, false);
document.getElementById('runCode').addEventListener('click', runCode, false);

