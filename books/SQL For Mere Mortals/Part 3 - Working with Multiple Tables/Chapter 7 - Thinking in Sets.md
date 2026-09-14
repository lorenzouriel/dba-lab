# Chapter 7: Thinking in Sets

Everything so far (SELECT, ORDER BY, WHERE) worked on one table. This chapter is the mental model shift for working with *multiple* sets of data before you ever write a JOIN.

Set == a collection of members (rows), where each member has the same number/type of attributes (columns). A table is a set. A result set is a set. Even an empty result (zero rows) is a valid set.

Codd's relational model is built on two branches of math: set theory + first-order predicate logic.

## The Three Set Operations

1. **Intersection** == common elements in two sets. "Recipes that have both beef and onions."
2. **Difference** == elements in set A that are not in set B. Order matters: A minus B != B minus A. "Recipes with beef but not onions."
3. **Union** == combine two sets into one, duplicates removed. "Recipes with either beef or onions."

All three require members with the *same number and type of attributes* to compare cleanly — this is the "pure" set-theory version, and it's also exactly why it breaks down fast with real tables (see below).

✨ **Side learning:** Euler and Venn diagrams for visualizing set operations aren't a modern invention — Venn used them in an 1880 paper at Cambridge. "Thinking in sets" predates SQL by over a century.

## Why Pure Set Operations Struggle with Tables

Pure INTERSECT/EXCEPT/UNION require matching on *all columns*. That's fine for two similarly-shaped result sets (e.g. customer names vs employee names), but falls apart once you need to match on just a *few* columns (like a foreign key) while returning different columns from each side.

That's the gap JOIN exists to fill:

| Set operation | Table-world equivalent |
|---|---|
| INTERSECT | INNER JOIN (intersection on key values) |
| EXCEPT (difference) | OUTER JOIN + test for NULL |
| UNION | UNION (still directly usable) |

🤯 A JOIN is really just an intersection where you get to pick *which* columns must match, instead of requiring every column to match. That reframing is the whole point of this chapter — JOIN isn't a new concept, it's INTERSECT with looser matching rules.

Also: don't reach for `WHERE MeatIngredient = 'Beef' AND VegetableIngredient = 'Onions'` against a single denormalized table. If ingredients live one-per-row in a proper `Recipe_Ingredients` table (per Ch.2 normalization), no single row can be both beef and onions — you need two separate row-sets (beef rows, onion rows) and then combine them via intersection/difference/union on `RecipeID`.

## SQL Syntax Overview

```sql
SELECT Statement INTERSECT [ALL] SELECT Statement
SELECT Statement EXCEPT    [ALL] SELECT Statement
SELECT Statement UNION     [ALL] SELECT Statement
```

- Plain `UNION`/`INTERSECT`/`EXCEPT` remove duplicates.
- Add `ALL` to keep duplicates.
- Column count + compatible types must match between the two SELECTs (a "union-compatible" requirement).

### INTERSECT — find rows in both sets

```sql
SELECT DISTINCT OrderNumber FROM Order_Details WHERE ProductNumber IN (1, 2, 6, 11)
INTERSECT
SELECT DISTINCT OrderNumber FROM Order_Details WHERE ProductNumber IN (10, 25, 26)
```
Returns order numbers that contain both a bike (first list) and a helmet (second list).

### EXCEPT — find rows in A but not B

```sql
SELECT DISTINCT OrderNumber FROM Order_Details WHERE ProductNumber IN (1, 2, 6, 11)
EXCEPT
SELECT DISTINCT OrderNumber FROM Order_Details WHERE ProductNumber IN (10, 25, 26)
```
Orders with a bike but no helmet. Flip the two SELECTs to get orders with a helmet but no bike — EXCEPT is not commutative.

### UNION — combine two sets

```sql
SELECT DISTINCT OrderNumber FROM Order_Details WHERE ProductNumber IN (1, 2, 6, 11)
UNION
SELECT DISTINCT OrderNumber FROM Order_Details WHERE ProductNumber IN (10, 25, 26)
```
Orders with a bike, a helmet, or both. (In this single-table case a plain `WHERE ProductNumber IN (1,2,6,10,11,25,26)` does the same job more simply — UNION earns its keep once you're combining rows from genuinely different tables/queries.)

## Recognizing Which Operation a Request Needs

Phrase the request literally and look for the tell:

- "both X and Y" → INTERSECT (or INNER JOIN on key values)
- "X but not Y" / "except" → EXCEPT (or OUTER JOIN + IS NULL)
- "either X or Y" / "combined with" / "together with" → UNION

✨ **Side learning:** INTERSECT and EXCEPT are part of the SQL Standard but historically under-supported compared to UNION — the book notes "not many commercial implementations... support" them (written pre-2018). Modern reality: PostgreSQL, SQL Server, Oracle all support INTERSECT/EXCEPT today. MySQL didn't add INTERSECT/EXCEPT until 8.0.31 (2022) — before that, INNER/OUTER JOIN was the only option there. This is why the book spends the next two chapters teaching the JOIN-based workarounds instead of just leaning on these keywords.

## Summary

- A set is any collection of rows with uniform attributes — a table, a query result, even an empty result.
- Three fundamental operations: intersection (common), difference (in A not B, order-sensitive), union (combined, deduped).
- SQL Standard syntax: `INTERSECT`, `EXCEPT`, `UNION`, each with an optional `ALL` to keep duplicates.
- Pure set operations require matching on *all* columns — real multi-table problems usually need matching on just a *few* columns, which is what JOIN is for.
- Mental mapping to carry forward: INTERSECT ≈ INNER JOIN, EXCEPT ≈ OUTER JOIN + `IS NULL`, UNION stays UNION.
- Spotting "both/and", "but not/except", "either/or/together" in a request tells you which operation — and which chapter's technique — to reach for.
