# Chapter 21: Performing Complex Calculations on Groups

Problem category: plain `GROUP BY` only gives you *one* breakdown at a time — one row per unique combination of the grouped columns, and nothing else. When you need subtotals **at multiple levels simultaneously** (by state, by state+gender, and a grand total, all in one result set), you need the SQL Standard's GROUP BY extensions: `ROLLUP`, `CUBE`, `GROUPING SETS`.

Why it's tricky: getting subtotals-at-several-levels the "naive" way means running N separate GROUP BY queries and UNIONing them together. These extensions do it in one query, and the syntax needs to be read carefully because ROLLUP/CUBE/GROUPING SETS behave quite differently from each other despite looking similar.

## The Problem: One GROUP BY, One Level of Detail

```sql
SELECT StudState, StudGender, StudMaritalStatus, COUNT(*) AS Number
FROM Students
GROUP BY StudState, StudGender, StudMaritalStatus;
```

This gives exactly one row per unique (state, gender, marital status) combination — no "total per state," no grand total. To get those you'd traditionally need extra queries.

## Extended GROUP BY Syntax

```sql
GROUP BY ROLLUP (col1, col2, ...)
GROUP BY CUBE (col1, col2, ...)
GROUP BY GROUPING SETS ( (col1, col2), (col3), () )
```

All the normal GROUP BY rules still apply: any non-aggregated SELECT column must appear in the grouping clause, and the grouping clause must reference real columns from FROM/WHERE, not SELECT-clause aliases.

✨ **Side learning:** Neither MS Access nor MySQL support `CUBE` or `GROUPING SETS`. MySQL does support `ROLLUP`, but with different (non-standard) syntax. Support for all three extensions is solid in SQL Server and PostgreSQL.

## ROLLUP — Hierarchical Subtotals

ROLLUP(col1, col2, col3) == n+1 levels of subtotal, rolled up **right to left**. Column order matters — it defines the subtotal hierarchy.

```sql
SELECT StudState, StudGender, StudMaritalStatus, COUNT(*) AS Number
FROM Students
GROUP BY ROLLUP (StudState, StudGender, StudMaritalStatus);
```

With 3 columns you get 4 levels:
1. Unique (state, gender, maritalstatus) combos
2. Unique (state, gender) combos, maritalstatus rolled up (shown as NULL)
3. Unique state values, gender+maritalstatus rolled up
4. Grand total (all three rolled up)

A subtotal row shows NULL in the columns that are "rolled up" (summarized over). Reordering the ROLLUP column list changes which column becomes the outermost subtotal level — `ROLLUP(StudState, StudGender, StudMaritalStatus)` subtotals by state; `ROLLUP(StudMaritalStatus, StudGender, StudState)` subtotals by marital status instead, even with the same SELECT list order.

## The GROUPING() Function

Problem: how do you tell a *real* NULL value in the data apart from a NULL that just means "this row is a subtotal"? `GROUPING(column)` returns 0 when the column is not rolled up on that row (real value present), and 1 (nonzero) when it's summarized (guaranteed NULL).

```sql
SELECT
    (CASE WHEN GROUPING(StudState) = 0 THEN StudState ELSE 'Any State' END) AS State,
    (CASE WHEN GROUPING(StudGender) = 0 THEN StudGender ELSE 'Any Gender' END) AS Gender,
    COUNT(*) AS Number
FROM Students
GROUP BY ROLLUP (StudState, StudGender);
```

Use this instead of `COALESCE`/`ISNULL` whenever the grouped column can itself legitimately contain NULL — COALESCE can't distinguish "really NULL" from "rolled up."

## CUBE — All Combination Subtotals

CUBE gives you everything ROLLUP gives you, **plus** subtotals for every other combination of the listed columns — not just the right-to-left hierarchy. n columns → 2ⁿ subtotal groupings.

```sql
SELECT StudState, StudGender, StudMaritalStatus, COUNT(*) AS Number
FROM Students
GROUP BY CUBE (StudState, StudGender, StudMaritalStatus);
```

3 columns → 2³ = 8 subtotal levels: (state,gender,status), (state,gender), (state,status), (gender,status), (state), (gender), (status), and the grand total.

Because CUBE covers every combination, **column order in the CUBE list doesn't affect which subtotals appear** (unlike ROLLUP) — only the row order of the output changes.

🤯 CUBE's subtotal count grows exponentially with the number of grouped columns — 2ⁿ. Five columns already means 32 different subtotal groupings computed in a single query. Worth remembering before reaching for CUBE on a wide grouping list; GROUPING SETS lets you ask for only the combinations you actually need.

## GROUPING SETS — Pick Exactly the Subtotals You Want

GROUPING SETS == "give me the union of several different GROUP BYs, in one query, without the CUBE's full combinatorial explosion." No implied hierarchy (unlike ROLLUP) and no requirement to compute every combination (unlike CUBE). Also: **no grand total** unless you explicitly add an empty set `()` to the list.

```sql
SELECT StudState, StudGender, StudMaritalStatus, COUNT(*) AS Number
FROM Students
GROUP BY GROUPING SETS (StudState, StudGender, StudMaritalStatus);
```

This is equivalent to three independent GROUP BYs UNIONed together — one totalling by state alone, one by gender alone, one by marital status alone:

```sql
SELECT NULL, NULL, StudMaritalStatus, COUNT(*) FROM Students GROUP BY StudMaritalStatus
UNION
SELECT NULL, StudGender, NULL, COUNT(*) FROM Students GROUP BY StudGender
UNION
SELECT StudState, NULL, NULL, COUNT(*) FROM Students GROUP BY StudState;
```

You can also group by *combinations*, mixing single columns and column-pairs in the same GROUPING SETS list:

```sql
GROUP BY GROUPING SETS (
    StudState,
    (StudState, StudGender),
    (StudState, StudMaritalStatus)
);
```

This gives subtotals by state alone, by state+gender, and by state+maritalstatus — but deliberately skips gender-alone, maritalstatus-alone, and the full 3-way combination.

📝 Rule of thumb from the book: reach for ROLLUP when the request smells like "subtotal for each subset, working down a hierarchy." Reach for CUBE when it smells like "every combination." Reach for GROUPING SETS when it's "some but not all combinations," or when you specifically don't want a grand total.

## Combining Techniques

ROLLUP, CUBE, and GROUPING SETS can be mixed with plain grouping columns (and, per the standard, with each other, though the book notes that's rarely useful). "Promoting" a column out of a CUBE/ROLLUP into a plain GROUP BY column removes the grand-total row and stops that column from participating in the subtotal combinatorics — it becomes a fixed grouping level that the CUBE/ROLLUP runs *underneath*.

```sql
-- Group by state normally, but ROLLUP the other two underneath each state
SELECT StudState, StudGender, StudMaritalStatus, COUNT(*) AS Number
FROM Students
GROUP BY StudState, ROLLUP (StudMaritalStatus, StudGender);
```

Result: 3 subtotal levels per state (state+gender+status, state+gender, state-alone) but no cross-state grand total — because `StudState` sits outside the ROLLUP.

Swap `ROLLUP` for `CUBE` in that same query and you get, per state, all 4 combinations of gender/maritalstatus (both, gender-only, status-only, neither) — again with no grand total, since state was promoted out.

## Summary

- Plain GROUP BY returns one level of subtotal; ROLLUP, CUBE, and GROUPING SETS extend it to return several levels (or several unrelated groupings) in a single query.
- `GROUP BY ROLLUP(a, b, c)` == hierarchical right-to-left subtotals, n+1 levels, column order defines the hierarchy.
- `GROUP BY CUBE(a, b, c)` == every combination of subtotals, 2ⁿ levels, column order irrelevant to which subtotals appear.
- `GROUP BY GROUPING SETS(...)` == a UNION of arbitrary GROUP BYs you specify explicitly; no grand total unless you add an empty set.
- `GROUPING(column)` distinguishes a rolled-up NULL (returns nonzero) from a genuine data NULL (returns 0) — safer than COALESCE for labeling subtotal rows.
- A column can be "promoted" out of ROLLUP/CUBE into a plain GROUP BY column to fix it as an outer grouping level and drop the grand total.
- MySQL and Access don't support CUBE or GROUPING SETS; MySQL's ROLLUP uses non-standard syntax.
