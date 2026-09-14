# Chapter 8: Modifying Data

Every previous chapter treated indexes as pure upside. This one is the
counterweight: **an index is redundant data that must be kept consistent on
every write.** `INSERT`/`UPDATE`/`DELETE` all pay for that redundancy —
this chapter is about how much, and where the cost is concentrated.

## Insert

`INSERT` has no `WHERE` clause, so it's the one DML statement that can never
*benefit* from an index — only pay for the ones that exist.

> **The number of indexes on a table is the dominant factor in insert cost.**
> Writing the row into the (unordered) heap is cheap and fast — the database
> just needs any block with free space. Writing the corresponding entries
> into *each* index is what's expensive, because each one requires:
>
> 1. A full B-tree traversal to find the correct leaf node (can't just drop
>    the entry anywhere — order must be preserved).
> 2. A possible **leaf-node split** if that node is full, which propagates
>    upward — potentially splitting branch nodes all the way to the root
>    (the only case where the tree grows a level).

The empirical shape of this (per the book's benchmark): going from 0 indexes
to 1 index increases insert time by roughly **100x** — the first index makes
the single biggest difference; each additional index adds cost more
gradually after that.

> Keep the index count deliberate and minimal — every index you don't
> actually need for a query is pure insert/update/delete tax with zero
> upside.

Consequence in practice: bulk data loads (data warehouse ETL, initial
seeding) often **drop indexes, load, then rebuild them** — rebuilding a
B-tree from sorted bulk data is far cheaper than maintaining it entry-by-
entry during the load.

## Delete

Unlike `INSERT`, `DELETE` *has* a `WHERE` clause — so everything from
Chapter 2 about access predicates applies to finding the rows to delete.
Once found, removing a row costs about the same as inserting one did (same
tree-rebalancing concerns, now in reverse — potentially merging
under-full nodes instead of splitting full ones).

> **Even `DELETE` and `UPDATE` statements have an execution plan** — check
> it the same way you would a `SELECT`, especially the access-vs-filter
> predicate distinction from Chapter 2/3.

A `DELETE` with no usable index for its `WHERE` clause still has to find its
target rows via a full scan first — same trade-off as an unindexed
`SELECT`, sometimes genuinely the right call for a large fraction of the
table. A `DELETE` with **no `WHERE` clause at all** is better served by
`TRUNCATE TABLE` (same end state, single operation) — but note two side
effects: it implicitly commits in most databases (PostgreSQL and SQL Server
are exceptions), and it skips triggers.

> **MVCC implementation details can decouple delete cost from index count
> entirely.** PostgreSQL, for example, marks rows "deleted" at the table
> level only at delete time — physical row removal and index cleanup are
> deferred to `VACUUM`. So on PostgreSQL specifically, `DELETE` performance
> doesn't scale with index count the way `INSERT`/`UPDATE` do; the real cost
> shows up later, during vacuum.

## Update

An `UPDATE` that changes an indexed column is really a delete-then-insert
for that index entry (old value removed, new value placed at its correct
sorted position) — so its cost is roughly the sum of delete + insert costs
for every *affected* index.

Critical nuance: **an update only touches the indexes covering the columns
it actually changes** — a single-column update leaves every other index
untouched, unlike insert/delete which always touch all indexes.

> Only update the columns that actually changed. Hand-written SQL usually
> gets this right by default; some ORMs (older Hibernate without
> `dynamic-update`) generate blanket "set every column" updates regardless
> of what changed, quietly turning a cheap single-index update into a
> full-table-of-indexes update. Check generated SQL (query logging) when
> using an ORM.
