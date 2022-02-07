(include "util.sch")

(defineCPS main ^()
  print_fringe
  ((() 1 ()) 2 ((() 3 ()) 4 ()))
  ^() exit 0)

(defineCPS print_fringe ^(tree . return)
  when(list_empty? tree) return ^()
  tree_left tree ^(left)
  print_fringe left ^()
  tree_label tree ^(label)
  print(label " ")^()
  tree_right tree ^(right)
  print_fringe right)

(defineCPS tree_left ^(tree)
  list_get_first tree)

(defineCPS tree_label ^(tree)
  list_get_rest tree ^(rest)
  list_get_first rest)

(defineCPS tree_right ^(tree)
  list_get_rest tree ^(rest)
  list_get_rest rest ^(rest)
  list_get_first rest)
