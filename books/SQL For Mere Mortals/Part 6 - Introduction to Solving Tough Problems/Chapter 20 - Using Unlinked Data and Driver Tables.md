# Chapter 20: Using Unlinked Data and "Driver" Tables

Problem category: queries where you deliberately put two (or more) tables in the FROM clause **without** an ON clause linking them. "Thinking outside the box" territory — most of SQL is about joining on matching keys, this chapter is about joining on purpose without matching keys.

## What Is Unlinked Data?

Unlinked data == putting multiple tables in FROM but not specifying any linking (ON) criteria between them.

The SQL Standard's term for this is CROSS JOIN. Putting tables in the FROM clause separated by commas with no ON clause is equivalent to CROSS JOIN (comma syntax is the SQL-92 way, CROSS JOIN is the explicit SQL Standard keyword).

Cartesian Product == the result of a CROSS JOIN. Every row of table A paired with every row of table B. Row count = rows(A) × rows(B).

```sql
SELECT Customers.CustLastName, Products.ProductName
FROM Customers CROSS JOIN Products;
```

28 customers × 40 products = 1,120 rows.

✨ **Side learning:** Vendor behavior around CROSS JOIN is inconsistent. SQL Server rewrites comma-separated tables in a saved view to `CROSS JOIN`. MySQL rewrites them to plain `JOIN` (CROSS is the default absent INNER/OUTER + ON). PostgreSQL keeps the commas but rewrites `INNER JOIN` to plain `JOIN`. MS Access doesn't support the `CROSS JOIN` keyword at all — only the comma syntax works there.

## Why Would You Ever Want a Cartesian Product?

Two legitimate use cases:

1. **Cross a main data table with another main data table.** Example: all Customers × all Products, to build a catalog that lists every product for every customer (not just products they've actually ordered). Or two copies of a Teams table, to enumerate all possible team-vs-team pairings.
2. **Cross a main data table with a "driver" table** — a helper table that exists purely to supply a set of values (dates, ranges, sequence numbers) to drive the result shape.

## Solving Problems with Unlinked Data (Case 1)

Normal instinct: link tables via their FK relationships. But sometimes that instinct gets you the *wrong* answer — e.g. INNER/OUTER JOIN through Orders/Order_Details would only return products a customer has actually purchased, when what you want is **every** product, annotated with purchase status.

Pattern: CROSS JOIN the two "main" entities, then use a correlated subquery in a CASE expression to look up related facts per combination.

```sql
SELECT c.CustLastName, p.ProductName,
    (CASE WHEN c.CustomerID IN
        (SELECT o.CustomerID
         FROM Orders o INNER JOIN Order_Details od
             ON o.OrderNumber = od.OrderNumber
         WHERE od.ProductNumber = p.ProductNumber)
     THEN 'Purchased' ELSE '' END) AS ProductStatus
FROM Customers c, Categories cat INNER JOIN Products p
    ON cat.CategoryID = p.CategoryID;
```

Note the INNER JOIN between Categories and Products is a normal join — the CROSS JOIN is specifically between `Customers` and everything else. A query can freely mix a real join with an unlinked join.

Same idea works for "all employees × all customers in the same state, flag whether they've ordered from each other," or "all pairings of two teams" (self-CROSS-JOIN with a `WHERE t2.TeamID > t1.TeamID` filter to avoid duplicate/reflexive pairs):

```sql
SELECT t1.TeamID AS Team1, t2.TeamID AS Team2
FROM Teams t1, Teams t2
WHERE t2.TeamID > t1.TeamID;
```

`n` teams → `n*(n-1)/2` unique pairings, no team paired with itself, no pair listed twice.

## Solving Problems Using "Driver" Tables (Case 2)

Driver table == "tally" table == a helper table whose rows exist only to drive/shape a result — not one of your real business entities.

Common driver table shapes:
1. **Date/period tables** — one row per day, week, or month across a relevant range, so you can list every period even when there's no matching business data (e.g., "show me every week whether or not anything happened").
2. **Range-lookup tables** — translate a value into a category by BETWEEN-matching against low/high bounds (grade points → letter grade, price → price tier, proficiency score → rating).
3. **Sequence-number tables** — a plain list of integers `1, 2, 3, …`, useful for "print N labels" or "generate N rows" problems.
4. **Pivot tables** — a driver table with one column per target output column, containing 0/1 flags, used to fan a single value out into "spreadsheet" style columns.

Loading a driver table: the SQL Standard's `WITH RECURSIVE` can generate a sequence of dates in a loop, but support is inconsistent. For a small range-lookup table, just hand-populate it — that's also the whole point: changing category boundaries becomes a data update, not a rewrite of every CASE expression that used them.

### Pattern: Range Lookup

Naming convention used throughout the book's samples: driver tables prefixed `ztbl` (sorts them away from real tables, e.g. `ztblLetterGrades`).

```sql
-- ztblLetterGrades: LetterGrade, LowGradePoint, HighGradePoint
SELECT s.StudFirstName, s.StudLastName, ss.Grade, lg.LetterGrade
FROM ztblLetterGrades lg, Students s
    INNER JOIN Student_Schedules ss ON s.StudentID = ss.StudentID
WHERE ss.Grade BETWEEN lg.LowGradePoint AND lg.HighGradePoint;
```

The CROSS JOIN with `ztblLetterGrades` combined with the BETWEEN in the WHERE clause is what does the "translation" — for any given grade, only one row of the driver table survives the join.

### Pattern: Pivot Using a Driver Table

A driver table like `ztblMonths` (one row per month, with columns `January…December` holding 1 for the matching month and 0 otherwise) lets you fan a value across output columns just by multiplying:

```sql
SELECT p.ProductName,
    SUM(od.QuotedPrice * od.QuantityOrdered * m.January) AS January,
    SUM(od.QuotedPrice * od.QuantityOrdered * m.February) AS February
    -- ... one SUM(...) per month
FROM ztblMonths m, Products p
    INNER JOIN Order_Details od ON p.ProductNumber = od.ProductNumber
    INNER JOIN Orders o ON o.OrderNumber = od.OrderNumber
WHERE o.OrderDate BETWEEN m.MonthStart AND m.MonthEnd
GROUP BY p.ProductName;
```

The trick: for any given order, exactly one row of `ztblMonths` matches the `BETWEEN MonthStart AND MonthEnd` filter. On that row, only the flag column for the correct month is 1 — every other month's flag is 0. Multiplying the amount by 0 sends it to nowhere; multiplying by 1 puts it in the "correct bucket." `SUM()` then aggregates each bucket independently. This is standard-SQL PIVOT without a vendor-specific PIVOT operator.

### Pattern: Sequence Numbers for "Print N Things"

```sql
-- ztblSeqNumbers: single integer column Sequence, values 1..N
SELECT seq.Sequence, p.ProductNumber, p.ProductName
FROM ztblSeqNumbers seq, Products p
WHERE seq.Sequence <= p.QuantityOnHand
ORDER BY p.ProductNumber, seq.Sequence;
```

Produces one row per unit in stock (e.g. one shelf/bin label per item) — a classic use of unlinked data to "explode" a quantity into that many rows.

A close cousin: skip the first N already-used labels on a page of labels, by UNION ALL-ing a blank-row query (limited to N rows via the driver table) with the real data query. Must be UNION ALL, not UNION — a plain UNION would collapse the duplicate blank rows.

```sql
SELECT '' AS BowlerLastName FROM ztblSkipLabels WHERE LabelCount <= 3
UNION ALL
SELECT BowlerLastName FROM Bowlers ORDER BY BowlerZip, BowlerLastName;
```

## Summary

- Unlinked data == tables in FROM without an ON clause == CROSS JOIN == Cartesian Product (rows(A) × rows(B)).
- Two legitimate uses: crossing two main data tables (to get "all combinations" rather than "only matched combinations"), or crossing a main table with a purpose-built driver/tally table.
- Driver tables are small helper tables — date ranges, range-lookup tables, sequence numbers, or pivot-flag tables — that exist only to shape a query's output.
- A range-lookup driver table + BETWEEN in the WHERE clause replaces long CASE chains and makes category boundaries a data change instead of a code change.
- A pivot driver table (0/1 flag columns) + `SUM(value * flag)` fans a single measure out across spreadsheet-style output columns using only standard SQL.
- Self-CROSS-JOIN with an inequality filter (`t2.id > t1.id`) is the standard trick for "all unique pairings without duplicates or self-pairing."
- CROSS JOIN syntax support/rewriting is inconsistent across SQL Server, MySQL, PostgreSQL, and Access — the comma syntax is the most portable.
