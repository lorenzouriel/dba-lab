# Chapter 6: Sorting and Grouping

## The Third Power of Indexing

Sorting is expensive: it needs real CPU work, and — critically — it can't
start emitting output until it has consumed *all* of its input. That means a
sort operation can never be pipelined, which matters a lot for anything that
only wants the first few rows (Chapter 7).

An index is, by construction, a pre-sorted representation of its columns
(Chapter 1). So if the index that already serves the where clause happens to
be sorted the way `ORDER BY` wants, the database can walk the leaf chain in
that order and **skip the sort step entirely.**

> A pipelined `ORDER BY` doesn't just save sort CPU/memory — it lets the
> database return the *first* row before reading all the input. This is
> the **third power of indexing**, and it's the mechanism Chapter 7's
> pagination techniques depend on.

Trade-off to watch: an `INDEX RANGE SCAN` avoiding a sort can still lose to a
`FULL TABLE SCAN + explicit sort` once the scanned range gets large enough —
same "wide range scan + many table accesses" cost from Chapter 1 can
outweigh the saved sort. It's still the optimizer's call based on cost.

## Indexing Order By

The rule: the index must cover the `WHERE` clause *and* be sorted according
to the `ORDER BY` clause, and both must hold over the **same scanned
range**.

```sql
SELECT sale_date, product_id, quantity FROM sales
 WHERE sale_date = TRUNC(sysdate) - INTERVAL '1' DAY
 ORDER BY sale_date, product_id;

CREATE INDEX sales_dt_pr ON sales (sale_date, product_id);
```

With this index, the `SORT ORDER BY` operation disappears from the plan —
the `INDEX RANGE SCAN` already delivers rows in the right order.

> If the index order matches the `ORDER BY` **within the scanned range**,
> the explicit sort operation can be omitted.

Subtlety: it's enough for the order to hold *within the scanned range*, not
globally. `ORDER BY product_id` alone still avoids a sort when the where
clause pins `sale_date` to a single value — because within that single-date
slice, `product_id` is the only variation, so the index is trivially sorted
by it. Widen the where clause to `sale_date >= yesterday` (spanning several
days) and that guarantee breaks: `product_id` order resets at each date
boundary, so the database must fall back to an explicit sort.

> **Two different reasons an expected pipelined sort doesn't happen:** (1)
> the optimizer's cost model genuinely prefers the sort-based plan, or (2)
> the index order doesn't actually match the order-by within the scanned
> range. To tell them apart, temporarily rewrite the `ORDER BY` to match the
> *full* index definition exactly — if the sort still appears, it's (1); if
> it disappears, the original query hit (2).

Extending an index purely to support `ORDER BY` will typically *worsen* its
clustering factor (see Chapter 5) — adding a sort column ahead of the
implicit row-order tiebreaker gives the database less freedom to align index
order with table order. That can look like a cost increase in the plan even
as the operation count drops; whether it's a net win depends on whether
rows for the same key are still roughly co-located physically (day-grouped
sales usually still are).

## Indexing ASC, DESC and NULLS FIRST/LAST

The leaf-node doubly-linked list (Chapter 1) can be walked in **either
direction**, so `ORDER BY col DESC` alone doesn't force a sort — the
database just reads the index backwards.

Mixed directions are the actual problem: `ORDER BY sale_date ASC, product_id
DESC` can't be satisfied by an index sorted `(sale_date ASC, product_id
ASC)` — walking forward through dates would require "jumping" backward
within each date's product_id run, which the leaf chain doesn't support in
either single direction.

Fix: define the index with matching per-column direction:

```sql
CREATE INDEX sales_dt_pr ON sales (sale_date ASC, product_id DESC);
```

> Only *mixed* ASC/DESC in the `ORDER BY` requires matching modifiers in the
> index definition — a uniformly-reversed order-by is still satisfiable by
> reading the same index backwards. This doesn't affect the index's
> usability for the `WHERE` clause at all — direction is irrelevant there.

`NULLS FIRST`/`NULLS LAST` (SQL:2003) get inconsistent support across
databases for indexing purposes specifically — check your database's
matrix before relying on it (as of the book's writing: only PostgreSQL
supported `NULLS FIRST/LAST` in both the `ORDER BY` and the index
definition; Oracle supports it in `ORDER BY` but not the index; MySQL/SQL
Server didn't support the modifier at all at the time).

## Indexing Group By

Two algorithms for `GROUP BY`:

1. **Hash**: build an in-memory hash table keyed by the group-by columns,
   aggregate as rows arrive. Needs to buffer only the *aggregated* result —
   memory scales with distinct group count, not input row count.
2. **Sort/group**: sort input by the grouping key first, then walk it
   linearly aggregating each run. Needs to materialize the *entire sorted
   input* — unless that sort is free because an index already provides it.

Only the sort/group algorithm can become pipelined, by the same mechanism as
`ORDER BY` — if the index already delivers rows sorted by the grouping key
within the scanned range, the sort disappears:

```sql
SELECT product_id, sum(eur_value) FROM sales
 WHERE sale_date = TRUNC(sysdate) - INTERVAL '1' DAY
 GROUP BY product_id;
```

Oracle marks this in the plan as `SORT GROUP BY NOSORT` — same operation
name, but the "NOSORT" qualifier signals no actual sort happens underneath.

Same prerequisite as `ORDER BY` (index order matches within the scanned
range), but **`ASC`/`DESC` and `NULLS FIRST/LAST` don't matter for grouping**
— a group doesn't care what order its members arrive in, only that they're
contiguous. (Some databases still have quirks here — e.g. PostgreSQL needs
an explicit `ORDER BY` alongside a `NULLS LAST` index to get the pipelined
group-by benefit.)

Widen the where clause past a single day again, and the optimizer falls back
to the hash algorithm rather than sort/group + explicit sort — because hash
only needs to buffer the (smaller) aggregated output, not the full sorted
input, making it the cheaper non-pipelined option once the free sort is
gone.

> The point of a pipelined `GROUP BY`/`ORDER BY` usually isn't raw speed —
> it's that the database can start emitting rows before consuming all the
> input. That property is what Chapter 7's "partial results" optimizations
> are built on.
