(define (main-proc cmd . args)
  (let loop ((exp (read)))
    (if (not (eof-object? exp))
      (begin
	(if (pair? exp)
	  (begin
	    (display "{")
	    (display (car exp))
	    (display "}{")
	    (display (cdr exp))
	    (display "}")
	    (newline))
	  (begin
	    (display "{")
	    (display exp)
	    (display "}")
	    (newline)))
	(loop (read))))))
