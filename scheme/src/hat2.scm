(define (main-proc . args)
  (print "begin")
  (print (list? 'a))
  ;; (display-IExp (SExp->IExp '(x ("hoge" w) v) '(v w x)))
  ;; (print)
  #; (let ((bv (make-BVar 'x 2)))
    (print bv)
    (print (BVar-name bv))
    (print (BVar-index bv))
  )
  (print "end")
  )

#|
IExp: Indexed Expression
束縛変数を de Bruijn index で表現した式
|#

(define (display-IExp iexp)
  (cond
    ((BVar? iexp)
      (display-BVar iexp))
    ((list? iexp)
      (display-list-of-IExp iexp))
    (* (write iexp))
    ))

(define (display-list-of-IExp list)
  (display "(")
  (unless (null? list)
    (display-IExp (car list))
    (let loop ((rest (cdr list)))
      (unless (null? rest)
        (display " ")
        (display-IExp (car rest))
        (loop (cdr rest)))))
  (display ")")
  )

#|
(define-record-type FVar #t #t ; 自由変数
  name ; シンボル
  index ; 出現順
  )
|#

(define (SExp->IExp sexp bvars)
  (cond
    ( (null? sexp)
      '()
      )
    ( (list? sexp)
      (if (eq-first? '^ sexp)
        (make-HExp (cdr sexp))
        (List->IExp sexp bvars)
        )
      )
    ( (symbol? sexp)
      (let ((index (find-sexp-in-list sexp bvars)))
        (if (< index 0) sexp
          (make-BVar sexp index)
          )
        )
      )
    ( *
      sexp
      )
    ))

(define (eq-first? sexp list)
  (if (null? list) #f
    (eq? sexp (car list))))

(define (List->IExp list bvars)
  (if (null? list) '()
    (cons (SExp->IExp (car list) bvars)
      (List->IExp (cdr list) bvars))
    ))

#|
listからsexpを探す。
見つかった場合、先頭を0とする番号で位置を返す。
見つからなかった場合、-1を返す。
|#
(define (find-sexp-in-list sexp list)
  (if (null? list) -1
    (if (eq? sexp (car list)) 0
      (let ((index (find-sexp-in-list sexp (cdr list))))
        (if (< index 0) -1
          (+ index 1)
          )))))

;;; データ構造

(define-record-type Task #t #t
  fun ; 関数（AHExp, AList, HExp, リスト、シンボル）
  args ; 実引数列（リスト）
  contArg ; 継続の実引数（AHExp、AList、リスト）
  contStack ; 継続スタック（リスト）
  dict ; 辞書（ハッシュ表）
  props ; 属性表（ハッシュ表）
  )

#|
taskを1段階実行する。
次の段階が残っている場合は #t、残っていない場合は #f を返す。

funが関数のとき、関数適用する。
funがprocedureのとき、

|#
(define (step-Task task)
  (let( [fun (Task-fun task)]
        [args (Task-args task)]
        [conta (Task-contArg task)]
        [conts (Task-contStack task)] )
    (cond
      [(procedure? fun) ; 関数がlambda式の場合
        ]
      [(list? fun) ; 関数がリストの場合
        (Task-fun-set! task (car args))
        (Task-args-set! task fun)
        (Task-contArg-set! task (cdr args))
        (Task-contStack-set! task (cons conta conts))
        #t]
      [(AList? fun) ; 関数がAListの場合
        #t]
      [(AHExp? fun)  ; 関数がハット式の場合
        (step-Task-AHExp task fun)]
      [*
        #| 処理が複雑なので後回し
        (if (null? conts) #f
          (begin
            (Task-fun-set! task (car conts))
            (Task-args-set! task (cons fun args))
            (Task-contStack-set! task (cdr conts))
        #t))
        |#
        ]
      )))

(define (step-Task-AHExp task fun)
  (let loop (
              ( args (Task-args task) )
              ( bvals (AHExp-bvals fun) )
              ( parnum (AHExp-parnum fun) )
              )
    (if (> parnum 0)
      (if (null? args)
        (let (
               ( conts (Task-conts task) )
               ( hexp (AHExp-hexp fun) )
               )
          (Task-args-set! task (list (make-AHExp hexp bvals parnum)))
          (Task-fun-set! task (car conts))
          (Task-conts-set! task (cdr conts))
          )
        (loop
          (cdr args)
          (cons (car args) bvals)
          (- parnum 1)
          )
        )
      (let (
             ( hexp (AHExp-hexp fun) )
             ( conts (cons args (Task-conts task)) )
             )
        (Task-fun-set! task (assign (HExp-fun hexp) bvals))
        (Task-args-set! task (assign-list (HExp-args hexp) bvals))
        (Task-conts-set! task (cons (assign (HExp-cont hexp) bvals) conts))
        )
      )
    )
  )

#|
束縛変数への値の割り当て済み
AHExp
AList
|#

(define-record-type AHExp #t #t ; Assigned Hat Expression
  hexp ; HExp
  bvals ; 束縛変数の値のリスト（関数適用順の逆順）
  parnum ; 残りの仮引数の数
  )

(define (assign exp bvals)
  (cond
    ( (HExp? exp)
      (make-AHExp exp bvals (HExp-parnum exp))
      )
    ( (list? exp)
      (make-AList exp bvals)
      )
    ( (BVar? exp)
      (let loop ( ( index (BVar-index exp) )
                  ( list bvals ) )
        (if (> index 0)
          (loop (- index 1) (cdr list))
          (car list))
        ))
    ( *
      exp
      )))

(define (assign-list list bvals)
  (map (lambda (exp) (assign exp bvals)) list))

(define (AHExp-fun ahexp) ; AHExpのhexpのfunをassignして返す。
  (assign (HExp-fun (AHExp-hexp ahexp)) (AHExp-bvals ahexp))
  )

(define (AHExp-cont ahexp)
  (assign (HExp-cont (AHExp-hexp ahexp)) (AHExp-bvals ahexp))
  )

(define-record-type AList #t #t ; Assigned List
  list ; リスト
  bvals ; 束縛変数の値のリスト（関数適用順の逆順）
  )

(define-record-type HExp #t #t ; Hat Expression ハット式
  bvars ; 束縛変数のリスト（出現順の逆順）
  parnum ; 仮引数の数
  fun ; 関数
  args ; 実引数のリスト
  cont ; 継続 HExp
  )

(define-record-type BVar #t #t ; 束縛変数
  name ; シンボル
  index ; de Bruijn index (0 based)
  )

(define (display-BVar bv)
  (display "#(BVar name: ")
  (display (BVar-name bv))
  (display " index: ")
  (display (BVar-index bv))
  (display ")")
  )
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTYwNDM3OTA2XX0=
-->