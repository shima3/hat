;; (use srfi-35)
;; (use srfi-36)

(print "command-line=" (command-line))

(define args (cdr (command-line)))
(print "args=" args)
(define port (open-input-file-in-pathlist (car args) (cdr args)))
(print "port=" port)

(define (with-input-file-or-exception file-name port-handler)
  (call-with-current-continuation
    (lambda(k)
      (with-exception-handler
        (lambda(ex)(k ex))
        (lambda()
          (call-with-input-file file-name port-handler))))))

(define ex
  (call-with-current-continuation
    (lambda(k)
      (with-exception-handler
        (lambda(ex)(k ex))
        (lambda()
          (read (open-input-file (car (cdr (command-line)))))
        )))))

#; (call-with-current-continuation
  (lambda(k)
    (let([port (with-exception-handler
                 (lambda(ex)(k ex))
                 (lambda()(open-input-file filename))
                 )])
      (let([ex (call-with-current-continuation
                 (lambda(k2)
                   (with-exception-handler
                     (lambda(ex)(k2 ex))
                     (lambda()(port-handler port))
                     )))])
        (close-input-port port)
        (if(exception? ex)(raise))
          )
        )
      ))

#; (define ex
  (with-input-file-or-exception (car (cdr (command-line)))
    (lambda(port)
      (print "port=" port)
      (print (read-line port))
      )))
(print "ex=" ex)
(print "condition-type? " (condition-type? ex))
(print "condition? " (condition? ex))
(print "condition-has-type? " (condition-has-type? ex &error))
(report-error ex)
