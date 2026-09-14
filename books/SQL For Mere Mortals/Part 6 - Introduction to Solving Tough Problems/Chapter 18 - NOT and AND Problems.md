# Chapter 18: "NOT" and "AND" Problems

The recurring trap in this chapter: ingredients (or bookings, or musical styles) for a single recipe/customer form a **set of rows**, not a single row. A WHERE clause tests one row at a time, so the obvious-looking `IN`/`NOT IN` translation of "has beef AND onions AND carrots" or "has neither beef, onions, nor carrots" is wrong — it tests each ingredient row independently instead of the whole set.

## The Broken Intuition

```sql
-- WRONG for "recipes with beef AND onions AND carrots"
WHERE Ingredient IN ('Beef', 'Onions', 'Carrots')
-- returns any recipe with AT LEAST ONE of the three — an OR, not an AND

-- WRONG for "recipes with none of beef, onions, carrots"
WHERE Ingredient NOT IN ('Beef', 'Onions', 'Carrots')
-- returns any recipe that has SOME OTHER ingredient too — eliminates almost nothing

-- WRONG for "has beef but not onions or carrots"
WHERE Ingredient = 'Beef' AND Ingredient NOT IN ('Onions', 'Carrots')
-- a single Ingredient column can't be both 'Beef' and something else in the same row —
-- this returns every row that just happens to equal 'Beef' (always true) OR'd nowhere,
-- so it quietly matches everything with beef regardless of the other ingredients
```

Root cause: the multi-valued attribute (ingredients of a recipe) lives in a **child table** of rows, so "recipe has ALL of X, Y, Z" or "recipe has NONE of X, Y, Z" is a statement about the whole child set per recipe, not about any single child row. This is the classic relational-division flavor of problem: divide the child rows by the criteria set and keep only the parents whose child-set satisfies it.

## Solving "NOT" (none of X, Y, Z) — Four Techniques

Goal example throughout: *"Find the recipes that have neither beef, nor onions, nor carrots."*

### 1. OUTER JOIN + subquery

Build the set of "bad" recipe IDs (those with beef/onion/carrot) as a derived table, LEFT JOIN it to Recipes, keep only rows where the match is NULL.

```sql
SELECT R.RecipeID, R.RecipeTitle
FROM Recipes AS R
LEFT JOIN
    (SELECT RI.RecipeID
     FROM Recipe_Ingredients AS RI
     INNER JOIN Ingredients AS I ON RI.IngredientID = I.IngredientID
     WHERE I.IngredientName IN ('Beef', 'Onion', 'Carrot')) AS Bad
    ON R.RecipeID = Bad.RecipeID
WHERE Bad.RecipeID IS NULL;
```

Do NOT try to fold the ingredient filter straight into a WHERE on a plain (non-subqueried) LEFT JOIN — filtering the "right side" table of a LEFT JOIN in the WHERE clause silently turns it back into an INNER JOIN (covered back in Ch. 9).

### 2. NOT IN

The naive version runs three separate `NOT IN` subqueries (one per excluded value) — works, but verbose. The clean version collects all disqualifying recipe IDs in **one** subquery:

```sql
SELECT R.RecipeID, R.RecipeTitle
FROM Recipes AS R
WHERE R.RecipeID NOT IN
    (SELECT RI.RecipeID
     FROM Recipe_Ingredients AS RI
     INNER JOIN Ingredients AS I ON RI.IngredientID = I.IngredientID
     WHERE I.IngredientName IN ('Beef', 'Onion', 'Carrot'));
```

Arguably the simplest of the four — the subquery runs once, then the result is used to filter. This is the go-to default.

### 3. NOT EXISTS

Same idea, but correlated: for each candidate recipe, check that no disqualifying ingredient row exists for *that specific* RecipeID.

```sql
SELECT R.RecipeID, R.RecipeTitle
FROM Recipes AS R
WHERE NOT EXISTS
    (SELECT RI.RecipeID
     FROM Recipe_Ingredients AS RI
     INNER JOIN Ingredients AS I ON RI.IngredientID = I.IngredientID
     WHERE I.IngredientName IN ('Beef', 'Onion', 'Carrot')
       AND RI.RecipeID = R.RecipeID);
```

Trade-off: the subquery is correlated, so conceptually it re-runs once per outer row (a good optimizer collapses this, but don't assume).

### 4. GROUP BY / HAVING COUNT = 0

LEFT JOIN to the disqualifying set as before, but instead of `IS NULL`, group and require the count of matches to be zero:

```sql
SELECT R.RecipeID, R.RecipeTitle
FROM Recipes AS R
LEFT JOIN
    (SELECT RI.RecipeID
     FROM Recipe_Ingredients AS RI
     INNER JOIN Ingredients AS I ON RI.IngredientID = I.IngredientID
     WHERE I.IngredientName IN ('Beef', 'Onion', 'Carrot')) AS Bad
    ON R.RecipeID = Bad.RecipeID
GROUP BY R.RecipeID, R.RecipeTitle
HAVING COUNT(Bad.RecipeID) = 0;
```

Works because `COUNT(column)` ignores NULLs — when the LEFT JOIN finds no match, `Bad.RecipeID` is NULL and doesn't get counted. For a single-table exclusion this is just a more roundabout version of technique #1 (skip the GROUP BY, it's overhead). It earns its keep once the query already needs grouping anyway — e.g. "recipes that have butter but neither beef, onion, nor carrot" needs a real JOIN chain (Recipes → Recipe_Ingredients → Ingredients) that produces multiple rows per recipe, and GROUP BY collapses that back to one row per recipe while HAVING applies the exclusion.

## Solving "AND" (all of X, Y, Z) — Four Techniques

Goal example throughout: *"List the customers who have booked [Group A], [Group B], and [Group C]."* — an intersection of three sets of CustomerIDs, one per required match.

### 1. INNER JOIN of subqueries

Build one derived table per criterion (each yielding matching CustomerIDs), then INNER JOIN all of them together on the key — an intersection via JOIN.

```sql
SELECT DISTINCT A.CustomerID, A.CustFirstName, A.CustLastName
FROM
  (SELECT C.CustomerID, C.CustFirstName, C.CustLastName
   FROM Customers AS C
   INNER JOIN Engagements AS E ON C.CustomerID = E.CustomerID
   INNER JOIN Entertainers AS Ent ON E.EntertainerID = Ent.EntertainerID
   WHERE Ent.EntStageName = 'Carol Peacock Trio') AS A
INNER JOIN
  (SELECT E.CustomerID
   FROM Engagements AS E
   INNER JOIN Entertainers AS Ent ON E.EntertainerID = Ent.EntertainerID
   WHERE Ent.EntStageName = 'Caroline Coie Cuartet') AS B
  ON A.CustomerID = B.CustomerID
INNER JOIN
  (SELECT E.CustomerID
   FROM Engagements AS E
   INNER JOIN Entertainers AS Ent ON E.EntertainerID = Ent.EntertainerID
   WHERE Ent.EntStageName = 'Jazz Persuasion') AS C
  ON B.CustomerID = C.CustomerID;
```

`DISTINCT` in the outer SELECT cleans up duplicates from a customer booking the same group more than once.

### 2. IN (chained, one per criterion)

The naive single `IN (...)` with all three names is the same OR-instead-of-AND trap from the top of the chapter. The fix: one `IN` subquery per criterion, ANDed together — the customer must be in set A **and** in set B **and** in set C.

```sql
SELECT CustomerID, CustFirstName, CustLastName
FROM Customers
WHERE CustomerID IN
    (SELECT E.CustomerID FROM Engagements AS E
     INNER JOIN Entertainers AS Ent ON E.EntertainerID = Ent.EntertainerID
     WHERE Ent.EntStageName = 'Carol Peacock Trio')
  AND CustomerID IN
    (SELECT E.CustomerID FROM Engagements AS E
     INNER JOIN Entertainers AS Ent ON E.EntertainerID = Ent.EntertainerID
     WHERE Ent.EntStageName = 'Caroline Coie Cuartet')
  AND CustomerID IN
    (SELECT E.CustomerID FROM Engagements AS E
     INNER JOIN Entertainers AS Ent ON E.EntertainerID = Ent.EntertainerID
     WHERE Ent.EntStageName = 'Jazz Persuasion');
```

### 3. EXISTS (chained, correlated)

Same shape as IN, but each subquery correlates back to the outer CustomerID via EXISTS instead of returning a value list.

```sql
SELECT CustomerID, CustFirstName, CustLastName
FROM Customers AS Cu
WHERE EXISTS
    (SELECT * FROM Engagements AS E INNER JOIN Entertainers AS Ent
       ON E.EntertainerID = Ent.EntertainerID
     WHERE Ent.EntStageName = 'Carol Peacock Trio' AND E.CustomerID = Cu.CustomerID)
  AND EXISTS
    (SELECT * FROM Engagements AS E INNER JOIN Entertainers AS Ent
       ON E.EntertainerID = Ent.EntertainerID
     WHERE Ent.EntStageName = 'Caroline Coie Cuartet' AND E.CustomerID = Cu.CustomerID)
  AND EXISTS
    (SELECT * FROM Engagements AS E INNER JOIN Entertainers AS Ent
       ON E.EntertainerID = Ent.EntertainerID
     WHERE Ent.EntStageName = 'Jazz Persuasion' AND E.CustomerID = Cu.CustomerID);
```

### 4. GROUP BY / HAVING — the "match ALL, dynamically" pattern

The first three techniques need a **fixed, known list** of criteria (three literal group names). GROUP BY/HAVING shines for the harder variant: *"match all of the styles this customer prefers"* — where "all" is a different, unknown-length list per customer. This is relational division in its purest form: divide the entertainer's styles by the customer's preferred styles and keep only entertainers whose styles are a superset.

```sql
SELECT Cu.CustomerID, Cu.CustFirstName, Cu.CustLastName,
       Ent.EntertainerID, Ent.EntStageName,
       COUNT(MP.StyleID) AS CountOfStyleID
FROM Customers AS Cu
INNER JOIN Musical_Preferences AS MP ON Cu.CustomerID = MP.CustomerID
INNER JOIN Entertainer_Styles AS ES ON MP.StyleID = ES.StyleID
INNER JOIN Entertainers AS Ent ON Ent.EntertainerID = ES.EntertainerID
GROUP BY Cu.CustomerID, Cu.CustFirstName, Cu.CustLastName,
         Ent.EntertainerID, Ent.EntStageName
HAVING COUNT(MP.StyleID) =
    (SELECT COUNT(*) FROM Musical_Preferences AS MP2
     WHERE MP2.CustomerID = Cu.CustomerID);
```

The trick: join customer-preferred-styles to entertainer-styles on `StyleID` (a legal join even without an FK, since both columns share the same domain/meaning), count how many of the customer's preferences each entertainer satisfies, and compare that count to the customer's *total* preference count (via correlated subquery). Equal counts == the entertainer plays every style the customer likes — you never need to know in advance how many styles that is.

✨ **Side learning**: the equivalent HAVING could instead compare against `(SELECT COUNT(*) FROM Entertainer_Styles WHERE EntertainerID = Ent.EntertainerID)` — same logical result, comparing "styles matched" against "entertainer's total style count" instead of "customer's total preference count." Pick whichever direction of superset you actually mean; they coincide only when the sets match exactly.

🤯 GROUP BY/HAVING for the "match multiple" (AND) case only works cleanly when each qualifying fact is a *distinct row* per parent (one row per ingredient per recipe). Once a customer can book the same entertainer multiple times, a naive COUNT will overcount — you'd need `COUNT(DISTINCT ...)` or a pre-aggregated subquery first.

## Choosing a Technique

- **Fixed short list of "not" criteria, single table** → OUTER JOIN with `IS NULL`, or `NOT IN` with one combined subquery. `NOT IN` collapsing three subqueries into one is usually the cleanest.
- **"Not" combined with other JOINs/filters that already need one row per parent** → GROUP BY/HAVING COUNT = 0 pulls its weight.
- **Fixed short list of "and" criteria** → INNER JOIN of subqueries, or chained `IN`, or chained `EXISTS`. All three are equivalent; correlated EXISTS may run once per outer row, `IN`/JOIN subqueries typically run once each.
- **"Match ALL of an unknown-length, per-row-varying list"** (relational division proper) → GROUP BY + HAVING COUNT(matches) = COUNT(total required), correlated back to the "requirer" row.
- Multiple sample statements in the chapter reuse "prerequisite not yet completed" (NOT IN with a correlated exclusion subquery) and "pairs of recipes sharing ≥3 ingredients" (self-join the child table to itself, `HAVING COUNT >= 3`, with a `RecipeID > RecipeID` inequality guard to avoid listing each pair twice) — both are variations on the same NOT IN / GROUP BY toolbox, just self-referential.

## Summary

- The core mistake: treating a multi-row child set (ingredients, bookings, preferences) as if a single `IN`/`NOT IN` test against one column could express "ALL of" or "NONE of" across that whole set. `IN` naturally expresses OR; getting AND/NOT-of-a-set requires either chaining tests or pre-aggregating.
- Four ways to solve "has none of X, Y, Z": OUTER JOIN + `IS NULL`, `NOT IN` (one combined subquery beats several), `NOT EXISTS` (correlated), `GROUP BY`/`HAVING COUNT = 0`.
- Four ways to solve "has all of X, Y, Z" (fixed list): INNER JOIN of per-criterion subqueries, chained `IN`, chained correlated `EXISTS`.
- When "all of" means a *dynamic, per-row* list (relational division) — no fixed literal list — `GROUP BY` + `HAVING COUNT(matched) = COUNT(required)` (required count from a correlated subquery) is the pattern, and it's the only one of the eight techniques that generalizes to that case.
- A guard like `RecipeID > RecipeID` (self-join) or `DISTINCT` in the outer SELECT is often needed to prevent duplicate pairs/rows once the JOINs start fanning out.
