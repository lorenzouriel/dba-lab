# Chapter 22: Partitioning Data into Windows

Problem category: you want an aggregate or a ranking calculated relative to other rows, but you also want to keep the detail rows — not collapse them the way GROUP BY does. Introduced in SQL:2003. This is the modern SQL Server (2017+) / PostgreSQL / Oracle window-function syntax, so worth getting exactly right — it maps 1:1 onto real query writing.

Why it's tricky: before window functions, "give me each row's detail plus a total/rank computed across a set of related rows" required either a correlated subquery per row (slow, verbose) or collapsing into GROUP BY and losing the detail. Window functions let an aggregate/ranking function return one value **per row** without reducing the row count.

## GROUP BY vs OVER() — the Core Distinction

- `GROUP BY` == collapses rows: one output row per unique combination of grouped columns.
- `OVER()` == does **not** collapse rows: same row count as the underlying query; the function's result is computed per row but based on a *window* (set of related rows) around it.

```sql
SELECT C.CustomerID, C.CustFirstName || ' ' || C.CustLastName AS Customer,
    MS.StyleName,
    COUNT(*) OVER (PARTITION BY C.CustomerID) AS Preferences
FROM Customers AS C
    INNER JOIN Musical_Preferences AS MP ON MP.CustomerID = C.CustomerID
    INNER JOIN Musical_Styles AS MS ON MS.StyleID = MP.StyleID;
```

Each detail row (one per customer/style pair) is preserved, but `Preferences` shows the count of styles for *that customer* — computed as a window, not collapsed into a summary row. Compare to the equivalent correlated subquery:

```sql
SELECT CustomerID, StyleName,
    (SELECT COUNT(*) FROM Musical_Preferences mp2 WHERE mp2.CustomerID = Customers.CustomerID)
FROM ...
```

Same result, but the window function is generally more efficient and reads more directly.

## OVER() Clause Syntax

```sql
function_name ( [arguments] ) OVER (
    [ PARTITION BY column_reference [, ...] ]
    [ ORDER BY column_name [ASC | DESC] [, ...] ]
    [ ROWS | RANGE frame_extent ]      -- aggregate functions only
)
```

Where `frame_extent` is one of:

```sql
UNBOUNDED PRECEDING
unsigned_integer PRECEDING
CURRENT ROW

BETWEEN frame_start AND frame_end
```

with `frame_start`/`frame_end` drawn from `UNBOUNDED PRECEDING`, `n PRECEDING`, `CURRENT ROW`, `n FOLLOWING`, `UNBOUNDED FOLLOWING`.

Three predicates inside `OVER()`:

1. **PARTITION BY** — divides the result set into independent groups ("windows"); the function resets/restarts per partition. Omit it and the function applies across the *entire* result set as one window.
2. **ORDER BY** — controls the order rows are evaluated in (needed for running totals, ranks, and any ROWS/RANGE frame). This ORDER BY is local to the window function — it does not sort the final output; you still need a separate query-level ORDER BY for that.
3. **ROWS or RANGE** — restricts the window to a sub-range of the partition, relative to the current row. Only legal with aggregate functions (not with ROW_NUMBER, RANK, DENSE_RANK, PERCENT_RANK, NTILE).

Which clauses are required/optional per function:

| Function | OVER() | PARTITION BY | ORDER BY | ROWS/RANGE |
|---|---|---|---|---|
| `ROW_NUMBER()` | required | optional | required | not allowed |
| `RANK()` | required | optional | required | not allowed |
| `DENSE_RANK()` | required | optional | required | not allowed |
| `PERCENT_RANK()` | required | optional | required | not allowed |
| `NTILE(n)` | required | optional | required | not allowed |
| aggregate fn (COUNT, SUM, AVG, MIN, MAX) | required | optional | optional | optional |

An empty `OVER()` with no clauses at all applies the aggregate over every row returned by FROM/WHERE — a way to get a grand total on every row without a GROUP BY:

```sql
SELECT CustomerID, StyleName, COUNT(*) OVER () AS TotalRows
FROM Customers ...
```

## Multiple OVER() Clauses in One Query

Nothing stops you from windowing the same or different aggregate functions multiple ways in a single SELECT — e.g. a per-partition count next to a running grand total:

```sql
SELECT C.CustomerID, MS.StyleName,
    COUNT(*) OVER (PARTITION BY C.CustomerID ORDER BY C.CustomerID) AS CustomerPreferences,
    COUNT(*) OVER (ORDER BY C.CustomerID) AS RunningTotal
FROM Customers AS C
    INNER JOIN Musical_Preferences AS MP ON MP.CustomerID = C.CustomerID
    INNER JOIN Musical_Styles AS MS ON MS.StyleID = MP.StyleID;
```

`CustomerPreferences` == count within that customer's partition. `RunningTotal` == count over all rows seen so far (no PARTITION BY, but an ORDER BY, so it accumulates). ⚠️ Keep the ORDER BY inside each window consistent with its PARTITION BY, or the running values get confusing to reason about.

## ROW_NUMBER() — Sequential Numbering

Assigns a strictly increasing integer per row within the window — no ties, no gaps, ever.

```sql
SELECT ROW_NUMBER() OVER (ORDER BY CustLastName, CustFirstName) AS RowNumber,
    CustomerID, CustFirstName || ' ' || CustLastName AS CustomerName
FROM Customers;
```

Add `PARTITION BY` to restart the count per group:

```sql
SELECT ROW_NUMBER() OVER (
    PARTITION BY CustState
    ORDER BY CustLastName, CustFirstName
) AS RowNumber, CustomerID, CustState
FROM Customers;
```

Numbering restarts at 1 for each new state.

## RANK(), DENSE_RANK(), PERCENT_RANK() — Ranking with Ties

```sql
SELECT StudFirstName, Grade,
    RANK() OVER (ORDER BY Grade DESC) AS Rank
FROM ...
```

- **RANK()** — ties share the same rank; the *next* rank skips ahead by the number of tied rows. Two rows tied at rank 4 → the next distinct value gets rank 6 (5 is skipped).
- **DENSE_RANK()** — ties share the same rank; the next distinct value gets the very next integer, no gap. Same scenario → next value gets rank 5.
- **PERCENT_RANK()** — `(rank - 1) / (rows_in_partition - 1)`. Always 0 for the top row; always 1 for a lone bottom row; ties get the same percentile.

```sql
SELECT BowlerName, AvgHandicap,
    RANK()         OVER (ORDER BY AvgHandicap DESC) AS Rank,
    DENSE_RANK()   OVER (ORDER BY AvgHandicap DESC) AS DenseRank,
    PERCENT_RANK() OVER (ORDER BY AvgHandicap DESC) AS PercentRank
FROM Bowlers ...
```

If 4 bowlers tie for 1st: RANK gives all four `1`, then the 5th-place group gets `5`. DENSE_RANK gives all four `1`, then the next group gets `2`.

## NTILE(n) — Splitting into Buckets

Divides the partition into `n` roughly-equal groups, numbered 1..n. When rows don't divide evenly, the **larger** groups come first.

```sql
SELECT StudFirstName, Grade,
    NTILE(5) OVER (ORDER BY Grade DESC) AS Quintile
FROM ...
```

18 rows split into 5 groups → sizes 4, 4, 4, 3, 3 (groups 1-3 get the extra rows, not evenly distributed at the tail).

🤯 This means NTILE-based quintiles can disagree with a hand-rolled "divide rank by count × 0.2" quintile calculation (the technique from Chapter 20's driver-table CROSS JOIN approach) purely because of how the leftover rows get distributed — neither approach is "more correct," they just allocate remainders differently. Worth checking which convention a report actually needs before picking one.

## ROWS vs RANGE — Framing the Window

Both require an ORDER BY. Both narrow the window to a sub-range of the current partition, relative to the current row — but they measure that sub-range differently:

- **ROWS** — a *physical* count of rows before/after the current one.
- **RANGE** — a *logical* range of values: "every row whose ORDER BY value equals the current row's ORDER BY value" is treated as part of the same range, even beyond one physical row.

```sql
SUM(COUNT(*)) OVER (
    ORDER BY CustCity
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS TotalUsingRows,

SUM(COUNT(*)) OVER (
    ORDER BY CustCity
    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS TotalUsingRange
```

`ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` == classic running total, one step per physical row. `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` == running total that stays flat across every row sharing the current ORDER BY value, then jumps once per distinct value — every row for the same city shows the *same* cumulative total (the total through the end of that city's group), not a partial value mid-group.

A sliding 3-row window (current row plus one before and one after) — useful for smoothing/moving-average style calculations:

```sql
SUM(ContractPrice) OVER (
    ORDER BY CustLastName, CustFirstName
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
) AS SumOf3
```

At the edges of the partition (first/last row), the missing neighbor simply doesn't contribute — the frame silently shrinks rather than erroring.

## Using Windows with Aggregate Functions

Any of the Chapter 12 aggregates (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) can carry an `OVER()` clause. A very common pattern: show each detail row alongside its group total, with no separate summary query needed.

```sql
SELECT C.CustFirstName || ' ' || C.CustLastName AS Customer,
    O.OrderNumber, P.ProductName, OD.QuantityOrdered, OD.QuotedPrice,
    SUM(OD.QuotedPrice) OVER (PARTITION BY O.OrderNumber) AS OrderTotal
FROM Orders AS O
    INNER JOIN Order_Details AS OD ON OD.OrderNumber = O.OrderNumber
    INNER JOIN Customers AS C ON C.CustomerID = O.CustomerID
    INNER JOIN Products AS P ON P.ProductNumber = OD.ProductNumber;
```

Every line item on order #1 shows the *same* `OrderTotal` — the sum across the whole partition (that order), not a running total, because there's no ROWS/RANGE frame narrowing it — the default frame for a PARTITION BY with no ORDER BY is the whole partition.

## Summary

- Window functions compute a value per row over a related set of rows ("window") without collapsing the row count, unlike GROUP BY.
- `OVER (PARTITION BY ... ORDER BY ... ROWS|RANGE ...)` is the full syntax; every clause inside it is optional except that ROWS/RANGE requires ORDER BY.
- PARTITION BY divides the result into independent windows; omit it and the function spans the whole result set.
- ORDER BY inside OVER() controls evaluation order for running calculations and ranking — it does not sort the query's final output.
- `ROW_NUMBER()` always assigns unique sequential integers, even across ties; `RANK()` leaves gaps after ties, `DENSE_RANK()` doesn't, `PERCENT_RANK()` returns a 0–1 percentile.
- `NTILE(n)` buckets rows into n groups, front-loading any remainder into the earlier groups.
- `ROWS` frames by physical row count; `RANGE` frames by logical value equality on the ORDER BY column(s) — they can produce very different running totals when the ORDER BY column has duplicates.
- ROWS/RANGE only apply to aggregate functions, never to ROW_NUMBER/RANK/DENSE_RANK/PERCENT_RANK/NTILE.
- SQL Server didn't get window functions until SQL Server 2017; MS Access and MySQL still don't support them at all.
