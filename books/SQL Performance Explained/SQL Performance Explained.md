# SQL Performance Explained (Markus Winand)

Core thesis of the book: SQL performance problems are usually not a DBA/hardware
problem, they're an **indexing** problem, and indexing is a development-time
concern, not an ops-time one. The reasoning:

> The most important input for good indexing is *how the application queries
> the data* — and that knowledge lives with the developer, not the DBA.

The book deliberately covers **one index type only: the B-tree index**, because
it's the one nearly every relational database uses for OLTP-style lookups. It
uses Oracle terminology as the baseline, with side notes for PostgreSQL, MySQL,
and SQL Server where behavior differs.

## How the book (and these notes) are organized

Each chapter roughly maps to one part of an SQL statement:

| Chapter | Maps to |
|---|---|
| 1. Anatomy of an Index | (foundation — no SQL yet, just the B-tree) |
| 2. The Where Clause | `WHERE` |
| 3. Performance and Scalability | (digression on measuring performance) |
| 4. The Join Operation | `JOIN` |
| 5. Clustering Data | `SELECT` (column access, table/index clustering) |
| 6. Sorting and Grouping | `ORDER BY` / `GROUP BY` |
| 7. Partial Results | `FETCH FIRST` / pagination |
| 8. Modifying Data | `INSERT` / `UPDATE` / `DELETE` |
| Appendix A | Reading execution plans per database |

Chapter 1 is required reading before everything else — the entire book's
reasoning about "why is this slow despite having an index" comes back to the
three-part anatomy of an index lookup introduced there (tree traversal → leaf
node chain → table access).

## Recurring theme

A huge fraction of "real world" slow queries trace back to one of:
1. An index exists, but the **leaf-node chain scan** returns far more rows than
   necessary (wrong/missing column in a concatenated index, function wrapped
   around an indexed column, etc.).
2. A correct index scan still needs a **table access by row-id for every hit**,
   which dominates cost once hit count grows — solved by clustering data
   (index-organized tables) or covering indexes (index-only scan).

Almost every "trick" in this book is really just: *give the database an index
that lets it avoid steps 2 and 3 of an index lookup, not just step 1.*
