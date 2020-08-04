(defineCPS substring/shared ^(s start end)
  start ^(start) end ^(end)
  (lambda(s start end)
    (substring/shared s start end)
    ) s start end)

(defineCPS string_tokenize ^($s)
  (lambda(s)
    (string-tokenize s)
    ) $s)

(defineCPS string-ref ^(s idx)
  idx ^(idx)
  (lambda(S Idx)
    (string-ref S Idx)
    ) s idx)

(defineCPS string-length ^(s)
  (lambda(S)
    (string-length S)
    ) s)

( defineCPS makeString ^(len) len ^(len)
  (lambda (len)(make-string len)) len )

( defineCPS stringSet! ^(str index char . return) index ^(index)
  (lambda (S I C)(string-set! S I C)) str index char ^(dummy)
  return )

( defineCPS stringToNumber ^(str)
  (lambda (str)(string->number str)) str )
