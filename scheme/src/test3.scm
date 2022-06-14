(require-extension r7rs)
;; (import (chicken process-context))
;; (import regex)
;; (import (chicken io))
(import simple-exceptions)

(define ex-maker (make-exn "message" 'i/o 'file))
;; (define ex (ex-maker "location" "arguments"))
(define exn-of-i/o? (exn-of? 'i/o))
(define ex
  (call-with-current-continuation
    (lambda(k)
      (with-exception-handler
        (lambda(ex)(k ex))
        (lambda()
          (call-with-input-file "hoge"
            (lambda(port)
              (display "port=")
              (write port)
              (newline))))))))
(display "ex=")(write ex)(newline)
(print (exn-of-i/o? ex))
(print (location ex))
(print (message ex))
(print (arguments ex))
