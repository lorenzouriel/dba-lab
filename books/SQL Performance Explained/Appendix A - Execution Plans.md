# Appendix A: Execution Plans

A per-database reference for the one skill every chapter of this book leans
on: getting an execution plan, and — critically — telling an **access
predicate** (narrows the scanned index range) apart from a **filter
predicate** (applied while walking the leaf chain / after fetching the row,
doesn't narrow anything). That distinction is the difference between "uses
an index" and "uses an index well" — see Chapter 1–3.

## Oracle Database

**Getting a plan** — two-step, because `EXPLAIN PLAN` only *saves* the plan;
you still have to render it:

```sql
EXPLAIN PLAN FOR SELECT * FROM dual;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```

> `EXPLAIN PLAN FOR` doesn't guarantee the same plan the statement would get
> if actually executed (bind variable peeking, etc. — see Chapter 2). Prefer
> capturing the real plan of an executed statement where possible
> (`DBMS_XPLAN.DISPLAY_CURSOR`).

**Key operations**: `INDEX UNIQUE SCAN` (tree traversal only) / `INDEX RANGE
SCAN` (+ leaf chain walk) / `INDEX FULL SCAN` (whole index, in order) /
`INDEX FAST FULL SCAN` (whole index, disk order, for index-only scans) /
`TABLE ACCESS BY INDEX ROWID` / `TABLE ACCESS FULL`. Joins: `NESTED LOOPS
JOIN` / `HASH JOIN` / `MERGE JOIN`. Sort/group: `SORT ORDER BY` (materializes)
vs `SORT GROUP BY NOSORT` (pipelined, no actual sort despite the name). Top-N:
`COUNT STOPKEY` / `WINDOW NOSORT STOPKEY` (early termination markers).

**Access vs. filter**: look at the `Predicate Information` block below the
plan, keyed by operation `Id`:

```
2 - access("SECTION"="A" AND "ID2"=:B)
      filter("ID2"=:B)
```

> **Oracle's quirk**: a condition can appear in *both* the `access` and
> `filter` lines for the same operation. If it shows up as `filter` at all,
> treat it as a filter predicate — it does not narrow the scanned range,
> regardless of also being listed under `access`.

## PostgreSQL

**Getting a plan** — `EXPLAIN` in front of the statement, but bind-parameter
queries need `PREPARE`/`EXPLAIN EXECUTE` first:

```sql
PREPARE stmt(int) AS SELECT $1;
EXPLAIN EXECUTE stmt(1);
DEALLOCATE stmt;
```

`EXPLAIN ANALYZE` actually **executes** the statement (to capture real
timing/row counts) — wrap DML in a transaction and roll back if you don't
want side effects:

```sql
BEGIN;
EXPLAIN ANALYZE EXECUTE stmt(1);
ROLLBACK;
```

**Key operations**: `Seq Scan` (full scan) / `Index Scan` (traversal + leaf
walk **+ table fetch, all in one operation** — unlike Oracle, there's no
separate table-access step shown) / `Index Only Scan` (9.2+) / `Bitmap Index
Scan`+`Bitmap Heap Scan` (build an in-memory bitmap from the index, then
visit table rows in physical order). Joins: `Nested Loops` / `Hash Join` /
`Merge Join`. Sort/group: `Sort` vs `GroupAggregate` (pipelined) vs
`HashAggregate` (not pipelined). Top-N: `Limit`; `WindowAgg` — but note
PostgreSQL **cannot** pipeline a top-N query that goes through a window
function (unlike Oracle/SQL Server).

**Access vs. filter** — this is the sharp edge in PostgreSQL: both access and
index-filter predicates are shown identically as `Index Cond`. There is no
built-in way to tell them apart from the plan text alone.

```
Index Cond: (scale_data.section = 1)
Filter: (scale_data.id2 = ($1))
```

> `Filter` in a PostgreSQL plan is **always a table-level filter** — even
> when it's attached to an `Index Scan` node, because PostgreSQL folds the
> table fetch into the `Index Scan` operation itself. To find an *index*
> filter predicate (one applied during the leaf walk, before the table
> fetch), you have to cross-reference the `Index Cond` list against the
> actual index column order yourself — the plan alone doesn't say which
> `Index Cond` entries are access vs. filter.

## SQL Server

**Getting a plan** — graphical (Management Studio, but predicate detail only
shows on mouse-hover, hard to share) or tabular (`SET STATISTICS PROFILE
ON`, easy to copy/paste in full):

```sql
SET STATISTICS PROFILE ON;
SELECT COUNT(*) FROM employees;
SET STATISTICS PROFILE OFF;
```

**Key operations**: SQL Server's naming is `Seek` (uses the B-tree, narrow)
vs `Scan` (reads everything) — `Index Seek`/`Clustered Index Seek` vs `Index
Scan`/`Clustered Index Scan`. `Key Lookup` (fetch by clustering key, IOT
equivalent) / `RID Lookup` (fetch by physical row ID, heap table
equivalent) / `Table Scan`. Joins: `Nested Loops` / `Hash Match` / `Merge
Join`. Sort/group: `Sort` / `Sort (Top N Sort)` / `Stream Aggregate`
(pipelined) / `Hash Match (Aggregate)` (not pipelined). Top-N: `Top`.

**Access vs. filter**: SQL Server explicitly labels both in the tabular plan
text:

```
Index Seek(..., SEEK: ([section]=[@sec]) ORDERED FORWARD
                 WHERE: ([id2]=[@id2]))
```

> `SEEK:` = access predicate. `WHERE:` = filter predicate. In the graphical
> plan, both live inside the same hover tooltip, unlabeled beyond "Seek
> Predicates" vs plain "Predicate".

## MySQL

**Getting a plan** — plain `EXPLAIN` in front of the statement. All the
signal is packed into the `type`, `key_len`, and `Extra` columns.

> MySQL's plan gives a false sense of security: it happily reports an index
> is "used" (`type`/`key` populated) without indicating whether it's used
> *well* — an index scan touching the whole table still shows up as "using
> an index."

**Key operations** (in the `type` column): `eq_ref`/`const` (unique lookup,
≈`INDEX UNIQUE SCAN`) / `ref`/`range` (≈`INDEX RANGE SCAN`) / `index` (full
index scan) / `ALL` (full table scan). `Using index` in `Extra` = index-only
scan — except a clustered primary index (InnoDB) never shows this label even
though it technically is one. Sort: `Using filesort` in `Extra` = an
explicit, non-pipelined sort happened (regardless of whether it spilled to
disk).

**Access vs. filter** — reconstructed indirectly from `key_len`, plus (5.6+)
an explicit `Using index condition` marker:

```
type=ref  key=demo_idx  key_len=12  Extra=(empty)              -- 2 columns as access predicate
type=ref  key=demo_idx  key_len=6   Extra=Using index condition -- 1 column access, rest index filter (5.6+)
type=ref  key=demo_idx  key_len=6   Extra=Using where            -- (pre-5.6) table-level filter instead
```

> `key_len` tells you **how many leading index columns** were used as access
> predicates — you have to know each column's on-disk width (from the docs)
> to map the byte count back to column count. `Using index condition` (5.6+)
> flags an index filter predicate; its absence with a shorter `key_len` than
> the full index (pre-5.6, or without that marker) means the remaining
> condition fell through to a **table-level** filter (`Using where`) instead
> of being checked during the index scan.
