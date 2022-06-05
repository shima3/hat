
## Hat terms

**Hat terms** are variable names, function applications, continuation applications, function abstraction, or continuation abstractions.
They are defined so that:
- A **variable name** is a sequence of characters which must starts with a letter (a, b, ..., z) or the dollar sign ($), and can contain letters and digits (0, 1, ..., 9), e.g. x, xy, x2, $sum, $12.
- (M N) is a **function application** if M and N are hat terms.
- (M . N) is a **continuation application** if M and N are hat terms.
- (^(x) M) is a **function abstraction** if x is a variable name and M is a hat term.
- (^ x M) is a **continuation abstraction** if x is a variable name and M is a hat term.

## Bound variables and free variables

A variable x of a function abstraction (^(x) M) or a continuation abstraction (^ x M) is a bound variable.
Variables that are contained in a hat term and are not bound variables, are free variables.
FV(M) is a set of free variables of M if M is a hat term.
This is defined so that:
- FV(x) is a set that contains just x.
- FV(M N) and FV(M . N) are a union of FV(M) and FV(N) if M and N are hat terms.
- FV(^(x) M) and FV(^ x M) are a set removed x from FV(M) if x is a variable and M is a hat term.

Variables except free variable of M are said to be **fresh** for M if M is a hat term.
That is, bound variables of M and variables not contained in M are fresh for M.

## Substitution

The notation M[x:=N] indicates substitution of N for x in M if M and N are hat terms and x is a variable.
This is defined so that:
- x[x:=N] = N
- y[x:=N] = y if y is a variable different from x.
- (M1 M2)[x:=N] = (M1[x:=N] M2[x:=N])
- (M1 . M2)[x:=N] = (M1[x:=N] . M2[x:=N])
- (^(x) M)[x:=N] = (^(x) M)
- (^ x M)[x:=N] = (^ x M)
- (^(y) M)[x:=N] = (^(y) M[x:=N]) if the variable y is different from x and fresh for N.
- (^ y M)[x:=N] = (^ y M[x:=N]) if the variable y is different from x and fresh for N.
- (^(y) M)[x:=N] = (^(y2) M[y:=y2][x:=N]) if the variable y is different from x and a free variable of N.
Here, the variable y2 must be fresh for M and N.
- (^ y M)[x:=N] = (^ y2 M[y:=y2][x:=N]) if the variable y is different from x and a free variable of N.
Here, the variable y2 must be fresh for M and N.

## Reduction

Suppose x, y and z are variables, and M and N are hat terms.
The reduction rules are as follow:

- ((^(x) M) N) is reduced to M[x:=N] if x is fresh for N.
((^(x) M) N) is reduced to M[x:=x2][x2:=N] if x is a free variable of N.
Here, x2 must be fresh for M and N.

- ((^ x M) . N) is reduced to (M[x:=N] . N) if x is fresh for N.
((^ x M) . N) is reduced to (M[x:=x2][x2:=N] . N) if x is a free variable of N.
Here, x2 must be fresh for M and N.

- ((^(x) M) . N) is reduced to (N (^(x) M)).

- ((^ x M) N) is reduced to (M . x)[x:=(^(y) y N)] if x is fresh for N.
((^ x M) N) is reduced to (M[x:=x2] . x2)[x2:=(^(y) y N)] if x is a free variable of N.
Here, y must be different from x and be fresh for N, and x2 must be fresh for M and N.

## Hat expressions

Hat expressions are hat terms applied the following conventions to keep the notation uncluttered.
- (M N1 N2) means ((M N1) N2).
(M N1 N2 ... Nm) means ((...((M N1) N2) ...) Nm).
- (M N . K) means ((M N) . K).
(M N1 N2 ... Nm . K) means (((...((M N1) N2) ...) Nm) . K).
- (^(x y) M) means (^(x)(^(y) M)).
(^(x1 x2 ... xn) M) means (^(x1)(^(x2)(...(^(xn) M)...))).
- (^(x . k) M) means (^(x)(^ k M)).
(^(x1 x2 ... xn . k) M) means (^(x1)(^(x2)(...(^(xn)(^ k M))...))).
- (^ k M N1 N2 ... Nm) means (^ k (M N1 N2 ... Nm)).
- (^(x1 x2 ... xn) M N1 N2 ... Nm) means (^(x1 x2 ... xn)(M N1 N2 ... Nm)).
- (^(x1 x2 ... xn . k) M N1 N2 ... Nm) means (^(x1 x2 ... xn . k)(M N1 N2 ... Nm)).
- (^ k M N1 N2 ... Nm . K) means (^ k (M N1 N2 ... Nm . K)).
- (^(x1 x2 ... xn) M N1 N2 ... Nm . K) means (^(x1 x2 ... xn)(M N1 N2 ... Nm . K)).
- (^(x1 x2 ... xn . k) M N1 N2 ... Nm . K) means (^(x1 x2 ... xn . k)(M N1 N2 ... Nm . K)).
- (M ^ k N) means (M . (^ k N)).
- (M ^(x1 x2 ... xn) N) means (M . (^(x1 x2 ... xn) N)).
- (M ^(x1 x2 ... xn . k) N) means (M . (^(x1 x2 ... xn . k) N)).

## Functions

(defineCPS *f* *M*) defines a function named *f* as *M* where *f* is a sequence of characters and *M* is a hat expression.
For example, the following two definitions are used for the boolean values True and False:
```
(defineCPS True ^(x y . return) return x)
(defineCPS False ^(x y . return) return y)
```
We can define a control statement IfThenElse:
```
(defineCPS IfThenElse ^(p t e) p t e ^(f) f)
```
`(IfThenElse True T E)` is reduced to T as follows:  
`(IfThenElse True T E)`  
&rarr;`((^(p t e) p t e ^(f) f) True T E)`  
&rarr;`((^(t e) True t e ^(f) f) T E)`  
&rarr;`((^(t e) True t e ^(f) f) T E)`  
&rarr;`(True T E ^(f) f)`  
&rarr;`((^(x y . return) return x) T E . (^(f) f))`  
&rarr;`((^ return return T) . (^(f) f))`  
&rarr;`((^(f) f) T)`  
&rarr;`T`  

We can define logic operators:
```
(defineCPS And ^(p q) p q p)
(defineCPS Or ^(p q) p p q)
(defineCPS Not ^(p) p False True)
```

`(And True False)`  
&darr;
`((^(p q) p q p) True False)`  
&darr;
`((^(q) True q True) False)`  
&darr;
`(True False True)`  
&darr;
`((^(x y . return) return x) False True)`  
&darr;
`((^(y . return) return False) True)`  
&darr;
`(^ return return False)`  

<!--
&larr;
&rarr;
$\downarrow$
$\leftarrow$
-->
