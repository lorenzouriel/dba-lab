# Chapter 8: INNER JOINs

JOIN == intersection, but restricted to matching on only the columns you specify, rather than requiring every column to match (the Ch.7 INTERSECT limitation). This lets you combine dissimilar tables — e.g. link `Customers` to `Orders` on `CustomerID` — instead of only combining same-shaped result sets.

INNER JOIN == returns only rows where the linking value matches in *both* tables. Unmatched rows on either side are dropped entirely. A student not yet registered for any class, or a class with no students, simply won't appear.

## What's "Legal" to JOIN

1. Normally: primary key of one table to the matching foreign key of another.
2. Technically legal: any "JOIN eligible" columns of compatible type (character-to-character, number-to-number, date-to-date) — e.g. joining `Customers` and `Employees` on city to find who lives where whom.
3. Legal != sensible. Joining `CustomerName` to `EmployeeAddress` compiles but returns garbage. Joining `StudentID` to `ClassID` (both numbers) returns rows that mean nothing.
4. Joining on an unindexed column, or on a computed expression (e.g. concatenated first+last name), can force a full scan of both tables — legal but slow.

## Column References

Once two+ tables are in the FROM clause, ambiguous column names (same name in both tables — very likely, since Ch.2's own advice is to copy PK name into the FK) must be qualified: `table_name.column_name`.

```sql
SELECT Employees.FirstName, Employees.LastName
FROM Employees
```

## INNER JOIN Syntax

```sql
SELECT Recipes.RecipeTitle, Recipes.Preparation, Recipe_Classes.RecipeClassDescription
FROM Recipe_Classes INNER JOIN Recipes
   ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
```

- `INNER` keyword is optional (bare `JOIN` defaults to INNER) — write it anyway, for clarity.
- Logically: the DB forms the Cartesian product of both tables, then filters by the ON condition. In practice, optimizers use an index to avoid ever materializing the full product.
- Old-style equivalent (no JOIN keyword, comma join + WHERE) still works everywhere:

```sql
SELECT Recipes.RecipeTitle, Recipes.Preparation, Recipe_Classes.RecipeClassDescription
FROM Recipe_Classes, Recipes
WHERE Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
```

### USING and NATURAL JOIN

If the linking columns share the same name, `USING` is shorthand for an equality `ON`:

```sql
FROM Recipe_Classes INNER JOIN Recipes USING (RecipeClassID)
```

`NATURAL JOIN` goes further — auto-matches *every* same-named column between the two tables. No `ON`/`USING` allowed with it. Risky if two tables happen to share a same-named column that isn't meant to be a join key.

🤯 A column referenced in `USING` loses its table identity — the two columns are "coalesced" into one, so you can no longer write `Recipes.RecipeClassID` in the SELECT list. Not true for `ON`, where both copies stay addressable.

## Correlation Names (Aliases)

```sql
SELECT R.RecipeTitle, R.Preparation, RC.RecipeClassDescription
FROM Recipe_Classes AS RC
INNER JOIN Recipes AS R
   ON RC.RecipeClassID = R.RecipeClassID
WHERE RC.RecipeClassDescription = 'Main course' OR RC.RecipeClassDescription = 'Dessert'
```

Required (not just convenient) when:
1. You include the same table twice in one query (e.g. `Bowlers` joined once for team captain, once for team roster) — each copy needs its own alias so the engine can tell them apart.
2. You substitute a derived table (embedded SELECT) for a table name — the derived result needs *some* name to be referenced in ON/SELECT.

## Embedding a SELECT in FROM (Derived Tables)

Any table name slot in a FROM clause can hold a whole SELECT statement instead — called a derived table. Must carry a correlation name.

```sql
SELECT R.RecipeTitle, RCFiltered.ClassName
FROM
  (SELECT RecipeClassID, RecipeClassDescription AS ClassName
   FROM Recipe_Classes
   WHERE RecipeClassDescription IN ('Main course', 'Dessert')) AS RCFiltered
INNER JOIN Recipes AS R
   ON RCFiltered.RecipeClassID = R.RecipeClassID
```

Gotcha: the derived table must still expose the linking column even if you don't want it in the final output (here, `RecipeClassID`), or the JOIN has nothing to key on. Filtering inside the derived table (rather than a WHERE after the JOIN) can also nudge the optimizer to filter *before* joining — cheaper on large tables, though a smart optimizer should do this either way.

## Chaining JOINs (3+ Tables)

Wrap an inner JOIN in parentheses and treat it as a single "table" for the next JOIN:

```sql
SELECT Recipe_Classes.RecipeClassDescription, Recipes.RecipeTitle, Recipes.Preparation,
       Ingredients.IngredientName, Recipe_Ingredients.RecipeSeqNo,
       Recipe_Ingredients.Amount, Measurements.MeasurementDescription
FROM (((Recipe_Classes
   INNER JOIN Recipes ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID)
   INNER JOIN Recipe_Ingredients ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
   INNER JOIN Ingredients ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID)
   INNER JOIN Measurements ON Measurements.MeasureAmountID = Recipe_Ingredients.MeasureAmountID
ORDER BY RecipeTitle, RecipeSeqNo
```

1. The join order/nesting in the SQL text doesn't have to match execution order — the optimizer is free to reorder, as long as the relationships hold (e.g. join table 2+3 first, then join that to table 1).
2. Some optimizers *are* sensitive to written JOIN order for performance — if a many-JOIN query is slow, try reordering.
3. A table can be included purely as a "bridge" even if none of its columns appear in the SELECT list — e.g. `Recipe_Ingredients` is required to link `Recipes` to `Ingredients`, even though you might only want recipe title + ingredient name.

✨ **Side learning:** Knowing your schema's relationships isn't optional once you're past 2 tables — get it wrong and you either can't express the query, or worse, get a query that runs and returns a plausible-looking but wrong answer (e.g. accidentally picking up an ingredient's *default* measurement instead of the one specific to that recipe, because two tables both have a `MeasureAmountID` column).

## What INNER JOIN Is Good For

1. **Finding related rows** — the obvious case: customers + their orders, teams + captains, students + subjects.
2. **Finding matching values (an INTERSECT stand-in)** — e.g. "customers and employees with the same name," "recipes with both beef and garlic." This works by first building two filtered row-sets (as derived tables), each keyed on the entity's ID, then INNER-joining those two derived sets on that ID:

```sql
SELECT CustBikes.CustFirstName, CustBikes.CustLastName
FROM
  (SELECT DISTINCT Customers.CustomerID, Customers.CustFirstName, Customers.CustLastName
   FROM Customers
   INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
   INNER JOIN Order_Details ON Orders.OrderNumber = Order_Details.OrderNumber
   INNER JOIN Products ON Products.ProductNumber = Order_Details.ProductNumber
   WHERE Products.ProductName LIKE '%Bike') AS CustBikes
INNER JOIN
  (SELECT DISTINCT Customers.CustomerID
   FROM Customers
   INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
   INNER JOIN Order_Details ON Orders.OrderNumber = Order_Details.OrderNumber
   INNER JOIN Products ON Products.ProductNumber = Order_Details.ProductNumber
   WHERE Products.ProductName LIKE '%Helmet') AS CustHelmets
ON CustBikes.CustomerID = CustHelmets.CustomerID
```
Returns customers who ordered both a bike and a helmet — the "both X and Y" pattern from Ch.7, done without `INTERSECT`. `DISTINCT` matters here since a customer could order the same category twice. (The book flags this as clunky — Ch.11 subqueries solve it more cleanly.)

## Summary

- A JOIN is an intersection restricted to specified columns — that's the whole conceptual leap from Ch.7's pure set INTERSECT.
- INNER JOIN drops any row from either side that has no match — no NULLs, no partial rows.
- Qualify column names once 2+ tables are in play; use `AS` correlation names when a table repeats or a derived table needs a handle.
- `ON` is the general form; `USING (col)` is shorthand for equal-named columns (but coalesces the column identity); `NATURAL JOIN` auto-matches all same-named columns (convenient, risky).
- Any FROM slot can hold a derived table (a parenthesized SELECT + alias) instead of a bare table name — must still expose whatever column the JOIN keys on.
- Chained JOINs are just JOINs-of-JOINs, wrapped in parentheses; join order in the SQL doesn't dictate execution order, but can matter for performance.
- INNER JOIN doubles as a workaround for INTERSECT-style "both A and B" problems: filter each side into its own derived set keyed on ID, then INNER JOIN those two sets together.
