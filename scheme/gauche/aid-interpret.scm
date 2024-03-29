(use gauche.threads)
;; (use util.queue)
(use gauche.net)
(use srfi-9) ; record
(use srfi-13)
(use srfi-19)
(use srfi-69)
;; (use srfi-99)
;; not implemented (use srfi-115)
(use srfi-117)

(define-macro (define-record Name . Fields)
  (cons 'define-record-type
    (cons Name
      (cons
	(cons (string->symbol (string-append "make-" (symbol->string Name)))
	  Fields)
	(cons (string->symbol (string-append (symbol->string Name) "?"))
	  (map list Fields)))))
  )

(define (seconds->duration sec)
  (receive (ns s)(modf sec)
    (set! ns (x->integer (* ns 1000000000)))
    (set! s (x->integer s))
    (make-time 'time-duration ns s)))
(define (fork-thread thunk)
  (thread-start! (make-thread thunk)))
(define sleep thread-sleep!)
(define (current-thread-specific)
  (thread-specific (current-thread))
  )
(define (current-thread-specific-set! value)
  (thread-specific-set! (current-thread) value)
  )
(define (make-eqv-hashtable)
  (make-hash-table eqv?))
(define (hash-table-ref/key table key)
  ;; (hash-table-get table key key)
  (hash-table-ref/default table key key)
  #; (guard (e (else key))
  (hash-table-ref/default table key key))
  )
;;; (hash-table-set! table key value)

(define (make_queue)
  (make-list-queue '()))
(define (queue_empty? queue)
  (list-queue-empty? queue))
(define (queue_front queue)
  (list-queue-front queue))
(define (queue_add! queue el)
  (list-queue-add-back! queue el))
(define (queue_remove! queue)
  (list-queue-remove-front! queue))
(define current_time current-time)
(define string_substring substring)

(define selector-input-table (make-eqv-hashtable))
(define (port->fd port)(car (sys-fdset->list (sys-fdset port))))
(define (selector-set-input-handler in handler)
  (hash-table-set! selector-input-table (port->fd in) handler))
(define (selector-reset-input-handler in)
  (hash-table-delete! selector-input-table (port->fd in)))
(define (selector-dispatch)
  (let ( [readfds (list->sys-fdset (hash-table-keys selector-input-table))] )
    ;; (print "read fds: " (sys-fdset->list readfds))
    (sys-select! readfds #f #f '(1 0))
    (dolist (fd (sys-fdset->list readfds))
      (let ( [handler (hash-table-ref/default selector-input-table fd #f)] )
	(if handler (start-command handler))))))

(define (with-input-file-exception-handler
          file-name input-file exception-handler)
  (call-with-current-continuation
    (lambda(k)
      (with-exception-handler
        (lambda(ex)
          (k (exception-handler ex)))
        (lambda()
          (call-with-input-file file-name input-file))))))

(define (eval1 expr)
  (if(procedure? expr) expr
    (eval expr (interaction-environment))))

(define port-read-line read-line)
(define string-cat string-concatenate)
(define port-close close-port)

#; (define (regexp-search regexp str)
  (define match (rxmatch regexp str))
  (if match (list #t (rxmatch-start match)(rxmatch-end match)) '(#f)))

(define (regexp-search regexp str)
  (let ( [match (rxmatch regexp str)] )
    (if match
      (list #t (rxmatch-start match)(rxmatch-end match))
      '(#f)
      )))

(define (write-list list)
  (display "(")
  (when(pair? list)
    (write-object (car list))
    (let loop
      ( [list3 (cdr list)] )
      (cond
        [(pair? list3)
          (display " ")
          (write-object (car list3))
          (loop (cdr list3))]
        [(not (null? list3))
          (display " . ")
          (write-object list3)])))
  (display ")"))

(define (write-object obj)
  (cond
    [(list? obj)
      (write-list obj)]
    #; [(keyword? obj)
      (display obj)]
    [else
      (write obj)]))

(define (print . list)
  (if(pair? list)
    (let( [first (car list)]
          [rest (cdr list)] )
      (if(string? first)
	(display first)
	(write-object first))
      (apply print rest))
    (newline)
    ))

(add-load-path ".")
(load (car (cdr (command-line))))
(apply main-proc (cdr (command-line)))
