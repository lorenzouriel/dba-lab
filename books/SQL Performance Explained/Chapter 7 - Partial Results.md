# Chapter 7: Partial Results

Building on the pipelined `ORDER BY`/`GROUP BY` from Chapter 6: if you only
need the first N rows (recent messages, a paginated list), the database can
in principle stop reading as soon as it has enough — but only if it *knows*
that up front.

> **The optimizer can only exploit a partial result if the query tells it so
> from the start** — it cannot foresee that the application will just stop
> fetching after N rows and choose a plan accordingly. That's the entire
> reason `LIMIT`/`FETCH FIRST`/`TOP`/`ROWNUM` exist as syntax rather than
> "just fetch fewer rows and disconnect."

## Querying Top-N Rows

```sql
-- MySQL / PostgreSQL
SELECT * FROM sales ORDER BY sale_date DESC LIMIT 10;

-- SQL:2008 standard (PostgreSQL 8.4+, SQL Server 2012+, Oracle 12c+, DB2)
SELECT * FROM sales ORDER BY sale_date DESC FETCH FIRST 10 ROWS ONLY;

-- SQL Server proprietary
SELECT TOP 10 * FROM sales ORDER BY sale_date DESC;

-- Oracle pre-12c: wrap in ROWNUM (a pseudo-column, numbered per row emitted)
SELECT * FROM (SELECT * FROM sales ORDER BY sale_date DESC) WHERE rownum <= 10;
```

Every database recognizes this syntax and marks the plan accordingly (Oracle:
`COUNT STOPKEY`) — but the syntax alone doesn't guarantee efficiency. The
underlying `ORDER BY` still needs to be **pipelined** (Chapter 6) for the
early-termination to actually pay off:

- **With** a covering, correctly-ordered index: `INDEX [FULL/RANGE] SCAN
  DESCENDING` feeds rows straight out, execution stops the instant 10 rows
  are emitted. Response time depends on **rows selected**, not table size —
  the whole point of the third power of indexing.
- **Without** one: `SORT ORDER BY STOPKEY` still avoids materializing more
  than 10 rows in memory (better than nothing), but must read and sort the
  *entire* table before it can emit even the first row — response time
  scales with table size, no better than the naive "fetch everything, stop
  early on the client" approach.

> A pipelined top-N query's response time is nearly *independent of table
> size* — only B-tree depth (log-scale) affects it. A non-pipelined top-N
> query's response time grows *linearly* with table size, same shape as any
> unindexed full scan.

## Paging Through Results

Getting page 1 fast is only half the problem — you also need page 2, 3, …
Two fundamentally different strategies:

### Offset method

```sql
SELECT * FROM sales ORDER BY sale_date DESC OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;
-- or LIMIT 10 OFFSET 10 (MySQL/PostgreSQL)
```

Simple, standardized, widely supported — but the database must still **walk
and discard every row before the offset** on each call. Two real downsides,
not just theoretical ones:

1. **Response time grows with page depth** — page 50 re-walks (and drops)
   the first 490 rows every single time.
2. **Pages drift under concurrent writes** — row *position* is recomputed
   from scratch on each query, so an insert between two page loads can shift
   which rows land on which page (duplicates or skips).

### Seek method ("keyset pagination")

Instead of counting rows to skip, remember the *last row's key values* from
the previous page and filter for "whatever comes after that":

```sql
SELECT * FROM sales
 WHERE sale_date < ?          -- last seen sale_date
 ORDER BY sale_date DESC
 FETCH FIRST 10 ROWS ONLY;
```

This turns the "skip" into a genuine **access predicate** — the database
jumps straight to the right spot in the index instead of scanning and
discarding. Immune to insert-drift, and response time stays flat regardless
of page depth (visible from roughly page 20 onward in the book's benchmark;
negligible before that).

Breaks the moment the sort key isn't unique (multiple sales on the same
date): `sale_date < last_seen_date` would skip *every* row from that date,
not just the ones already shown.

> **Paging requires a deterministic sort order.** `ORDER BY sale_date DESC`
> alone doesn't guarantee a stable row sequence when dates repeat — the
> database is free to return ties in any order (and increasingly does, with
> parallel query execution). Extend the `ORDER BY` (and the backing index)
> with a unique tiebreaker column, typically the primary key.

With a compound key, the correct seek condition is really a **row
comparison** ("come after this whole tuple"), expressible via SQL row
values where supported:

```sql
CREATE INDEX sl_dtid ON sales (sale_date, sale_id);

SELECT * FROM sales
 WHERE (sale_date, sale_id) < (?, ?)
 ORDER BY sale_date DESC, sale_id DESC
 FETCH FIRST 10 ROWS ONLY;
```

Support for this syntax is spotty (book-era: PostgreSQL supported it fully
including index access; Oracle accepted the syntax but not as a range
operator; MySQL evaluated it but couldn't use it as an access predicate; SQL
Server didn't support it at all) — the portable fallback decomposes the same
logic into an OR of scalar comparisons, **plus a redundant leading condition**
so at least one branch is usable as an access predicate:

```sql
WHERE sale_date <= ?                          -- redundant, but indexable
  AND NOT (sale_date = ? AND sale_id >= ?)    -- the real "already shown" exclusion
```

> Databases don't factor common terms out of `OR` branches for you — writing
> the "obviously equivalent," purely-disjunctive version of this condition
> (no redundant leading clause) leaves the optimizer with *no* access
> predicate at all, just a filter over everything.

Net trade-off: seek pagination is strictly better performance, but loses
the ability to jump to an arbitrary page number or flip direction without
re-deriving the comparison logic — a real cost for traditional numbered
pagination UI, a non-issue for "infinite scroll" (which only ever asks for
"the next page" anyway).

## Using Window Functions for Pagination

`ROW_NUMBER() OVER (...)` gives a standards-compliant alternative:

```sql
SELECT * FROM (
  SELECT sales.*, ROW_NUMBER() OVER (ORDER BY sale_date DESC, sale_id DESC) rn
    FROM sales
) tmp
WHERE rn BETWEEN 11 AND 20
ORDER BY sale_date DESC, sale_id DESC;
```

Whether this is efficient depends entirely on whether the database can push
the `rn <= 20` cutoff down into the windowing operation *and* recognize the
underlying order as already indexed (Oracle: `WINDOW NOSORT STOPKEY` — both
optimizations firing together). Support is uneven: at book-writing time,
Oracle and SQL Server could execute this as a genuine pipelined,
early-terminating scan; PostgreSQL computed the full window before applying
the filter (no early termination); MySQL had no window functions at all.
(Note: MySQL 8.0+ added window function support after this book's original
edition.)

> Window functions are far more valuable for analytical calculations
> (running totals, ranking, lead/lag) than as a pagination mechanism — worth
> learning for that reason even where pagination isn't the driver.
