#|
インタプリタ本体
シングルスレッド版
|#

;; -------------------------------------
;; Scheme処理系依存を吸収するためのユーティリティ関数

(define (cons-alist key datum alist)(cons (cons key datum) alist))
(define (eval1 expr)(eval expr (interaction-environment)))
(define (print . list)
  (if(pair? list)
    (let ([first (car list)][rest (cdr list)])
      (if(string? first)
	(display first)
	(write first))
      (apply print rest))))
(define (println . list)
  (apply print list)
  (newline))

;; -------------------------------------
;; データ構造

;; (cons key value) ; key-value pair
;; (list kv1 kv2 ...) ; list of key-value pairs

;;; (define-record-type vtb #t #t ; 変数表 variable table
(define-record vtb ; 変数表 variable table
  kvld ; キーと値の対の降順リスト list of key-value pairs in descending order
  kvla ; キーと値の対の昇順リスト list of key-value pairs in ascending order
)

;; 空の変数表を作って返す
(define (new-vtb)(make-vtb '() '()))

(define (print-vtb t)
  (println (vtb-kvld t))
  (println (vtb-kvla t)))

;; 次のような降順リストと昇順リストからなる変数表を返す。
;;   降順リスト：指定されたキー以下
;;   昇順リスト：指定されたキーより大きい
(define (move-vtb
	  kvld ; 降順リスト
	  kvla ; 昇順リスト
	  key ; キー
	  )
  (cond
    [(and(pair? kvld)(> (compare (car (car kvld)) key) 0))
      (move-vtb (cdr kvld)(cons (car kvld) kvla) key)]
    [(and(pair? kvla)(<= (compare (car (car kvla)) key) 0))
      (move-vtb (cons (car kvla) kvld)(cdr kvla) key)]
    [else (make-vtb kvld kvla)]
    )
  )

(define (remove-vtb ; 指定されたキーの対を変数表から取り除く
	  t ; 変数表
	  key ; キー
	  )
  (let([t (move-vtb (vtb-kvld t)(vtb-kvla t) key)])
    (if(and(pair? (vtb-kvld t))(eq? (car (car (vtb-kvld t))) key))
      (make-vtb (cdr (vtb-kvld t))(vtb-kvla t))
      t)))

(define (put-vtb ; 指定されたキーと値の対を変数表に登録する
	  t ; 変数表
	  key ; キー
	  value ; 値
	  )
  (let ([t (remove-vtb t key)])
    (make-vtb (cons (cons key value)(vtb-kvld t))(vtb-kvla t))))

;;; (define-record-type fap #t #t ; 関数適用 function application
(define-record fap ; 関数適用 function application
  func ; 関数
  args ; 通常の実引数のリスト
  cont ; 継続の実引数
  )

;;; (define-record-type fab #t #t ; 関数抽象 function abstraction
(define-record fab ; 関数抽象 function abstraction
  pars ; 仮引数のリスト 
  fap  ; 関数適用
  vars ; 変数表
  )

;; --------------------------------------
;; 大域変数用ハッシュ表
(define cps-env (make-eqv-hashtable))
;; (define cps-env (make-hash-table)) ;; 2017/7/13 bug 

;; 大域変数 var の値を返す。
(define (get-global-var var)
  (hash-table-ref/key cps-env var)
  )

;; 項 term を値とする変数 var を定義する．
(define (set-global-var var term)
;;; (println "set-global-var " var "=" term)
  (hash-table-set! cps-env var term))

;; インタプリタによる式の評価を繰り返すかどうかを示すフラグ
(define loop-flag #t)

;; インタプリタを停止する．
(define (interpreter-stop!)
  (set! loop-flag #f))

;; 終了コード
(define exit-code 0)

;; built-in function: make.queue ^(queue)
;; 空のキューを新たに作り，変数 queue に渡す
(set-global-var 'make.queue
  `(lambda args
     (cons 'quote (make-queue))))

#|
built-in function: mailboxAdd message ^(isFirst)
メールボックスにメッセージ message を追加する
追加する直前にメールボックスが空だった場合、isFirst は #t
既に他のメッセージがあった場合、isFirst は #f
|#
(set-global-var 'mailboxAdd
  `(lambda (message)
     (let ( (mailbox (actor-mailbox (current-actor))) )
       (let ( (flag (queue-empty? mailbox)) )
	 (queue-add! mailbox message)
	 flag)))
  )

#|
built-in function: mailboxRemove ^(isEmpty)
メールボックスから先頭のメッセージを取り除く
削除した直後、メールボックスが空になった場合、isEmpty は #t
他のメッセージが残っていた場合、isEmpty は #f
|#
(set-global-var 'mailboxRemove
  `(lambda ()
     (let ((mailbox (actor-mailbox (current-actor))))
       (queue-remove! mailbox)
       )))

;; 現在のアクターを返す
(define (current-actor)
  (current-thread-specific)
  )

;; built-in function: currentActor ^(actor)
;; 現在のアクターを変数 actor に渡す
(set-global-var 'currentActor
  '(lambda ( )
     (cons 'quote (current-actor))
     ))

;; actor を現在のアクターとして設定する
(define (current-actor-set! actor)
;;; (println "current-actor=" actor)
  (current-thread-specific-set! actor))
;;;  (thread-specific-set! (current-thread) actor))

;; 計算過程のキュー
;; 計算過程は関数適用とアクターの組で表現される
(define app-queue (make-queue))
;;; (define app-queue (make-mt-queue))

;; 関数適用 app とアクター actor の組を計算過程のキューに追加する
(define (app-enqueue! app actor)
;;; (println "app-enqueue! 1 app=" app)
  (queue-add! app-queue (cons app actor))
;;; (mt-enqueue! app-queue (cons app actor))
;;; (println "app-enqueue! 2 " app)
  )

(define (start-fap fap)
  (app-enqueue! fap (current-actor)))

;; built-in function: start fap ^( )
;; 関数適用 fap の計算を開始する
(set-global-var 'start
  '(lambda(fap)
     ;; (println "start 1")
     ;; (app-enqueue! app (current-actor))
     (start-fap fap)
     ;; (println "start 2")
     '( )))

;; 計算過程のキューから関数適用とアクターの組を取り出す
(define (app-dequeue!)
  (if (queue-empty? app-queue) '()
    (queue-remove! app-queue)))
  ;; (mt-dequeue! app-queue))

;; アクターは振舞とメールボックスからなる
;; メールボックスはキューである
(define-record actor behavior mailbox dictionary properties)
;; (define-type actor behavior mailbox dictionary properties)
#; (define-record-type actor ; srfi-9
  (make-actor behavior mailbox dictionary)
  actor?
  (behavior actor-behavior actor-behavior-set!)
  (mailbox actor-mailbox)
  (dictionary actor-dictionary))
#; (define-record-type actor #t #t
  (behavior)
  (mailbox)
  (dictionary))
#; (define-record-type actor ; rnrs
  (fields behavior mailbox dictionary))
#; (define-record-type actor ; rnrs
  (fields (mutable behavior)(mutable mailbox)(mutable dictionary)))

;; 振舞 behavior を持つアクターを作る
(define (new-actor behavior)
  (make-actor behavior (make-queue)(make-eqv-hashtable)(make-eqv-hashtable))
  )
;;  (cons behavior (make-mt-queue)))

;; built-in function: makeActor behavior ^(actor)
;; 動作 behavior を行うアクターを作り，変数 actor に渡す
(set-global-var 'makeActor
  '(lambda (behavior)
     (cons 'quote (new-actor behavior))))

;; アクター actor の動作を behavior に変更する
(define (actor-become actor behavior)
  ;; (println "actor-become 1")
  (actor-behavior-set! actor behavior)
  ;; (println "actor-become 2")
  )
;;  (set-car! actor behavior))

;; built-in function: actorBecome behavior
;; 現在のアクターの動作を behavior に変更する
(set-global-var 'actorBecome
  '(^(behavior . return)
     (lambda (behavior)
       (actor-become (current-actor) behavior))
     behavior ^(dummy)
     return))

;; built-in function: getBehavior ^(behavior)
;; 現在のアクターのメールボックスを変数 mailbox に渡す
(set-global-var 'getBehavior
  '(lambda ( )
     (actor-behavior (current-actor))))

;; built-in function: getMailbox ^(mailbox)
;; 現在のアクターのメールボックスを変数 mailbox に渡す
(set-global-var 'getMailbox
  '(lambda ( )
     (actor-mailbox (current-actor))))

(define (get-current-properties)
  (actor-properties (current-actor)))

;; built-in function: getProperty name failure ^(value)
(set-global-var 'getProperty
  '(^(name failure . return)
     (lambda (K F)
       (hash-table-ref/default (get-current-properties) K F)
       ) name failure ^(action)
     action
     ))

;; built-in function: getProperty name failure ^()
(set-global-var 'setProperty
  '(^(name value . return)
     (lambda (K A)
       (hash-table-set! (get-current-properties) K A)
       ) name (^ r r value) ^(dummy)
     return
     ))

;; built-in function: let actor app ^( )
;; アクター actor に関数適用 app を計算させる
(set-global-var 'let
  '(^(actor app . return)
     (lambda (qactor app)
       (app-enqueue! app (cdr qactor))) actor app ^(dummy)
     return))

;; アクター actor 宛てのメッセージのキューからメッセージを１つ取り出し，actor に実行させる
(define (actor-respond actor)
  ;; (display "actor-respond 1 ")(display actor)(newline)
  (let ( (behavior (actor-behavior actor))
	 (mailbox (actor-mailbox actor)) )
    (let ( (message (queue-first mailbox)) )
    ;; (let ([message (mt-queue-peek mailbox)])
      ;; (display "actor-respond 2 ")(display message)(newline)
      (if (not (null? message))
	(begin
	  (app-enqueue! (list message behavior) actor)
	  ;; (display "actor-respond 3 ")(display actor)(newline)
	  )
	)))
  ;; (display "actor-respond 4 ")(display actor)(newline)
  )

;; 現在のアクターに次のメッセージを実行させる
(set-global-var 'actorNext
  '( ^ return
     ( lambda ()
       ;; (display "actorNext 1")(newline)
       (let ([actor (current-actor)])
	 ;; (display "actorNext 2")(newline)
	 (let ( (mailbox (actor-mailbox actor)) )
	   ;; (display "actorNext 3")(newline)
	   (queue-remove! mailbox)
	   ;; (mt-dequeue! mailbox)
	   (if (not (queue-empty? mailbox))
	   ;; (if (not (mt-queue-empty? mailbox))
	     (actor-respond actor)
	     )
	   )
	 )
       ;; (display "actorNext 2")(newline)
       ) ^(dummy)
     return
     )
  )

;; ユーザによって定義された main を最初に呼び出す．
(define entry-point 'main)

;; 0.1秒の時間間隔
(define duration100ms (seconds->duration 0.1))
;; 1秒の時間間隔
(define duration1s (seconds->duration 1))

;; (define default-continuation '(F.C end))
;; (define default-continuation '(F.C stack_end))
;; (define default-continuation 'stack_end)
;; (define default-continuation '(F.C (exit 0) . stack_end))
;; (define default-continuation '(^ R R ^(F . C) C))
;; (define default-continuation '(^ R R end . stack_end))
;;; (define default-continuation '(^ R R stop . stack_end))
;;; (define default-continuation '(^ seq seq stop . cont_end))
;;; (define default-continuation 'cont_end)
(define default-continuation '(F.C stop . cont_end))

(define (step-loop)
  (let loop ( [app-actor (app-dequeue!)] )
    (if (not (null? app-actor))
      (let ( (actor (cdr app-actor))
	     (timeout (add-duration (current-time) duration100ms)) )
	(current-actor-set! actor)
	; (println (car app-actor))
	(let loop2 ( [app (car app-actor)] )
	  (if (not (null? app))
	    (if (time<? (current-time) timeout)
	      ;; (loop2 (step-app app '(F.C end)))
              (begin
;;                (display "app=")(write app)(newline)
	        (loop2 (step-app app default-continuation))
                )
	      ;; (loop2 (step-app app 'end))
	      ;; (loop2 (step-app app '(^($1) $1 . end)))
	      ;; (loop2 (step-app app '( )))
	      (app-enqueue! app actor))))
	(loop (app-dequeue!)))))
  )

;; プログラムを解釈し，実行する．
;; args：コマンドラインの引数のリスト
;; [-e entry-point] script argument ...
(define (interpret args)
  (let loop ( )
    (if (pair? args)
      (let ((arg (car args)))
	(if (equal? (string-ref arg 0) #\-)
	  (let ((opt (string-ref arg 1)))
	    (case opt
	      ([#\e]
		(set! entry-point (substring arg 2 (string-length arg)))
		(if (equal? entry-point "")
		  (begin
		    (set! args (cdr args))
		    (set! entry-point (car args))))
		(set! entry-point (string->symbol entry-point)))
	      ([#\I]
		(set! args (cdr args))
		(let([dir (car args)])
		  (unless(eq? (string-ref dir (- (string-length dir) 1)) #\/)
		    (set! dir (string-append dir "/")))
		  (set! sch-load-path (cons dir sch-load-path))))
	      )
	    (set! args (cdr args))
	    (loop))))))
  (set! sch-load-path (cons "" sch-load-path))
;;;  (println "sch-load-path=" sch-load-path)
  (load-sch-script (car args) sch-load-path)
  (app-enqueue! (list entry-point (cdr args))(new-actor "main"))
  (step-loop)
  (exit exit-code))

(define sch-load-path '())

(define(get-path filename)
  (let([index (string-index-right filename #\/)])
    (if(number? index)
      (substring filename 0 (+ index 1))
      #f
      )))

;; sch-script 言語のファイル filename を読み込む
(define(load-sch-script filename path)
  (if(pair? path)
    (let([filepath (string-append (car path) filename)])
;;;      (println "filepath=" filepath)
      (call-with-input-file filepath
	(lambda(port)
	  (if port
	    (let( [previous sch-load-path]
		  [next (get-path filepath)] )
	      (if (string? next)
		(set! sch-load-path (cons next sch-load-path)))
	      (while(interpret-sexp (read port)) '())
	      #; (let loop ( )
	      (if (interpret-sexp (read port))
	      (loop)))
	      (set! sch-load-path previous)
	      )
	    (load-sch-script filename (cdr path))))
	:if-does-not-exist #f))
    (begin
      (println "*** ERROR: cannot find \"" filename "\" in " sch-load-path)
      (exit 1))
    ))

;; S式 sexp を解釈し，実行する．
(define (interpret-sexp sexp)
  (cond
    ((pair? sexp)(interpret-command (car sexp)(cdr sexp)) #t)
    ((eof-object? sexp) #f)
    (else #t)))

;; コマンド cmd，引数 args を解釈し，実行する．
(define (interpret-command cmd args)
  (case cmd
    ([defineCPS](set-global-var (car args)(cdr args)))
    ([include](load-sch-script (car args) sch-load-path))
    ))

(define (arg-seq? func)
;;;  (println "arg-seq? " func)
  (and(pair? func)
    (equal? (car func) '^)
    (equal? (car (cdr func)) '(A$S))))

;; 関数適用 app を一段階実行する．
(define (step-app app defcont)
;;;  (println "step-app " app)
;;;  (println "defcont=" defcont)
  (let ((func (car app))(args (cdr app)))
    (set! func (get-global-var func))
    ;; (println "step-app func=" func)
    (cond
      ((pair? func)
	(let ((first (car func))(rest (cdr func)))
	  (case first
	    ((^)
	      (step-abs (car rest)(cdr rest) args '( ) defcont))
	    ((lambda)
;;;	      (println "lambda func=" func)
	      (apply-func func (pickup-cont-arg args) defcont))
	    ((quote)
	      (step-app (cons (car rest) args) defcont))
	    ((PROMISE)
	      (step-app (cons (eval-promise func) args) defcont))
	    ((F.C) ; 継続付き関数 (F.C 関数 . 継続)
;;;	      (println "func=" func)(println "args=" args)
	      (step-app (cons (car rest) args)(cdr rest))
#;	      (let ([second (car rest)][rest2 (cdr rest)])
		(if(null? args)
		  (step-app rest rest2)
		  (if(and(eq? (car args) '^)
		       (pair? second)(not(eq? (car second) 'lambda)))
		    (step-app (cons args rest) rest2)
		    (step-app (cons second args) rest2)
		    )
		  )))
	    (else ; funcが関数適用
	      (step-app func (func-with-cont (args-to-func args) defcont)))
	    )))
;;; ((null? func)
;;;      ((eq? func 'stop)
      ((or(eq? func 'stop)(null? func))
	;; (println "step-app func is null")
	'( )
	;; (if (null? defcont) '( )(list defcont))
	)
      ((not (pair-terms? args))
	;; (println "step-app args not pair")
	(if (null? args)
	  (list defcont func)
	  ;; (cons defcont (cons func 'end))
	  (cons args (cons func defcont))))
	;; (list args func))
      ((func-with-cont? app) ; app が継続付き関数ならば
	(println "func-with-cont")
	'( )) ; なにもしない
      ((procedure? func)
	(apply-func func (pickup-cont-arg args) defcont))
      (else
	(display "Illegal function error: ")
	(write app)
	(newline)
	(exit 1)))))

(define (get-tail args)
  (if (pair-terms? args)
    (get-tail (cdr args))
    args))

(define (args-to-func args)
  (if (pair-terms? args)
    (cons '^ (cons '(A$S)(cons 'A$S args))) ; Argument Sequence
;;;    (cons '^ (cons '(I$0)(cons 'I$0 args)))
    #; (if (null? (get-tail args))
    (cons '^ (cons '($0 . $1)(cons '$0 (append args '$1))))
    (cons '^ (cons '($0)(cons '$0 args)))
    )
    args))

;; parsとappからなるラムダ抽象にargsを与えて一段階実行する。
;; pars 仮引数
;; app 関数適用
;; args 実引数
;; env 変数環境
;; defcont 省略時継続
(define (step-abs pars app args env defcont)
  ;; (println "step-abs pars=" pars " app=" app " args=" args " env=" env)
  (if (pair? pars)
    (if (pair-terms? args)
      (step-abs (cdr pars) app (cdr args)(cons-alist (car pars)(car args) env)
	defcont)
      ;; 部分適用の場合
      (let ([func (cons '^ (cons pars (substitute-term app env)))])
	(if (null? args)
	  (list defcont func)
	  (cons args (cons func defcont)))
	)
      ;; (list args (cons '^ (cons pars (substitute-term app env '( )))))
      )
    ;; parsが継続仮引数の場合
    (begin
      (set! args (func-with-cont (args-to-func args) defcont))
      (if (not (null? pars)) ; 継続仮引数があれば
	(begin
	  ;; (println "step-abs 2 pars=" pars)
	  #; (if(equal? pars 'reply)
	    (begin
	      (println "step-abs 3 args=" args)
	      (println "step-abs 4 defcont=" defcont)
	      )
	    )
	  (set! env (cons-alist pars args env)) ; 継続実引数を割り当てる
	  )
	)
      ;; (println "step-abs 3 app=" app " env=" env)
      (set! app (substitute-term app env)) ; 局所変数に値を代入する
      ;; { if flag (println "step-abs 4 (car app)=" (car app)) }
      ;; (println "step-abs 4 app=" app " args=" args)
      ;; 2018/6/24
;;;      (if(func-with-cont? (car app))(set! hoge-count (- hoge-count 1)))
      (cons (func-with-cont (car app) args)(cdr app))
      )
    )
  )

(define (eval-promise P)
  (define (f r)(set-car! (cdr P) r))
  (set-car! P 'quote)
  `(^ return
     ,(car (cdr P))^ seq
     ,f (^ c seq c)^(dummy) seq return)
  #; (list '^ 'return (car (cdr P)) '^ 'seq
    (lambda(r)
      (set-car! (cdr P) r)
      ) '(^ c seq c) '^ '(dummy) 'seq 'return)
  #; `(^ return
     ,(car (cdr P))^ seq
     (lambda(r)
       (set-car! (quote ,(cdr P)) r)
       )(^ c seq c)^(dummy)
     seq return)
  )

(define (func-with-cont? func)
  (and (pair? func) (equal? (car func) 'F.C))
  )

;;; (define hoge-count 0)

;; 継続付き関数を返す。
(define (func-with-cont func cont)
  (if (null? func)
    cont
    (if (or (null? cont)
	  (if (func-with-cont? func)
	    (begin
;;;	      (set! hoge-count (+ hoge-count 1))
	      ;; (write func)(newline)
	      #t)
	      ;; #f)
	    #f))
      func
      (cons 'F.C (cons func cont))
      )))

;; termがpairならば #t、そうでなければ #f を返す。
(define (pair-terms? term)
  (and (pair? term)
    (case (car term)
      ((^ lambda quote F.C PROMISE) #f)
      (else #t)))
  )

;; 環境 env における変数 var の値を返す。
(define (get-var var env)
  (let ((kv (assq var env))) ; assoc -> assq 2017/3/28
    (if kv (cdr kv) var)))

;; 通常の順序の引数リストを継続第一にして返す。
;; 通常の順序 (引数1 引数2 … . 継続) -> 継続第一 (継続 引数1 引数2 …)
;; このとき大域変数を値に置き換える。
;; (define (pickup-cont-arg args env)
(define (pickup-cont-arg args)
  (if (pair-terms? args)
    (let ((cargs (pickup-cont-arg (cdr args))))
      (cons (car cargs)(cons (get-global-var (car args))(cdr cargs))))
    (list (get-global-var args))
  ))

;; 関数 func に継続第一の引数リスト cargs を適用する。
(define (apply-func func cargs defcont)
  [let ([cont (car cargs)][args (cdr cargs)])
    ;; 2019/7/2 多値返却に対応
    (cons (func-with-cont cont defcont)
      (call-with-values (lambda()(apply (eval1 func) args))
	(lambda results results)))
    ])

;; 項 term に含まれる変数を env で対応づけられた値に置き換える。
;; env 環境（変数と値との対応）
(define (substitute-term term env)
;;;  (println "substitute-term " term " env=" env)
  (cond
    ((pair? term)
      (let ((first (car term))(rest (cdr term)))
	(case first
	  ((^)(substitute-abs (car rest)(cdr rest) env))
	  ((lambda quote F.C PROMISE) term)
	  (else
	    ;; (println "substitute-term else")
	    (cons (substitute-term first env)
	      (substitute-term rest env))
	    ))))
    ((null? term) '( ))
    (else (get-var term env))))

;; 仮引数列 pars、関数適用 app からなるラムダ抽象に含まれる変数を env で対応づけられた値に置き換える。
(define (substitute-abs pars app env)
  (cons '^ (cons pars (substitute-term app (assign-self pars env)))))

;; 仮引数列 pars の各仮引数に対し、その仮引数自身を値として割り当てた対応を環境 env に追加した環境を返す。
;; 束縛変数が substitute-abs において外部の変数の値に置き換えられることを防ぐ。
(define (assign-self pars env)
  (cond
    ((pair? pars)(assign-self (cdr pars)(assign-self (car pars) env)))
    ((null? pars) env)
    (else (cons-alist pars pars env))))

;; コマンド引数を与えてインタプリタを呼び出す。
(define (main-proc cmd . args)
  (interpret args))

(define (copy-cell dst src)
  ;; (display "copy-cell: ")(display dst)(newline)
  (set-car! dst (car src))
  (set-cdr! dst (cdr src))
  dst)

;; ----- built-in functions -----

#|
null
空リスト
|#
;; (set-global-var 'null '( ))
(set-global-var 'end '( ))
#; (set-global-var 'end
  '(^(out . return)
     return #t . end
     )
  )

;; (set-global-var 'stop '(null . null))
;; (set-global-var 'stop '(end . end))

#|
exit code
スクリプトを終了する
code: 終了コード
|#
(set-global-var 'exit
  '(^($code)
     (lambda(code)
       ;; (display "hoge count=")(display hoge-count)(newline)
       (exit code)
       ;; ) $code . null)
       ) $code . end)
  )
;; 2020/6/14 Sun changed
#; (set-global-var 'exit
  `(^(code)
     (lambda (Code)
       (set! exit-code Code)
       (interpreter-stop!)) code . end))

#|
delay app ^(P)
promiseを生成し、変数Pに渡す。
|#
(set-global-var 'delay
  '(^($e) ; print("e=" $e "\n")^()
     (lambda(e) ; (newline)(display (ipair? (list e)))(newline)
       (cons 'PROMISE (list e))) $e))

#; (set-global-var 'cont_push
  '(^($cont $func)
     (lambda(cont func)
       (func-with-cont func cont)
       ) $cont $func)
  )

#; (set-global-var 'cont_pop
  '(^($cont . $return)
     (lambda(cont)
       (cadr cont)
       ) $cont ^($first)
     (lambda(cont)
       (cddr cont)
       ) $cont ^($rest)
     $return $first $rest)
  )
