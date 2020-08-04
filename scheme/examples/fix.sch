(defineCPS main ^(args)
  currentInputPort ^(in)
  print("start\n") ^()
  fix
  (^(loop)
    readByte in ^(byte)
    unless (eof? byte) ^()
    print(byte "\n") ^()
    loop
    ) ^()
  print("end\n")
  )

(defineCPS currentInputPort ^ return
  (lambda ()(current-input-port)) . return)

(defineCPS readByte ^(in)
  (lambda (in)(read-byte in)) in)

(defineCPS eof? ^(byte)
  (lambda (byte)(eof-object? byte)) byte)

(defineCPS print ^(list . return)
  (lambda (list)
    (display (string-append (string-concatenate (map x->string list))))
    ) list ^(dummy)
  return)

(defineCPS fix ^(f) f (fix f))

(defineCPS if0 ^(condition action . return)
  condition action return)

(defineCPS if ^(condition then else)
  condition then else ^(action)
  action)

(defineCPS unless ^(condition . action)
  getDefaultContinuation action ^(defcont)
  if condition '() action . defcont)

(defineCPS getDefaultContinuation ^(func . cont)
  (lambda (func cont)
    (if (func-with-cont? func)
      (cdr (cdr func))
      cont)) func cont)

(defineCPS isPair ^(exp)
  (lambda (exp)(pair? exp)) exp)

(defineCPS getFirst ^(list)
  (lambda (list)(car list)) list)

(defineCPS getRest ^(list)
  (lambda (list)(cdr list)) list)

(defineCPS not ^(boolean)
  boolean ^(boolean)
  boolean #f #t)

(defineCPS 0t ^(then else) then)
(defineCPS 0f ^(then else) else)

(defineCPS #t ^(then else . return) return then)
(defineCPS #f ^(then else . return) return else)
