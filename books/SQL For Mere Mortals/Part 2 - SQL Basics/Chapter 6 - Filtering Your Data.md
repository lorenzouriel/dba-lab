# Chapter 6: Filtering Your Data

WHERE clause == filters the rows a SELECT statement draws from a table, using a **search condition**.

Search condition == one or more **predicates** — each an expression testing a value expression, evaluating to true, false, or **unknown**. Only rows where the whole search condition evaluates to true make it into the result set. A search condition with a single predicate == that predicate (the terms are synonymous in that case).

```sql
SELECT CustLastName
FROM   Customers
WHERE  CustLastName = 'Smith'
```

The Standard defines 18 predicates; the book covers the 5 you'll use constantly: **Comparison**, **BETWEEN** (range), **IN** (membership), **LIKE** (pattern match), **IS NULL**. (The other 13 — Similar, Regex, Quantified, Exists, Unique, Normalized, Match, Overlaps, Distinct, Member, Submultiset, Set, Type — are mostly unimplemented outside MySQL/PostgreSQL's Regex support; Quantified and Exists get their own treatment in Chapter 11.)

## Comparison

```sql
WHERE CustLastName = 'Smith'
```

Six operators: `= <> < > <= >=`.

✨ **Side learning:** the Standard's "not equal to" is `<>`, but SQL Server/Sybase also accept `!=` and DB2 also accepts `¬=`.

### Comparing Strings: A Caution

String comparison depends entirely on the database's **collating sequence** — no default is mandated by the Standard.

1. **ASCII collation** (common default): numbers < uppercase < lowercase. So `'Zebra' < 'allegheny'`.
2. **Case-insensitive ASCII**: `{Aa} {Bb} {Cc} ...` — case ignored, alphabetic order wins.
3. **EBCDIC** (IBM mainframes): lowercase < uppercase < numbers — the reverse grouping of ASCII.

🤯 Comparing strings of unequal length pads the shorter one with spaces (per the Standard) before comparing — so `'John'` equals `'John '`. Some systems instead just ignore trailing blanks entirely, arriving at the same equality via a different rule — but `'Mitch'` and `'Mitchell'` remain unequal either way since padding only adds trailing spaces, not extra letters.

### Less/Greater Than

Meaning depends on data type:
1. Character strings — collating-sequence order (`a < c` means "a precedes c").
2. Numbers — magnitude.
3. Dates/times — chronological order.

```sql
WHERE ShipDate < OrderDate         -- data-entry error check
WHERE Credits > 4
WHERE DateHired >= '1989-01-01'
WHERE RetailPrice <= 50
```

## Range: BETWEEN

```sql
value_expr BETWEEN low_expr AND high_expr
```

Inclusive on both ends; equivalent to `value_expr >= low AND value_expr <= high`.

```sql
WHERE DateHired BETWEEN '1986-07-01' AND '1986-07-31'
WHERE StudLastName BETWEEN 'B' AND 'Bz'
```

🤯 BETWEEN is **order-sensitive** by default (ASYMMETRIC in Standard terms): `MyColumn BETWEEN 10 AND 5` is `MyColumn >= 10 AND MyColumn <= 5` — a condition that can never be true. The Standard defines a SYMMETRIC keyword to swap the bounds automatically, but the book notes no major implementation supports it — so always put the smaller bound first.

BETWEEN's first operand can itself be a value expression, not just a plain column — enabling a neat trick: testing whether a literal falls between two *columns*:

```sql
WHERE '2017-10-10' BETWEEN StartDate AND EndDate
```

## Set Membership: IN

```sql
value_expr IN (value, value, ...)
```

```sql
WHERE TourneyDate IN ('2017-09-18', '2017-10-09', '2017-11-06')
WHERE EntCity IN ('Seattle', 'Redmond', 'Bothell')
```

Best for a short, explicit, finite list — reach for BETWEEN instead when the values form a natural range.

## Pattern Match: LIKE

```sql
value_expr LIKE 'pattern' [ESCAPE 'escape_char']
```

Wildcards: `%` == zero or more arbitrary characters, `_` == exactly one arbitrary character.

| Pattern | Matches |
|---|---|
| `'Sha%'` | begins with "Sha" |
| `'%son'` | ends with "son" |
| `'%han%'` | contains "han" anywhere |
| `'Ro_'` | exactly 3 chars, starts "Ro" |
| `'_ar_'` | exactly 4 chars, "ar" in positions 2-3 |

```sql
WHERE CustLastName LIKE 'Mar%'
WHERE VendStreetAddress LIKE '%Forest%'
```

To search for a literal `%` or `_` inside the data, escape it:

```sql
WHERE ProductCode LIKE 'G\_00_' ESCAPE '\'
```
Here the escaped `\_` is a literal underscore; the trailing unescaped `_` is still a wildcard.

✨ **Side learning:** Microsoft Access uses `*` and `?` instead of `%` and `_` for its LIKE wildcards (plus `#` for "any digit") — a leftover from its non-standard query engine roots.

🤯 LIKE is frequently **case-sensitive** depending on install/collation — `LIKE '%chi%'` matches "roast chicken" but not "Chicken a la King" on a case-sensitive system. Always check your server's collation before assuming a pattern will catch every case variant.

## Null: IS NULL

```sql
value_expr IS NULL
```

```sql
WHERE CustCounty IS NULL
WHERE ContractPrice IS NULL
```

`<value_expr> = NULL` is **always invalid/wrong** — you cannot compare anything to Null with `=`, because Null represents "unknown," and unknown compared to anything is itself unknown (never true). Only `IS NULL` / `IS NOT NULL` actually test for it.

Watch out for false positives when 0 is a legitimate value in the same column that also uses Null for "not yet determined" — searching for `= 0` and searching `IS NULL` are two very different questions.

## Excluding Rows: NOT

NOT is available two ways:
1. As an option baked into BETWEEN / IN / LIKE / IS NULL: `NOT BETWEEN`, `NOT IN`, `NOT LIKE`, `IS NOT NULL`.
2. As a prefix on an entire predicate or parenthesized search condition — this form also works in front of a plain comparison, which the inline form can't do:

```sql
WHERE NOT BowlerCity = 'Bellevue'          -- equivalent to <>
WHERE Title NOT IN ('Professor', 'Associate Professor')
```

🤯 Two NOTs in the same condition cancel out — easy to do by accident:

```sql
WHERE NOT Title NOT IN ('Teacher', 'Teacher''s Aide')
```
reads as "not (not teacher)" — the double negative flips the intended filter, returning *only* teachers/aides instead of everyone else.

## Combining Conditions: AND / OR

```sql
WHERE CustCity = 'Seattle' AND CustLastName LIKE 'H%'
WHERE StfCity = 'Seattle' OR StfState = 'OR'
```

1. AND — row must satisfy **all** combined conditions.
2. OR — row must satisfy **at least one**.

Watch for requests that sound like "and" in English but mean "or" logically — "vendors based in Washington and California" really means `VendState = 'WA' OR VendState = 'CA'`, since a single row's State column can't hold two values at once.

### Order of Precedence

```
1. Unary + / -
2. * /
3. Binary + / -
4. = <> < > <= >= BETWEEN IN LIKE IS NULL
5. NOT
6. AND
7. OR
```

AND binds tighter than OR — always parenthesize mixed AND/OR conditions to make intent explicit rather than relying on memorized precedence:

```sql
WHERE (CustLastName = 'Patterson' AND CustState = 'CA')
   OR CustZipCode LIKE '%9'
```
vs.
```sql
WHERE CustLastName = 'Patterson'
  AND (CustState = 'CA' OR CustZipCode LIKE '%9')
```
Same tokens, different parens, genuinely different result sets.

Parenthetical evaluation order: parenthesized groups process before non-parenthesized ones; multiple groups at the same level go left to right; nested parens go innermost to outermost.

✨ **Side learning:** the book's performance tip — put the most selective condition first in an AND chain (e.g., filter by a specific CustomerID before a broad ShipDate = OrderDate check), since a smart optimizer may use it to shrink the working set earlier. Modern cost-based optimizers mostly reorder predicates themselves based on indexes/statistics, but it doesn't hurt to write it that way regardless.

### Checking Overlapping Ranges

BETWEEN can't directly answer "does my range overlap this other range?" — testing StartDate BETWEEN ... AND EndDate BETWEEN ... only catches engagements that start *and* end fully inside the target window, missing ones that merely straddle it.

🤯 The clean trick: any overlap exists exactly when `StartDate <= window_end AND EndDate >= window_start` — no need to enumerate all 4 overlap scenarios (fully inside, straddling the start, straddling the end, spanning the whole window) separately.

```sql
WHERE StartDate <= '2017-11-18'
  AND EndDate   >= '2017-11-12'
```

## Nulls in Search Conditions

A predicate touching a Null evaluates to **unknown**, not false — and unknown is never enough to select a row (only true selects it).

AND/OR truth tables with unknown added:

1. `unknown AND true` → unknown (rejected)
2. `unknown AND false` → false (rejected)
3. `unknown OR true` → true (selected!)
4. `unknown OR false` → unknown (rejected)
5. `NOT unknown` → still unknown (not flipped to true)

🤯 `NOT (A = B)` is **not** guaranteed to be the opposite of `A = B` when Null is involved — if the comparison is unknown, negating it is *still* unknown, not true. This is why `A <> B` and `NOT (A = B)` can behave identically only when neither side is Null.

Practical implication: with OR, a row can still make it into the result set even if one side involves a Null column, as long as the other side is true. With AND, a Null on either side reliably knocks the row out (unknown never survives an AND).

If a result set looks wrong, test the suspect column with `IS NULL` directly to rule out Null-driven surprises before assuming a logic bug.

## Expressing the Same Condition Different Ways

Multiple predicates often express identical logic — pick whichever reads clearest for the case at hand:

```sql
DateHired BETWEEN '2007-10-01' AND '2007-10-31'
DateHired >= '2007-10-01' AND DateHired <= '2007-10-31'

VendState IN ('CA', 'OR', 'WA')
VendState = 'CA' OR VendState = 'OR' OR VendState = 'WA'

CustLastName LIKE 'H%'
CustLastName BETWEEN 'H' AND 'HZ'

StudCity NOT IN ('Seattle', 'Redmond')
NOT (StudCity = 'Seattle' OR StudCity = 'Redmond')
```

None is "more correct" syntactically — but check your engine's docs, since some optimizers handle one form measurably better than an equivalent one.

## Summary

- WHERE filters rows via a search condition built from one or more predicates, each evaluating true/false/unknown.
- Five workhorse predicates: comparison, BETWEEN (range), IN (membership), LIKE (pattern match), IS NULL.
- String comparisons depend on collating sequence — case sensitivity and sort order are not standardized.
- BETWEEN is inclusive and order-sensitive (low value must come first) unless the (rarely supported) SYMMETRIC form is used.
- LIKE wildcards: `%` for any run of characters, `_` for exactly one; use ESCAPE to match a literal wildcard character.
- Null can only be tested with IS NULL / IS NOT NULL — `= NULL` is always wrong.
- NOT can prefix a predicate keyword (NOT BETWEEN/IN/LIKE) or an entire search condition — stacking two cancels out.
- AND binds tighter than OR; parenthesize mixed conditions explicitly rather than trusting memorized precedence.
- Overlapping date ranges are tested with `Start1 <= End2 AND End1 >= Start2`, not two BETWEENs.
- Any predicate touching Null returns unknown, not false — AND with unknown always rejects the row, but OR with unknown can still select it if the other side is true.
