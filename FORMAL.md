# Formal specification of the hat programming language

The hat programming language is based on lambda calculus in continuation passing style.
This page describes a specification of the language and differences from lambda calculus.

## Hat terms

**Hat terms** are variable names, function applications, continuation applications, function abstraction, or continuation abstractions.
They are defined so that:
- A **variable name** is a sequence of characters which must starts with a letter (a, b, ..., z) or the dollar sign ($), and can contain letters and digits (0, 1, ..., 9), e.g. x, xy, x2, $sum, $12.
- ($M\ N$) is a **function application** if $M$ and $N$ are hat terms.
- ($M\ .\ N$) is a **continuation application** if $M$ and $N$ are hat terms.
- (^($x$) $M$) is a **function abstraction** if $x$ is a variable name and $M$ is a hat term.
- (^ $x\ M$) is a **continuation abstraction** if $x$ is a variable name and $M$ is a hat term.

Continuation application and continuation abstraction are similar to function application and function abstraction, respectively.
But, they are distinguished in order to describe functions in continuation passing style.
Continuation application passes a continuation to a function.
Continuation abstraction is a function that receives a continuatoin.
Function application is same with that of lambda calculus.
Function abstraction (^($x$) $M$) is same with lambda abstraction $\lambda x. M$.

## Bound variables and free variables

A variable x of a function abstraction (^($x$) $M$) or a continuation abstraction (^ $x\ M$) is a bound variable.
Variables that are contained in a hat term and are not bound variables, are free variables.
FV($M$) is a set of free variables of $M$ if $M$ is a hat term.
This is defined so that:
- FV($x$) is a set that contains just $x$.
- FV($M\ N$) and FV($M\ .\ N$) are a union of FV($M$) and FV($N$) if $M$ and $N$ are hat terms.
- FV(^($x$) $M$) and FV(^ $x\ M$) are a set removed $x$ from FV($M$) if $x$ is a variable and $M$ is a hat term.

Variables except free variable of $M$ are said to be **fresh** for $M$ if $M$ is a hat term.
That is, bound variables of $M$ and variables not contained in $M$ are fresh for $M$.

## Substitution

The notation $M[x\leftarrow N]$ indicates substitution of $N$ for $x$ in $M$ if $M$ and $N$ are hat terms and $x$ is a variable.
This is defined so that:
- $x[x\leftarrow N] = N$
- $y[x\leftarrow N] = y$ if $y$ is a variable different from $x$.
- $(M_1\ M_2)[x\leftarrow N] = (M_1[x\leftarrow N]\ M_2[x\leftarrow N])$
- $(M_1\ .\ M_2)[x\leftarrow N] = (M_1[x\leftarrow N] . M_2[x\leftarrow N])$
- (^($x$) $M$)[$x\leftarrow N$] = (^($x$) $M$)
- (^ $x\ M$)[$x\leftarrow N$] = (^ $x\ M$)
- (^($y$) $M$)[$x\leftarrow N$] = (^($y$) $M$[$x\leftarrow N$]) if the variable y is different from $x$ and fresh for $N$.
- (^ $y\ M$)[$x\leftarrow N$] = (^ $y\ M$[$x\leftarrow N$]) if the variable $y$ is different from $x$ and fresh for N.
- (^($y$) $M$)[$x\leftarrow N$] = (^($y'$) M[$y\leftarrow y'$][$x\leftarrow N$]) if the variable $y$ is different from $x$ and a free variable of $N$.
Here, the variable $y'$ must be fresh for $M$ and $N$.
- (^ $y\ M$)[$x\leftarrow N$] = (^ $y' M[y\leftarrow y'][x\leftarrow N]$) if the variable $y$ is different from $x$ and a free variable of $N$.
Here, the variable $y'$ must be fresh for $M$ and $N$.

## Reduction

Suppose $x$, $x'$ and $t$ are variables, and $M$, $N$, $M_2$ and $N_2$ are hat terms.
$M$ &rarr; $N$ means that $M$ is reduced to $N$.
The reduction rules are as follow:
- ((^($x$) $M$) $N$) &rarr; $M$[$x$:=$N$] if $x$ is fresh for $N$.
((^($x$) $M$) $N$) &rarr; $M$[$x$:=$x'$][$x'$:=$N$] if $x$ is a free variable of $N$.
Here, $x'$ must be fresh for $M$ and $N$.
- ((^ $x$ $M$) . $N$) &rarr; ($M$[$x$:=$N$] . $N$) if $x$ is fresh for $N$.
((^ $x$ $M$) . $N$) &rarr; ($M$[$x$:=$x'$][$x'$:=$N$] . $N$) if $x$ is a free variable of $N$.
Here, $x'$ must be fresh for $M$ and $N$.
- ((^($x$) $M$) . $N$) &rarr; ($N$ (^($x$) $M$)).
- ((^ $x$ $M$) $N$) &rarr; ($M$ . $x$)[$x$:=(^($t$) $t$ $N$)] if $x$ is fresh for $N$.
((^ $x$ $M$) $N$) &rarr; ($M$[$x$:=$x'$] . $x'$)[$x'$:=(^($t$) $t$ $N$)] if $x$ is a free variable of $N$.
Here, $t$ must be different from $x$ and be fresh for $N$, and $x'$ must be fresh for $M$ and $N$.
- (($M$ $N$) $N_2$) &rarr; ($M_2$ $N_2$) if ($M$ $N$) &rarr; $M_2$.
- (($M$ . $N$) . $N_2$) &rarr; ($M_2$ . $N_2$) if ($M$ . $N$) &rarr; $M_2$.

## Hat expressions

Hat expressions are hat terms applied the following conventions to keep the notation uncluttered.
- $(M N_1 N_2)$ means $((M N_1) N_2)$.
$(M N_1 N_2 \cdots N_m)$ means $((\cdots((M N_1) N_2)\cdots) N_m)$.
- $(M N . K)$ means $((M N . K)$.
$(M N_1 N_2 \cdots N_m . K)$ means $(((\cdots((M N_1) N_2)\cdots) N_m) . K)$.
- (^($x y$) $M$) means (^($x$)(^($y$) $M$)).
(^($x_1 x_2 \cdots x_n$) $M$) means (^($x_1$)(^($x_2$)($\cdots$(^($x_n$) $M$)$\cdots$))).
- (^($x$ . $k$) $M$) means (^($x$)(^ $k$ $M$)).
(^($x_1 x_2 \cdots x_n . k$) $M$) means (^($x_1$)(^($x_2$)($\cdots$(^($x_n$)(^ $k M$))$\cdots$))).
- (^ $k M N_1 N_2 \cdots N_m$) means (^ $k (M N_1 N_2 \cdots N_m$)).
- (^($x_1 x_2 \cdots x_n$) $M N_1 N_2 \cdots N_m$) means (^($x_1 x_2 \cdots x_n$)($M N_1 N_2 \cdots N_m$)).
- (^($x_1 x_2 \cdots x_n . k$) $M N_1 N_2 \cdots N_m$) means (^($x_1 x_2 \cdots x_n . k$)($M N_1 N_2 \cdots N_m$)).
- (^ $k M N_1 N_2 \cdots N_m . K$) means (^ $k (M N_1 N_2 \cdots N_m . K$)).
- (^($x_1 x_2 \cdots x_n$) $M N_1 N_2 \cdots N_m . K$) means (^($x_1 x_2 \cdots x_n$)($M N_1 N_2 \cdots N_m . K$)).
- (^($x_1 x_2 \cdots x_n . k$) $M N_1 N_2 \cdots N_m . K$) means (^($x_1 x_2 \cdots x_n . k$)($M N_1 N_2 \cdots N_m . K$)).
- ($M$ ^ $k N$) means ($M$ . (^ $k N$)).
- ($M$ ^($x_1 x_2 \cdots x_n$) $N$) means ($M$ . (^($x_1 x_2 \cdots x_n$) $N$)).
- ($M$ ^($x_1 x_2 \cdots x_n . k$) $N$) means ($M$ . (^($x_1 x_2 \cdots x_n . k$) $N$)).

## Functions

(defineCPS $f\ M$) defines a function named $f$ as $M$ where $f$ is a sequence of characters and $M$ is a hat expression.
For example, the following two definitions are used for the boolean values True and False:
```
(defineCPS True ^(x y . return) return x)
(defineCPS False ^(x y . return) return y)
```
We can define a control statement IfThenElse:
```
(defineCPS IfThenElse ^(p x y) p x y ^(f) f)
```
$M$ can be substituted for $f$ in hat expressions if $f$ is defined as $M$.
$(f \cdots)$ &rArr; $(M \cdots)$ means that $M$ is substituted for $f$ in the function application.
For example, (IfThenElse True $X\ Y$) is reduced to $X$ as follows:  
(IfThenElse True $X\ Y$)  
&rArr;((^(p x y) p x y ^(f) f) True $X\ Y$)  
&rarr;((^(x y) True x y ^(f) f) $X\ Y$)  
&rarr;(True $X\ Y$ ^(f) f)  
&rArr;((^(x y . return) return x) $X\ Y$ . (^(f) f))  
&rarr;((^ return return $X$) . (^(f) f))  
&rarr;((^(f) f) $X$)  
&rarr;$X$

We can define logic operators:
```
(defineCPS And ^(p q) p q p)
(defineCPS Or ^(p q) p p q)
(defineCPS Not ^(p) p False True)
```
For example, (IfThenElse (And True False) $X\ Y$) is reduced to $Y$ as follows:  
(IfThenElse (And True False) $X\ Y$)  
&rArr;((^(p x y) p x y ^(f) f) (And True False) $X\ Y$)  
&rarr;((And True False) $X\ Y$ ^(f) f)  
&rArr;(((^(p q) p q p) True False) $X\ Y$ ^(f) f)  
&rarr;((True False True) $X\ Y$ ^(f) f)  
&rArr;(((^(x y . return) return x) False True) $X\ Y$ ^(f) f)  
&rarr;((^ return return False) $X\ Y$ ^(f) f)  
&rarr;((^ return return False) . (^($t$) $t\ X\ Y$ ^(f) f))  
&rarr;((^($t$) $t\ X\ Y$ ^(f) f) False)  
&rarr;(False $X\ Y$ ^(f) f)  
&rArr;((^(x y . return) return y) $X\ Y$ ^(f) f)  
&rarr;((^ return return $Y$) . (^(f) f))  
&rarr;((^(f) f) $Y$)  
&rarr;$Y$  

## Numerals

Church numerals, which are the natural numbers in lambda calculus, can be defined in the hat programming language as follows:
```
(defineCPS C0 ^(f x . return) return x)
(defineCPS C1 ^(f x . return) f x ^(x) return x)
(defineCPS C2 ^(f x . return) f (f x)^(x) return x)
(defineCPS C3 ^(f x . return) f (f (f x))^(x) return x)
```
We can define also arithmetic operators for Church numerals: addition, subtraction, multiplication, and so on.
But, modern CPUs can perform these operators more efficiently not only for natural numbers, but also integers and decimal numbers.
Therefore, the hat programming language supports arithmetic operators like other programming languages: addition (Add), subtraction (Sub), multiplication (Mul), and division (Div).
- (Plus $x\ y$) returns the value of $x$ plus $y$.
- (Minus $x\ y$) returns the value of $x$ minus $y$.
- (Mul $x\ y$) returns the value of $x$ multiplied by $y$.
- (Div $x\ y$) returns the value of $x$ divided by $y$.

## Recursion

Recursion of a named function is done by explicitly calling the function by name.
For example, a fixed-point combinator can be defined as follows:
```
(defineCPS Fix ^(f) f (Fix f))
```
Fixed-point combinators can be used to implement recursive definition of anonymous functions.
Recursion of an anonymous function can be done by using such a fixed-point combinator.



<!--
&larr;
&rarr;
$\downarrow$
$\leftarrow$
-->
