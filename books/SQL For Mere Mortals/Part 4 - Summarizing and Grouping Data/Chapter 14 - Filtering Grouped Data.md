# Chapter 14: Filtering Grouped Data

`HAVING` == a filter that runs *after* grouping/aggregation, so it can test aggregate values directly. `WHERE` can't do this because it filters rows before grouping ever happens — at WHERE-time, `COUNT(*)` or `SUM(x)` per group don't exist yet.

## Why WHERE can't do this

```sql
-- illegal: COUNT(*) isn't a column produced by FROM, which is all WHERE can see
SELECT Entertainers.EntStageName, COUNT(*) AS CountOfMembers
FROM Entertainers
INNER JOIN Entertainer_Members ON Entertainers.EntertainerID = Entertainer_Members.EntertainerID
WHERE ... AND COUNT(*) > 3   -- ✗
GROUP BY Entertainers.EntStageName
```

`WHERE` predicates may only reference columns from the FROM clause's tables. An aggregate value is computed *during* grouping, so it belongs in a clause that runs after `GROUP BY`.

```sql
SELECT Entertainers.EntertainerID, Entertainers.EntStageName,
     COUNT(Entertainer_Members.EntertainerID) AS CountOfMembers
FROM Entertainers
INNER JOIN Entertainer_Members ON Entertainers.EntertainerID = Entertainer_Members.EntertainerID
INNER JOIN Entertainer_Styles ON Entertainers.EntertainerID = Entertainer_Styles.EntertainerID
INNER JOIN Musical_Styles ON Musical_Styles.StyleID = Entertainer_Styles.StyleID
WHERE Musical_Styles.StyleName = 'Jazz'
GROUP BY Entertainers.EntertainerID, Entertainers.EntStageName
HAVING COUNT(Entertainer_Members.EntertainerID) > 3
```

## Full clause pipeline

1. `FROM` — assemble the base rows (joins happen here).
2. `WHERE` — filter individual rows, before any grouping.
3. `GROUP BY` — partition remaining rows into buckets.
4. `HAVING` — filter *buckets*, using grouped columns and/or aggregate expressions.
5. `SELECT` — project the final columns (aliases defined here aren't visible to HAVING on most engines — repeat the expression).

`HAVING`'s predicate rule mirrors GROUP BY's SELECT-list rule: any column reference in `HAVING` must either be a GROUP BY column or be wrapped in an aggregate function.

🤯 A `HAVING` with no `GROUP BY` is legal — the whole FROM+WHERE result is treated as one single group. The book calls this rarely, if ever, useful in practice.

## WHERE vs HAVING: prefer WHERE when you can

Both clauses can sometimes express the same condition, but they run at different times with very different cost. A predicate that doesn't depend on the aggregate should go in `WHERE` so unwanted rows are dropped *before* the expensive grouping work, not after.

```sql
-- wasteful: computes SUM for every state (including ones you'll discard), then filters
SELECT Customers.CustState, SUM(Order_Details.QuantityOrdered * Order_Details.QuotedPrice) AS SumOfOrders
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
INNER JOIN Order_Details ON Orders.OrderNumber = Order_Details.OrderNumber
GROUP BY Customers.CustState
HAVING SUM(Order_Details.QuantityOrdered * Order_Details.QuotedPrice) > 1000000
     AND CustState IN ('WA', 'OR', 'CA')

-- better: drop unwanted states before grouping ever runs
...
WHERE Customers.CustState IN ('WA', 'OR', 'CA')
GROUP BY Customers.CustState
HAVING SUM(Order_Details.QuantityOrdered * Order_Details.QuotedPrice) > 1000000
```

Rule of thumb: filter on a *row-level* condition (doesn't need an aggregate) in `WHERE`; filter on a *group-level* condition (needs an aggregate) in `HAVING`.

## The HAVING COUNT zero trap

`WHERE` runs before grouping, so if `WHERE` filters out *all* rows for some group, that group never reaches `GROUP BY`/`HAVING` at all — it silently disappears instead of showing up with a count of zero.

```sql
-- WRONG: categories with 0 professors never appear in the output at all
SELECT Categories.CategoryDescription, COUNT(Faculty_Categories.StaffID) AS ProfCount
FROM Categories
INNER JOIN Faculty_Categories ON Categories.CategoryID = Faculty_Categories.CategoryID
INNER JOIN Faculty ON Faculty.StaffID = Faculty_Categories.StaffID
WHERE Faculty.Title = 'Professor'
GROUP BY Categories.CategoryDescription
HAVING COUNT(Faculty_Categories.StaffID) < 3
```

The `WHERE Faculty.Title = 'Professor'` filter throws away the "zero" cases *before* grouping, along with any category that legitimately has zero professors — so those categories can't be counted as zero, they're just gone.

Fix: use a correlated subquery instead of a WHERE-filtered join, so each category is evaluated one at a time and a genuine empty set correctly evaluates to `COUNT = 0`:

```sql
SELECT Categories.CategoryDescription,
     (SELECT COUNT(Faculty.StaffID)
      FROM Faculty
      INNER JOIN Faculty_Categories ON Faculty.StaffID = Faculty_Categories.StaffID
      WHERE Faculty_Categories.CategoryID = Categories.CategoryID
        AND Faculty.Title = 'Professor') AS ProfCount
FROM Categories
WHERE (SELECT COUNT(Faculty.StaffID)
       FROM Faculty
       INNER JOIN Faculty_Categories ON Faculty.StaffID = Faculty_Categories.StaffID
       WHERE Faculty_Categories.CategoryID = Categories.CategoryID
         AND Faculty.Title = 'Professor') < 3
```

An alternative fix that keeps `GROUP BY`/`HAVING`: filter for "Professor" inside a derived table in `FROM` *before* the join to `Categories`, so an `OUTER JOIN` against that pre-filtered set can still produce a zero-count row per category.

Rule of thumb: if "fewer than N, including zero" matters, don't put the row-level filter that could zero out a whole group into `WHERE` ahead of a plain `HAVING COUNT... < N` — check with a subquery or restructure with an outer join instead.

## Summary

- `HAVING` filters groups after aggregation; `WHERE` filters rows before it — a `HAVING` predicate's columns must be grouped or aggregated, same rule as the SELECT list under GROUP BY.
- Put row-level conditions in `WHERE` even when `HAVING` could technically express them — it avoids aggregating rows you're going to throw away anyway.
- `HAVING` clause expressions must be repeated in full — you generally cannot reference a SELECT-list alias from it.
- Watch for the "HAVING COUNT zero trap": a `WHERE` clause that eliminates all detail rows for a group makes that group vanish entirely instead of surfacing with count zero. Use a correlated subquery (or a pre-filtered derived table + OUTER JOIN) when you need to see the zero cases.
