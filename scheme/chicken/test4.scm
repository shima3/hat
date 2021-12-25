(import (chicken io))

(let loop()
  (print (eval (read)(interaction-environment)))
  (loop))
