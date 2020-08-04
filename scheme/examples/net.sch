(defineCPS client ^(args)
  getFirst args ^(host) getRest args ^(args)
  getFirst args ^(port)
  makeClientSocket host port ^(socket)
  socketGetPeerName socket ^(addr)
  print("peer name=" addr "\n") ^()
  socketInputPort socket ^(sin)
  socketOutputPort socket ^(sout)
  currentInputPort ^(cin)
  currentOutputPort ^(cout)
  addPipe cin sout ^()
  addPipe sin cout ^()
  pollingLoop)

(defineCPS server ^(args)
  getFirst args ^(port)
  makeServerSocket port ^(server)
  print("server=" server "\n") ^()
  socketGetSockName server ^(addr)
  print("sock name=" addr "\n") ^()
  setService server echoService ^()
  pollingLoop)

(defineCPS socketGetSockName ^(socket)
  (lambda (socket)(socket-getsockname socket)) socket)

(defineCPS socketGetPeerName ^(socket)
  (lambda (socket)(socket-getpeername socket)) socket)

(defineCPS echoService2 ^(client in out)
  pipeHandle in out)

(defineCPS echoService ^(client in out . return)
  pipeHandle in out ^()
  (when (portClosed? out) ^()
    pollingResetInputHandler in ^()
    socketClose client) . return)

(defineCPS getFirst ^(list)
  (lambda (list)(car list)) list)

(defineCPS getRest ^(list)
  (lambda (list)(cdr list)) list)

(defineCPS makeClientSocket ^(host port)
  (lambda (host port)
    (make-client-socket 'inet host port)
    ) host port)

(defineCPS socketInputPort ^(socket)
  (lambda (socket)
    (socket-input-port socket :buffering :modest)
    ) socket)

(defineCPS socketOutputPort ^(socket)
  (lambda (socket)
    (socket-output-port socket)) socket)

(defineCPS currentInputPort ^()
  (lambda ()(current-input-port)))

(defineCPS currentOutputPort ^()
  (lambda ()(current-output-port)))

(defineCPS addPipe ^(in out)
  pollingSetInputHandler in (pipeHandle in out))

(defineCPS pipeHandle ^(in out)
  fix
  (^(loop)
    when (byteReady? in) ^()
    readByte in ^(byte)
    if (eof? byte)
    ( ;; closePort out ^()
      pollingResetInputHandler in)
    ( writeByte byte out ^()
      (when (equal? byte #x0a) ^()
	flush out) ^()
      loop)))

(defineCPS pipeHandle1 ^(in out . return)
  fix
  (^(loop . break)
    print("pipeHandle 1\n") ^()
    if (byteReady? in)
    ( readByte in ^(byte)
      if (eof? byte) break
      ( writeByte byte out ^()
	(when (equal? byte #x0a) ^()
	  print("pipeHandle 2\n") ^()
	  flush out) ^()
	print("pipeHandle 3\n") ^()
	loop . break ) )
    return
    ) ^()
  print("pipeHandle 4\n") ^()
  closePort out ^()
  pollingResetInputHandler in . return)

(defineCPS print ^(list . return)
  (lambda (list)
    (display (string-append (string-concatenate (map x->string list))))
    ) list ^(dummy)
  return)

(defineCPS test ^(args . return)
  print("end\n") . return)

(defineCPS test2 ^(args)
  currentInputPort ^(in)
  currentOutputPort ^(out)
  fix
  (^(loop . break)
    readByte in ^(byte)
    if (eof? byte)
    ( ;; print("break=" break) ^()
      break)
    ( writeByte byte out ^()
      flush out ^()
      loop . break)) ^()
  print("end\n"))

(defineCPS test3 ^(args)
  currentInputPort ^(in)
  currentOutputPort ^(out)
  fix
  (^(loop)
    readByte in ^(byte)
    unless (eof? byte) ^()
    writeByte byte out ^()
    flush out ^()
    loop) ^()
  print("end\n"))

(defineCPS fix ^(f) f (fix f))

(defineCPS #t ^(then else . return) return then)
(defineCPS #f ^(then else . return) return else)

(defineCPS if ^(condition then else . cont)
  condition then else ^(action)
  action . cont)

(defineCPS when ^(condition . action)
  getDefaultContinuation action ^(defcont)
  if condition action '() . defcont)
;;  condition action defcont . end)

(defineCPS unless ^(condition . action)
  getDefaultContinuation action ^(defcont)
  if condition '() action . defcont)

(defineCPS getDefaultContinuation ^(func . cont)
  (lambda (func cont)
    (if (func-with-cont? func)
      (cdr (cdr func))
      cont)) func cont)

(defineCPS byteReady? ^(in)
  (lambda (in)(byte-ready? in)) in)

(defineCPS readByte ^(in)
  (lambda (in)(read-byte in)) in)

(defineCPS writeByte ^(byte out . return)
  (lambda (byte out)(write-byte byte out)) byte out ^(dummy)
  return)

(defineCPS eof? ^(byte)
  (lambda (byte)(eof-object? byte)) byte)

(defineCPS closePort ^(port . return)
  (lambda (port)(close-port port)) port ^(dummy)
  return)

(defineCPS flush ^(out . return)
  (lambda (out)(flush out)) out ^(dummy)
  return)

(defineCPS portClosed? ^(port)
  (lambda (port)(port-closed? port)) port)

(defineCPS equal? ^(a b) a ^(a) b ^(b)
  (lambda (a b)(equal? a b)) a b)

(defineCPS pollingSetInputHandler ^(in handler . return)
  (lambda (in handler)
    (selector-set-input-handler in handler)
    ) in handler ^(dummy)
  return)

(defineCPS pollingResetInputHandler ^(in . return)
  (lambda (in)
    (selector-reset-input-handler in)
    ) in ^(dummy)
  return)

(defineCPS pollingLoop ^()
  (lambda ()(selector-dispatch)) ^(dummy)
  pollingLoop)

(defineCPS pollingStart ^()
  start pollingLoop)

(defineCPS makeServerSocket ^(port)
  (lambda (port)(make-server-socket 'inet port :reuse-addr? #t)) port)

(defineCPS setService ^(server service)
  ;; print("setService 1\n") ^()
  socketGetFileDescriptor server ^(fd)
  ;; print("setService 2 fd=" fd "\n") ^()
  pollingSetInputHandler fd (serviceHandler server service))

(defineCPS socketGetFileDescriptor ^(socket)
  (lambda (socket)(socket-fd socket)) socket)

(defineCPS socketClose ^(socket . return)
  (lambda (socket)(socket-close socket)) socket ^(dummy)
  return)

(defineCPS serviceHandler ^(server service)
  ;; print("serviceHandler 1\n") ^()
  socketAccept server ^(client)
  ;; print("serviceHandler 2\n") ^()
  socketGetPeerName client ^(addr)
  ;; print("peer name=" addr "\n") ^()
  socketInputPort client ^(in)
  socketOutputPort client ^(out)
  ;; print("serviceHandler 3 in=" in "\n") ^()
  pollingSetInputHandler in (service client in out))

(defineCPS socketAccept ^(server)
  print("socketAccept 1\n") ^()
  (lambda (server)(socket-accept server)) server)
