(import (chicken process-context))
(import (srfi 34))
(import (srfi 35))

(define (with-input-file-or-exception file-name input-file)
  (call-with-current-continuation
    (lambda(k)
      (with-exception-handler
        (lambda(ex)(k ex))
        (lambda()
          (call-with-input-file file-name input-file))))))

(print "command line: " (command-line-arguments))
(define ex
  (with-input-file-or-exception (car (command-line-arguments))
    (lambda(port)
      (print "port=" port)
      (print (read-line port))
      )))
(print "ex=" ex)
(print "condition-type? " (condition-type? ex))
(print "condition? " (condition? ex))
(print "condition-has-type? " (condition-has-type? ex 'i/o))
#; (call-with-current-continuation
  (lambda(k)
    (with-exception-handler
      (lambda(ex)
        (print "ex=" ex)
        (k))
      (lambda()
        (call-with-input-file (car (command-line-arguments))
          (lambda(port)
            (print "port=" port)
            (print (read port))
            ))))))
