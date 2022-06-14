(use srfi-9) ; record

(define (main-proc . args)
  #|
  (defineFreeVar function-table '+ '(^($a $b)(lambda(a b)(+ a b)) $a $b))
  (let( [exp (sexp2HatExp '(^(x) + x 1) '() function-table)]
        [exp2 (sexp2HatExp '(2 ^(v) print v) '() function-table)] )
    (print (HatExp2sexp exp))
    (set! exp (HatFun-apply exp exp2))
    (print (HatExp2sexp exp))
  |#
  (defineFreeVar function-table 'print
    '(^($a . return)
       (lambda(a)
         (apply print a)) $a ^($dummy) return))
  (defineFreeVar function-table 'f
    '(^() print("f1")^()
       g ^ c print("f2")))
  (defineFreeVar function-table 'g '(^() print("g1")^() h ^() print("g2")))
  (defineFreeVar function-table 'h '(^() print("h")))
  (let( [exp (sexp2HatExp '(f) '() function-table)] )
    (let( [task (make-Task exp '() '())] )
      (set! task (stepTask task))(print "main 1 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 2 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 3 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 4 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 5 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 6 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 7 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 8 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 9 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 10 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 11 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 12 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 13 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 14 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 15 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 16 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 17 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 18 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 19 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 20 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 21 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 22 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 23 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 24 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 25 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 26 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 27 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 28 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 29 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 30 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 31 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 32 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 33 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 34 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 35 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 36 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 37 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 38 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 39 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 40 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 41 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 42 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 43 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 44 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 45 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 46 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 47 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 48 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 49 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 50 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 51 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 52 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 53 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 54 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 55 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 56 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 57 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 58 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 59 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 60 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 61 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 62 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 63 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 64 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 65 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 66 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 67 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 68 " (HatExp2sexp (Task-fun task)))
      (set! task (stepTask task))(print "main 69 " (HatExp2sexp (Task-fun task)))
      )
    #|
    (set! exp (HatExp-eval exp))(print "main 1" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 2" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 3" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 4" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 5" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 6" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 7" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 8" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 9" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 10" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 11" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 12" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 13" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 14" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 15" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 16" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 17" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 18" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 19" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 20" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 21" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 22" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 23" (HatExp2sexp exp))
    (set! exp (HatExp-eval exp))(print "main 24" (HatExp2sexp exp))
    |#
    ))

(define-record-type HatFun #t #t
  ;; source ; ソースコードの位置
  pars ; 通常の仮引数のリスト
  ;; contpar ; 継続の仮引数
  funcall ; 関数適用のHatList
  )

;;; lazy substitution list
(define-record-type HatList #t #t
  ;; source ; ソースコードの位置
  formers ; 要素の proper リスト（シンボルはBoundVarまたはFreeVarに置き換える）
  tail ; 末尾の要素（HatExp）
  pars ; 仮引数のリスト（先頭から逆順）（BoundVarではなくシンボル）
  args ; 実引数のリスト（渡された順序の逆）
  parnum ; 仮引数の数-実引数の数
  )

;;; 束縛変数
(define-record-type BoundVar #t #t
  no ; de Bruijn index
  )

;;; 自由変数
(define-record-type FreeVar #t #t
  name
  (value)
  )

;;; source
(define-record-type src-loc #t #t
  file-name
  line-number
  )

(define-record-type Task #t #t
  fun ; 関数 HatFun, HatList, Cont, procedure, ()
  args ; 通常の実引数のリスト HatList
  cont ; 現在の継続 Cont
  )

(define-record-type Cont #t #t
  list ; 関数 HatFun のリスト
  )

(define (stepTask task)
  (let( [fun (Task-fun task)]
        [args (Task-args task)]
        [cont (Task-cont task)] )
    (cond
      [(FreeVar? fun)
        (make-Task (FreeVar-value fun) args cont)]
      [(HatFun? fun)
        (HatFun-apply fun args cont)]
      [(HatList? fun)
        (HatList-apply fun args cont)]
      [(Cont? fun)
        (Cont-apply fun args cont)]
      [(procedure? fun)
        (procedure-apply fun args cont)]
      [(null? fun)
        ;; (if(null? cont)(exit 0)(Cont-apply cont args '()))
        task]
      [else
        (print "Illeagal function: " fun)
        (exit 1)]
      )
    ))

#|
S式sexpを解析し、Hat式を返す。
bounds: 束縛変数のリスト
frees: 自由変数のハッシュ表
|#
(define (sexp2HatExp sexp bounds frees)
  ;; (print "sexp2HatExp sexp=" sexp)
  (cond
    [(pair? sexp)
      (case(car sexp) ;        if(eq? (car sexp) '^)
        ([^]
          (list2HatFun (cdr sexp) bounds frees))
        ([lambda]
          ;; (print "lambda sexp=" sexp)
          (eval sexp '(interaction-environment)))
        (else
          (list2HatList sexp bounds frees))
        )]
    [(symbol? sexp)
      ;; (print "sexp2HatExp symbol " sexp)
      (let( [var (findBoundVar sexp bounds 0)] )
        ;; (print "sexp2HatExp var " var)
        (if(null? var)
          (begin
            ;; (print "sexp2HatExp var 2 " var)
            (getFreeVar sexp frees))
          var))]
    [else sexp]))

#|
list: (p1 p2 ...) f a1 a2 ...
|#
(define (list2HatFun list bounds frees)
  ;; (print "list2HatFun")
  (make-HatFun
    (car list)
    (list2HatList
      (cdr list)
      (push-pars-bounds (car list) bounds)
      frees
      )
    ))

(define (push-pars-bounds pars bounds)
  (if(pair? pars)
    (push-pars-bounds(cdr pars)(cons(car pars) bounds))
    (cons pars bounds)
    ))

(define (list2HatList list bounds frees)
  (let( [cont-first (list2HatExp-cont-first list bounds frees)]
        [pars bounds] )
;;        [pars (reverse-list (car list) bounds)] )
    ;; (print "list=" list)
    ;; (print "pars=" pars)
    (let( [tail (car cont-first)] )
      #; (if(null? tail)
        (set! tail (findBoundVar tail bounds 0)))
      (make-HatList
        (cdr cont-first) ; formers
        tail ; (car cont-first) ; tail
        pars
        '() ; args
        (length pars) ; parnum
        ))))

(define (list2HatExp-cont-first list bounds frees)
  (if(hat-pair? list)
    (let( [cont-first (list2HatExp-cont-first (cdr list) bounds frees)] )
      (cons(car cont-first)
        (cons(sexp2HatExp(car list) bounds frees)(cdr cont-first))
      ))
    (cons(sexp2HatExp list bounds frees) '())
    ))

(define (hat-pair? sexp)
  (if(pair? sexp)
    (case(car sexp)
      ([^] #f)
      (else #t)
      )
    #f))

(define (reverse-list list tail)
  (if(pair? list)
    (reverse-list(cdr list)(cons(car list) tail))
    (cons list tail)))

(define (findBoundVar symbol bounds no)
  ;; (print "findBoundVar " symbol " " bounds " " no)
  (cond
    [(null? bounds)
      ;; (print "bounds=" bounds)
      '()]
    [(eq? symbol (car bounds))
      ;; (print "BoundVar no=" no)
      (make-BoundVar no)]
    [else
      ;; (print "findBoundVar else")
      (findBoundVar symbol (cdr bounds)(+ no 1))]
    ))

(define (getFreeVar symbol frees)
  (let( [var (hash-table-ref/default frees symbol '())] )
    ;; (print "getFreeVar symbol=" symbol " var=" var)
    (if(null? var)
      (let( [var (make-FreeVar symbol '())] )
        (hash-table-set! frees symbol var)
        var)
      var)))

;; (print "Hello")
(define function-table (make-eqv-hashtable))

(define (HatList-pair? exp)
  (and(HatList? exp)(not (null? (HatList-formers exp)))))

(define (HatList-getFirst hatlist)
  (HatList-get hatlist (car(HatList-formers hatlist)))
  )

(define (HatList-getRest hatlist)
  (let( [rest (cdr(HatList-formers hatlist))] )
    (if(null? rest)
      (HatList-getTail hatlist)
      (make-HatList
        rest ; (cdr(HatList-elements hatlist))
        (HatList-tail hatlist)
        (HatList-pars hatlist)
        (HatList-args hatlist)
        (HatList-parnum hatlist)
        ))))

(define (HatList-getTail hatlist)
  (HatList-get hatlist (HatList-get-tail hatlist)))

(define (HatList-get hatlist el)
  (cond
    [(BoundVar? el)
      (HatList-getBoundVar hatlist (BoundVar-no el)(HatList-parnum hatlist))]
    ;; [(FreeVar? el)(FreeVar-name el)]
    [else el]
    ))

(define (HatList-getBoundVar hatlist no parnum)
  (let
    ( [value
        (if(< no parnum)
          (list-ref (HatList-pars hatlist) no)
          (list-ref (HatList-args hatlist)(- no parnum))
          )] )
    ;; (print "no=" no ", parnum=" parnum ", value=" value)
    ;; (print "pars=" (HatList-pars hatlist) ", args=" (HatList-args hatlist))
    value
    ))

(define (HatExp2sexp hatexp)
  (cond
    [(HatFun? hatexp)
      (cons '^
        (cons(HatFun-pars hatexp)
          (HatList2sexp(HatFun-funcall hatexp))))]
    [(HatList? hatexp)
      (HatList2sexp hatexp)]
    [(FreeVar? hatexp)
      (FreeVar-name hatexp)]
    [else
      hatexp]
    ))

(define (HatList2sexp hatlist)
  (if(HatList-pair? hatlist)
    (cons(HatExp2sexp(HatList-getFirst hatlist))
      (HatExp2sexp(HatList-getRest hatlist)))
    (HatExp2sexp hatlist)
    ))

(define (HatFun-apply fun args cont)
  (let( [funcall (HatFun-funcall fun)] )
    ;; (print "HatFun-apply 01 pars=" (HatList-pars funcall))
    ;; (print "HatFun-apply 02 args=" (HatList-args funcall))
    (let loop
      ( [pars (HatFun-pars fun)]
        [args args]
        [allargs (HatList-args funcall)]
        [parnum (HatList-parnum funcall)] )
      ;; (print "HatFun-apply 1 args=" (HatExp2sexp args))
      ;; (print "HatFun-apply 5 allargs=" (HatExp2sexp allargs))
      (cond
        [(HatList-pair? args)
          (if(pair? pars)
            (loop
              (cdr pars)
              (HatList-getRest args)
              (cons(HatList-getFirst args) allargs)
              (- parnum 1)
              )
            (make-Task funcall args cont)
            #; (HatList-set-args funcall
              (cons
                (make-HatFun '($0) (make-HatList '($0) args '() '() 0))
                allargs)
              (- parnum 1))
            )]
        [(null? args)
          #|
          (print "HatFun-apply 3 pars=" pars " args=" args)
          (print "HatFun-apply 4 funcall=" (HatList2sexp funcall))
          (print "HatFun-apply 6 allargs=" (map HatExp2sexp allargs))
          |#
          (if(pair? pars) ; 通常の仮引数が余っているか？
            (make-Task cont ; 部分適用した結果を現在の継続に渡す。
              (make-HatList
                (list (make-HatFun pars
                        (HatList-set-args funcall allargs parnum)))
                '() '() '() 0)
              '())
            (make-Task ; 継続の仮引数に現在の継続を代入する。
              (HatList-set-args funcall (cons cont allargs)(- parnum 1))
              '() cont)
            )]
        [(Cont? args)
          (if(pair? pars) ; 通常の仮引数が余っているか？
            (make-Task args ; 部分適用した結果を継続の実引数に渡す。
              (make-HatList
                (list (make-HatFun pars
                        (HatList-set-args funcall allargs parnum)))
                '() '() '() 0)
              '())
            (make-Task ; 継続の実引数を現在の継続に追加して継続の仮引数に渡す。
              (HatList-set-args funcall (cons args allargs)(- parnum 1))
              '() args))
          ]
        [else ; 継続の実引数がある場合
          ;; (unless(pair? pars)(print "HatFun-apply 2 args=" args))
          ;; (print "HatFun-apply 7 allargs=" (map HatExp2sexp allargs))
          (if(pair? pars) ; 通常の仮引数が余っているか？
            (make-Task args ; 部分適用した結果を継続の実引数に渡す。
              (make-HatList
                (list (make-HatFun pars
                        (HatList-set-args funcall allargs parnum)))
                '() '() '() 0)
              cont)
            (let( [cont2 (push-Cont args cont)] )
              (make-Task ; 継続の実引数を現在の継続に追加して継続の仮引数に渡す。
                (HatList-set-args funcall (cons cont2 allargs)(- parnum 1))
                '() cont2))
            )]
        ))))

(define (Cont-getFirst cont)
  (car (Cont-list cont)))

(define (pop-Cont cont)
  (make-Cont (cdr (Cont-list cont))))

(define (push-Cont first rest)
  (if(null? rest)
    (make-Cont (list first))
    (make-Cont (cons first (Cont-list rest)))
    ))

(define (flat-first-Cont cont)
  (make-Cont (flat-first-list (Cont-list cont))))

#|
(((1) 2) 3) -> (1 (2) 3)
|#
(define (flat-first-list list)
  (if(pair? list)
    (let( [first (flat-first-list (car list))]
          [rest (cdr list)] )
      (if(pair? first)
        (let( [car-first (car first)]
              [cdr-first (cdr first)] )
          (cons car-first (if(null? cdr-first) rest (cons cdr-first rest))))
        (cons first rest)
        ))
    list
    ))

(define (HatList-apply fun args cont)
  (let( [first (HatList-getFirst fun)]
        [rest (HatList-getRest fun)] )
    (make-Task first rest
      (if(null? args)
        cont
        (push-Cont (args2HatFun args) cont)
        ))
    ))

(define (args2HatFun args)
  (make-HatFun tmpPar (make-HatList BoundVar1 args tmpPar2 '() 2)))

(define tmpPar '($0))
(define tmpPar2 '(() $0))
(define BoundVar1 (list (make-BoundVar 1)))

(define (Cont-apply fun args cont)
  (let( [flat-first (flat-first-Cont fun)]
        [cont-first (HatList-cont-first args)] )
    ;; (print "Cont-apply flat-first=" flat-first)
    (if(Cont-empty? flat-first)
      (make-Task cont args '())
      (let( [contarg (car cont-first)]
            [usualargs (cdr cont-first)]
            [restcont (pop-Cont flat-first)] )
        (make-Task (Cont-getFirst flat-first) usualargs
          (cond
            [(Cont? contarg)(push-Cont restcont contarg)]
            [(null? contarg) restcont]
            [else (push-Cont contarg restcont)]
          ))))))

(define (Cont-empty? cont)
  (or(null? cont)(null? (Cont-list cont))))

(define (HatList-cont-first hatlist)
  (cond
    [(null? hatlist) '(())]
    [(HatList? hatlist)
      (if(HatList-pair? hatlist)
        (let( [cont-first (HatList-cont-first (HatList-getRest hatlist))] )
          (cons (car cont-first)
            (cons (HatList-getFirst hatlist)(cdr cont-first))))
        (HatList-getTail hatlist)
        )]
    [else (list hatlist)]))

(define (procedure-apply fun args cont)
  (let( [cont-first (HatList-cont-first args)] )
    (make-Task (car cont-first)
      (call-with-values
        (lambda()(apply fun (map HatExp2sexp (cdr cont-first))))
        (lambda results (sexp2HatExp results '() '())))
      cont)))

(define (HatList-set-args hatlist args parnum)
  #|
  (print "HatList-set-args 1 old args=" (HatList-args hatlist))
  (print "HatList-set-args 2 new args=" args)
  (print "HatList-set-args 3 old parnum=" (HatList-parnum hatlist))
  (print "HatList-set-args 4 new parnum=" parnum)
  (print "HatList-set-args 5 pars=" (HatList-pars hatlist))
  |#
  (make-HatList
    (HatList-formers hatlist)
    (HatList-tail hatlist)
    (HatList-pars hatlist)
    args
    parnum
    ))

(define (HatList-get-tail hatlist)
  (let( [tail (HatList-tail hatlist)] )
    (if(HatFun? tail)
      (make-HatFun(HatFun-pars tail)
        (HatList-set-args(HatFun-funcall tail)
          (HatList-args hatlist)
          (- (length (HatList-pars (HatFun-funcall tail)))
            (length (HatList-args hatlist)))))
      tail
      )))

(define (defineFreeVar table symbol sexp)
  (FreeVar-value-set! (getFreeVar symbol table) (sexp2HatExp sexp '() table)))

(define (HatList-eval hatlist)
  ;; (print "HatList-eval hatlist=" (HatList2sexp hatlist))
  (let( [fun (HatList-getFirst hatlist)]
        [args (HatList-getRest hatlist)] )
    #|
    (print "HatList-eval 1 fun=" fun)
    (print "HatList-eval 2 fun=" (HatList2sexp fun))
    (cond
      [(FreeVar? fun)
        (print "HatList-eval 7 fun=" fun)
        (set! fun (FreeVar-value fun))
        (print "HatList-eval 8 fun=" fun)
        ]
      )
    (print "HatList-eval 3 fun=" (HatExp2sexp fun) " args=" (HatList2sexp args))
    (when(HatList? args)
      (print "HatList-eval 4 args.pars=" (HatList-pars args) " args.args=" (HatList-args args))
      (let( [tail (HatList-tail args)] )
        (when(HatFun? tail)
          (let( [funcall (HatFun-funcall tail)] )
            (print "HatList-eval 5 tail.pars=" (HatList-pars funcall))
            (print "HatList-eval 6 tail.args=" (HatList-args funcall))
        ))))
    |#
    (cond
      [(HatFun? fun)
        ;; (print "HatFun-apply fun=" fun " args=" args)
        (HatFun-apply fun args)]
      [(procedure? fun)
        ;; (print "procedure fun " fun)
        (HatList-apply-procedure fun args)]
      [else hatlist]
      )
    ))

(define (HatList-apply-procedure fun args)
  #|
  (print "HatList-apply-procedure 1 args.pars=" (HatList-pars args))
  (print "HatList-apply-procedure 3 args.args=" (HatList-args args))
  (let( [tail (HatList-tail args)] )
    (print "HatList-apply-procedure 2 tail=" (HatExp2sexp tail))
    (if(HatFun? tail)
      (let( [funcall (HatFun-funcall tail)] )
        (print "tail.pars=" (HatList-pars funcall)
          " tail.args=" (HatList-args funcall))
        )))
  |#
  (make-HatList
    (cons(HatList-get-tail args) ; (HatList-get args (HatList-tail args))
      (map(lambda(result)(sexp2HatExp result '() function-table))
        (call-with-values
          (lambda()
            (let( [sexpargs (HatList2sexpArgs args)] )
              (apply fun sexpargs)))
          (lambda results ; (print "results=" results)
            results)
          )))
    '() '() '() 0))

(define (HatList2sexpArgs hatlist)
  (if(HatList-pair? hatlist)
    (cons(HatExp2sexp(HatList-getFirst hatlist))
      (HatList2sexpArgs(HatList-getRest hatlist)))
    '()))

(define (HatExp-eval exp)
  (cond
    [(HatList? exp)
      (print "HatExp-eval 1 exp=" exp)
      (HatList-eval exp)]
    [(HatFun? exp)
      (HatFun-apply exp '())]
    [else exp]
    ))
