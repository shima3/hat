(defineCPS main ^(args)
  log "hello")

(defineCPS log ^(str . return)
  (javascript "str" "console.log(str);") str ^(dummy)
  return)
