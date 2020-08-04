(defineCPS main ^(args)
  ;; (^ c unless #t c ^() print("hello\n")) ^()
  ;; (^ c unless #f c ^() print("world\n")) ^()
  (when #t ^() print("hello\n")) ^()
  (when #f ^() print("world\n")) ^()
  print("end\n"))

(defineCPS when ^(condition . then)
  getDefaultContinuation then ^(c)
  condition then () . c)

(defineCPS unless ^(condition else)
  condition () else)

(defineCPS getDefaultContinuation ^(func . cont)
  (lambda (func cont)
    (if (func-with-cont? func)
      (cdr (cdr func))
      cont)) func cont)

(defineCPS #t ^(a b) a)
(defineCPS #f ^(a b) b)

(defineCPS print ^(list . return)
  ( lambda (list)
    (display (string-concatenate (map x->string list)))
    ) list ^(dummy)
  return)
