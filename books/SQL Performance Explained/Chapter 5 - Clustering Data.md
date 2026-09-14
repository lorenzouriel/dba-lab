# Chapter 5: Clustering Data

## The Second Power of Indexing

*Clustering* here means storing consecutively-accessed data physically close
together, so retrieving it costs fewer I/O operations — not a computer
cluster. An index's leaf nodes are already an ordered list of similar values
sitting next to each other, which means **an index is itself a tool for
clustering rows**, independent of the physical table order. That capability
— the "second power of indexing" (the first was fast tree traversal, from
Chapter 1) — is what this chapter is about.

## Index Filter Predicates Used Intentionally

Not every filter predicate is a sign of a badly-ordered index. Sometimes it's
a deliberate, useful trade-off: add a column to an index purely so its filter
runs *during* the index scan, before the table access, rather than after —
even if it can never serve as an access predicate.

```sql
SELECT first_name, last_name, subsidiary_id, phone_number
  FROM employees
 WHERE subsidiary_id = ? AND UPPER(last_name) LIKE '%INA%';
```

A leading-wildcard `LIKE` can never narrow the scanned index range — no
index change fixes that. But `subsidiary_id` narrows it fine. Extending the
existing index to also carry the `LIKE` expression:

```sql
CREATE INDEX empsubupnam ON employees (subsidiary_id, UPPER(last_name));
```

...makes the `LIKE` a **filter predicate applied during the index scan**
instead of after fetching the row. The optimizer estimate might go from
"333 rows scanned, 17 kept after table access" down to "17 rows scanned,
17 table accesses" — the same operations in the plan, but the table access
count (usually the dominant cost) drops to match the true result size.

> Extend an *existing* index for this purpose rather than creating a new
> one — keep write-side maintenance cost down.

This doesn't mean "index every where-clause column" — column *order* still
governs what can be an access predicate, and every added column grows the
index and its maintenance cost. Only add a column as a filter predicate when
it meaningfully reduces rows reaching the table access.

### The Index Clustering Factor

Whether a table access after an index scan is cheap or expensive depends on
the **clustering factor**: how well the physical row order in the table
correlates with the index's logical order. Well-clustered rows for a given
scan land in a handful of table blocks (cheap); poorly-clustered rows are
scattered one-per-block (expensive) — this is a statistic the optimizer
actually tracks and costs into `TABLE ACCESS BY INDEX ROWID`.

Reordering the physical table to match one particular index ("row
sequencing") is possible in principle but rarely practical — you can only
optimize physical order for *one* index, tooling support is thin, and it
doesn't survive future writes without maintenance. The clustering-factor
problem is instead usually solved the other way: don't rely on physical
order — pull the needed data into the index itself (below), or exploit a
column that's *naturally* well-clustered already (an append-only date column
in an insert-only table, for instance — see the sale_date example below).

## Index-Only Scan

The strongest form of clustering: if the index carries **every column the
query needs** — not just the where-clause columns, but the select-list
columns too — the database never touches the table at all.

```sql
CREATE INDEX sales_sub_eur ON sales (subsidiary_id, eur_value);

SELECT SUM(eur_value) FROM sales WHERE subsidiary_id = ?;
```

Plan shows only `INDEX RANGE SCAN` — no `TABLE ACCESS BY INDEX ROWID` at
all. This is called an **index-only scan**, and the index enabling it is
called a *covering index* (a property of the query, not the index itself —
the same index might not cover a different query).

> The benefit scales with **row count** avoided (thousands of table fetches
> saved) and inversely with how good the clustering factor already was — if
> the rows were already tightly clustered, the table access wasn't expensive
> to begin with, so an index-only scan buys little.

Two sharp edges:

1. **Adding a where-clause column not in the index kills the index-only
   scan** even if it makes the result *smaller* — because "fewer rows
   returned" isn't the same as "fewer rows the database had to fetch to
   check." The optimizer may fall back to a different index entirely if
   that one happens to have a better clustering factor (e.g. a
   chronologically-appended `sale_date` column that's naturally well
   clustered because new rows are always appended at the end).
2. **A function-based index doesn't cover a select on the raw column.** An
   index on `UPPER(last_name)` can't serve `SELECT last_name` — only
   `UPPER(last_name)` itself is stored. Prefer indexing the raw column when
   both the filter and the select-list need it.

> Don't design for an index-only scan speculatively — it costs storage and
> write-time maintenance (Chapter 8). Index for the where clause first;
> extend only if profiling shows it's worth it. And select only the columns
> you actually need (`SELECT *` defeats this optimization outright, and
> widens every covering index that would otherwise be small).

Every database caps index key size/column count (MySQL ~767B/col, 3072B
total for InnoDB; Oracle up to 32 cols, ~6398B; PostgreSQL 2713B, 32 cols) —
you can't index-only-scan your way around arbitrarily wide rows. SQL Server
partially escapes this with `INCLUDE(...)` **nonkey columns**: stored in the
leaf nodes for index-only-scan purposes, unlimited length, but never usable
as access predicates.

## Index-Organized Tables

Taking index-only scans to their logical extreme: if the index already
carries every column, why keep a separate heap table at all? Some databases
let the **index itself be the primary storage** — Oracle calls this an
Index-Organized Table (IOT); SQL Server/MySQL(InnoDB) call it a **clustered
index**. Every access to it is automatically an index-only scan, and the
heap table's storage overhead disappears.

The catch shows up the moment you add a **second** (secondary) index. A
secondary index on a heap table stores a physical `ROWID` — a direct
pointer. A secondary index on a clustered table *can't* do that, because
rows inside a clustered index move around (leaf-node splits, rebalancing) —
there's no stable physical address to point to. So a secondary index instead
stores the **clustering key** (typically the primary key) and must perform a
*second* full tree traversal to resolve it:

```
Heap table:    INDEX RANGE SCAN → TABLE ACCESS BY INDEX ROWID   (1 extra step)
Clustered:     INDEX RANGE SCAN → INDEX UNIQUE SCAN on the clustered index  (also 1 extra step, but a full tree traversal each time, not a single block read)
```

> Accessing an index-organized/clustered table through a *secondary* index
> is inherently less efficient than the equivalent heap-table lookup — you
> traded a cheap direct-pointer fetch for a second B-tree traversal.

The same index-only-scan trick still helps here: a secondary index carries
a copy of the clustering key, so a query that only needs the clustering key
(or columns already in that secondary index) can skip the clustered-index
traversal entirely — same principle as Chapter 5's index-only scan, applied
one level down.

Net guidance:

> **Tables with only one index** (i.e. the primary key) benefit from being
> clustered/IOT — every access is already an index-only scan.
> **Tables with multiple indexes** usually do better as heap tables, using
> regular index-only scans selectively where they help — this avoids
> making every *other* index pay the clustering-key-instead-of-ROWID tax.

Per-database defaults vary a lot and are easy to get wrong by accident:

| Database | Default | Notes |
|---|---|---|
| Oracle | Heap table | Opt in via `ORGANIZATION INDEX`; clustering key is always the PK |
| PostgreSQL | Heap table only | No true IOT; `CLUSTER` can physically reorder a heap once, but doesn't maintain it |
| MySQL | Heap (MyISAM) / clustered (InnoDB) | Not a per-table choice — determined by storage engine |
| SQL Server | **Clustered by default** | PK is the clustering key unless you declare `NONCLUSTERED`; this default silently taxes every secondary index unless you're deliberate about it |
