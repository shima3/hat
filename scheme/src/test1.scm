(load "src/hat.scm")

(define (main-proc cmd . args)
  (define t (new-vtb))
  (set! t (put-vtb t 'c 1))
  (set! t (put-vtb t 'b 1))
  (set! t (put-vtb t 'a 1))
  (set! t (remove-vtb t 'c))
  (print-vtb t)
  )
