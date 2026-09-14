# Appendix A: SQL Standard Diagrams

Quick-reference note: this appendix is a set of **syntax (railroad) diagrams** — flowchart-style pictures of SQL grammar, not ER/table diagrams. The book uses them to show every legal path through a clause at a glance, collecting in one place all the syntax spread across the chapters.

## How to Read a Railroad Diagram

1. Read left to right, following the line.
2. A single line with no branch == mandatory, in that order.
3. Stacked alternatives (options on top of each other) == pick exactly one.
4. A loop-back line, usually via a comma == the preceding element can repeat one-or-more times.
5. An asterisk/footnote hanging off a branch == a restriction that can't be drawn as a simple line (e.g. "can't combine with BETWEEN CURRENT ROW").
6. UPPERCASE words == literal keywords, typed exactly. Mixed/lowercase words == placeholders you fill in (`table_name`, `Value Expression`).

✨ **Side learning:** This is the same style of diagram used in the official ISO SQL standard documents and in tools like SQLite's "railroad diagrams" grammar reference on sqlite.org — once you can read one, you can read the other.

## SELECT Statement (skeleton)

```sql
SELECT [DISTINCT] Value Expression [AS alias], ...
FROM Table Reference
[WHERE Search Condition]
[GROUP BY Column Reference, ... | ROLLUP(...) | CUBE(...) | GROUPING SETS(...)]
[HAVING Search Condition]
```

- `DISTINCT` is optional, sits right after `SELECT`.
- The select list is a repeating (comma-loop) list of Value Expressions, each optionally aliased with `AS`.
- `GROUP BY` branches into four shapes: plain column list, `ROLLUP`, `CUBE`, or `GROUPING SETS` — all still comma-separated lists of column references underneath.

## Value Expression

A Value Expression is one of:
1. A literal value
2. A column reference
3. A function call
4. A `CASE` expression
5. A parenthesized Value Expression, or a scalar subquery `(SELECT ...)`
6. Two Value Expressions combined with `+ - * /` or `||`

Which operators are legal depends on the data type:

| Type | Valid operators |
|---|---|
| Character | `\|\|` (concatenation) |
| Numeric | `+ - * /` |
| Date/Time | `+ -` |
| Interval | `+ - * /` |

## CASE Expression

```sql
CASE value_expr
    WHEN value_expr THEN value_expr   -- simple form
    ELSE value_expr
END

CASE
    WHEN search_condition THEN value_expr   -- searched form
    ELSE NULL
END
```

Two shapes: **simple** CASE compares one expression against a list of values; **searched** CASE evaluates independent boolean conditions. `ELSE` is optional and defaults to `NULL` when omitted.

## Joined Table

```sql
Table Reference [NATURAL | CROSS]
    [INNER | LEFT [OUTER] | RIGHT [OUTER] | FULL [OUTER] | UNION]
    JOIN Table Reference
    [ON Search Condition | USING (column_name, ...)]
```

Rule called out with a footnote in the diagram: if you use `NATURAL` or `CROSS`, you **cannot** also supply `ON` or `USING` — the join columns are implied, not stated.

## Set (Aggregate) Functions — GROUPING

```sql
GROUPING(Column Reference, ...)
```

Used alongside `ROLLUP`/`CUBE`/`GROUPING SETS` to tell which rows in the result are the "subtotal" rows the standard SQL grouping extensions synthesize.

## Window Functions

General shape shared by every window function:

```sql
<ranking/aggregate/value function> OVER (
    [PARTITION BY Column Reference, ...]
    [ORDER BY column_name [ASC | DESC], ...]
    [ROWS | RANGE
        BETWEEN {UNBOUNDED PRECEDING | n PRECEDING | CURRENT ROW}
        AND     {n FOLLOWING | CURRENT ROW | UNBOUNDED FOLLOWING | n PRECEDING}]
)
```

Functions that plug into this frame, grouped by what they need:

| Function | Needs `ORDER BY`? | Notes |
|---|---|---|
| `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `PERCENT_RANK()` | Yes | No arguments |
| `NTILE(n)` | Yes | Splits partition into `n` buckets |
| `LEAD(expr, [n], [default])`, `LAG(...)` | Yes | Looks ahead/behind `n` rows (default 1) |
| `FIRST_VALUE(expr)`, `LAST_VALUE(expr)` | Optional | Respects the frame clause |
| `NTH_VALUE(expr, n)` | Optional | Respects the frame clause |

- `ROWS`/`RANGE` frame clauses require an `ORDER BY` to be meaningful (marked `***` in the diagram).
- `AND n PRECEDING` can't be combined with `BETWEEN CURRENT ROW` (marked `*`); `AND CURRENT ROW` can't combine with `BETWEEN n FOLLOWING` (marked `**`).

🤯 The window function frame clause diagram is identical whether you're calling `SUM() OVER (...)` or `RANK() OVER (...)` — the frame syntax is orthogonal to which function you plug into `OVER (...)`.
