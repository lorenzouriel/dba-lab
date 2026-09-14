# Chapter 15: Updating Sets of Data

UPDATE == change values in one or more columns, across one or more rows, in a single table. Simpler grammar than SELECT (only three clauses) but far more consequential when you get the WHERE clause wrong.

## The UPDATE Statement

```sql
UPDATE table_name
SET column_name = value_expression [, column_name = value_expression ...]
WHERE search_condition
```

1. `UPDATE` — the one target table. Unlike SELECT, you cannot name multiple tables here (some vendors relax this — see below).
2. `SET` — required, one or more `column = expression` assignments, comma-separated.
3. `WHERE` — optional. Omit it and every row in the table gets updated.

```sql
UPDATE Products
SET Price = Price + (0.1 * Price)
```

Increases every product's price by 10%. Note the assignment direction: the column name always goes on the left of `=`; the expression on the right can reference the *current* value of that same column.

🤯 The Standard requires the database to evaluate **all** SET expressions using the *pre-update* row values before changing anything. So `SET A = B, B = A` genuinely swaps A and B — it doesn't clobber B with the already-updated A.

## Updating Selected Rows

Add a WHERE clause to restrict which rows change:

```sql
UPDATE Products
SET RetailPrice = RetailPrice * 1.04
WHERE CategoryID = 3
```

⚠️ **Idempotency gotcha**: if your WHERE clause filters on the same column you're updating (e.g. `WHERE MondaySchedule = 1` right before setting `MondaySchedule = 0`), running the query a second time updates zero rows — not because it's "already correct," but because the filter condition no longer matches anything. Don't mistake "ran with no rows changed" for "nothing needed changing."

## Safety First: Verify Before You Update

⚠️ Recommended workflow for every non-trivial UPDATE: write the WHERE clause as a **SELECT** first, look at the actual rows and computed new values, and only then convert it to UPDATE.

```sql
-- Step 1: verify
SELECT ProductName, RetailPrice, RetailPrice * 1.04 AS NewPrice
FROM Products
WHERE CategoryID = 3

-- Step 2: convert (swap SELECT list -> SET clause, keep the WHERE)
UPDATE Products
SET RetailPrice = RetailPrice * 1.04
WHERE CategoryID = 3
```

The mechanical conversion: drop the SELECT columns you don't need, move the table name from FROM to UPDATE, turn `column, expression` pairs into `SET column = expression`, keep WHERE unchanged.

✨ **Side learning**: MySQL Workbench ships with "Safe Updates" mode on by default, which refuses to run an UPDATE/DELETE unless the WHERE clause references the primary key — a built-in guardrail against exactly this chapter's core danger. (Edit → Preferences → SQL Editor to turn it off if a query legitimately needs to filter on something else.)

## A Brief Aside: Transactions

Transaction == a unit of work you can commit (make permanent) or roll back (undo) as a whole.

1. `START TRANSACTION` — begin protecting a sequence of changes.
2. `COMMIT` — make all changes since the start permanent.
3. `ROLLBACK` — undo everything since the start.

Applies to UPDATE, INSERT, and DELETE alike (this Part's other two chapters). Not every database system requires you to manage this explicitly — Microsoft Access starts one behind the scenes for every data-changing query run from its UI and prompts you with a row count before committing.

⚠️ Transactions are exactly the safety net for the case where an UPDATE affects more (or fewer) rows than you expected — if you can review a row count before committing, do so.

## Updating Multiple Columns

Comma-separate multiple `SET` assignments; all apply to every row matched by WHERE:

```sql
UPDATE Classes
SET ClassRoomID = 1635,
    MondaySchedule = 0, WednesdaySchedule = 0, FridaySchedule = 0,
    TuesdaySchedule = 1, ThursdaySchedule = 1, SaturdaySchedule = 1
WHERE SubjectID = 13
```

## Filtering on a Related Table

The UPDATE clause only accepts a single table name — no JOIN there in standard syntax. To filter on a column that lives in a *different* table, push the lookup into a subquery in WHERE:

```sql
UPDATE Products
SET RetailPrice = RetailPrice * 1.04
WHERE CategoryID = (SELECT CategoryID FROM Categories WHERE CategoryDescription = 'Clothing')
```

⚠️ Using `=` against a subquery only works if the subquery is guaranteed to return exactly one row — if `CategoryDescription = 'Clothing'` ever matched two rows in Categories, this UPDATE throws an error instead of silently doing the wrong thing. When you're not certain of single-row uniqueness, use `IN` instead of `=`:

```sql
UPDATE Classes
SET ClassRoomID = 1635, TuesdaySchedule = 1, ThursdaySchedule = 1, SaturdaySchedule = 1
WHERE SubjectID IN (SELECT SubjectID FROM Subjects WHERE SubjectName = 'Drawing')
```

### Vendor Extension: JOIN Directly in UPDATE

✨ **Side learning**: Microsoft Access and SQL Server both allow a JOIN right in the UPDATE's FROM-equivalent, sidestepping the subquery — restricted to primary-key-to-foreign-key joins so the engine can still figure out which row(s) to touch:

```sql
UPDATE Classes INNER JOIN Subjects
   ON Classes.SubjectID = Subjects.SubjectID
SET ClassRoomID = 1635, TuesdaySchedule = 1, ThursdaySchedule = 1, SaturdaySchedule = 1
WHERE Subjects.SubjectName = 'Drawing'
```

⚠️ Updating across a join like this is convenient but riskier to reason about than a plain WHERE: if the join fans out (one Classes row matching multiple Subjects rows, say), you can end up updating a row multiple times or matching rows you didn't intend. Not portable — check vendor docs before relying on it. The Standard itself only allows the target of UPDATE to be a table or an updatable view, and leaves view-updatability rules entirely to the implementation.

## Subquery as the Value Being Assigned

A `SET column = ...` value expression can itself be a scalar subquery — useful for keeping a denormalized/calculated column in sync with a related table:

```sql
UPDATE Orders
SET OrderTotal = (SELECT SUM(QuantityOrdered * QuotedPrice)
                  FROM Order_Details
                  WHERE Order_Details.OrderNumber = Orders.OrderNumber)
```

This is a *correlated* subquery — it references `Orders.OrderNumber` from the outer statement, so it re-evaluates per row being updated. Notice there's no WHERE on the outer UPDATE here; in application code you'd normally add one to touch only the order that actually changed, otherwise every row in Orders gets recalculated.

✨ **Side learning**: this is exactly the kind of logic a database **trigger** automates — code the engine runs automatically whenever a row is added/updated/deleted, so an application never has to remember to re-run this UPDATE by hand after touching Order_Details. Some systems (notably SQL Server) also support true computed columns defined once at the table level instead.

## Uses for UPDATE

Recurring shapes across the sample databases:
- Recalculating a value from related detail rows (order totals, GPA from grades, bowling average/handicap).
- Percentage adjustments filtered by category (raises, price increases, discounts) — often via a subquery on a lookup table.
- Bulk corrections keyed by a shared attribute (ZIP code → area code).
- Simple find-and-replace on a single column (rename a location, rename a team).

## Summary

- UPDATE has exactly three clauses: UPDATE (one target table), SET (required), WHERE (optional — and omitting it updates every row).
- All SET expressions are evaluated against pre-update values before any row changes, so self-referencing and swap-style assignments behave correctly.
- ⚠️ Build and run a verifying SELECT with the same WHERE clause before running the real UPDATE — the mechanical conversion (SELECT list → SET clause) is nearly free insurance.
- ⚠️ A WHERE clause that filters on the column you're about to change can make a query silently "stop working" on rerun — that's expected, not a bug.
- Filtering an UPDATE by a related table's column requires a subquery (`=` for guaranteed single-row results, `IN` otherwise) since UPDATE's target clause takes only one table name — SQL Server/Access allow a JOIN extension instead, non-portable.
- A SET value can be a correlated scalar subquery, letting you resync a calculated column from detail rows — the same job triggers or computed columns automate.
- Transactions (START TRANSACTION / COMMIT / ROLLBACK) are the safety net across all three data-modifying statements in this Part.
