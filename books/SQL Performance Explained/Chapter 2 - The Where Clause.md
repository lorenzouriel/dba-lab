# Chapter 2: The Where Clause

The `WHERE` clause is where most indexing mistakes happen, because it's the
part of the query that decides how much of the index the database actually
has to scan. This is the main chapter of the book — everything else builds on
top of the patterns here.

## The Equality Operator

### Primary Keys

A primary key always gets an index automatically. A lookup on a unique,
single-column key produces the cheapest possible plan:

```sql
SELECT first_name, last_name FROM employees WHERE employee_id = 123;
```

```
INDEX UNIQUE SCAN  -- tree traversal only, guaranteed ≤1 row
TABLE ACCESS BY INDEX ROWID  -- exactly one fetch, never more
```

`INDEX UNIQUE SCAN` is the *only* index operation that can never trigger the
"many table accesses" failure mode from Chapter 1 — a unique constraint
guarantees at most one hit, so at most one row fetch.

### Concatenated Indexes

A multi-column primary key gets one index across **all** its columns (a
*concatenated*/composite/multi-column index) — not one index per column.

> A concatenated index is one index across multiple columns, sorted by the
> first column, then the second only where the first ties, etc. — exactly
> like a phone book sorted by last name, then first name.

Consequence: **you can't search efficiently on a non-leading column alone.**
Searching `WHERE subsidiary_id = 20` against an index defined as
`(employee_id, subsidiary_id)` can't use the tree at all — subsidiary_id
values for a given subsidiary are scattered all over the leaf chain, so the
optimizer falls back to a full table scan.

Fix: put the column that's searched *alone* first:

```sql
CREATE UNIQUE INDEX employees_pk ON employees (subsidiary_id, employee_id);
```

Now `subsidiary_id = 20` alone gets an `INDEX RANGE SCAN`, and the full key
still works too (just needs to walk the leaf chain instead of a unique hit).

> **Rule:** a concatenated index can be used by any query that filters on a
> *leftmost prefix* of its columns — first column alone, first two together,
> etc. Not just the last column, not any arbitrary subset.

Prefer one well-ordered concatenated index over two single-column indexes:
same query performance, but less storage and less write-side maintenance
(every index costs something on insert/update/delete — see Chapter 8).

Choosing the right column order requires knowing the **application's access
patterns**, not just the schema. That's why good indexing is a development
task, not something a DBA or outside consultant can fully own from the
schema alone.

### Slow Indexes, Part II

Changing an index changes which queries can use it — for better *and* worse.
A worked example: reordering the primary key index above to lead with
`subsidiary_id` makes a *different*, unrelated query pick it up:

```sql
SELECT first_name, last_name, subsidiary_id, phone_number
  FROM employees
 WHERE last_name = 'WINAND' AND subsidiary_id = 30;
```

The optimizer now uses the (subsidiary_id, employee_id) index to satisfy the
`subsidiary_id` filter, then applies `last_name = 'WINAND'` as a **plain
filter** on the fetched rows (not an access predicate) — meaning it has to
fetch and discard *every* row for that subsidiary before checking the name.
If the subsidiary has 1000 employees, that's 1000 wasted table accesses. A
`TABLE ACCESS FULL` can end up cheaper than this "indexed" plan.

The optimizer's choice depends on accurate **statistics** (row counts, column
histograms) — with stale or default statistics it may badly misjudge
selectivity and pick the worse plan even by its own cost model.

The actual fix is not to argue about the primary key index at all — add a
dedicated index for the real access path:

```sql
CREATE INDEX emp_name ON employees (last_name);
```

> Two execution plans can look structurally identical (same operations,
> similar cost) and still perform wildly differently — "uses an index" says
> nothing about *how much* of the index it has to touch.

## Functions

### Case-Insensitive Search Using UPPER/LOWER

```sql
WHERE UPPER(last_name) = UPPER('winand')
```

To the optimizer, `UPPER(last_name)` is an opaque black box — there is no
general relationship between a function's input and output, so an index on
`last_name` is useless here. Mentally replace the function name with
`BLACKBOX(...)` to see it the way the optimizer does.

Fix: a **function-based index** (FBI) that stores the *transformed* value:

```sql
CREATE INDEX emp_up_name ON employees (UPPER(last_name));
```

The database can use it whenever the exact same expression appears in a
query. No new plan operation exists for this — it's a normal `INDEX RANGE
SCAN`, just over pre-transformed data.

- Oracle/PostgreSQL: real function-based indexes (`UPPER(...)`, `IMMUTABLE`
  functions declared as such).
- SQL Server: no FBI, but computed columns can be indexed instead.
- MySQL: no function-based indexing at all (pre-8.0; needs a generated/virtual
  column instead).

> ORM tools can inject this silently — e.g. Hibernate wraps case-insensitive
> comparisons in an implicit `LOWER(...)` without telling you.

### User-Defined Functions

Only **deterministic** functions (same input → always same output) can be
indexed. A function like `get_age(date_of_birth)` that depends on the current
date is *not* deterministic — the index value is computed once at insert time
and never refreshed, so an indexed "age" silently goes stale the moment a
birthday passes. Databases require you to explicitly mark a function
`DETERMINISTIC` (Oracle) / `IMMUTABLE` (PostgreSQL) to use it in an index —
and they *trust* that declaration, so lying about it produces a subtly wrong
index rather than an error.

### Over-Indexing

Function-based indexes make it easy to accidentally create redundant
indexes: `UPPER(last_name)` and `LOWER(last_name)` need two *separate*
indexes to each be useful, doubling write-time maintenance for the same
logical query.

> Standardize on one function throughout the app so a single index serves
> every query. Prefer indexing the raw column when you have the choice.

## Parameterized Queries

Bind parameters (`?`, `:name`, `@name`) vs. literal values baked into the SQL
string. Two independent reasons to prefer bind parameters:

1. **Security** — the standard defense against SQL injection.
2. **Performance** — databases with a plan cache (Oracle, SQL Server) reuse a
   compiled execution plan only when the SQL text is *identical*. Literal
   values make every call a "different" statement, forcing a fresh optimize
   every time — "like recompiling a program on every run."

The trade-off: with a literal value the optimizer can use it directly to
estimate selectivity from a histogram (e.g. "subsidiary 30 has 1000 of 1099
employees, so a full scan wins"); with a bind parameter the optimizer must
guess a generic distribution and picks **one plan for all values**, which can
be wrong for skewed columns (heavily unbalanced status codes, `LIKE` search
terms, partitioned tables).

> Default to bind parameters. Use literals deliberately, only for values that
> should actually steer plan choice (skewed distributions).

Databases work around this dilemma with heuristics: Oracle's *bind peeking* /
*adaptive cursor sharing* (cache multiple plans per statement, keyed by bind
selectivity), SQL Server's *parameter sniffing* + `OPTION(RECOMPILE)` /
`OPTIMIZE FOR` hints. All are workarounds for the same fundamental tension.

Note: bind parameters can only replace **values**, never identifiers (table
or column names) — that still requires dynamic SQL.

## Searching for Ranges

### Greater, Less and BETWEEN

> **Golden rule:** the scanned index range should be as small as possible —
> ask "where does the scan start, where does it end?"

With two conditions — a range on column A and equality on column B — column
**order in the index matters a lot**, even though both conditions might look
equally selective in isolation:

- Index `(date_of_birth, subsidiary_id)`: the date range is the only usable
  access predicate; `subsidiary_id` becomes a leftover filter applied while
  walking a wide leaf-chain range (all dates in range, across every
  subsidiary).
- Index `(subsidiary_id, date_of_birth)`: `subsidiary_id =` narrows the tree
  traversal first, and *within* that the dates are already sorted, so the
  scan range collapses to exactly the matching leaf nodes.

> **Rule of thumb: index for equality first, then for ranges.** Order
> range/inequality columns *after* every equality column in a concatenated
> index.

This is provable directly from the execution plan via **access predicates**
(narrow the scanned range — used during tree traversal) vs. **filter
predicates** (checked while walking the leaf chain, don't narrow the range).
The same condition can be either, purely depending on index column order —
which is *why* "most selective column first" is a myth in general (it only
holds once a filter predicate is unavoidable).

`BETWEEN x AND y` is exactly `col >= x AND col <= y` — inclusive on both ends.

### Indexing LIKE Filters

Only the literal prefix **before the first wildcard** can serve as an access
predicate:

| Pattern | Access predicate | Filter predicate |
|---|---|---|
| `'WI%ND'` | `WI` | rest |
| `'WIN%D'` | `WIN` | rest (tighter → fewer rows scanned) |
| `'WINA%'` | `WINA` | none (best case) |
| `'%TERM'` | none | everything → full scan |

A leading-wildcard `LIKE` cannot use a B-tree at all — needs a full-text index
(`CONTAINS`/`MATCH...AGAINST`/`@@` depending on database) or a different
access path.

With bind parameters the optimizer can't inspect the pattern to guess whether
it has a leading wildcard, so it assumes there isn't one — silently wrong for
full-text-style searches. PostgreSQL goes the other way and assumes there
*is* one for bound `LIKE`, so it just skips the index. There is no reliable
"is this a prefix search" hint you can pass — see "Combining Columns" below
for the deliberate-obfuscation trick used when you know better than the
optimizer.

### Index Merge

For two *independent* range conditions (e.g. `UPPER(last_name) < ?  AND
date_of_birth < ?`), **no single B-tree column order can support both as
access predicates** — a B-tree is a chain (one sort axis), not a grid. You
always end up with one access predicate and one filter predicate, or two
separate index scans combined afterward (index join / bitmap conversion).

- One index scan is always cheaper than combining two.
- Bitmap indexes solve the "combine many independently-indexed columns"
  problem well for ad-hoc data-warehouse queries, but have terrible
  concurrent-write scalability — essentially unusable for OLTP.
- Some databases convert several B-tree range scans into an in-memory bitmap
  at runtime to combine them; effective, but CPU/memory-heavy — "an
  optimizer's act of desperation."

### Partial Indexes

Index only the rows that matter for a hot, narrow query:

```sql
CREATE INDEX messages_todo ON messages (receiver) WHERE processed = 'N';
```

For a queue where "done" vastly outnumbers "todo," this keeps the index tiny
and roughly constant-size even as the table grows unbounded — you get the
column-order savings (drop `processed` from the index entirely, since it's
constant within the index) *and* a row filter. SQL Server calls these
*filtered indexes* and restricts what can appear in the predicate (no
functions, no `OR`). Oracle has no partial index syntax — see below for its
NULL-based emulation.

## NULL in the Oracle Database

Two Oracle-specific landmines, independent of the general SQL indexing
rules above:

- Oracle treats an **empty string as NULL** — you cannot store `''` in a
  `VARCHAR2`; it becomes `NULL`. Not standard SQL behavior, easy to get
  bitten by.
- **Oracle omits a row from an index entirely if every indexed column is
  NULL.** Every Oracle index is implicitly a partial index excluding
  "all-NULL" rows — which is why `WHERE date_of_birth IS NULL` against a
  single-column index on `date_of_birth` can't use it: rows with a NULL
  value were never inserted into the index.

### Indexing NULL

Trick: add a column that **can never be NULL** to the index (any `NOT NULL`
column, or a constant expression) so every row is guaranteed to appear:

```sql
CREATE INDEX emp_dob ON employees (date_of_birth, '1');
```

This is a function-based index, and it directly disproves "Oracle can't
index NULL" — it can, once at least one indexed expression is guaranteed
non-null.

### NOT NULL Constraints

The database needs a *guarantee*, not just an absence of NULLs in practice —
dropping a `NOT NULL` constraint on the extra column immediately makes the
index unusable for `IS NULL` lookups again, even if no row actually has NULL
there. A user-defined function used as that "safety" column doesn't
propagate the guarantee either (the optimizer can't see through it) unless
you materialize it as a `NOT NULL` generated/virtual column.

### Emulating Partial Indexes

Combine "all-NULL rows are excluded" with a deterministic function that
returns `NULL` for rows you don't want indexed, to hand-roll a partial index
in Oracle:

```sql
CREATE FUNCTION pi_processed(processed CHAR, receiver NUMBER) RETURN NUMBER
DETERMINISTIC AS BEGIN
  IF processed = 'N' THEN RETURN receiver; ELSE RETURN NULL; END IF;
END;

CREATE INDEX messages_todo ON messages (pi_processed(processed, receiver));
```

The query must then reference the same expression to hit the index.

## Obfuscated Conditions

A grab-bag of where-clause anti-patterns that all reduce to the same root
cause: **wrapping the indexed column in a function/conversion/expression
turns it into a black box.**

### Date Types

`TRUNC(sale_date) = TRUNC(sysdate)` obfuscates `sale_date` exactly like
`UPPER(last_name)` did — an index on `sale_date` can't be used because the
query isn't searching `sale_date`, it's searching a derived value.

> **Fix: rewrite as an explicit range** instead of truncating/reformatting a
> timestamp column:
> ```sql
> WHERE sale_date >= TRUNC(sysdate) AND sale_date < TRUNC(sysdate) + INTERVAL '1' DAY
> ```
> This is a generic pattern — works for "this quarter," "this day," "this
> month" — and needs only a plain index on the raw column. Watch the
> boundary math: `BETWEEN` is inclusive, so an exclusive upper bound (`<`)
> avoids off-by-a-value-at-midnight bugs.

Comparing a date via `LIKE` against a formatted string is a sneaky variant —
it forces an implicit type conversion on the column even though no function
is visibly wrapped around it in the SQL text.

### Numeric Strings

Storing numbers as text and then comparing with a numeric literal
(`numeric_string = 42`, no quotes) triggers an implicit `TO_NUMBER(...)`
conversion **applied to the column**, breaking the index — and it's not
merely a performance problem: `'042'`, `'42'`, and `'0042'` are all different
strings but the same number, so switching which side gets converted changes
*which rows match*, not just how fast.

> Convert the *search term*, never the column: `WHERE numeric_string =
> TO_CHAR(42)`. Better: don't store numbers as text at all.

### Combining Columns

Deriving a value from *multiple* columns (`ADDTIME(date_column,
time_column) > ...`) can't use an index on either column alone. Where you
can't restructure the schema, add a **redundant** filter on the most
significant column so the optimizer at least gets a usable, if imprecise,
access predicate:

```sql
WHERE ADDTIME(date_column, time_column) > cutoff
  AND date_column >= DATE(cutoff)   -- redundant, but indexable
```

The reverse trick — **deliberately** obfuscating a condition so the
optimizer *won't* consider a particular index — is occasionally useful, e.g.
forcing a `LIKE` with a known-always-leading-wildcard off an index:
`last_name || '' LIKE ?`. Last resort only.

### Smart Logic

The "one query handles every optional filter combination" pattern:

```sql
WHERE (subsidiary_id = :sub_id OR :sub_id IS NULL)
  AND (employee_id   = :emp_id OR :emp_id IS NULL)
  AND (UPPER(last_name) = :name OR :name IS NULL)
```

Semantically fine (three-valued NULL logic works as intended), but a serious
performance anti-pattern with bind parameters: since *any* clause could be
disabled at runtime, the optimizer must plan for the **worst case where all
filters are off** — full table scan, regardless of which filters are
actually active for a given call. Literal values "fix" it only by proving the
optimizer *could* resolve it — that's not a real solution (reintroduces
injection risk and cache-thrashing).

> **Real fix: build the WHERE clause dynamically** (still with bind
> parameters!) so the SQL text sent to the database only contains the
> filters actually in use. Static SQL that hides dynamic behavior behind
> `OR ... IS NULL` performs worse than honest dynamic SQL.

### Math

Same black-box problem again, now via arithmetic: `numeric_number - 1000 >
?` or `3*a + 5 = b` can't use an index on the raw column(s), because
databases don't run an equation solver against the optimizer's search space.

Fix: **algebraically isolate the indexed column(s) on one side**, constants
on the other, then index that exact expression:

```sql
WHERE 3*a - b = -5
CREATE INDEX math ON table_name (3*a - b);
```

Zero-cost inverse trick: adding `+ 0` obfuscates a column deliberately, same
spirit as the `LIKE` obfuscation trick above.
