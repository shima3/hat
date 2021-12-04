Blockly.JavaScript.text_shuffle = function(block) {
  const args0 = Blockly.JavaScript.valueToCode(block, 'TEXT', Blockly.JavaScript.ORDER_FUNCTION_CALL) || '\'\'';
  const OPERATOR = ".split('').sort(function(){return 0.5-Math.random()}).join('')";
  return [args0 + OPERATOR, Blockly.JavaScript.ORDER_MEMBER];
};

Blockly.Blocks.prime_factorization = {
  /**
   * Block for shuffle characters.
   * @this Blockly.Block
   */
  init() {
    this.jsonInit({
        message0: '1から%1までの整数乱数',
      args0: [
        {
          type: 'input_value',
          name: 'max',
          check: 'Number',
        },
      ],
      output: 'Number',
      inputsInline: true,
      colour: 160,
      tooltip: '0~入力された数字の範囲で乱数を生成する',
    });
  },
};

Blockly.JavaScript.prime_factorization = function(block) {
  const args0 = Blockly.JavaScript.valueToCode(block, 'max', Blockly.JavaScript.ORDER_FUNCTION_CALL);
  return ["(+ (floor(* random "+args0+")) 1)", Blockly.JavaScript.ORDER_MEMBER];
};

Blockly.JavaScript.controls_repeat_ext=function(block){
    const TIMES = Blockly.JavaScript.valueToCode(block, 'TIMES', Blockly.JavaScript.ORDER_FUNCTION_CALL);
    const DO = Blockly.JavaScript.statementToCode(block, 'DO');
    return '(^(LOOP COUNT . BREAK) COUNT ^(COUNT)\n  when(<= COUNT 0) BREAK ^()\n'+DO+'  LOOP LOOP (- COUNT 1) . BREAK)^(LOOP)\nLOOP LOOP '+TIMES+' ^()\n';
};

Blockly.JavaScript.text = function(block) {
    const args0 = block.getFieldValue('TEXT');
    return ['"'+args0+'"', Blockly.JavaScript.ORDER_MEMBER];
};

Blockly.JavaScript.text_print=function(block){
    const args0 = Blockly.JavaScript.valueToCode(block, 'TEXT', Blockly.JavaScript.ORDER_FUNCTION_CALL) || '\'\'';
    return args0+" ^(v) window_alert v ^()\n";
};
