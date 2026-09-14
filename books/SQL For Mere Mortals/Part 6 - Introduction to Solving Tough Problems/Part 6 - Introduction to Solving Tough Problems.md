# Part 6: Introduction to Solving Tough Problems

Parts I-V covered the SQL Standard's building blocks (SELECT, JOINs, subqueries, GROUP BY, UPDATE/INSERT/DELETE) one at a time. This Part is different: it's a catalog of named, recurring *problem shapes* that don't have an obvious single-clause solution — and the reusable trick for solving each. Every chapter here picks a category of "this looks simple until you try to write it" request and walks through the technique(s) that actually work.

The common thread: basic SELECT/JOIN/GROUP BY answers "what matches one condition." These chapters answer harder questions — all of these conditions at once, none of these conditions, a value that depends on other values, a total compared against data it has no direct relationship to, running/moving calculations across rows a plain GROUP BY would collapse away.

## Chapters in This Part

1. **Chapter 18 - "NOT" and "AND" Problems**: queries needing "has ALL of X/Y/Z" or "has NONE of X/Y/Z" against a multi-row child set (ingredients, bookings, preferences) — the classic trap where a naive `IN`/`NOT IN` silently becomes an OR instead of an AND. Solved via OUTER JOIN + IS NULL, NOT IN/NOT EXISTS, or GROUP BY/HAVING COUNT — relational division in disguise.
2. **Chapter 19 - Condition Testing**: `CASE` as SQL's If-Then-Else for Value Expressions — decoding stored codes, guarding divide-by-zero, exact leap-year-correct date math, bucketing values into named ranges. Simple CASE (equality only) vs. Searched CASE (any predicate), and the rule that evaluation stops at the first true WHEN.
3. **Chapter 20 - Using Unlinked Data and "Driver" Tables**: solving problems by joining against a table with **no foreign-key relationship** to anything else — a calendar/sequence table invented purely to drive a query (fill date gaps, generate a running list of numbers) rather than to store real facts.
4. **Chapter 21 - Performing Complex Calculations on Groups**: getting subtotals *and* a grand total in one query, or comparing a row against an aggregate of its own group — extending GROUP BY past single flat totals.
5. **Chapter 22 - Partitioning Data into "Windows"**: window functions (`OVER`, `PARTITION BY`) — running totals, rankings, and row-to-row comparisons that need per-row detail *and* group-level context simultaneously, something GROUP BY alone can't give you because it collapses rows.

## Why These Don't Fit Earlier Parts

Every technique before this Part answered a question in one dimension — filter rows (WHERE), combine tables (JOIN), collapse rows (GROUP BY), or reshape stored data (UPDATE/INSERT/DELETE). These chapters solve problems that need **two of those at once**: matching a whole set of child rows against a condition (JOIN semantics wearing GROUP BY logic), or keeping row-level detail while also needing an aggregate view of the row's group (GROUP BY semantics without the collapsing). The tools themselves aren't new — it's compositions and non-obvious uses of JOIN, subqueries, GROUP BY, and (new in Ch. 22) window functions.

🤯 A useful frame for the whole Part: most of these "hard" problems are actually **relational division** wearing different clothes — find parents whose child rows satisfy a *whole set* of criteria, not just one. Chapters 18 and 21 attack it head-on; Chapter 20's driver tables and Chapter 22's windows solve adjacent but distinct problems (filling gaps, seeing group context per row).
