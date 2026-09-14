# Chapter 19: Condition Testing

CASE == SQL's "If ... Then ... Else" for Value Expressions. Needed whenever the right expression to return depends on the value(s) in some other column(s) — decoding a stored code ("M"/"F" → "Male"/"Female"), avoiding a divide-by-zero, computing an exact date-difference in years, bucketing a number into a named range, building a conditional salutation, etc.

CASE is a **Value Expression**, not a statement — so it's legal anywhere a Value Expression is: the SELECT list, an ON clause, a WHERE clause, a HAVING clause. It always evaluates to a single value.

## Syntax: Simple vs. Searched

Two forms:

1. **Simple CASE** — `CASE <expr> WHEN <value> THEN <result> ... ELSE <default> END`. Tests one expression for equality against a list of literal values. Nothing but `=` is possible in a Simple CASE.
2. **Searched CASE** — `CASE WHEN <search condition> THEN <result> ... ELSE <default> END`. Each WHEN carries a full Search Condition — `>`, `<`, `BETWEEN`, `IN`, `LIKE`, `IS NULL`, `EXISTS`, subqueries, AND/OR — anything legal in a WHERE clause.

```sql
-- Simple: equality only
CASE StudGender
    WHEN 'M' THEN 'Male'
    WHEN 'F' THEN 'Female'
    ELSE 'Not Specified'
END

-- Searched: arbitrary predicates, can reference multiple columns
CASE
    WHEN AVG(RawScore) < 140 THEN 'Fair'
    WHEN AVG(RawScore) < 160 THEN 'Average'
    WHEN AVG(RawScore) < 185 THEN 'Good'
    ELSE 'Excellent'
END
```

Both forms:
1. Evaluate WHEN clauses top to bottom and **stop at the first one that's true** — order matters, later WHENs implicitly assume all earlier ones failed.
2. `ELSE` is optional; if omitted and nothing matches, the result is `NULL` (an implicit `ELSE NULL`).
3. Because evaluation stops at the first match, ranges don't need both bounds spelled out — `WHEN < 500 THEN 'Average'` after `WHEN <= 200 THEN 'Poor'` already means "> 200 and <= 500", the lower bound is implied by having fallen through the first WHEN.

✨ **Side learning**: Microsoft Access has no `CASE` at all — it uses `IIf(condition, true_result, false_result)` instead, nested for multiple branches. SQL Server, MySQL, PostgreSQL, and Oracle all support standard `CASE`. Also: the SQL Standard technically doesn't require parentheses around a CASE expression, but SQL Server and MySQL choke without them in some contexts — wrap it in `(...)` defensively.

## Pattern: Decoding a Stored Code (Simple CASE)

The recurring reason a "code" column exists at all: storage efficiency, or an externally-imposed format (M/F, C/F for Celsius/Fahrenheit, credit/debit sign). CASE turns the code into the human-meaningful label at query time, leaving the stored representation untouched.

```sql
SELECT StudentID, StudFirstName, StudLastName,
       (CASE StudGender
            WHEN 'M' THEN 'Male'
            WHEN 'F' THEN 'Female'
            ELSE 'Not Specified' END) AS Gender
FROM Students;
```

## Pattern: Avoiding Divide-by-Zero

A `SUM(...) / SUM(...)` (e.g. weighted average like GPA = Σ(credits × grade) / Σ(credits)) blows up when the denominator's sum is zero — typically because an OUTER JOIN produced no matching child rows for some parent (a student who completed zero classes). Test a COUNT of the joined child rows first; COUNT is always a safe non-NULL integer even when the SUMs would be NULL.

```sql
SELECT St.StudentID,
       COUNT(SC.StudentID) AS NumberCompleted,
       (CASE COUNT(SC.StudentID)
            WHEN 0 THEN 0
            ELSE SUM(SC.Credits * SC.Grade) / SUM(SC.Credits)
        END) AS GPA
FROM Students AS St
LEFT OUTER JOIN
    (SELECT StudentID, Grade, Credits FROM ... WHERE Grade >= 67) AS SC
    ON St.StudentID = SC.StudentID
GROUP BY St.StudentID;
```

This is portable standard SQL, versus reaching for a vendor-specific null-guard function.

✨ **Side learning**: every major engine has its own non-standard divide-by-zero-avoidance helper that solves a narrower problem (NULL-coalescing, not zero-avoidance) — Access `NZ`, SQL Server `ISNULL`, MySQL `IFNULL`, PostgreSQL/standard `COALESCE`. Those guard against a NULL operand, not a zero denominator — CASE is the only portable way to guard the divide itself.

## Pattern: Exact Interval Math (Leap-Year-Correct Ages/Tenure)

`(target_year - start_year)` alone overcounts by one whenever the start month/day hasn't "occurred yet" in the target year. Searched CASE encodes the adjustment as three ordered branches (stop-at-first-true does the rest — no need to test the "exactly equal" case separately, it falls out of the two inequalities already failing):

```sql
SELECT StaffID,
       YEAR(CAST('2017-10-01' AS DATE)) - YEAR(DateHired)
       - (CASE
              WHEN MONTH(DateHired) < 10 THEN 0
              WHEN MONTH(DateHired) > 10 THEN 1
              WHEN DAY(DateHired) > 1 THEN 1
              ELSE 0
          END) AS LengthOfService
FROM Staff;
```

🤯 A naive `(target_date - hired_date) / 365` is wrong by one full day for every leap year spanned — invisible for short spans, quietly compounding for anyone hired decades ago. The CASE version sidesteps the whole leap-year question by comparing year/month/day components directly instead of doing day-count arithmetic.

## Pattern: Multi-Column Conditional Concatenation

Building a value from more than one input column (a mailing-label salutation from gender + marital status) requires Searched CASE, since Simple CASE can only test one expression. Order the WHEN branches to exploit fallthrough — test the case that eliminates the most rows first:

```sql
SELECT (CASE WHEN StudGender = 'M' THEN 'Mr. '
             WHEN StudMaritalStatus = 'S' THEN 'Ms. '
             ELSE 'Mrs. ' END)
       || StudFirstName || ' ' || StudLastName AS NameLine
FROM Students;
```

All males get "Mr." without ever checking marital status; among the non-males (implicitly female), singles get "Ms.", everyone else (married/divorced/widowed) gets "Mrs." Three branches instead of the naive four-way cross of gender × status.

## Pattern: CASE in WHERE/HAVING

Legal, since CASE is just a Value Expression — but the book is blunt about it: **almost never the clearest way to write a predicate**. `WHERE 'Male' = (CASE WHEN StudGender = 'M' THEN 'Male' ELSE 'Nomatch' END)` is a working but pointless detour around `WHERE StudGender = 'M'`.

Where CASE-in-WHERE actually earns its place: encoding "A but not B" logic where a straightforward AND/OR would accidentally short-circuit to the wrong set. To find customers who like Jazz but not Standards, test the *disqualifying* conditions first (in order), because — as always — evaluation stops at the first true WHEN:

```sql
SELECT CustomerID, CustFirstName, CustLastName
FROM Customers
WHERE 1 = (CASE
    WHEN CustomerID NOT IN
        (SELECT CustomerID FROM Musical_Preferences
         INNER JOIN Musical_Styles ON ... WHERE StyleName = 'Jazz')
        THEN 0                                    -- doesn't like Jazz -> disqualify
    WHEN CustomerID IN
        (SELECT CustomerID FROM Musical_Preferences
         INNER JOIN Musical_Styles ON ... WHERE StyleName = 'Standards')
        THEN 0                                    -- likes Standards -> disqualify
    ELSE 1 END);                                   -- survives both checks -> keep
```

Testing "likes Jazz" as the *first* WHEN (the seemingly natural order) would have wrongly captured every Jazz fan before ever checking Standards — order-sensitivity strikes again. This mirrors the "NOT" set-logic headaches from Chapter 18; CASE just gives an alternative vehicle for the same elimination-order reasoning.

## Pattern: Bucketing into Named Ranges

Sales tiers, letter grades, bowling ratings — any continuous numeric value collapsed into named bands. Same fallthrough trick as the divide-by-zero example: only the lower bound needs stating per branch.

```sql
SELECT Grade,
    (CASE WHEN Grade BETWEEN 97 AND 100 THEN 'A+'
          WHEN Grade BETWEEN 93 AND 96.99 THEN 'A'
          WHEN Grade BETWEEN 90 AND 92.99 THEN 'A-'
          -- ... more bands ...
          ELSE 'F' END) AS LetterGrade
FROM Student_Schedules;
```

A smart optimizer recognizes repeated identical subqueries across WHEN branches (e.g. the same `SELECT SUM(QuantityOrdered) FROM Order_Details WHERE ...` repeated in three WHEN conditions of a sales-tier CASE) and evaluates it once per row rather than once per branch — but this isn't guaranteed by the Standard, just common in practice.

## Summary

- CASE is a Value Expression, not a statement — usable in SELECT, ON, WHERE, or HAVING, anywhere a value is expected.
- Simple CASE: one expression tested for equality against a list of literals. Searched CASE: each WHEN is a full Search Condition — comparisons, ranges, IN, subqueries, anything WHERE allows.
- Both forms stop at the **first** true WHEN — order your branches from most-specific/most-eliminating to least, and exploit that fallthrough to skip redundant bound checks (`< 500` after `<= 200` already means "in (200, 500]").
- Recurring uses: decode a stored code into a label, guard a division by testing COUNT before dividing, do leap-year-correct interval math by comparing date parts instead of subtracting raw days, build multi-column conditional text, bucket a continuous value into named ranges.
- CASE inside WHERE/HAVING is legal but rarely clearer than a direct predicate — the one place it earns its keep is encoding ordered "eliminate A, then eliminate B, keep the rest" logic that a plain AND/OR would get backward.
- Access has no CASE — use nested `IIf()` there instead; every other major engine follows the Standard syntax.
