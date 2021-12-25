(import (chicken process-context))

(define (main-proc . args)(display "main-proc ")(print args))
(print (program-name))
(print (command-line-arguments))
;; (exit 0)
