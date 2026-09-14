# Chapter 13: Grouping Data

Chapter 12's aggregates collapsed the *entire* FROM+WHERE result down to one row. `GROUP BY` == the way to collapse it down to one row *per distinct value* (or combination of values) instead — subtotals rather than a single grand total.

## Why group

Without grouping, you can only get one aggregate row for the whole table, or filter down to one entity with `WHERE`. To get "count/sum/avg per customer" (one row per customer, side by side), you need the database to partition rows into buckets first, then aggregate within each bucket.

```sql
SELECT Entertainers.EntStageName,
     COUNT(*) AS NumContracts,
     SUM(Engagements.ContractPrice) AS TotPrice,
     MIN(Engagements.ContractPrice) AS MinPrice,
     MAX(Engagements.ContractPrice) AS MaxPrice,
     AVG(Engagements.ContractPrice) AS AvgPrice
FROM Entertainers
INNER JOIN Engagements ON Entertainers.EntertainerID = Engagements.EntertainerID
GROUP BY Entertainers.EntStageName
```

Returns one row per entertainer, with the aggregates computed only over that entertainer's engagement rows.

✨ **Side learning**: results often *look* sorted by the GROUP BY columns because many optimizers sort internally to make grouping efficient — but that's an implementation detail, not a guarantee. Always add `ORDER BY` if sort order matters.

## The column rule

1. Every column in the GROUP BY clause can appear bare (unaggregated) in the SELECT list.
2. Every other column reference in the SELECT list must be wrapped in an aggregate function.
3. If you need two columns to identify a group (e.g. first + last name), both go in GROUP BY.

```sql
SELECT Customers.CustLastName, Customers.CustFirstName,
     COUNT(*) AS NumContracts,
     SUM(Engagements.ContractPrice) AS TotPrice
FROM Customers
INNER JOIN Engagements ON Customers.CustomerID = Engagements.CustomerID
GROUP BY Customers.CustLastName, Customers.CustFirstName
```

🤯 Grouping on a primary key does *not* let you skip listing the other "obviously unique per key" columns in GROUP BY. SQL is syntactic, not semantic — it has no idea `CustomerID` determines `CustFirstName`/`CustLastName` functionally, so both must be listed explicitly on a Standard-compliant engine:

```sql
-- fails on strict engines: CustFirstName/CustLastName aren't aggregated or grouped
SELECT Customers.CustomerID,
     Customers.CustFirstName || ' ' || Customers.CustLastName AS CustFullName,
     SUM(Engagements.ContractPrice) AS TotalPrice
FROM Customers INNER JOIN Engagements ON Customers.CustomerID = Engagements.CustomerID
GROUP BY Customers.CustomerID
-- correct:
GROUP BY Customers.CustomerID, Customers.CustFirstName, Customers.CustLastName
```

✨ **Side learning**: MySQL and PostgreSQL historically let the "wrong" version above run anyway (functional-dependency detection), which is more forgiving but non-portable. Oracle and MS Access go the opposite direction — some versions *require* the exact SELECT-list expression to be repeated verbatim in GROUP BY, rather than accepting the individual source columns.

## Don't group on a SELECT-list alias

GROUP BY operates on columns produced by FROM + WHERE — it runs *before* the SELECT list's expressions/aliases exist, so it can't reference them.

```sql
-- illegal: CustomerFullName doesn't exist yet at GROUP BY time
SELECT Customers.CustLastName || ', ' || Customers.CustFirstName AS CustomerFullName, ...
GROUP BY CustomerFullName
```

Fix: repeat the underlying columns in GROUP BY (simplest), or push the concatenation into a subquery/derived table in FROM so it's already a real column by the time GROUP BY runs.

## OUTER JOIN + GROUP BY: the COUNT(*) trap

`LEFT OUTER JOIN` + `GROUP BY` is how you include groups with zero matching detail rows (e.g. an entertainer never booked). But `COUNT(*)` still counts the single NULL-padded row the outer join produces — giving a wrong count of 1 instead of 0.

```sql
-- WRONG: unbooked entertainer shows NumContracts = 1
SELECT Entertainers.EntStageName, COUNT(*) AS NumContracts, ...
FROM Entertainers
LEFT OUTER JOIN Engagements ON Entertainers.EntertainerID = Engagements.EntertainerID
GROUP BY Entertainers.EntStageName

-- CORRECT: count a column from the joined (nullable) side instead
SELECT Entertainers.EntStageName,
     COUNT(Engagements.EntertainerID) AS NumContracts, ...
```

`COUNT(column)` skips NULLs, and the outer join produces NULL for that column when there's no match — so the count correctly comes out as 0.

## GROUP BY without aggregates == DISTINCT

Leaving out all aggregate functions and just grouping gives you unique combinations of the grouped columns — functionally the same result as `SELECT DISTINCT`.

```sql
SELECT DISTINCT Customers.CustCity FROM Customers
-- same rows as:
SELECT Customers.CustCity FROM Customers GROUP BY Customers.CustCity
```

GROUP BY's edge: you can tack on an aggregate for free extra info, which DISTINCT can't do.

```sql
SELECT Customers.CustCity, COUNT(*) AS CustPerCity
FROM Customers
GROUP BY Customers.CustCity
```

## GROUP BY inside a subquery filter

A correlated subquery can itself contain GROUP BY, letting a WHERE clause compare against a per-group aggregate computed for *other* rows:

```sql
-- engagements priced higher than the total of any other single customer's contracts
SELECT Customers.CustFirstName, Customers.CustLastName,
     Engagements.StartDate, Engagements.ContractPrice
FROM Customers
INNER JOIN Engagements ON Customers.CustomerID = Engagements.CustomerID
WHERE Engagements.ContractPrice > ALL
    (SELECT SUM(ContractPrice) FROM Engagements AS E2
     WHERE E2.CustomerID <> Customers.CustomerID
     GROUP BY E2.CustomerID)
```

The subquery returns one sum per *other* customer, so a simple `>` can't compare against a set of values — hence `> ALL`.

## Summary

- `GROUP BY` partitions FROM+WHERE output into buckets by matching column values, then aggregates run per-bucket instead of over the whole set.
- SELECT-list rule: every column must be either in GROUP BY or wrapped in an aggregate — no exceptions for "obviously unique" columns like primary keys.
- GROUP BY can't reference SELECT-list aliases/expressions — only real columns from FROM/WHERE.
- With `LEFT OUTER JOIN`, use `COUNT(column)` from the joined table, not `COUNT(*)`, to get correct zero-counts for unmatched groups.
- GROUP BY with no aggregates behaves like `SELECT DISTINCT`, but lets you add an aggregate for free.
- GROUP BY can appear inside a correlated subquery used as a filter, often paired with `ALL`/`ANY` when comparing against a per-group set of values.
