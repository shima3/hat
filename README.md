# hat
- [The Hat Programming Language](https://shima3.github.io/hat/)
- [A Hat Interpreter in JavaScript](https://shima3.github.io/hat/js/)
- [Tutorial](https://shima3.github.io/hat/tutorial/)

## Hat terms

**Hat terms** are variable names, function applications, continuation applications, function abstraction, or continuation abstractions.
They are defined so that:
- A **variable name** is a string that must starts with a letter (A-Z, a-z) or the dollar sign ($), and can contain letters and digits (0-9), e.g. x, M, xy, N2, $sum, or $12.
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

## Substitution

The notation M[x:=N] indicates substitution of N for x in M if M and N are hat terms and x is a variable.
This is defined so that:
- x[x:=N] = N
- y[x:=N] = y if y is a variable different from x.
- (M1 M2)[x:=N] = (M1[x:=N] M2[x:=N])
- (M1 . M2)[x:=N] = (M1[x:=N] . M2[x:=N])
- (^(x) M)[x:=N] = (^(x) M)
- (^ x M)[x:=N] = (^ x M)
- (^(y) M)[x:=N] = (^(y) M[x:=N]) if y is a variable different from x and is not a free variable of N.
- (^ y M)[x:=N] = (^ y M[x:=N]) if y is a variable different from x and is not a free variable of N.

## Reduction



