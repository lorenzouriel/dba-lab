# Part 3: Working with Multiple Tables

Parts 1-2 covered getting answers out of a single table (SELECT, expressions, WHERE). Part 3 is about combining and relating *multiple* tables/result sets — the actual bread and butter of any normalized database, since Ch.2's design rules guarantee your data will be spread across many tables.

The arc of this Part:

1. **Ch.7 - Thinking in Sets**: the math underneath it all. Intersection, difference, union — and their would-be SQL keywords `INTERSECT`, `EXCEPT`, `UNION`. Pure set operations require matching on *every* column, which barely works for real tables.
2. **Ch.8 - INNER JOINs**: the practical fix for INTERSECT's all-columns limitation — match on just the columns you specify (usually a PK/FK pair). Returns only rows with a match on both sides.
3. **Ch.9 - OUTER JOINs**: the practical fix for EXCEPT — LEFT/RIGHT/FULL OUTER JOIN keep the *unmatched* rows too (NULL-padded), which combined with `IS NULL` reproduces set difference.
4. **Ch.10 - UNIONs**: the one pure set operation that's actually well-supported everywhere — stacking similarly-shaped result sets into one, with dedup rules and column-compatibility requirements.
5. **Ch.11 - Subqueries**: an alternative to JOINs for a whole class of problems (esp. the "both A and B" / intersection-style ones Ch.8 solved clunkily with derived-table JOINs) — often reads cleaner and can be more efficient.

🤯 The throughline: JOIN and subqueries aren't a separate topic from set theory — they're just how commercial SQL lets you express intersection/difference on a *subset* of columns, because the "pure" `INTERSECT`/`EXCEPT` keywords were historically under-supported (and even where supported, JOIN/subquery forms are often more natural or better-optimized).

✨ **Side learning:** the book uses five running example databases throughout (Sales Orders, Entertainment Agency, School Scheduling, Bowling League, Recipes) — the same schemas resurface chapter to chapter, so a JOIN example in Ch.8 and its OUTER JOIN counterpart in Ch.9 are often the exact same tables, just with the matching rules loosened.
