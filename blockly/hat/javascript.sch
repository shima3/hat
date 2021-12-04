#| ラッパー関数（wrapper functions）
親言語（処理系の実装言語）で提供される機能を呼び出す。
処理系の間で関数名を共通化し、処理系依存を隠蔽する。
処理系によっては未実装の関数もありえる。
|#

;; データ

(defineCPS equal? ^(obj1 obj2)
  JavaScript "areEqual" obj1 obj2)

;; 制御関係

(defineCPS exit ^(status . return)
  JavaScript "hatExit" status ^(dummy)
  end)

(defineCPS wait_disp ^ return
  JavaScript "HatInterpreter.waitDisplay" return ^(dummy)
  end)

(defineCPS stack_size ^(cont)
  JavaScript "(function(cont){ return cont.size; })" cont)

(defineCPS log_stack_size ^(tag . return)
  JavaScript "(function(tag){ console.log(tag+': stack size='+currentTask.stack.size); })" tag ^(dummy)
  return)

(defineCPS log ^($obj . return)
  JavaScript "HatInterpreter.log" return $obj ^(dummy)
  return)

;; 数値関連

(defineCPS PI 3.1415926535897932384626433)

(defineCPS + ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a+b; })" a b)

(defineCPS - ^(a b) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a-b; })" a b)

(defineCPS * ^(a b . return) a ^(a) b ^(b)
  JavaScript "(function(a, b){ return a*b; })" a b)
;;  JavaScript "(function(a, b){ return a*b; })" a b ^(result)
;;  return result)

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

(defineCPS floor ^(a) a ^(a)
  JavaScript "(function(a){ return Math.floor(a); })" a)

(defineCPS ceil ^(a) a ^(a)
  JavaScript "(function(a){ return Math.ceil(a); })" a)

(defineCPS random ^()
  JavaScript "(function(){ return Math.random(); })")

;; 文字列関連

(defineCPS string2number ^(str)
  JavaScript "(function(str){ return +str; })" str)

;; リスト関連

(defineCPS list2values ^(list . return)
  ;; print(list "\n")^()
  JavaScript "HatInterpreter.makePair" return list ^(exp)
  ;; print(exp "\n")^()
  exp)

(defineCPS list? ^($list)
  JavaScript "HatInterpreter.isList" $list)

(defineCPS list_empty? ^($list)
  JavaScript "HatInterpreter.listIsEmpty" $list)

(defineCPS list_get_first ^($list)
  JavaScript "HatInterpreter.listGetFirst" $list)

(defineCPS list_get_rest ^($list)
  JavaScript "HatInterpreter.listGetRest" $list)

(defineCPS list_push ^($list $el)
  JavaScript "HatInterpreter.listPush" $list ($el))

(defineCPS list_string ^($list)
  JavaScript "HatInterpreter.listString" $list)

;; キャラクタユーザインタフェース用関数群

(defineCPS print ^(list . return)
  JavaScript "hatPrint" list ^(dummy)
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

(defineCPS get_cmd_args ^ return
  seq_cmd_args ^(args)
  seq_ex args
  ( print("Error: lack of command arguments\n")^()
    exit 1 ) return)

(defineCPS window_alert ^(str . return)
  JavaScript "(function(str){ window.alert(str); })" str ^(dummy)
  return)

;; GUI関連

(defineCPS begin_chain ^(x f . return)
  f x ^ c
  c begin_chain . return)

(defineCPS end_chain ^(x . return)
  return ^(bc . r)
  r x)

(defineCPS line_to2 ^(x y p . return)
  return(x y - . p))

(defineCPS curve_to2 ^(x y p . return)
  return(x y ~ . p))

(defineCPS begin_path ^( . return)
  JavaScript "hatBeginPath" ^(dummy)
  return)

(defineCPS end_path ^ return
  JavaScript "hatEndPath" ^(dummy)
  return)

(defineCPS close_path ^ return
  JavaScript "hatClosePath" ^(dummy)
  return)

(defineCPS move_to ^(x y . return)
  x ^(x) y ^(y)
  JavaScript "hatMoveTo" x y ^(dummy)
  return)

(defineCPS line_to ^(x y . return)
  x ^(x) y ^(y)
  JavaScript "hatLineTo" x y ^(dummy)
  return)

(defineCPS arc ^(x y r s e . return)
  x ^(x) y ^(y) r ^(r) s ^(s) e ^(e)
  JavaScript "hatArc" x y r s e ^(dummy)
  return)

(defineCPS rotate ^(x y angle . return) x ^(x) y ^(y) angle ^(angle)
  JavaScript "hatRotate" x y angle ^(dummy)
  return)

(defineCPS stroke2 ^ return
  JavaScript "hatStroke" ^(dummy)
  return)

(defineCPS line2 ^(x1 y1 x2 y2 . return)
  x1 ^(x1) y1 ^(y1) x2 ^(x2) y2 ^(y2)
  JavaScript "hatLine" x1 y1 x2 y2 ^(dummy)
  return )

(defineCPS triangle ^(x1 y1 x2 y2 x3 y3 . return)
  x1 ^(x1) y1 ^(y1) x2 ^(x2) y2 ^(y2) x3 ^(x3) y3 ^(y3)
  JavaScript "hatTriangle" x1 y1 x2 y2 x3 y3 ^(dummy)
  return )

(defineCPS rect ^(x y width height . return)
  x ^(x) y ^(y) width ^(width) height ^(height)
  JavaScript "hatRect" x y width height ^(dummy)
  return )

(defineCPS circle ^(x y r . return)
  x ^(x) y ^(y) r ^(r)
  JavaScript "hatCircle" x y r ^(dummy)
  return )

(defineCPS ellipse ^(x y width height start end . return)
  x ^(x) y ^(y) width ^(width) height ^(height) start ^(start) end ^(end)
  JavaScript "hatEllipse" x y width height start end ^(dummy)
  return )

(defineCPS line_width ^(width . return)
  width ^(width)
  JavaScript "hatLineWidth" width ^(dummy)
  return)

(defineCPS stroke_rgb ^(red green blue . return)
  red ^(red) green ^(green) blue ^(blue)
  JavaScript "hatStrokeRGB" red green blue ^(dummy)
  return)

(defineCPS fill_rgb ^(red green blue . return)
  red ^(red) green ^(green) blue ^(blue)
  JavaScript "hatFillRGB" red green blue ^(dummy)
  return)

(defineCPS no_stroke ^ return
  JavaScript "hatNoStroke" ^(dummy)
  return)

(defineCPS no_fill ^ return
  JavaScript "hatNoFill" ^(dummy)
  return)

(defineCPS draw_text ^(text x y . return)
  x ^(x) y ^(y)
  JavaScript "hatText" text x y ^(dummy)
  return)

(defineCPS text ^(text x y . return)
  x ^(x) y ^(y)
  JavaScript "hatText" text x y ^(dummy)
  return)

(defineCPS measure_text ^(text . return)
  JavaScript "hatMeasureText" text ^(size)
  size return . end)

(defineCPS text_size ^(size . return)
  size ^(size)
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
  size return . end)

(defineCPS property? ^(key)
  JavaScript "isProperty" key)

(defineCPS get ^(key)
  JavaScript "getProperty" key)

(defineCPS set ^(key value . return)
  JavaScript "setProperty" key value ^(dummy)
  return)

;; 時間

(defineCPS time_start ^(label . return)
  JavaScript "timeStart" label ^(dummy)
  return)

(defineCPS time_end ^(label)
  JavaScript "timeEnd" label)
