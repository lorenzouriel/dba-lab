# Chapter 3: Performance and Scalability

A digression away from SQL syntax to talk about how to *measure*
performance — and to debunk "just add hardware" as a fix for slow queries.

Scalability == how performance responds to a growing environmental
parameter — not (as popularly assumed) just "how much hardware do I throw at
it." Data volume, concurrent load, and hardware are all separate axes.

> A single response-time measurement is just one point on a scalability
> chart, not the whole picture. "Fast enough in dev" says nothing about
> "fast enough in prod with 100x the data or 25 concurrent callers."

## Performance Impacts of Data Volume

Two indexes can produce structurally near-identical execution plans (same
operations, same row estimates) and still scale completely differently as
data grows — because the *shape* of the plan doesn't show which conditions
are access predicates vs. filter predicates.

Worked example: `WHERE section = ? AND id2 = ?` against two 3-column
indexes:

```sql
CREATE INDEX scale_slow ON scale_data (section, id1, id2);  -- id2 not 2nd!
CREATE INDEX scale_fast ON scale_data (section, id2, id1);
```

Both produce an `INDEX RANGE SCAN`. But the predicate information reveals
the real difference:

```
scale_slow: access("SECTION"=:A)         filter("ID2"=:B)
scale_fast: access("SECTION"=:A AND "ID2"=:B)
```

`scale_slow` must walk **every** row in the section and discard non-matches —
response time scales with *section size*. `scale_fast` narrows the tree
traversal to just the matching rows — response time scales with *result
size*. As data volume grows 100x, the badly-ordered index gets ~20x slower;
the well-ordered one barely moves.

> **Filter predicates are like unexploded ordnance — they can go off (i.e.,
> blow up your response time) at any data volume, without warning, because
> the plan shape alone doesn't reveal them.**

Always read the full predicate information, not just the operation names —
this is the same access-predicate/filter-predicate distinction from Chapter
2, now shown to be exactly what makes scalability curves diverge.

## Performance Impacts of System Load

The optimizer picks an index because it beats a full table scan, not because
it's the best possible index for that query — verifying "uses an index"
isn't enough; you have to check *which conditions* actually narrow the scan.
Different tools bury this information differently (SQL Server: a mouse-over
tooltip; MySQL/PostgreSQL: less accessible still), so it's easy to miss.

Same `scale_slow`/`scale_fast` example, now holding data volume constant and
increasing concurrent query load: `scale_slow` degrades to 30x its baseline
response time at 25 concurrent queries; `scale_fast` (no filter predicates,
therefore doing far less wasted I/O and CPU per call) stays under 2 seconds
throughout.

> A query that "seems fine" with no background load can fall apart under
> production concurrency — for reasons invisible in a low-load dev
> environment, and invisible in the execution plan's shape (only visible in
> the predicate info).

## Response Time and Throughput

Bigger/more hardware is a wider highway, not a faster car — more concurrent
capacity, not lower latency for a single query. Multi-core CPUs and
horizontal scaling both add *throughput*, not *response time* improvement
for one query — single-core clock speed gains (the thing that used to make
old code "just get faster") largely stalled in the early 2000s.

> Proper indexing — exploiting the B-tree's logarithmic scalability — is the
> best lever for response time, in relational and non-relational databases
> alike (an unindexed search tree is a search tree in name only).

A sloppy vs. well-ordered index produces a response-time gap that's very
hard to buy your way out of with hardware.

Side note on distributed/NoSQL systems: horizontal write scalability there
usually comes from **eventual consistency**, trading strict consistency for
availability and lower write latency (see CAP theorem: Consistency,
Availability, Partition tolerance — pick your trade-offs). That's a
different lever entirely from indexing, and doesn't make single-query
lookups faster on its own.

Counter-intuitive but real: production hardware can be *slower* than a dev
laptop for a single query, because production infrastructure accumulates
more latency hops (network, firewalls between app and DB tiers, etc.) even
though it has more raw capacity.

Disk seek latency matters concretely for indexes: a spinning-disk seek is a
few milliseconds; a 4-level B-tree traversal can mean ~4 seeks (a few dozen
ms total) — imperceptible once, but a single SQL statement (especially a
join) can trigger hundreds or thousands of these. SSDs cut seek time by an
order of magnitude, and DB buffer caching (especially for hot index root/
branch nodes) can eliminate the seek entirely for frequently-used indexes —
but neither erases the underlying cost model. This sets up Chapter 4: joins
are the operation most likely to multiply per-row lookups into real seek
costs.
