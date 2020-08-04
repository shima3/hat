;; シングルスレッド版

;; Scheme処理系依存を吸収するためのユーティリティ関数
(define (cons-alist key datum alist)(cons (cons key datum) alist))
(define (eval1 expr)(eval expr (interaction-environment)))
(define (println first . rest)
  (display first)
  (if (null? rest)
    (newline)
    (apply println rest)
    )
  )

;; 大域変数用ハッシュ表
(define cps-env (make-eqv-hashtable))
;; (define cps-env (make-hash-table)) ;; 2017/7/13 bug 

;; 大域変数 var の値を返す。
(define (get-global-var var)
  (hash-table-ref/key cps-env var)
  )

;; 項 term を値とする変数 var を定義する．
(define (set-global-var var term)
  ;; (println "set-global-var " var "=" term)
  (hash-table-set! cps-env var term))

;; インタプリタによる式の評価を繰り返すかどうかを示すフラグ
(define loop-flag #t)

;; インタプリタを停止する．
(define (interpreter-stop!)
  (set! loop-flag #f)
  )

;; 終了コード
(define exit-code 0)

;; キューを作る
#; (define (make-queue)(cons '( ) '( )))

#|
キュー queue に要素 el を追加する
追加して要素数が１の場合，戻り値は #t
追加して要素数が２つ以上の場合，戻り値は #f
|#
#; (define (enqueue! queue el)
  (let ((first (car queue))(last (cdr queue))(new-last (cons el '( ))))
    (if (null? first)
      (set-car! queue new-last)
      (set-cdr! last new-last))
    (set-cdr! queue new-last)
    (null? first) ; 削除予定
    )
  )

;; キュー queue から要素を取り出す
#; (define (dequeue! queue)
  (let ((first (car queue)))
    (if (null? first)
      '( )
      (begin
	(set-car! queue (cdr first))
	(car first)))
    )
  )

;; キュー queue が空かどうか判定する
#; (define (queue-empty? queue)
  (null? (car queue)))

;; キュー queue の要素が１つだけかどうか判定する
#; (define (queue-one? queue)
  (eq? (car queue)(cdr queue)))

;; キュー queue の先頭の値を返す
#; (define (queue-peek queue)
  (let ((first (car queue)))
    (if (null? first)
      '( )
      (car first))))

;; スレッドセーフなキューを作る
#; (define (make-mt-queue)
  (cons (make-mutex)(make-queue)))

#|
スレッドセーフなキュー queue に要素 el を追加する
追加して要素数が１の場合，戻り値は #t
追加して要素数が２つ以上の場合，戻り値は #f
|#
#; (define (mt-enqueue! queue el)
  (let ((mutex (car queue)))
    (mutex-lock! mutex)
    (let ((flag (enqueue! (cdr queue) el)))
      (mutex-unlock! mutex)
      flag
      )
    )
  )

;; スレッドセーフなキュー queue から要素を取り出す
#; (define (mt-dequeue! queue)
  (let ((mutex (car queue))(el '( )))
    (mutex-lock! mutex)
    (set! el (dequeue! (cdr queue)))
    (mutex-unlock! mutex)
    el)
  )

;; スレッドセーフなキュー queue が空かどうか判定する
#; (define (mt-queue-empty? queue)
  (queue-empty? (cdr queue)))

#; (define (mt-queue-peek queue)
  (queue-peek (cdr queue)))

;; (define test-queue (make-mt-queue))
;; (mt-enqueue! test-queue "aho 1")
;; (mt-enqueue! test-queue "boke 2")
;; (println (mt-dequeue! test-queue))
;; (println (mt-dequeue! test-queue))

;; built-in function: make.queue ^(queue)
;; 空のキューを新たに作り，変数 queue に渡す
(set-global-var 'make.queue
  `(lambda args
     (cons 'quote (make-queue))))
;;     (cons 'quote (make-mt-queue))))

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
#; (let ([mutex (car mailbox)][queue (cdr mailbox)])
(mutex-lock! mutex)
(enqueue! queue message)
(mutex-unlock! mutex))

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
       #; (let ([mutex (car mailbox)][queue (cdr mailbox)])
	 (mutex-lock! mutex)
	 (dequeue! queue)
	 (let ([flag (queue-empty? queue)])
	   (mutex-unlock! mutex)
	   flag))
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
  ;; (println "current-actor=" actor)
  (current-thread-specific-set! actor))
;;  (thread-specific-set! (current-thread) actor))

;; 計算過程のキュー
;; 計算過程は関数適用とアクターの組で表現される
(define app-queue (make-queue))
;; (define app-queue (make-mt-queue))

;; 関数適用 app とアクター actor の組を計算過程のキューに追加する
(define (app-enqueue! app actor)
  ;; (println "app-enqueue! 1 app=" app)
  (queue-add! app-queue (cons app actor))
  ;; (mt-enqueue! app-queue (cons app actor))
  ;; (println "app-enqueue! 2 " app)
  )

#| 2018/9/25 Tue
関数 実引数* . 継続実引数
を command と記述することにする。
これまで app と記述していたが、徐々に書き換えて行く。
|#

;; command: 
(define (start-command command)
  (app-enqueue! command (current-actor)))

;; built-in function: start command ^( )
;; 関数適用 command の計算を開始する
(set-global-var 'start
  '(lambda (command)
     ;; (println "start 1")
     ;; (app-enqueue! app (current-actor))
     (start-command command)
     ;; (println "start 2")
     '( )))

;; 計算過程のキューから関数適用とアクターの組を取り出す
(define (app-dequeue!)
  (if (queue-empty? app-queue) '()
    (queue-remove! app-queue)))
  ;; (mt-dequeue! app-queue))

;; アクターは振舞とメールボックスからなる
;; メールボックスはキューである
(define-type actor behavior mailbox dictionary)
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
  ;; (println "new-actor 1")
  #; (let ((actor (make-actor behavior (make-mt-queue)(make-eqv-hashtable))))
    (println "new-actor 2 mailbox=" (actor-mailbox actor))
    actor)
  (make-actor behavior (make-queue)(make-eqv-hashtable))
  ;; (make-actor behavior (make-mt-queue)(make-eqv-hashtable))
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

;; アクター actor の動作を返す
#; (define (actor-behavior actor)
  (car actor))

;; built-in function: getBehavior ^(behavior)
;; 現在のアクターのメールボックスを変数 mailbox に渡す
(set-global-var 'getBehavior
  '(lambda ( )
     (actor-behavior (current-actor))))

;; アクター actor のメールボックスを返す
#; (define (actor-mailbox actor)
  (cdr actor))

;; built-in function: getMailbox ^(mailbox)
;; 現在のアクターのメールボックスを変数 mailbox に渡す
(set-global-var 'getMailbox
  '(lambda ( )
     (actor-mailbox (current-actor))))

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
#; (define (actor-respond actor)
  (let ((behavior (car actor))(queue (cdr actor)))
    (let ((message (mt-dequeue! queue)))
      (if (not (null? message))
	  (app-enqueue! (list message behavior) actor)
	)
      )
    )
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

;; アクター actor にメッセージ message を送信する
#; (define (send actor message)
  ;; (display "send")(newline)
  ;; (display (cdr (cdr actor)))(newline)
  (if (mt-enqueue! (cdr actor) message)
    (actor-respond actor))
  )

;; built-in function: sendAsync qActor message ^( )
;; quote つきアクター qActor に非同期メッセージ message を送信する
#; (set-global-var 'sendAsync
  '(lambda (qActor message)
     ;; (display "sendAsync")(display message)(newline)
     (send (cdr qActor) message)
     '( )))

;; インタプリタの個数を１つ増やす（スレッドセーフ）
#; (define (interpreter-count-add! n)
  (mutex-lock! interpreter-mutex)
  (set! interpreter-count (+ interpreter-count n))
  (mutex-unlock! interpreter-mutex)
  )

;; ユーザによって定義された main を最初に呼び出す．
(define entry-point 'main)

;; 0.1秒の時間間隔
(define duration100ms (seconds->duration 0.1))
;; 1秒の時間間隔
(define duration1s (seconds->duration 1))

(define (step-loop)
  (let loop ( (app-actor (app-dequeue!)) )
    (if (not (null? app-actor))
      (let ( (actor (cdr app-actor))
	     (timeout (add-duration (current-time) duration100ms)) )
	(current-actor-set! actor)
	; (println (car app-actor))
	(let loop2 ( (app (car app-actor)) )
	  (if (not (null? app))
	    (if (time<? (current-time) timeout)
	      (loop2 (step-app app 'end))
	      ;; (loop2 (step-app app '(^($1) $1 . end)))
	      ;; (loop2 (step-app app '( )))
	      (app-enqueue! app actor))))
	(loop (app-dequeue!)))))
  )

#; (define (step-loop command)
  (if (and loop-flag (not (null? command)))
    (step-loop (step-app command 'end))))

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
	      ((#\e)
	       (set! entry-point (substring arg 2 (string-length arg)))
	       (if (equal? entry-point "")
		   (begin
		     (set! args (cdr args))
		     (set! entry-point (car args))))
	       (set! entry-point (string->symbol entry-point))
	       ))
	    (set! args (cdr args))
	    (loop))))))
  (load-sch-script (car args))
  (app-enqueue! (list entry-point (cdr args))(new-actor "main"))
  (step-loop)
  (exit exit-code))

;; sch-script 言語のファイル filename を読み込む
(define (load-sch-script filename)
  (call-with-input-file filename
    (lambda (port)
      (let loop ( )
	(if (interpret-sexp (read port))
	  (loop))))))

;; S式 sexp を解釈し，実行する．
(define (interpret-sexp sexp)
  (cond
    ((pair? sexp)(interpret-command (car sexp)(cdr sexp)) #t)
    ((eof-object? sexp) #f)
    (else #t)))

;; コマンド cmd，引数 args を解釈し，実行する．
(define (interpret-command cmd args)
  (case cmd
    ((defineCPS)(set-global-var (car args)(cdr args)))))

;; 関数適用 app を一段階実行する．
(define (step-app app defcont)
  ;; (println "step-app " app " defcont=" defcont)
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
	      (apply-func func (pickup-cont-arg args) defcont))
	    ((quote)
	      ; (println "step-app quote")
	      ; (cons (args-to-func args)(cons (car rest) defcont)))
	      (cons (func-with-cont (args-to-func args) defcont) func))
	    ((F.C) ; 継続付き関数 (F.C 関数 . 継続)
	      ;; (println "func=" func ", args=" args)
	      ;; 2019/5/25 継続はトップレベルまで戻るのでdefcontは付けない。
	      (step-app (cons (car rest) args)(cdr rest)))
	    (else ; funcが関数適用
	      ;; (println "step-app else func=" func " args=" args)
	      ;; (step-app func (func-with-cont (cons '^ (cons '($0)(cons '$0 args))) defcont)))
	      (step-app func (func-with-cont (args-to-func args) defcont)))
	      ;; (substitute-term func '( ) args))
	      ;; bug (cons (cons '^ (cons '($0) (cons '$0 func))) args))
	      ;; bug? (substitute-term func cps-env args))
	    )))
      ((null? func)
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
      ((func-with-cont? app)
	'( ))
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
    (cons '^ (cons '($0)(cons '$0 args)))
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
      ;; (let ([flag (and (pair? args)(equal? (car args) "aho"))])
      ;; (println "step-abs 2 args=" args)
      #; (if(pair-terms? args) ; 引数が余った場合
	(set! args (cons '^ (cons '($1)(cons '$1 args))))
	)
      ;; (set! args (func-with-cont args defcont))
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
	  #; (set! env
	    (cons-alist pars
	      (func-with-cont
		(cons '^ (cons '($1)(cons '$1 args)))
		defcont) env)) ; 継続実引数を割り当てる
	  )
	)
      ;; (println "step-abs 3 app=" app " env=" env)
      (set! app (substitute-term app env)) ; 局所変数に値を代入する
      ;; { if flag (println "step-abs 4 (car app)=" (car app)) }
      ;; (println "step-abs 4 app=" app " args=" args)
      ;; 2018/6/24
      (cons (func-with-cont (car app) args)(cdr app))
      )
    )
  )

(define (func-with-cont? func)
  (and (pair? func) (equal? (car func) 'F.C))
  )

;; 継続付き関数を返す。
(define (func-with-cont func cont)
  ;; (cons 'F.C (cons func cont))
  (if (null? func) cont
    (if (null? cont) func
      (cons 'F.C
	(if (func-with-cont? func)
	  ;; (cons (car (cdr func)) (func-with-cont (cdr (cdr func)) cont))
	  (cons func cont)
	  ;; (cons (car (cdr func))(cdr (cdr func)))
	  (cons func cont)
	  ))
      ))
  ;; (if (null? cont) func (if (null? func) cont (cons 'F.C (cons func cont))))
  )

;; termがpairならば #t、そうでなければ #f を返す。
(define (pair-terms? term)
  (and (pair? term)
    (case (car term)
      ((^ lambda quote F.C) #f)
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
    ;; (println "apply-func func=" func " args=" args)
    ;; (list (if (null? cont) defcont cont)(apply (eval1 func) args))))
    (list (func-with-cont cont defcont)(apply (eval1 func) args))
    ])

;; 項 term に含まれる変数を env で対応づけられた値に置き換える。
;; env 環境（変数と値との対応）
(define (substitute-term term env)
  ;; (println "substitute-term " term " env=" env)
  (cond
    ((pair? term)
      (let ((first (car term))(rest (cdr term)))
	(case first
	  ((^)(substitute-abs (car rest)(cdr rest) env))
	  ((F.C)
	    ;; (println "substitute-term F.C rest=" rest)
	    term
	    #; (func-with-cont (substitute-term (car rest) env)
	      ;; (cdr rest)
	      (substitute-term (cdr rest) env)
	      )
	    )
	  ((lambda) term)
	  ((quote) term)
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
  (interpret args)
  )

;; ----- built-in functions -----

#|
end
式の終端
|#
(set-global-var 'end '( ))

(set-global-var 'stop '(end . end))

#|
exit code
スクリプトを終了する
code: 終了コード
|#
(set-global-var 'exit
  `(^(code)
     (lambda (Code)
       (set! exit-code Code)
       (interpreter-stop!)) code . end))
