# Part 5: Modifying Sets of Data

Parts II-IV were entirely read-only: SELECT can't hurt you (much). This Part introduces the three SQL Standard statements that actually change stored data: UPDATE, INSERT, DELETE.

Same "modify" sample databases as before, but with extra columns/tables specifically added to support these chapters (order totals, archive tables, etc.) — see the Introduction's note on "Example" vs "Modify" database flavors.

## Why "Think in Sets" Matters More Here

A SELECT that's slightly wrong shows you a slightly wrong result set — annoying, harmless, rerun it. An UPDATE or DELETE that's slightly wrong (a missing WHERE, a WHERE that matches more rows than intended) silently overwrites or destroys data across every row it touches, in one shot, before you get a chance to look at it.

All three statements act on a set of rows in a single pass — there's no implicit "row 1, then row 2, ..." loop to reason about, but there's also no undo once it commits. The set-based mental model isn't optional flavor here; it's the actual mechanism of the danger: one WHERE clause decides the fate of however many rows match, all at once.

## The Pattern Introduced in This Part

1. **Build the SELECT first.** Every chapter here teaches converting a verification SELECT (same WHERE clause) into the real UPDATE/INSERT/DELETE only after confirming it targets the right rows.
2. **Transactions** (START TRANSACTION / COMMIT / ROLLBACK) get their first real mention — a safety net for exactly the failure mode above.
3. **Order of operations matters** across related tables — referential integrity constraints dictate whether you delete children before parents, or insert parents before children.

## Chapters in This Part

1. **Chapter 15 - Updating Sets of Data**: UPDATE, including subqueries in SET and WHERE.
2. **Chapter 16 - Inserting Sets of Data**: INSERT ... VALUES vs. INSERT ... SELECT.
3. **Chapter 17 - Deleting Sets of Data**: DELETE, the simplest and most dangerous statement in SQL.

🤯 DELETE has no LIMIT/TOP in the Standard syntax and no "preview" mode — the verify-with-SELECT-first habit this Part teaches is the closest thing SQL gives you to a safety catch.
