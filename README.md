# hat
- [The Hat Programming Language](https://shima3.github.io/hat/)
- [A Hat Interpreter in JavaScript](https://shima3.github.io/hat/js/)
- [Tutorial](https://shima3.github.io/hat/tutorial/)

## Hat terms

**Hat terms** are variable names, function applications, continuation applications, function abstraction, or continuation abstractions defined as follows.
- A **variable name** is a string that must starts with a letter (A-Z, a-z) or the dollar sign ($), and can contain letters and digits (0-9), e.g. x, M, xy, N2, $sum, or $12.
- (M N) is a **function application** if M and N are hat terms.
- (M . N) is a **continuation application** if M and N are hat terms.
- (^(x) M) is a **function abstraction** if x is a variable name and M is a hat term.
- (^ x M) is a **continuation abstraction** if x is a variable name and M is a hat term.

## Bound variables and free variables

A variable x of a function abstraction (^(x) M) or a continuation abstraction (^ x M) is a bound variable.
Variables that are contained in a hat term and are not bound variables, are free variables.
FV(M) is a set of free variables of M if M is a hat term, and is defined as follows:
- FV(x) is a set that contains just x.
- FV(M N) and FV(M . N) are a union of FV(M) and FV(N) if M and N are hat terms.
- FV(^(x) M) and FV(^ x M) are a set removed x from FV(M) if x is a variable and M is a hat term.
