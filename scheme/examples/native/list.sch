
#; (defineCPS nil #f)
#; (defineCPS isnil ^(s) s (^(x y d) #f) #t)

(defineCPS list_pair? ^($list)
  (lambda(list)
    (pair? list)
    ) $list)

#|
(defineCPS car ^(s) s #t)
( defineCPS getFirst ^(list)
|#
(defineCPS list_car ^($list)
  (lambda(list)
    (car list)
    ) $list)

#|
(defineCPS cdr ^(s) s #f)
( defineCPS getRest ^(list)
|#
(defineCPS list_cdr ^($list)
  (lambda(list)
    (cdr list)
    ) $list)

#|
(defineCPS cons ^(x y f) f x y)
(defineCPS makePair ^(left right)
|#
(defineCPS list_cons ^($obj1 $obj2)
  (lambda(obj1 obj2)
    (cons obj1 obj2)
    ) $obj1 $obj2)

(defineCPS list_split ^($list . $return)
  (lambda(list)(car list)) $list ^($obj1)
  (lambda(list)(cdr list)) $list ^($obj2)
  $return $obj1 $obj2)

(defineCPS list_values ^($list . $return)
  (lambda(list return)
    (cons return list)
    ) $list $return ^($values)
  $values)

;; 文字のリスト ls を文字列に変換します。
(defineCPS list_string ^($list)
  (lambda(list)
    (list->string list)
    ) $list)

(defineCPS list_seq ^($list $tail)
  (list_pair? $list)
  (^($out)
    list_split $list ^($first $rest)
    list_seq $rest $tail ^($seq)
    $out $first . $seq)
  $tail)

(defineCPS list_and ^($list . $return)
  unless(list_pair? $list)($return #t)^()
  list_split $list ^($first $rest)
  unless($first)($return #f)^()
  list_and $rest . $return
  )

(defineCPS list_or ^($list . $return)
  unless(list_pair? $list)($return #f)^()
  list_split $list ^($first $rest)
  if($first)($return #t)^()
  list_or $rest . $return
  )

(defineCPS list_contains? ^($list $obj . $return)
  unless(list_pair? $list)($return #f)^()
  list_split $list ^($first $rest)
  if(object_eq? $first $obj)($return #t)^()
  list_contains? $rest $obj . $return
  )
