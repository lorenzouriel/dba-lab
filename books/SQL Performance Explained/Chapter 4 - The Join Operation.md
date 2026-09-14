# Chapter 4: The Join Operation

A join denormalizes data back into the shape a specific query needs. It's
especially sensitive to disk-seek latency because it stitches together
scattered fragments from two tables — and the *right* index depends entirely
on which of the three join algorithms the optimizer picks.

Every join algorithm processes exactly **two** tables at a time — a query
joining N tables is executed as N-1 pairwise joins in some order. Join order
doesn't affect the result, but it affects performance, and evaluating every
permutation is `n!` — another reason bind parameters matter more as queries
get more complex (re-optimizing a many-table join on every call is
expensive).

> Databases pipeline intermediate join results row-by-row into the next join
> step rather than materializing them — so "intermediate result set" is a
> conceptual model, not literally a temp table the engine builds.

## Nested Loops

The simplest algorithm: for each row from a **driving** (outer) query, run a
second lookup against the other table. Structurally identical to writing the
join yourself as nested queries — which is exactly what naive ORM code
generates by accident (fetch parent rows, then loop and fetch children one
at a time).

> This is the infamous **N+1 selects problem**: N rows from the driving
> query → N+1 total statements. Every major ORM (Hibernate/JPA, Doctrine,
> DBIx::Class, …) can produce it silently under default "lazy loading"
> settings — turn on SQL logging during development to catch it.

A real `JOIN` executes the *same* index lookups as the N+1 pattern, but
avoids paying network latency N times, and it's not just about
transferred-bytes: response time is dominated by **round trips (latency)**,
not the volume of data moved (**bandwidth**) — so a single joined query beats
N+1 round trips even when the join sends more total bytes.

> **Execute joins in the database — don't emulate them in application code.**

Indexing for a nested-loops join mirrors indexing the equivalent
nested-select: an index to drive the outer lookup, plus a concatenated
index on the inner table's join columns:

```sql
CREATE INDEX emp_up_name ON employees (UPPER(last_name));  -- drives outer scan
CREATE INDEX sales_emp ON sales (subsidiary_id, employee_id);  -- inner join lookup
```

Execution plan shape: `NESTED LOOPS [OUTER]` with one branch doing the
driving table access, the other repeating a `TABLE ACCESS BY INDEX ROWID` +
`INDEX RANGE SCAN` per row.

Nested loops wins when the driving result set is small — each outer row
costs one more B-tree traversal. As the driving set grows, the optimizer
tends to switch to a hash join instead — but *only if the query is phrased
as an actual join*, so the database can see and choose that alternative in
the first place. ORM eager-fetch settings (statically configured per
relationship) are a poor substitute for controlling this at the query level,
since the right join strategy depends on the query, not just the schema
relationship.

## Hash Join

Where nested loops repeats many small B-tree traversals, a hash join builds
an **in-memory hash table** from one side of the join (usually the smaller
one) in a single pass, then probes it once per row from the other side.

> **Indexing the join columns does nothing for a hash join** — the hash
> table itself replaces the need for a B-tree lookup on those columns.
> What *does* help: indexing the **independent** where-clause predicates —
> conditions that apply to one table only and aren't part of the join
> condition.

```sql
SELECT * FROM sales s
  JOIN employees e ON s.subsidiary_id = e.subsidiary_id AND s.employee_id = e.employee_id
 WHERE s.sale_date > TRUNC(sysdate) - INTERVAL '6' MONTH;

CREATE INDEX sales_date ON sales (sale_date);  -- the independent predicate
```

With this index, `EMPLOYEES` (no independent predicate) is still a
`TABLE ACCESS FULL` feeding the hash table, while `SALES` uses the index to
avoid scanning rows outside the 6-month window before probing the hash
table.

Unlike nested loops, hash-join indexing is **symmetric** — doesn't matter
which side of the join you call "driving," the same independent-predicate
indexes help regardless of join order.

Two more hash-join-specific levers, since a hash join is only efficient while
the whole hash table fits in memory:

1. **Shrink the candidate row count** — add filters that reduce which rows
   go into the hash table (with matching integrity constraints backing the
   assumption, e.g. "sales staff only ever appear in `sales`").
2. **Select fewer columns** — the hash table's memory footprint is driven by
   row *width*, not just row count. Trimming unused columns from the select
   list can shrink a hash table by 90%+ with no index changes at all. This
   is easy in hand-written SQL, hard in most ORMs (lazy/partial-object
   loading exists but is inconsistent and easy to defeat accidentally).

> MySQL historically had no hash join implementation at all — nested loops
> only (this changed in later 8.0.18+ releases, after the book's original
> writing).

## Sort Merge

Zips two inputs that are **already sorted on the join key**, walking both in
lockstep — no hash table, no per-row B-tree probe.

- Needs the same indexing as a hash join (index independent predicates, not
  join columns) — indexing the join columns doesn't help a sort-merge join
  either.
- Fully **symmetric**, more so than a hash join: join order truly doesn't
  matter, including for outer joins — it's the only algorithm that can
  execute a full outer join (left + right simultaneously) as a single pass.
- Sorting both sides from scratch is expensive enough that it's rarely
  chosen over a hash join *unless* one or both inputs are already sorted —
  typically because an index already stores the data in join-key order,
  letting the database skip the sort. That connection between index order
  and avoiding explicit sorts is the subject of Chapter 6.
