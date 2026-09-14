# Part 4: Summarizing and Grouping Data

Up through Part 3, every technique (SELECT, JOIN, subquery, WHERE) answers questions about *individual rows*. Part 4 is a mental gear shift: instead of "which rows," the question becomes "what single number (or number per bucket) summarizes these rows."

## The pipeline: WHERE -> GROUP BY -> HAVING

1. `WHERE` filters rows, one at a time, before anything is aggregated.
2. Aggregate functions (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) collapse a set of rows into one value — with no `GROUP BY`, the "set" is everything WHERE let through.
3. `GROUP BY` splits that set into buckets by matching column values, so aggregates run once per bucket instead of once overall.
4. `HAVING` filters buckets, using the aggregate values computed in step 3 — it exists only because `WHERE` runs too early to see them.

## Why this needs a different mental model

Row-filtering logic (`WHERE`) is about individual records and can be reasoned about one row at a time. Aggregate logic is about a whole set collapsing to fewer rows, so the rules change: unaggregated columns become illegal to reference unless they're doing double duty as the grouping key, and a "row-level" filter applied in the wrong place (before grouping) can silently delete entire groups instead of reporting them as zero — the recurring trap covered in Chapter 14.

1. Chapter 12 — aggregate functions in isolation, no grouping.
2. Chapter 13 — GROUP BY, and its restriction that every SELECT-list column must be grouped or aggregated.
3. Chapter 14 — HAVING, and when to filter in WHERE instead for performance.
