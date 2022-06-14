(define (main-proc . args)
  ;; (print "args=" args)
  (push-sch-load-path (string-append (sys-dirname (car args)) "/../include2/"))
  (push-sch-load-path "./")
  (print sch-load-path-list)
  (load-sch-file (car (cdr args)) sch-load-path-list)
  (let loop
    ( [task (make-Task (sexp2HatExp '(main) '() function-table) '() '())] )
    (unless(null? (Task-fun task))
      (loop (stepTask task))
      )))

;;; Hat式データ構造 ----------------------------

#|
^(a1 a2) a1 (a2 a1) (^(b1) a2 b1) (^(c1 . c2) a1 c2) ^ d1 a2 d1
の場合
[a2 a1] a1#1 (a2#0 a1#1) ([b1 a2 a1] a2#1 b1#0) ([c2 c1 a2 a1] a1#3 c2#0) [d1 a2 a1] a2#1 d1#0
|#

#|
define-record-type 型名 コンストラクタ 型判定 フィールド ...
コンストラクタが#tならば (make-型名 初期値 ...) を生成する。
型判定が#tならば (型名? 値) を生成する。
フィールドはシンボルならば変更不能。(型名-フィールド レコード) でアクセス
フィールドが(シンボル)ならば変更可能。(型名-フィールド! レコード 値) で変更
|#

(define-record-type HatFun #t #t
  pars ; 仮引数のリスト
  funcall ; 関数適用を示すHatList
  )

(define (HatFun-print hatfun)
  (print "(record HatFun ")
  (display "\tpars: ")
  (print (HatFun-pars hatfun))
  (display "\tfuncall")
  (print (HatFun-funcall hatfun))
  )

#|
list -> seq
(a1 a2 ...) -> ^($0) $0 a1 a2 ...
HatList
|#

;; lazy substitution list
(define-record-type HatList #t #t
  source ; ソースコードの位置
  ;; 実行時エラーのほとんどは関数適用で発生する。
  bounds ; 束縛変数のリスト
  ;; 仮引数のリストとは逆順
  ;; 継続の仮引数も含む。
  ;; 入れ子になったHatFunのすべての仮引数を含む。
  ;; 要素はBoundVarではなくシンボル
  args ; 実引数のリスト
  ;; 渡された順序とは逆順
  ;; 入れ子になったHatFunに渡されたすべての実引数を含む。
  parnum ; 仮引数の数=束縛変数の数-実引数の数
  elements ; 要素の proper リスト
  ;; シンボルはBoundVarまたはFreeVarに置き換える。
  tail ; 末尾の要素
  ;; シンボルはBoundVarまたはFreeVarに置き換える。
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

(define-record-type Task #t #t
  fun ; 関数 HatFun, HatList, Cont, procedure, ()
  args ; 通常の実引数のリスト HatList
  cont ; 現在の継続 Cont
  )

(define-record-type Cont #t #t
  list ; 関数 HatFun のリスト
  )

;;; S式 -> Hat式 変換 -------------------

#|
S式sexpを解析し、Hat式を返す。
bounds: 束縛変数のリスト
frees: 自由変数のハッシュ表
|#
(define (sexp2HatExp sexp bounds frees)
  ;; (print "sexp2HatExp sexp=" sexp)
  (cond
    [(pair? sexp) ; sexpがリストの場合
      (case(car sexp) ;        if(eq? (car sexp) '^)
        ([^] ; sexpの先頭が^の場合
          (list2HatFun (cdr sexp) bounds frees))
        ([lambda] ; sexpの先頭がlambdaの場合
          ;; (print "lambda sexp=" sexp)
          (eval sexp '(interaction-environment)))
        (else ; sexpが通常のリストの場合
          (list2HatList sexp bounds frees))
        )]
    [(symbol? sexp) ; sexpがシンボルの場合
      ;; (print "sexp2HatExp symbol " sexp)
      (let( [var (findBoundVar sexp bounds 0)] ) ; boundsからsexpを探す
        ;; (print "sexp2HatExp var " var)
        (if(null? var) ; boundsにsexpがなかった場合
          (begin
            ;; (print "sexp2HatExp var 2 " var)
            (getFreeVar sexp frees)) ; freesにあればそれを、なければsexpを返す
          var))] ; boundsにsexpがあれば、de Bruijn indexを返す
    [else sexp])) ; リストでもシンボルでもなければsexpをそのまま返す

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
  (if(HatList? exp)
    (if(null? (HatList-elements exp))
      (HatList-pair? (HatList-tail exp))
      #t)
    (pair? exp)))

(define (HatList-getFirst list)
  (if(HatList? list)
    (HatList-get list (car(HatList-elements list)))
    (car list)
    ))

(define (HatList-getRest list)
  (if(HatList? list)
    (let( [rest (cdr(HatList-elements list))] )
      (if(null? rest)
        (HatList-getTail list)
        (make-HatList
          rest ; (cdr(HatList-elements hatlist))
          (HatList-tail list)
          (HatList-pars list)
          (HatList-args list)
          (HatList-parnum list)
          )))
    (cdr list)
    ))

(define (HatList-getTail hatlist)
  (HatList-get hatlist (HatList-get-tail hatlist)))

;; hatlistにおける要素elを示す値を返す
;; elが束縛変数の場合、それに割り当てられた値に置き換えて返す。
(define (HatList-get hatlist el)
  (cond
    [(BoundVar? el)
      (HatList-getBoundVar hatlist (BoundVar-no el)(HatList-parnum hatlist))]
    ;; [(FreeVar? el)(FreeVar-name el)]
    #; [(HatList? el)
      (let( [parslen (length (HatList-pars el))]
            [argslen (length (HatList-args el))] )
        (HatList-print el)
        (print "HatList-get parslen=" parslen " argslen=" argslen)
        )
      el]
    #; [(list? el)
      (print "HatList-get list=" el)
    el]
    [(HatList? el)
      (HatList-set-args el (HatList-args hatlist)
        (- (HatList-pars el)(length (HatList-args hatlist))))]
    [(HatFun? el)
      (make-HatFun (HatFun-pars el)
        (HatList-set-args (HatFun-funcall el)(HatList-args hatlist)
          (- (length (HatFun-pars el))(length (HatList-args hatlist)))))]
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

;;; Hat式 -> S式 変換 -------------------

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

;;; Hat式演算 ----------------------

(define (stepTask task)
  (let( [fun (Task-fun task)]
        [args (Task-args task)]
        [cont (Task-cont task)] )
    (print "stepTask fun=" (HatExp2sexp fun))
    (print "stepTask raw args=" args)
    (print "stepTask sexp args=" (HatList2sexp args))
    (print "stepTask cont=" (if(Cont? cont)(Cont-list cont) cont))
    (cond
      [(FreeVar? fun)
        (print "stepTask FreeVar name=" (FreeVar-name fun))
        (print "stepTask FreeVar value=" (FreeVar-value fun))
        (make-Task (FreeVar-value fun) args cont)]
      [(HatFun? fun)
        (HatFun-apply fun args cont)]
      [(HatList? fun)
        (print "stepTask HatList fun=" (HatList2sexp fun))
        (HatList-apply fun args cont)]
      [(Cont? fun)
        (print "stepTask Cont fun=" (Cont-list fun))
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

(define (HatFun-apply fun args cont)
  (let( [funcall (HatFun-funcall fun)] )
    (print "HatFun-apply 1 funcall.pars=" (HatList-pars funcall))
    (print "HatFun-apply 2 funcall.args=" (HatList-args funcall))
    (let loop
      ( [pars (HatFun-pars fun)]
        [args args]
        [allargs (HatList-args funcall)]
        [parnum (HatList-parnum funcall)] )
      (print "HatFun-apply 3 parnum=" parnum)
      (print "HatFun-apply 4 pars=" (HatExp2sexp pars))
      (print "HatFun-apply 5 args=" (HatExp2sexp args))
      (print "HatFun-apply 5.1 args=" args)
      (print "HatFun-apply 6 allargs=" (HatExp2sexp allargs))
      (cond
        [(HatList-pair? args)
          (if(pair? pars)
            (loop
              (cdr pars)
              (HatList-getRest args)
              (cons(HatList-getFirst args) allargs)
              (- parnum 1)
              )
            ;; (make-Task funcall args cont)
            (let( [cont-first (HatList-cont-first args)] )
              (print "HatFun-apply 7 cont-first=" (HatExp2sexp cont-first))
              (let( [usualargs (cdr cont-first)]
                    [contarg (car cont-first)] )
                (let( [cont2
                        (push-Cont (args2HatFun usualargs)
                          (if(null? contarg) cont (push-Cont contarg cont))
                          )] )
                  (make-Task
                    (HatList-set-args funcall (cons cont2 allargs) (- parnum 1))
                    '() cont2)
                  ))))]
        [(null? args)
          (print "HatFun-apply 8 pars=" pars)
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
          (print "HatFun-apply 9 pars=" pars)
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
          (print "HatFun-apply 10 pars=" pars)
          (print "HatFun-apply 11 args=" args)
          ;; (unless(pair? pars)(print "HatFun-apply 2 args=" args))
          ;; (print "HatFun-apply 7 allargs=" (map HatExp2sexp allargs))
          (if(pair? pars) ; 通常の仮引数が余っているか？
            (make-Task args ; 部分適用した結果を継続の実引数に渡す。
              (make-HatList
                (list (make-HatFun pars
;;                        (HatList-set-args funcall allargs parnum)))
                        (HatList-set-args funcall allargs parnum)))
                '() (HatList-pars funcall) allargs parnum)
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
  (HatList-print fun)
  ;; (print "HatList-apply fun=" (HatExp2sexp fun))
  (print "HatList-apply args=" (HatExp2sexp args))
  (if(Cont? cont)
    (print "HatList-apply cont=" (map HatExp2sexp (Cont-list cont)))
    )
  (let( [first (HatList-getFirst fun)]
        [rest (HatList-getRest fun)] )
    (make-Task first rest
      (cond
        [(HatList-pair? args)
          (push-Cont (args2HatFun args) cont)]
        [(null? args) cont]
        [else (push-Cont args cont)]
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
        (make-Task (Cont-getFirst flat-first)
          usualargs
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
    (print "procedure-apply cont-first=" cont-first)
    ;; (if(HatList? (car (cdr cont-first)))(HatList-print (car (cdr cont-first))))
    (let( [usualargs (map HatExp2sexp (cdr cont-first))]
          [contarg (car cont-first)] )
      (print "procedure-apply usualargs=" usualargs)
      (set! contarg (if(null? contarg) cont (push-Cont contarg cont)))
      (make-Task contarg
        (call-with-values (lambda()(apply fun usualargs))
          (lambda results (sexp2HatExp results '() '())))
        '()
        ))))

(define (HatList-print hatlist)
  (print "HatList-print elements=" (HatList-elements hatlist))
  (print "HatList-print tail=" (HatList-tail hatlist))
  (print "HatList-print pars=" (HatList-pars hatlist))
  (print "HatList-print args=" (HatList-args hatlist))
  (print "HatList-print parnum=" (HatList-parnum hatlist))
  )

(define (HatList-set-args hatlist args parnum)
  #|
  (print "HatList-set-args 1 old args=" (HatList-args hatlist))
  (print "HatList-set-args 2 new args=" args)
  (print "HatList-set-args 3 old parnum=" (HatList-parnum hatlist))
  (print "HatList-set-args 4 new parnum=" parnum)
  (print "HatList-set-args 5 pars=" (HatList-pars hatlist))
  |#
  (make-HatList
    (HatList-elements hatlist)
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

;;; schファイル処理 ---------------------

(define sch-load-path-list '())

(define (push-sch-load-path path)
  (set! sch-load-path-list (cons path sch-load-path-list)))

(define (pop-sch-load-path)
  (set! sch-load-path-list (cdr sch-load-path-list)))

(define (load-sch-file filename pathlist)
  (define port&path (open-input-file-in-pathlist filename pathlist))
  (when(null? port&path)
    (print "*** ERROR: cannot find \"" filename "\" in " pathlist)
    (exit 1))
  (let( [port (car port&path)]
        [path (car (cdr port&path))] )
    (print "open " path)
    ;; (push-sch-load-path (get-path path))
    (let loop ( [sexp (read port)] )
      (when(not (eof-object? sexp))
        ;; (print sexp)
        (case (car sexp)
          ([include]
            ;; (print "include " (car (cdr sexp)))
            (load-sch-file (car (cdr sexp)) (cons (get-path path) pathlist))
            )
          ([defineCPS]
            (let( [rest (cdr sexp)] )
              (print "defineCPS " (car rest))
              (defineFreeVar function-table (car rest)(cdr rest))
              ))
          (else
            (print "Error: unknown command: " sexp)))
        (loop (read port))
        ))
    (print "close " path)
    (close-port port)
    ;; (pop-sch-load-path)
    ))

#|
ディレクトリ名のリストpathlistの各ディレクトリでファイ名filenameのファイルを探す。
見つかった場合、そのファイルをオープンし、そのポートとフルパスのリストを返す。
見つからなかった場合、空リストを返す。
|#
(define (open-input-file-in-pathlist filename pathlist)
  (if(null? pathlist) '()
    (let( [filepath (string-append (car pathlist) filename)] )
      (let( [port (open-input-file-or-exception filepath)] )
        (if(port? port)(list port filepath)
          (open-input-file-in-pathlist filename (cdr pathlist))
          )))))

(define (open-input-file-or-exception filename)
  (call-with-current-continuation
    (lambda(k)
      (with-exception-handler
        (lambda(ex)(k #f))
        (lambda()(open-input-file filename))))))

(define(get-path filename)
  (let([index (string-index-right filename #\/)])
    (if(number? index)
      (string_substring filename 0 (+ index 1))
      #f
      )))
