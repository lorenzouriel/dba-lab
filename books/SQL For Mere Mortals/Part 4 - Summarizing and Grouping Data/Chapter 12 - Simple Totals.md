# Chapter 12: Simple Totals

Aggregate function == a function that collapses many rows (or many values from a value expression) into a single calculated value.

The five basic ones, supported by every major RDBMS: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`.

Without a `GROUP BY` clause (covered next chapter), the "group" an aggregate operates on is implicitly *all rows returned by FROM + WHERE*. That's the mental model shift from earlier chapters: you stop thinking row-by-row and start thinking "one calculated value across the whole set."

## Mixing aggregates with non-aggregates

Once a SELECT list has one aggregate expression, every other value expression in that list must be either:
1. Another aggregate expression, or
2. A literal constant (same value on every row, so it doesn't conflict with collapsing to one row).

A bare column reference alongside an aggregate is illegal — the engine can't know which row's value to show for a result that's now a single row.

```sql
-- illegal: LastName isn't aggregated and isn't unique across the collapsed result
SELECT LastName, COUNT(*) AS CountOfStudents
FROM Students

-- legal: literal string, same on every row
SELECT 'Total students: ', COUNT(*) AS CountOfStudents
FROM Students
```

🤯 Every aggregate function except `COUNT(*)` silently ignores NULLs. `COUNT(*)` counts rows, full stop — NULLs, duplicates, everything.

## COUNT

Two flavors:
1. `COUNT(*)` — counts rows in the result set, including NULLs and duplicates. No DISTINCT allowed (doesn't make sense — you're counting rows, not values).
2. `COUNT(value expression)` — counts non-NULL values returned by the expression. Add `DISTINCT` to count only unique non-NULL values.

```sql
SELECT COUNT(*) AS TotalWashingtonEmployees
FROM Employees
WHERE EmpState = 'WA'

SELECT COUNT(CustCounty) AS NumberOfKnownCounties
FROM Customers
-- equivalent in effect to COUNT(*) WHERE CustCounty IS NOT NULL

SELECT COUNT(DISTINCT CustCounty) AS NumberOfUniqueCounties
FROM Customers
```

## SUM

Totals a numeric value expression, ignoring NULLs. Returns NULL (not zero) if every value is NULL or the input set is empty.

```sql
SELECT SUM(WholesalePrice * QuantityOnHand) AS TotalInventoryValue
FROM Products
```

Works on an expression, not just a bare column — a row only counts if all referenced columns are non-NULL, otherwise the expression itself evaluates to NULL and gets skipped. `DISTINCT` is supported (sums only unique values) but rarely useful.

## AVG

Arithmetic mean of non-NULL values. Numeric only — most engines error on character/datetime input. Returns NULL under the same empty/all-NULL conditions as SUM.

```sql
SELECT AVG(Price * QuantityOrdered) AS AverageItemTotal
FROM Order_Details
WHERE OrderID = 64
```

✨ **Side learning**: "Average" is not a SQL keyword — only `AVG`. Easy typo to make when translating a request into SQL by hand.

## MAX / MIN

Return the largest/smallest value of a value expression, across any data type:
1. Character strings — largest/smallest per the collating sequence (locale/case sensitivity dependent).
2. Numbers — largest/smallest number.
3. Datetime — most recent/earliest.

`DISTINCT` is syntactically legal on `MAX`/`MIN` (it's in the Standard) but has **zero effect** — there's only ever one largest or smallest value regardless of duplicates, so `DISTINCT` just makes the engine do pointless extra work finding uniques first.

```sql
SELECT MAX(ContractPrice) AS LargestContractPrice FROM Engagements
SELECT MIN(Price) AS LowestProductPrice FROM Products
```

## Restrictions on aggregate expressions

1. Cannot nest one aggregate inside another: `SUM(AVG(LineItemTotal))` is illegal. (Exception: window functions, Chapter 22.)
2. Cannot use a subquery as the value expression of an aggregate: `AVG((SELECT Price FROM Products WHERE Category = 'Bikes'))` is illegal.
3. You *can* use several independent aggregates side by side in one SELECT list — e.g. `MIN(ReviewDate)` and `MAX(ReviewDate)` together to get an earliest/latest pair in one pass.

```sql
SELECT MIN(ReviewDate) AS EarliestReviewDate,
       MAX(ReviewDate) AS RecentReviewDate
FROM Employees
WHERE Department = 'Advertising'
```

## Aggregates as filters (via subquery)

An aggregate returns a single value, so it can feed a comparison predicate — but only wrapped in a subquery, never inline in `WHERE`. This is the same subquery pattern from Chapter 11, now put to work with dynamic statistics instead of hardcoded literals.

```sql
-- rather than hardcoding WHERE RetailPrice <= 196.03 (which goes stale)
SELECT ProductName
FROM Products
WHERE RetailPrice <= (SELECT AVG(RetailPrice) FROM Products)
```

The subquery re-evaluates every execution, so it never drifts out of sync the way a hardcoded literal would. A `WHERE` clause inside the subquery further narrows which rows feed the aggregate:

```sql
SELECT EngagementNumber, ContractPrice
FROM Engagements
WHERE ContractPrice >
    (SELECT SUM(ContractPrice) FROM Engagements
     WHERE StartDate BETWEEN '2017-09-01' AND '2017-09-30')
```

## Summary

- Aggregate functions (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) collapse a set of rows/values into one value; without `GROUP BY`, the set is everything FROM + WHERE returns.
- All aggregates except `COUNT(*)` ignore NULLs; `SUM`/`AVG` return NULL (not 0) over an empty or all-NULL input.
- Once you aggregate, every other SELECT-list expression must be a literal or another aggregate — no bare unaggregated columns.
- `COUNT(*)` counts rows; `COUNT(expr)` counts non-NULL values; `DISTINCT` narrows to unique values but is meaningless (though legal) on `MAX`/`MIN`.
- Aggregates cannot nest and cannot take a subquery as their argument.
- To use an aggregate as a filter condition, wrap it in a subquery inside `WHERE` — this keeps the comparison value always current instead of a stale hardcoded literal.
