# Chapter 10: UNIONs

Third of the three set operations from Chapter 7 (intersection, difference, union). INNER JOIN == intersection. OUTER JOIN + test for Null == difference. UNION == union.

## What Is a UNION?

UNION == combine rows from two or more similar result sets into one result set.

Key distinction vs JOIN:
1. JOIN combines **columns** — result sets appear side by side (more columns).
2. UNION combines **rows** — result sets are interleaved vertically (more rows, same column count).

```sql
SELECT RecipeClassDescription FROM Recipe_Classes
UNION
SELECT RecipeTitle FROM Recipes;
```

Returns a single column, one merged list of class descriptions and recipe titles stacked on top of each other.

Requirements to UNION two SELECT statements:
1. Same number of output columns in each SELECT.
2. Each corresponding column pair must be "comparable" (same rules as comparing values in a WHERE clause — character with character, number with number, datetime with datetime).

## UNION vs UNION ALL

1. `UNION` (bare) == duplicate rows across the combined result are eliminated.
2. `UNION ALL` == no duplicate elimination, all rows kept.

🤯 `UNION ALL` is generally much faster since the engine skips the dedup pass. Default to `ALL` whenever you know (or don't care) that the two sets don't overlap.

```sql
SELECT CustFirstName, CustLastName FROM Customers
UNION ALL
SELECT EmpFirstName, EmpLastName FROM Employees;
```

✨ **Side learning:** the SQL Standard also defines a `CORRESPONDING` clause to UNION by matching column *names* rather than position (optionally restricted to a specific column list). Barely any commercial database implements it.

## Column Naming

Output column names come from the **first** SELECT statement in the UNION chain (implementation-defined per the Standard, but this is what everyone does in practice). If the two sides name a column differently, you get the first side's name — so alias deliberately if you care what the result set is called.

```sql
SELECT CustLastName || ', ' || CustFirstName AS MailingName,
       CustStreetAddress, CustCity, CustState, CustZipCode
FROM Customers
UNION
SELECT VendName, VendStreetAddress, VendCity, VendState, VendZipCode
FROM Vendors;
```

Note the expression on the Customers side collapsing two columns (first/last name) into one, to match the Vendors side's single `VendName` column — column *count* must match even when the underlying tables don't line up naturally.

## Combining Complex SELECT Statements

Each side of a UNION can be as complex a query as needed — full JOINs, WHERE, GROUP BY, HAVING — the only constraint stays column count + comparability.

Common trick: tag each side with a literal "set identifier" column so you can tell which branch a row came from after the interleave.

```sql
SELECT CustLastName, ProductName, 'Customer' AS RowSource
FROM Customers ...
UNION
SELECT VendName, ProductName, 'Vendor' AS RowSource
FROM Vendors ...
```

Don't bother adding `DISTINCT` inside a branch just to be safe — plain `UNION` already dedups the final combined set, so `DISTINCT` there is redundant extra work.

## Chaining Multiple UNIONs

You can chain as many `UNION`/`UNION ALL` SELECTs as you like (implementations may cap the total, but the syntax itself has no limit):

```sql
SELECT CustFirstName || ' ' || CustLastName, CustStreetAddress, CustCity, CustState, CustZipCode FROM Customers
UNION
SELECT EmpFirstName || ' ' || EmpLastName, EmpStreetAddress, EmpCity, EmpState, EmpZipCode FROM Employees
UNION
SELECT VendName, VendStreetAddress, VendCity, VendState, VendZipCode FROM Vendors;
```

A WHERE clause can be added to any, all, or just one of the branches independently (e.g. "vendors in Texas combined with *all* customers and employees").

## Sorting a UNION

1. `ORDER BY` must appear once, after the **last** SELECT in the chain — it sorts the combined result, not just the final branch.
2. Sort by column name (from the first SELECT's naming) or by relative column position (`ORDER BY 5`).

```sql
SELECT CustFirstName || ' ' || CustLastName AS FullName, CustZipCode FROM Customers
UNION
SELECT EmpFirstName || ' ' || EmpLastName, EmpZipCode FROM Employees
ORDER BY 2;
```

Without an ORDER BY, most systems visually appear sorted left-to-right by the output columns — but that's incidental, never rely on it.

## Uses for UNION

You'll reach for UNION far less than INNER/OUTER JOIN. Typical shape of problem: stitch together two or more *dissimilar tables* into one homogeneous list (mailing lists spanning Customers/Employees/Vendors, combined "who plays X" lists spanning Agents/Entertainers, etc).

Some problems phrased as UNION ("customers who ordered bikes combined with customers who ordered helmets") can also be solved with a single SELECT and a more complex WHERE (`... LIKE '%bike%' OR ... LIKE '%helmet%'`). When the source table is the *same* on both sides, prefer WHERE — it's typically evaluated more efficiently than a UNION, since the engine doesn't have to build and merge two separate result sets. Reach for UNION instead when:
1. The rows come from genuinely different tables/FROM clauses.
2. You need a "which side did this come from" tag column (not expressible cleanly without CASE, which isn't covered until Chapter 19).

## Summary

- UNION stacks rows from two-or-more SELECTs vertically; JOIN places columns side by side.
- Column count must match on every branch; corresponding columns must be comparable types.
- Bare UNION dedups; UNION ALL doesn't and is faster — prefer ALL when duplicates are impossible or don't matter.
- Output column names are inherited from the first SELECT in the chain.
- Any branch can carry its own complex JOIN/WHERE; branches can be chained indefinitely.
- ORDER BY belongs once, at the very end, and sorts the whole combined result — by name or relative position.
- A literal string column is a cheap way to tag which branch a row originated from.
- Problems solvable by UNION over the *same* table are often better solved with a WHERE + OR instead.
