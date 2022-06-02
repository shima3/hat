(include "util.sch")

(defineCPS main ^()
  print("hello,\n")^()
  print(" world\n")^()
  
  list_push (1 2) 3 ^($list)
  list_get_first $list ^($el)
  list_get_rest $list ^($list)
  print("first: " $el "\n")^()
  print("rest: " $list "\n")^()
  list_get_first $list ^($el)
  list_get_rest $list ^($list)
  print("first: " $el "\n")^()
  print("rest: " $list "\n")^()

  exit 0)
