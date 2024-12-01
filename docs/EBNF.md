# EBNF Notation Used

The EBNF (Extended Backus-Naur Form) notation used in the definitions adheres to common conventions for describing the syntax of formal languages.
Below is an explanation of the elements and constructs in this EBNF:

## Key Elements and Constructs

### Rule Definition

Syntax rules are defined with the format:
```ebnf

RuleName = Expression ;
```

- The left-hand side (RuleName) specifies the name of the rule.
- The right-hand side (Expression) defines its structure.

### Concatenation

Elements listed sequentially must appear in the given order:

```ebnf

Expression = Element1, Element2 ;
```

- Example: Element1 is followed by Element2.

### Alternatives

Multiple options are separated by |, indicating that any one of them can match:

```ebnf

Expression = Option1 | Option2 ;
```

- Example: Matches either Option1 or Option2.
