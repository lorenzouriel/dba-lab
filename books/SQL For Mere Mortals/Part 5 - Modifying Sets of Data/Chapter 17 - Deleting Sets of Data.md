# Chapter 17: Deleting Sets of Data

DELETE == remove rows from a table. Simplest statement in SQL — only three keywords — and, per the book, "the most dangerous statement that you can execute."

## The DELETE Statement

```sql
DELETE FROM table_name
WHERE search_condition
```

WHERE is optional. Leave it off and every row in the table disappears.

⚠️ **This is the whole chapter's central warning.** A bare `DELETE FROM Bowlers` with no WHERE removes every bowler, permanently, in one statement — no confirmation prompt from SQL itself. Some tools add their own guardrail (Access starts an implicit transaction per query from its UI and shows a row-count warning before commit), but that's the *tool*, not the language — don't rely on it being there.

```sql
DELETE FROM Bowlers
```

✨ **Side learning**: even this bare, no-WHERE example can be partially rescued by other structure in the schema — if a `FOREIGN KEY` constraint from `Bowler_Scores` to `Bowlers` exists, the engine refuses to delete any Bowlers row that still has matching Bowler_Scores rows. In the book's sample data this "protects" 32 of 34 rows, deleting only the two bowlers with no games — a reminder that referential integrity constraints are a real (if incidental) backstop against an underspecified DELETE, not something to depend on deliberately.

## Deleting Some Rows

Same WHERE grammar as SELECT/UPDATE — anything from a simple comparison to nested subqueries with IN/NOT IN/EXISTS/NOT EXISTS.

```sql
DELETE FROM Orders
WHERE OrderTotal = 0
```

## Safety First: Verify Before You Delete

⚠️ Identical discipline to Chapter 15's UPDATE workflow: run the WHERE clause as a SELECT first, eyeball the actual rows that would disappear, only then swap `SELECT *` for `DELETE`:

```sql
-- Step 1: verify
SELECT * FROM Orders WHERE OrderTotal = 0

-- Step 2: convert
DELETE FROM Orders WHERE OrderTotal = 0
```

Unlike UPDATE (where a bad run at least leaves recognizable — if wrong — values behind), a bad DELETE leaves nothing to inspect after the fact. Once committed, the rows are gone; recovery (if possible at all) means digging into the database system's transaction/change log, not SQL.

## Using a Subquery to Delete Based on a Related Table

A literal condition (`OrderTotal = 0`) is only as trustworthy as the calculated column it depends on. If `OrderTotal` were never recalculated after an Order_Details row changed, filtering on the stale total misses or wrongly-targets rows. A subquery against the actual related table is more robust:

```sql
DELETE FROM Orders
WHERE OrderNumber NOT IN (SELECT OrderNumber FROM Order_Details)
```

⚠️ **NOT IN with the wrong idea in mind is a classic self-inflicted wound**: this deletes orders that no longer have *any* line items — not orders whose stored total happens to be zero. Know which condition you actually mean before picking one.

### ⚠️ Order-of-Deletion and the "Unsafe" Pattern

Archiving a batch of rows (Chapter 16) is usually followed by deleting the originals. It's tempting to just re-filter by the same condition used to archive them:

```sql
-- UNSAFE: assumes the archive INSERT actually ran and succeeded
DELETE FROM Order_Details
WHERE OrderNumber IN (SELECT OrderNumber FROM Orders WHERE OrderDate < '2018-01-01')
```

If the archiving INSERT was skipped, failed partway, or someone just claimed to have run it, this deletes rows that were never actually copied anywhere — permanent data loss with no fallback. The safer version checks the archive table itself, not the original filter condition:

```sql
-- SAFER: only deletes rows verified to exist in the archive
DELETE FROM Order_Details
WHERE OrderNumber IN (SELECT OrderNumber FROM Order_Details_Archive)
```

Belt-and-suspenders: `AND` both conditions together if you want rows that are *both* old *and* confirmed archived.

⚠️ **Referential-integrity order also reverses relative to INSERT**: when archiving parent+child tables, you insert parent-then-child (Chapter 16) but you must **delete child-then-parent** — a defined foreign key from Order_Details to Orders won't let you delete an Orders row while matching Order_Details rows still exist. Getting this backwards fails the DELETE outright rather than silently corrupting anything, at least — but it's still the opposite order from the INSERT you just ran.

```sql
-- 1. Children first
DELETE FROM Order_Details
WHERE OrderNumber IN (SELECT OrderNumber FROM Order_Details_Archive)

-- 2. Then parent
DELETE FROM Orders
WHERE OrderNumber IN (SELECT OrderNumber FROM Orders_Archive)
```

The same pattern recurs with three or four dependent levels (e.g. Bowler_Scores → Match_Games → Tourney_Matches → Tournaments): delete from the deepest child table outward to the top-level parent.

## Uses for DELETE

Recurring shape across the sample databases: "delete X that have no related Y" — orphan cleanup keyed on `NOT IN (SELECT ... FROM related_table)`:

```sql
DELETE FROM Customers
WHERE CustomerID NOT IN (SELECT CustomerID FROM Orders)
```

⚠️ Watch for a table with **more than one** dependent child table before deleting the parent — e.g. an Entertainer can have rows in both Entertainer_Members and Entertainer_Styles; both must be cleared (deepest-first) before the Entertainers row itself can go. Missing one means the parent DELETE simply fails on the constraint — annoying but not destructive, unlike getting the WHERE condition itself wrong.

## Summary

- DELETE has only two clauses: `DELETE FROM table_name` and an optional `WHERE` — omitting WHERE deletes every row in the table, with no built-in confirmation from SQL itself.
- ⚠️ Verify with a `SELECT *` using the same WHERE clause before running the real DELETE — there's no way to recover a bad DELETE the way you can eyeball a bad UPDATE's leftover values.
- Foreign key constraints act as an incidental safety net (they'll block a delete that would orphan child rows) but should never be the *intended* safeguard.
- Prefer filtering on verified related-table existence (`NOT IN (SELECT ... FROM related_table)`) over a possibly-stale calculated column when deciding what to delete.
- ⚠️ When cleaning up rows already copied to an archive, verify against the archive table itself rather than re-running the original archiving filter — the filter alone can't tell you whether the copy actually succeeded.
- ⚠️ Order of operations across related tables is the mirror image of INSERT: delete children before parents (deepest dependency first), the opposite of insert-parent-then-child.
- Transactions (Chapter 15) apply here too — wrap multi-table archive-then-delete sequences so a failure partway rolls back cleanly instead of leaving the data half-deleted.
