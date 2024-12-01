---
layout: default
---

# Specification of the Hat programming language

The hat programming language is based on lambda calculus in continuation passing style (CPS).
This page describes a specification of the language and differences from lambda calculus in direct style.

# EBNF Syntax Definition

This document separates the **lexical definitions** (used for tokenization) and **syntactic definitions** (used for parsing).

---

## Lexical Definitions (Tokens)

```ebnf
Token        = Significant | Whitespace | Comment ;
Significant  = Symbol | String | "(" | ")" ;

Symbol      = SymbolChar, { SymbolChar } ;
SymbolChar  = Letter | Digit | SpecialChar ;
Letter      = "a"..."z" | "A"..."Z" | "_" ;
Digit       = "0"..."9" ;
SpecialChar = "!" | "?" | "*" | "+" | "-" | "/" | "=" | "<" | ">" | "$" | "%" | "&" | "|" | "." | "^" ;

String      = '"', { StringCharacter }, '"' ;
StringCharacter = Character | EscapeSequence ;
Character   = ? any valid character except '"', '\', and Newline ? ;
EscapeSequence  = "\", ( '"' | "\" | "n" | "t" | "r" ) ;

Digits      = Digit, { Digit } ;

Whitespace  = Space | Tab | Newline ;
Space       = " " ;
Tab         = "\t" ;
Newline     = "\n" | "\r\n" ;

Comment     = LineComment | BlockComment ;
LineComment = ";", { LineCommentCharacter }, Newline ;
LineCommentCharacter = ? any valid character except Newline ? ;

BlockComment = "#|", { BlockCommentContent }, "|#" ;
BlockCommentContent = BlockCommentText | BlockComment ;
BlockCommentText    = ? character sequence not containing #| or |# ? ;
```

## Syntactic Definitions (Grammar)

```ebnf

HatProgram  = { Statement } ;
Statement   = Includer | Definition ;
Includer    = "(", "include", String, ")" ;
Definition  = "(", "define", Symbol, Function, ")" ;
Function    = "^", Head, Body ;
Head        = "(", { Symbol }, ")" ;
Body        = [ LineMetadata ], Expression, { Expression }, [ Function ] ;
Expression  = Symbol | String | "(", Function, ")" ;
LineMetadata = "(", "_LINE_", Symbol, { String }, ")" ;
```

## Hat terms

**Hat terms** are variable names, function applications, continuation applications, function abstractions, continuation abstractions or continuations.
They are defined so that:
- A **variable name** is a sequence of characters which must starts with a dollar sign (\$), and can contain letters and digits (0, 1, ..., 9), e.g. $x, $xy, $x2, \$sum, \$12.
- {^($x$) $M$} is a **function abstraction** if $x$ is a variable name and $M$ is a hat term.
- {^( ) $M$ $N$} is a **function application** if $M$ and $N$ are hat terms.
- {^ $x$ $M$} is a **continuation abstraction** if $x$ is a variable name and $M$ is a hat term.
- {^( ) $M$ . $N$} is a **continuation application** if $M$ and $N$ are hat terms.
- {^^ $M$ . $N$} is a **continuation** if $M$ and $N$ are hat terms.

Continuation application and continuation abstraction are similar to function application and function abstraction, respectively.
But, they are distinguished in order to describe functions in continuation passing style.
Continuation abstraction is a function that receives a continuatoin.
Continuation application passes a continuation to a function.
Function abstraction {^($x$) $M$} means ($\lambda x. M$) in lambda calculus transformed into CPS.
Function application {^( ) $M$ $N$} means ($M$ $N$) in lambda calculus transformed into CPS.

## Free variables

The set of free variables of a hat term $M$, is denoted as $\text{FV}M$ and is defined inductively:
- $\text{FV}x$ is the set that contains just $x$, where $x$ is a variable.
- Either of $\text{FV}${^( ) $M$ $N$}, $\text{FV}${^( ) $M$ . $N$}, or $\text{FV}${^^ $M$ . $N$} is the union of $\text{FV}M$ and $\text{FV}N$, where $M$ and $N$ are hat terms.
- Either of $\text{FV}${^($x$) $M$} or $\text{FV}${^ $x\ M$} is the set difference of $\text{FV}M$ and $\{x\}$, where $x$ is a variable and $M$ is a hat term.

## Substitution

The notation $M[x\leftarrow N]$ indicates substitution of $N$ for $x$ in $M$ if $M$ and $N$ are hat terms, and $x$ is a variable.
This is defined so that:
- $x[x\leftarrow N] = N$
- $y[x\leftarrow N] = y$ if $x\neq y$
- {^( ) $M_1$ $M_2$}[$x\leftarrow N$] = {^( ) $M_1$[$x\leftarrow N$] $M_2$[$x\leftarrow N$]}
- {^( ) $M_1$ . $M_2$}[$x\leftarrow N$] = {^( ) $M_1$[$x\leftarrow N$] . $M_2$[$x\leftarrow N$]}
- {^($x$) $M$}[$x\leftarrow N$] = {^($x$) $M$}
- {^ $x$ $M$}[$x\leftarrow N$] = {^ $x$ $M$}
- {^($y$) $M$}[$x\leftarrow N$] = {^($y$) $M$[$x\leftarrow N$]} if $x\neq y$ and $y\notin\text{FV}N$
- {^ $y$ $M$}[$x\leftarrow N$] = {^ $y$ $M$[$x\leftarrow N$]} if $x\neq y$ and $y\notin\text{FV}N$
- {^($y$) $M$}[$x\leftarrow N$] = {^($y'$) $M$[$y\leftarrow y'$][$x\leftarrow N$]} if $x\neq y$, $y\in\text{FV}N$, $y'\notin\text{FV}M$ and $y'\notin\text{FV}N$
- {^ $y$ $M$}[$x\leftarrow N$] = {^ $y'$ $M$[$y\leftarrow y'$][$x\leftarrow N$]} if $x\neq y$, $y\in\text{FV}N$, $y'\notin\text{FV}M$ and $y'\notin\text{FV}N$
- {^^ $M_1$ . $M_2$}[$x\leftarrow N$] = {^^ $M_1$[$x\leftarrow N$] . $M_2$[$x\leftarrow N$]}

## Reduction

Suppose $x$, $y$ and $k$ are variables, and $M$, $N$, $M_2$ and $N_2$ are hat terms.
$M$ &rarr; $N$ means that $M$ is reduced to $N$.
The reduction rules are as follow:
- (^( ) (^($x$) $M$) $N$) &rarr; $M$[$x\leftarrow N$].
- (^( ) (^ $x$ $M$) . $N$) &rarr; (^( ) $M[x\leftarrow N]$) if $N$ is a continuation.
- (^( ) (^ $x$ $M$) . $N$) &rarr; (^ $k$ $M$[$x\leftarrow$(^^ $N$ . $k$)]) if $N$ is not a continuation and $^\exists k\notin\text{FV}M\cup\text{FV}N$.
- (^( ) (^($x$) $M$) . $N$) &rarr; (^( ) $N$ (^($x$) $M$)).
- (^( ) (^ $x$ $M$) $N$) &rarr; (^ $k$ $M$ . $x$)[$x\leftarrow$(^^ (^($y$) $y$ $N$) . $k$)] if $^\exists y\notin\text{FV}N$, and $^\exists k\notin\text{FV}M\cup\text{FV}N$.
- (^( ) (^( ) $M$ $N$) $N_2$) &rarr; (^( ) $M_2$ $N_2$) if (^( ) $M$ $N$) &rarr; $M_2$.
- (^( ) (^( ) $M$ . $N$) . $N_2$) &rarr; (^( ) $M_2$ . $N_2$) if (^( ) $M$ . $N$) &rarr; $M_2$.
- (^( ) (^^ $M$ . $N$) $N_2$) &rarr; (^( ) (^( ) $M$ $N_2$) . $N$).
- (^( ) (^^ $M$ . $N$) . $N_2$) &rarr; (^( ) $M$ . (^^ $N$ . $N_2$)).

## Hat expressions

In order to keep the notation uncluttered, **hat expressions** are hat terms applied the following conventions:
- {^( ) $M$ $N_1$ $N_2$ $N_3$ $\cdots$ $N_m$} means {^( ) {^( ) $M$ $N_1$} $N_2$ $N_3$ $\cdots$ $N_m$}, that is {^( ) {^( ) $\cdots$ {^( ) {^( ) $M$ $N_1$} $N_2$} $\cdots$} $N_m$}.
For example, {^( ) $M$ $N_1$ $N_2$} means {^( ) {^( ) $M$ $N_1$} $N_2$}.
- {^( ) $M$ $N_1$ $N_2$ $\cdots$ $N_m$ . $K$} means {^( ) {^( ) $M$ $N_1$ $N_2$ $\cdots$ $N_m$} . $K$}.
For example, {^( ) $M$ $N$ . $K$} means {^( ) {^( ) $M$ $N$} . $K$}.
- {^($x_1$ $x_2$ $x_3$ $\cdots$ $x_n$) $M$} means {^($x_1$) {^($x_2$ $x_3$ $\cdots$ $x_n$) $M$}}, that is {^($x_1$) {^($x_2$) {^($x_3$) $\cdots$ {^($x_n$) $M$} $\cdots$}}}.
For example, (^($x_1$ $x_2$) $M$) means (^($x_1$) (^($x_2$) $M$)).
- (^($x_1$ $x_2$ $\cdots$ $x_n$ . $k$) $M$) means (^($x_1$ $x_2$ $\cdots$ $x_n$)(^ $k$ $M$)),
e.g. (^($x$ . $k$) $M$) means (^($x$)(^ $k$ $M$)).
- (^ $k$ $M$ $N_1$ $N_2$ $\cdots$ $N_m$) means (^ $k$ (^( ) $M$ $N_1$ $N_2$ $\cdots$ $N_m$)).
- (^($x_1$ $x_2$ $\cdots$ $x_n$) $M$ $N_1$ $N_2$ $\cdots$ $N_m$) means (^($x_1$ $x_2$ $\cdots$ $x_n$)(^( ) $M$ $N_1$ $N_2$ $\cdots$ $N_m$)).
- (^($x_1$ $x_2$ $\cdots$ $x_n$ . $k$) $M$ $N_1$ $N_2$ $\cdots$ $N_m$) means (^($x_1$ $x_2$ $\cdots$ $x_n$ . $k$)(^( ) $M$ $N_1$ $N_2$ $\cdots$ $N_m$)).
- (^ $k$ $M$ $N_1$ $N_2$ $\cdots$ $N_m$ . $K$) means (^ $k$ (^( ) $M$ $N_1$ $N_2$ $\cdots$ $N_m$ . $K$)).
- (^($x_1$ $x_2$ $\cdots$ $x_n$) $M$ $N_1$ $N_2$ $\cdots$ $N_m$ . $K$) means (^($x_1$ $x_2$ $\cdots$ $x_n$)(^( ) $M$ $N_1$ $N_2$ $\cdots$ $N_m$ . $K$)).
- (^($x_1$ $x_2$ $\cdots$ $x_n$ . $k$) $M$ $N_1$ $N_2$ $\cdots$ $N_m$ . $K$) means (^($x_1$ $x_2$ $\cdots$ $x_n$ . $k$)(^( ) $M$ $N_1$ $N_2$ $\cdots$ $N_m$ . $K$)).
- (^( ) $M$ ^ $k$ $N$) means (^( ) $M$ . (^ $k$ $N$)).
- (^( ) $M$ ^($x_1$ $x_2$ $\cdots$ $x_n$) $N$) means (^( ) $M$ . (^($x_1$ $x_2$ $\cdots$ $x_n$) $N$)).
- (^( ) $M$ ^($x_1$ $x_2$ $\cdots$ $x_n$ . $k$) $N$) means (^( ) $M$ . (^($x_1$ $x_2$ $\cdots$ $x_n$ . $k$) $N$)).
- {^^ $M_1$ $M_2$ $M_3$ $\cdots$ $M_m$ . $N$} means {^^ $M_1$ . {^^ $M_2$ $M_3$ $\cdots$ $M_m$ . $N$}}, that is {^^ $M_1$ . {^^ $M_2$ . {^^ $M_3$ . {^^ $\cdots$ . {^^ $M_n$ . $N$}$\cdots$}}}}.

In the above rules,
- $m$ and $n$ are natural numbers,
- $x, x_1, x_2, \ldots, x_m$, and $k$ are variables,
- $M, N, M_1, M_2, \ldots, M_m, N_1, N_2, \ldots, N_m$ are hat terms.

## Functions

(defineCPS $f\ M$) defines a function named $f$ as $M$ where $f$ is a sequence of characters and $M$ is a hat expression.
A function name is a sequence of characters which must starts with an uppercase letter (A, B, ..., Z), and can contain letters and digits (0, 1, ..., 9).
For example, the following two definitions are used for the boolean values `True` and `False`:
```
(defineCPS True ^($x $y . $ret) $ret $x)
(defineCPS False ^($x $y . $ret) $ret $y)
```
We can define a control statement `IfThenElse`:
```
(defineCPS IfThenElse ^($p $x $y) $p $x $y ^($f) $f)
```
$M$ can be substituted for $f$ in hat expressions if $f$ is defined as $M$.
`(^( ) `$f\ \cdots$`) `&rArr;` (^( ) `$M\ \cdots$`)` means that $M$ is substituted for $f$ in the function application.
For example, `(^( ) IfThenElse True `$X\ Y$`)` is reduced to $X$ as follows:  
`(^( ) IfThenElse True `$X\ Y$`)`  
&rArr;`((^($p $x $y) $p $x $y ^($f) $f) True `$X\ Y$`)`  
&rarr;`((^($x $y) True $x $y ^($f) $f) `$X\ Y$`)`  
&rarr;`(^( ) True `$X\ Y$` ^(f) f)`  
&rArr;`(^( ) (^($x $y . $ret) $ret $x) `$X\ Y$` . (^($f) $f))`  
&rarr;`(^( ) (^ $ret $ret `$X$`) . (^($f) $f))`  
&rarr;`(^( ) (^($f) $f) `$X$`)`  
&rarr;$X$

We can define logic operators:
```
(defineCPS And ^(p q) p q p)  
(defineCPS Or ^(p q) p p q)  
(defineCPS Not ^(p) p False True)
```
For example, `(^( ) IfThenElse (^( ) And True False) `$X\ Y$`)` is reduced to $Y$ as follows:  
`(^( ) IfThenElse (^( ) And True False) `$X\ Y$`)`  
&rArr;`(^( ) (^($p $x $y) $p $x $y ^($f) $f) (^( ) And True False) `$X\ Y$`)`  
&rarr;`(^( ) (^( ) And True False) `$X\ Y$` ^($f) $f)`  
&rArr;`(^( ) (^( ) (^($p $q) $p $q $p) True False) `$X\ Y$` ^($f) $f)`  
&rarr;`(^( ) (^( ) True False True) `$X\ Y$` ^($f) $f)`  
&rArr;`(^( ) (^( ) (^($x $y . $ret) $ret $x) False True) `$X\ Y$` ^($f) $f)`  
&rarr;`(^( ) (^ $ret $ret False) `$X\ Y$` ^($f) $f)`  
&rarr;`(^( ) (^ $ret $ret False) . (^(`$t$`) `$t\ X\ Y$` ^($f) $f))`  
&rarr;`(^( ) (^(`$t$`) `$t\ X\ Y$` ^($f) $f) False)`  
&rarr;`(^( ) False `$X\ Y$` ^($f) $f)`  
&rArr;`(^( ) (^($x $y . $ret) $ret $y) `$X\ Y$` ^($f) $f)`  
&rarr;`(^( ) (^ $ret $ret `$Y$`) . (^($f) $f))`  
&rarr;`(^( ) (^($f) $f) `$Y$`)`  
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
- (^( ) Add $x\ y$) returns the sum of $x$ and $y$.
- (^( ) Sub $x\ y$) returns the value of $y$ subtracted from $x$.
- (^( ) Mul $x\ y$) returns the product of $x$ and $y$.
- (^( ) Div $x\ y$) returns the value of $x$ divided by $y$.
- (^( ) Mod $x\ y$) returns the value of $x$ divided by $y$.
- (^( ) DivMod $x\ y$) returns the value of $x$ divided by $y$.

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
