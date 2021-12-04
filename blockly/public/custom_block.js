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
        message0: '%1までの乱数を生成する',
      args0: [
        {
          type: 'input_value',
          name: 'TEXT',
          check: 'String',
        },
      ],
      output: 'String',
      inputsInline: true,
      colour: 160,
      tooltip: '0~入力された数字の範囲で乱数を生成する',
    });
  },
};

Blockly.JavaScript.prime_factorization = function(block) {
  const args0 = Blockly.JavaScript.valueToCode(block, 'TEXT', Blockly.JavaScript.ORDER_FUNCTION_CALL) || '\'\'';
  const OPERATOR = " Math.floor(Math.random() * ";
  const OPERATOR2 = ")";
  return [OPERATOR + args0 + OPERATOR2, Blockly.JavaScript.ORDER_MEMBER];
};