# Chapter 9: OUTER JOINs

Where INNER JOIN gives you only the matches, OUTER JOIN gives you the matches *plus* the unmatched rows from one or both sides — filled with NULL for the columns that had no partner.

Concretely: INNER JOIN on Students/Classes drops students with no classes and classes with no students. An OUTER JOIN can keep either (or both) of those "orphan" groups around.

🤯 An OUTER JOIN + a `IS NULL` filter is how you implement Ch.7's EXCEPT/difference operation in engines that lack (or predate) the `EXCEPT` keyword — walk this through once and it clicks: LEFT JOIN keeps every row from the left table, matched or not; a row that had no match gets NULL in every right-table column; filtering `WHERE <right-table-key> IS NULL` isolates exactly the left rows with no counterpart — i.e., left minus right.

## LEFT / RIGHT OUTER JOIN

Naming: the first-named table is "left," the second is "right." `LEFT OUTER JOIN` keeps all rows from the left table; `RIGHT OUTER JOIN` keeps all rows from the right table. `OUTER` is optional (`LEFT JOIN` == `LEFT OUTER JOIN`), but `LEFT`/`RIGHT` itself is required — unlike INNER, there's no direction-free default.

```sql
SELECT Recipe_Classes.RecipeClassDescription, Recipes.RecipeTitle
FROM Recipe_Classes
LEFT OUTER JOIN Recipes
   ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
```
Every recipe class appears, even ones with zero recipes (NULL `RecipeTitle` for those rows).

### Finding the gap (EXCEPT via OUTER JOIN)

```sql
SELECT Recipe_Classes.RecipeClassDescription
FROM Recipe_Classes
LEFT OUTER JOIN Recipes
   ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID
WHERE Recipes.RecipeID IS NULL
```
Recipe classes with *no* recipes at all — "all recipe classes except the ones that already have recipes."

Same idea with `USING`:
```sql
FROM Recipe_Classes LEFT OUTER JOIN Recipes USING (RecipeClassID)
WHERE Recipes.RecipeID IS NULL
```

✨ **Side learning — legacy non-standard OUTER JOIN syntax:** Before the SQL-92 `LEFT/RIGHT OUTER JOIN` syntax was widely adopted, vendors invented their own WHERE-clause markers for "outer" comparisons: old SQL Server used `*=` (`WHERE a.id *= b.id`), Oracle used a trailing `(+)` (`WHERE a.id = b.id(+)`). Both are deprecated/removed in modern versions — the standard `LEFT/RIGHT OUTER JOIN` in the FROM clause replaced them everywhere. If you ever see `(+)` or `*=` in an old codebase, that's what it means.

### NATURAL LEFT OUTER JOIN

Same idea as Ch.8's NATURAL JOIN — auto-matches all same-named columns, no ON/USING allowed:
```sql
SELECT Recipe_Classes.RecipeClassDescription
FROM Recipe_Classes NATURAL LEFT OUTER JOIN Recipes
WHERE Recipes.RecipeID IS NULL
```

### Filtering the "many" side correctly

Careless placement of a WHERE filter can silently turn your OUTER JOIN back into an INNER JOIN. If you want "all recipe classes, but only show Salads/Soup/Main-course recipes when they exist," filtering `Recipes` in the main WHERE clause throws away exactly the rows you wanted to keep. Fix: filter *inside* a derived table on the appropriate side before joining.

```sql
SELECT RCFiltered.ClassName, R.RecipeTitle
FROM
  (SELECT RecipeClassID, RecipeClassDescription AS ClassName
   FROM Recipe_Classes
   WHERE RecipeClassDescription IN ('Salads', 'Soup', 'Main Course')) AS RCFiltered
LEFT OUTER JOIN Recipes AS R
   ON RCFiltered.RecipeClassID = R.RecipeClassID
```

⚠️ Gotcha called out explicitly in the book: putting extra filter conditions (beyond the join key comparison) directly in the `ON` clause is legal per the Standard, but several major implementations mishandle it or reject it outright. Safer habit: keep `ON` strictly to the join-key comparison, and put any additional filtering on the "many"/right side inside a derived table's own WHERE.

## Chaining OUTER JOINs — walking down vs. walking back up

Multiple LEFT OUTER JOINs compose fine *as long as you're following a one-to-many chain in one direction* ("walking down the hill"):

```sql
FROM (((Recipe_Classes
   LEFT OUTER JOIN Recipes ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID)
   LEFT OUTER JOIN Recipe_Ingredients ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
   INNER JOIN Ingredients ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID)
   INNER JOIN Measurements ON Measurements.MeasureAmountID = Recipe_Ingredients.MeasureAmountID
```

But if you then need to "walk back up" — e.g. also show *ingredients never used in any recipe* — a trailing `RIGHT OUTER JOIN Ingredients` breaks, because NULL never equals NULL. Rows already carrying a NULL `IngredientID` (recipes with no ingredients yet) can't match the RIGHT JOIN's real `IngredientID` values, so they get silently dropped, and you lose the very "no recipes yet" rows you built up earlier. Some engines even refuse the query outright with an "ambiguous OUTER JOIN" error.

## FULL OUTER JOIN

Keeps unmatched rows from *both* sides at once — the actual fix for the "walking back up" problem above:

```sql
SELECT Recipe_Classes.RecipeClassDescription, Recipes.RecipeTitle, ...
FROM (((Recipe_Classes
   FULL OUTER JOIN Recipes ON Recipe_Classes.RecipeClassID = Recipes.RecipeClassID)
   LEFT OUTER JOIN Recipe_Ingredients ON Recipes.RecipeID = Recipe_Ingredients.RecipeID)
   INNER JOIN Measurements ON Measurements.MeasureAmountID = Recipe_Ingredients.MeasureAmountID)
   FULL OUTER JOIN Ingredients ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
ORDER BY RecipeTitle, RecipeSeqNo
```
Now recipe classes with no recipes, recipes with no ingredients, *and* ingredients used in no recipe all survive in one result set.

FULL OUTER JOIN also works on non-key columns — e.g. a FULL OUTER JOIN of `Students`/`Staff` on first name shows matches, students with no same-named staff, and staff with no same-named student, all at once.

✨ **Side learning:** Products without FULL OUTER JOIN support (older MySQL, older Access) fake it with `LEFT OUTER JOIN ... UNION ... RIGHT OUTER JOIN ...`. MySQL didn't add native `FULL OUTER JOIN` until version 8.0.31 (2022) — before that this UNION trick was the standard workaround. Ch.10 covers UNION.

## UNION JOIN

Per the Standard: a FULL OUTER JOIN with the *matching* rows removed (only the unmatched leftovers from both sides). Barely implemented anywhere, and the book itself admits it's hard-pressed to justify a real use case. Mentioned for completeness only.

## What OUTER JOIN Is Good For

1. **Finding missing values** (LEFT JOIN + `IS NULL`): "products never ordered," "entertainers never booked," "faculty not teaching a class," "ingredients unused in any recipe."
2. **Partially matched reporting** (no NULL filter — you want to *see* the gaps): "all customers and any orders for bicycles," "all recipe types, all recipes, and any ingredients."

For case 1, the same "filter before joining" rule from earlier applies in reverse: to answer "customers who never ordered a helmet," you must build the *inner*-joined "customers who ordered a helmet" set first, then LEFT JOIN `Customers` against that and test for NULL — filtering directly in a plain WHERE after a straight `Customers LEFT JOIN Orders` won't isolate helmet orders correctly.

```sql
SELECT Ingredients.IngredientName
FROM Ingredients
LEFT OUTER JOIN Recipe_Ingredients
   ON Ingredients.IngredientID = Recipe_Ingredients.IngredientID
WHERE Recipe_Ingredients.RecipeID IS NULL
```

## Summary

- OUTER JOIN keeps unmatched rows (from one or both tables) as NULL-padded rows, instead of dropping them like INNER JOIN.
- LEFT keeps all of the first-named table; RIGHT keeps all of the second-named table; the direction is not optional the way INNER is.
- LEFT/RIGHT JOIN + `WHERE <right/left-side key> IS NULL` == the difference/EXCEPT operation from Ch.7.
- Extra filter conditions on the "many" side belong in a derived table's WHERE, not stacked onto the JOIN's ON clause or a plain WHERE after — either can silently defeat the OUTER JOIN's whole purpose.
- Chained one-directional (all-LEFT) OUTER JOINs are safe; mixing directions to "walk back up" a chain breaks on NULL-vs-NULL mismatches — use FULL OUTER JOIN instead when you need gaps from both ends.
- FULL OUTER JOIN = unmatched rows from both sides kept; UNION JOIN = FULL OUTER JOIN with the matched rows thrown away (rarely implemented, rarely useful).
- Classic use cases: "what's missing" (JOIN + IS NULL) and "show everything, matched or not" (reporting-style outer joins).
