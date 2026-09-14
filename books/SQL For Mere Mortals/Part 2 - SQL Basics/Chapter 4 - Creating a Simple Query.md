# Chapter 4: Creating a Simple Query

SELECT == the workhorse of SQL. Nearly every question you pose to a database boils down to some form of SELECT.

The book splits the SELECT operation into three nested pieces:
1. **SELECT statement** == SELECT + FROM (+ WHERE, GROUP BY, HAVING)
2. **SELECT expression** == a SELECT statement combined with set operators (UNION etc, covered later)
3. **SELECT query** == a SELECT statement/expression with an ORDER BY tacked on

This chapter only deals with the simplest possible statement: SELECT + FROM, optionally DISTINCT, optionally sorted with ORDER BY.

## Data vs. Information

Data == what's stored in the database (raw, static values). Information == data after it's been processed/presented in a way that's meaningful to someone.

A SELECT statement's job is to turn data into information. The rows it returns are collectively called the **result set**.

## The SELECT Statement

```sql
SELECT column_name, column_name
FROM   table_name
```

Clause summary:
1. `SELECT` — required. Columns (or expressions) to return.
2. `FROM` — required. Table(s)/view(s) to draw from.
3. `WHERE` — optional. Row filter (Chapter 6).
4. `GROUP BY` — optional. Grouping for aggregates (Chapter 13).
5. `HAVING` — optional. Filter on grouped/aggregated results (Chapter 14).

Column order in the SELECT clause is arbitrary — list them in whatever order you want the output columns to appear. Table/column naming note: the SQL Standard says table/row/column, not relation/tuple/attribute — the book sticks to table/row/column throughout.

## The Translation Technique

The book teaches a repeatable 3-step method for turning an English request into SQL:

1. **Translation** — rewrite the request as `Select <item> from the <source>`, swapping words like "show me", "list", "who" for "Select".
2. **Clean Up** — cross out anything that isn't a column/table name or SQL keyword.
3. **SQL** — what's left, properly capitalized/spelled per the schema.

```
"Which cities do our customers live in?"
→ Select city from the customers table
→ SELECT City FROM Customers
```

When a request doesn't map cleanly onto column names, two fallback moves:
- Look at the actual table structure for columns that match the intent (e.g., "names and addresses" → EmpFirstName, EmpLastName, EmpStreetAddress, EmpCity, EmpState, EmpZipCode).
- Look for a word that *implies* a column via a synonym (e.g., "what kind of classes" → Category column).

## Selecting All Columns: `*`

```sql
SELECT * FROM Subjects
```

Shortcut for "every column currently in the table." Gotcha: since `*` is resolved against the table's current column list, adding/dropping columns silently changes your result set shape. Rule of thumb from the book: use `*` only for quick-and-dirty exploration; spell out columns in anything you intend to keep, since it's both safer and self-documenting.

✨ **Side learning:** the SQL Standard actually states that adding/removing columns should *not* change what `SELECT *` returns from a saved view — but virtually no product implements it that way in practice.

## Eliminating Duplicate Rows: DISTINCT

```sql
SELECT DISTINCT City FROM Bowlers
```

DISTINCT == evaluate all selected columns together as one unit per row, discard redundant rows. Without it, `SELECT City FROM Bowlers` repeats "Seattle" once per matching bowler — noisy if all you want is the list of distinct cities represented.

DISTINCT applies to the *combination* of listed columns, not each column independently:

```sql
SELECT DISTINCT City, State FROM Bowlers
```
This keeps "Portland, ME" and "Portland, OR" as two separate rows.

🤯 A DISTINCT result set is not updatable in any database system the author tested — the database can't map a displayed (deduplicated) row back to a single underlying row, so it has no idea which physical row(s) to change.

## Sorting: ORDER BY

By definition, a SELECT statement's result set is **unordered** — row sequence is whatever the engine finds most efficient, not something you can rely on. Sorting is technically a separate operation, layered on by turning a SELECT statement into a "SELECT query" (the book's term — not standard SQL terminology, but useful shorthand) via `ORDER BY`.

```sql
SELECT Category
FROM   Classes
ORDER BY Category
```

1. Default sort direction is ascending (`ASC`); use `DESC` for descending.
2. Multiple columns: separate with commas, evaluated left to right in the order listed — sequence matters.
3. Each column in the ORDER BY can have its own direction:

```sql
SELECT EmpLastName, EmpFirstName, EmpPhoneNumber, EmployeeID
FROM   Employees
ORDER BY EmpLastName DESC, EmpFirstName ASC
```

Per the Standard, you can only ORDER BY columns that are also in the SELECT list — some vendors relax this, but the book sticks to the rule throughout.

ORDER BY never changes a table's physical row order — it only affects what the result set looks like.

✨ **Side learning:** SQL Server's `TOP` extension lets you cap the result set based on the ORDER BY: `SELECT TOP 5 ProductName, RetailPrice FROM Products ORDER BY RetailPrice DESC` grabs the 5 priciest products; `TOP 10 PERCENT` works too. SQL Server also quirks in that it *ignores* ORDER BY in a saved view unless you open the view directly or wrap another `SELECT * FROM view ORDER BY ...` around it — and it requires `TOP 100 PERCENT` if you want ORDER BY to even be accepted syntactically in a view definition.

## Collating Sequences (preview)

ORDER BY's sort behavior for character data depends on the database's **collating sequence** — determines whether uppercase sorts before lowercase, whether case matters at all, etc. No default is mandated by the Standard. Covered in depth in Chapter 6.

## Saving Your Work

Save SELECT statements as queries/views/stored procedures/functions (terminology varies by product) so you don't have to retype them. Give them meaningful names + descriptions — future-you will thank present-you.

## Summary

- SELECT statement == SELECT + FROM at minimum; WHERE/GROUP BY/HAVING optional.
- Data becomes information only once it's retrieved/processed by a query.
- Translation technique: turn the request into "Select item from source", strip non-SQL words, capitalize into real SQL.
- Column order in SELECT is arbitrary; list order in ORDER BY is not.
- `*` is a shortcut for all columns but couples your query to the table's current shape — avoid it outside quick exploration.
- DISTINCT dedupes on the full combination of selected columns; result sets with DISTINCT are not updatable.
- A result set has no guaranteed order unless you add ORDER BY — which the book models as its own "SELECT query" layer on top of a SELECT statement.
- ORDER BY can only reference columns present in the SELECT clause (per the Standard), supports multiple columns, and independent ASC/DESC per column.
