# Chapter 1: Anatomy of an Index

An index == a distinct, redundant data structure built with `CREATE INDEX`. It
has its own disk space, holds a copy of the indexed column(s), and does **not**
change the table data at all — it's a separate structure that points back to it.
Like a book's index: separate space, redundant, refers back to the real content.

A database index is made of two structures layered on top of each other:

1. A **doubly linked list** of leaf nodes (maintains logical/sort order).
2. A **B-tree** (search tree) built on top of the leaf nodes (makes lookups fast).

## The Index Leaf Nodes

The problem: you can't store index entries in physical sort order on disk,
because inserting a new entry would require shifting every entry after it —
too slow. Solution: keep *logical* order via a doubly linked list instead of
physical order.

- Each leaf node lives in one database block/page (the DB's smallest I/O unit,
  typically a few KB).
- A block holds as many index entries as fit.
- Order is maintained at two levels: entries *within* a leaf block (sorted),
  and leaf blocks *among each other* (via the linked list).
- Each index entry = indexed column value(s) + a pointer back to the table row
  (**ROWID** in Oracle, **RID** elsewhere).
- The table itself (heap) is *not* sorted — no relation between rows in the
  same block, no relation between blocks.

## The Search Tree (B-Tree)

Leaf nodes are stored in arbitrary physical order, so you still need a way to
find the right leaf block without scanning all of them — that's the B-tree
sitting on top.

- Built bottom-up: each branch node entry stores the *largest* key present in
  the child (leaf or lower branch) it points to.
- Branch layers keep stacking until everything collapses into one **root
  node**.
- Balanced: every leaf is the same distance from the root (a B-tree is
  balanced, **not** a binary tree — nodes can have far more than 2 children).

**Traversal**: at each node, scan entries in order until you find one `>=` the
search key, follow that pointer down, repeat until you hit a leaf. This is
called the *first power of indexing* — extremely fast even on huge datasets,
because of two properties compounding:

1. Balance → every lookup takes the same number of steps.
2. Logarithmic growth → tree depth grows *very* slowly relative to row count.

> Real-world indexes with millions of rows typically have a tree depth of 4-5.
> Depth 6 is rare.

### Why depth grows so slowly

Tree depth ≈ log_b(number of entries), where `b` = fanout (entries per node,
often in the hundreds). Doubling entries doesn't double depth — depth only
increases when the *current* capacity is exceeded, and capacity grows
multiplicatively with each new level:

| Tree depth | Max entries (fanout=4 example) |
|---|---|
| 3 | 64 |
| 4 | 256 |
| 5 | 1,024 |
| 10 | 1,048,576 |

Real indexes use a much higher fanout (hundreds), so the effect is even more
extreme — each additional level supports ~100x more rows, not 4x.

## Slow Indexes, Part I

**The "degenerated index" myth**: people assume a slow lookup on an indexed
column means the index is "broken" and needs a rebuild. Usually false — the
tree traversal itself is never the bottleneck. The real cost comes from the
two steps *after* traversal:

An index lookup is actually three steps, and only the first has a bounded cost:

1. **Tree traversal** — bounded by tree depth (4-5 block reads, always).
2. **Follow the leaf node chain** — if the search key isn't unique, keep
   reading forward along the linked list to catch every match. Unbounded.
3. **Table access per hit** — for every matching leaf entry, a separate fetch
   of the actual row (scattered randomly across table blocks, since the heap
   is unsorted). Unbounded, and the classic dominant cost.

> The tree traversal has an upper bound (index depth). Steps 2 and 3 don't —
> they can each touch arbitrarily many blocks, and *that's* what makes an
> "indexed" query slow.

Oracle names three plan operations that map directly onto this:

| Operation | What it does |
|---|---|
| `INDEX UNIQUE SCAN` | Tree traversal only — used when a unique constraint guarantees ≤1 match |
| `INDEX RANGE SCAN` | Tree traversal + leaf chain walk — the fallback whenever multiple rows could match |
| `TABLE ACCESS BY INDEX ROWID` | One row fetch per matched index entry |

The takeaway for the rest of the book: an `INDEX RANGE SCAN` can read a large
slice of the index, and each hit can trigger its own table access — so "has an
index" does not imply "is fast." Everything in Chapter 2 onward is about
shrinking what the range scan has to touch.
