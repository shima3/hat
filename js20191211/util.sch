#|
ユーティリティ関数群
|#
(include "hat.sch")

#|
親言語（処理系の実装言語）で提供されるデータを扱うための関数群
|#

;; 制御関係

(defineCPS wait ^(sec . return)
  JavaScript "HatInterpreter.wait" sec return ^(dummy)
  end)

;; 数値関連

(defineCPS + ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a+b; })" a b)

(defineCPS - ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a-b; })" a b)

(defineCPS * ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a*b; })" a b)

(defineCPS / ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a/b; })" a b)

(defineCPS div ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return Math.floor(a/b); })" a b)

(defineCPS mod ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a%b; })" a b)

(defineCPS div_mod ^(a b . return) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return Math.floor(a/b); })" a b ^(d)
  JavaScript "(function(a, b){ return a%b; })" a b ^(m)
  return d m)

(defineCPS = ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a==b; })" a b)

(defineCPS < ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a<b; })" a b)

(defineCPS <= ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a<=b; })" a b)

(defineCPS > ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a>b; })" a b)

(defineCPS >= ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a>=b; })" a b)

(defineCPS <> ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a!=b; })" a b)

;; 文字列関連

(defineCPS string2number ^(str)
  JavaScript "(function(str){ return +str; })" str)

;; リスト関連

(defineCPS list2values ^(list . return)
  print(list "\n")^()
  JavaScript "HatInterpreter.makePair" return list ^(exp)
  print(exp "\n")^()
  exp)

;; キャラクタユーザインタフェース用関数群

(defineCPS print ^(list . return)
  JavaScript "hat_print" list ^(dummy)
  return)

(defineCPS seq_cmd_args ^ return
  JavaScript "hat_get_command_line_args" ^(args)
  return args)

(defineCPS log_on ^ return
  JavaScript "HatInterpreter.log_on" ^(dummy)
  return)

(defineCPS log_off ^ return
  JavaScript "HatInterpreter.log_off" ^(dummy)
  return)

(defineCPS seq_ex ^(seq2 ex r)
  if(seq_empty? seq2) ex ^()
  seq2 (^(first . rest)
	 r first ^(r2)
	 seq_ex rest ex r2))

(defineCPS seq_ex_get ^(seq . return)
  seq return)

(defineCPS get_cmd_args ^ return
  seq_cmd_args ^(args)
  seq_ex args
  ( print("Error: lack of command arguments\n")^()
    exit 1 ) return)

(defineCPS exit ^(status . return)
  JavaScript "hat_exit" status ^(dummy)
  return)

;; GUI関連

(defineCPS line ^(x1 y1 x2 y2 . return)
  JavaScript "hatLine" x1 y1 x2 y2 ^(dummy)
  return )

(defineCPS triangle ^(x1 y1 x2 y2 x3 y3 . return)
  JavaScript "hatTriangle" x1 y1 x2 y2 x3 y3 ^(dummy)
  return )

(defineCPS rect ^(x y width height . return)
  JavaScript "hatRect" x y width height ^(dummy)
  return )

(defineCPS ellipse ^(x y width height start end . return)
  JavaScript "hatEllipse" x y width height start end ^(dummy)
  return )

(defineCPS line_width ^(width . return)
  JavaScript "hatLineWidth" width ^(dummy)
  return)

(defineCPS stroke_rgb ^(red green blue . return)
  JavaScript "hatStrokeRGB" red green blue ^(dummy)
  return)

(defineCPS fill_rgb ^(red green blue . return)
  JavaScript "hatFillRGB" red green blue ^(dummy)
  return)

(defineCPS no_stroke ^ return
  JavaScript "hatNoStroke" ^(dummy)
  return)

(defineCPS no_fill ^ return
  JavaScript "hatNoFill" ^(dummy)
  return)

(defineCPS text ^(text x y . return)
  JavaScript "hatText" text x y ^(dummy)
  return)

(defineCPS text_size ^(size . return)
  JavaScript "hatTextSize" size ^(dummy)
  return)

(defineCPS text_align ^(align . return)
  JavaScript "hatTextAlign" align ^(dummy)
  return)

(defineCPS fill_canvas ^ return
  JavaScript "hatFillCanvas" ^(dummy)
  return)

(defineCPS canvas_size ^ return
  JavaScript "hatGetCanvasSize" ^(size)
  size return)
