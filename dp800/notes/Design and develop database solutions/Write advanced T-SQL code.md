## Introduction
- This module = advanced T-SQL: CTEs, window functions, JSON, regex, fuzzy matching, graph queries, correlated subqueries, error handling

- **Exam angle**: heaviest module for "pick the right technique for the scenario" questions — expect direct comparisons (window function vs correlated subquery, CTE vs derived table, EXISTS vs IN)

## Organize queries with common table expressions
- CTE = temporary named result set, scoped to a single statement (SELECT/INSERT/UPDATE/DELETE), no persistence/cleanup needed
```sql
WITH CTE_Name (Column1, Column2) AS
(
    SELECT Column1, Column2 FROM SomeTable WHERE SomeCondition = 'Value'
)
SELECT * FROM CTE_Name;
```

- Benefits over subqueries: readability, reusable within the same query (reference multiple times), **self-referencing (recursion)**, multiple chained CTEs in one `WITH` (later CTEs can reference earlier ones)

- **Recursive CTE** — two parts, separated by `UNION ALL`:
    - **Anchor member**: the starting/base result
    - **Recursive member**: references the CTE itself, joins back to build the next level
```sql
WITH RecursiveCTE AS
(
    SELECT columns FROM table WHERE starting_condition   -- anchor
    UNION ALL
    SELECT columns FROM table INNER JOIN RecursiveCTE ON join_condition  -- recursive
)
SELECT * FROM RecursiveCTE;
```

- Classic use: org hierarchy traversal (manager→employee chains), also generating number/date sequences without a physical numbers table

- **`OPTION (MAXRECURSION n)`** — default limit is **100** levels; `n = 0` means unlimited; exceeding the limit without setting this throws an error

- CTEs work with **INSERT/UPDATE/DELETE** too — isolate the row-selection logic in the CTE, then modify against it

- **Exam angle**: the **MAXRECURSION default of 100** and the anchor/recursive/UNION ALL structure are prime exam targets; know that a missing termination condition + no MAXRECURSION override = runtime error

## Apply window functions for analytics
- Core distinction: window functions compute across a set of related rows **without collapsing** the result set (unlike GROUP BY aggregates)
```sql
function_name(args) OVER (
    [PARTITION BY partition_expr]
    [ORDER BY order_expr]
    [ROWS | RANGE frame_spec]
)
```

- `PARTITION BY` = grouping for the calc; `ORDER BY` = logical row order within partition; `ROWS`/`RANGE` = frame boundaries

- **Default frame** when `ORDER BY` is present but no explicit frame: `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` → produces **running/cumulative** calculations automatically

- **Ranking functions — know the tie-handling differences cold:**
    - `ROW_NUMBER()` — unique sequential number, no ties (1,2,3,4...)
    - `RANK()` — ties share rank, **skips** subsequent numbers (1,1,1,4...)
    - `DENSE_RANK()` — ties share rank, **no skip** (1,1,1,2...)
    - `NTILE(n)` — splits rows into n roughly-equal buckets (percentile/quartile analysis)
    - Use `ROW_NUMBER()` for exactly-one-row-per-rank (top-N per group); use `RANK`/`DENSE_RANK` when ties must be preserved

- Aggregate window functions: `SUM/AVG/COUNT/MIN/MAX(...) OVER (...)` — **no `ORDER BY`** = calculates across the whole partition; **with `ORDER BY`** = running calculation up to current row

- Frame boundary keywords: `UNBOUNDED PRECEDING`, `n PRECEDING`, `CURRENT ROW`, `n FOLLOWING`, `UNBOUNDED FOLLOWING`; `ROWS` = counts physical rows, `RANGE` = groups by equal logical value
```sql
AVG(TotalDue) OVER (ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg3
```

- **Analytical functions** (pull values from other specific rows, no self-join needed):
    - `LAG(col, offset, default)` / `LEAD(col, offset, default)` → previous/next row values, for period-over-period comparisons
    - `FIRST_VALUE()` / `LAST_VALUE()` — **`LAST_VALUE()` requires explicit frame `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`**, otherwise default frame only goes up to current row and just returns the current row's own value — classic gotcha
    - `PERCENT_RANK()` (0 to 1, % of rows with lower value) and `CUME_DIST()` (cumulative distribution, % ≤ current row) — for percentile/outlier analysis

- **Exam angle**: RANK vs DENSE_RANK vs ROW_NUMBER tie behavior, the LAST_VALUE frame requirement, and default-frame behavior with/without ORDER BY are the top three testable traps here

## Process JSON data with built-in functions
- `JSON_VALUE()` → scalar (string/number/bool), returns as NVARCHAR(4000), cast as needed

- `JSON_QUERY()` → object/array, **preserves JSON structure** (unlike JSON_VALUE)

- Path syntax: `$` = root, dot notation for nesting, `[n]` (0-based) for array index

- **`OPENJSON`** — table-valued function, turns JSON into rows
    - No schema → default 3 columns: `key`, `value`, `type` (0=null,1=string,2=number,3=bool,4=array,5=object)
    - With `WITH (...)` schema → typed columns mapped from JSON paths
    - Combine with table data via **`CROSS APPLY`** — note: `CROSS APPLY` **drops rows** with NULL/empty JSON; use `OUTER APPLY` to keep them
```sql
SELECT ProductID, ProductName, Price
FROM OPENJSON(@json)
WITH (ProductID INT '$.id', ProductName NVARCHAR(100) '$.name', Price DECIMAL(10,2) '$.price');
```

- **`JSON_OBJECT()` / `JSON_ARRAY()`** (SQL Server 2022+) — construct JSON directly, can nest calls for hierarchical output

- **`JSON_ARRAYAGG()`** (2022+) — aggregates multiple rows into one JSON array; combine with `JSON_OBJECT()` for arrays-of-objects output (denormalized API-style results)

- **Validation functions**:
    - **lax mode** (default) → missing path returns NULL; **strict mode** → missing path raises an error
    - `ISJSON()` → 1 valid / 0 invalid / NULL if input is NULL
    - `JSON_PATH_EXISTS()` → 1/0 whether a path exists (check before strict-mode extraction)
    - `JSON_CONTAINS()` → checks whether a value/object exists within the JSON

- **Performance**: repeated JSON parsing on every query = expensive at scale → **computed column** extracting the property (`ALTER TABLE ... ADD Col AS JSON_VALUE(...)`), optionally **`PERSISTED`** (parses only on INSERT/UPDATE, not SELECT) → then **index the computed column** for index seeks instead of table scans
```sql
ALTER TABLE Products ADD ProductCategory AS JSON_VALUE(ProductData, '$.category') PERSISTED;
CREATE INDEX IX_Products_Category ON Products(ProductCategory);
```

- **`FOR JSON PATH`** / **`FOR JSON AUTO`** — relational→JSON output; `ROOT('name')` wraps output; dot-notation column aliases (`'product.id'`) create nested JSON objects

- **Exam angle**: JSON_VALUE vs JSON_QUERY (scalar vs structure-preserving), lax vs strict mode, and the computed-column+PERSISTED+index pattern for performance are all high-yield; also know `JSON_ARRAYAGG`/`JSON_OBJECT` require **SQL Server 2022+**

## Match patterns with regular expressions
- SQL Server 2025 / Fabric SQL DB feature — **uses ECMAScript regex syntax** (same as JavaScript)

- Core pattern tokens to memorize: `.` any char, `*` zero+, `+` one+, `?` zero/one, `^`/`$` anchors, `[abc]` class, `[^abc]` negated class, `\d` digit, `\w` word char, `{n}` exact count, `{n,m}` range count

- Functions:
    - `REGEXP_LIKE(str, pattern, [flags])` → boolean match, use in WHERE for filtering/validation (more efficient than extracting when you just need existence)
    - `REGEXP_REPLACE(str, pattern, replacement)` → supports capture groups + backreferences (`$1`, `$2`) for things like reformatting or masking
    - `REGEXP_SUBSTR(source, pattern, start_position, occurrence, flags, capture_group)` → extract matching substring
    - `REGEXP_INSTR()` → starting position of match, 0 if none
    - `REGEXP_COUNT()` → number of pattern occurrences
    - `REGEXP_SPLIT_TO_TABLE(str, pattern)` → table-valued, splits string into rows (use with `CROSS APPLY` for per-row splitting)
    - `REGEXP_MATCHES()` → table-valued, returns **all** matches as rows (`match_value`, `match_index`)
    - `'i'` flag → case-insensitive matching

- **Exam angle**: know this feature is **2025/Fabric-only** — earlier versions need CLR or app-layer regex; also know which function returns boolean vs position vs substring vs table

## Find approximate matches with fuzzy string functions
- Two similarity concepts: **edit distance** (Levenshtein — count of insert/delete/substitute ops to transform one string to another, lower = more similar) vs **similarity score** (normalized %, higher = more similar)

- `EDIT_DISTANCE(str1, str2)` → raw edit count (e.g., "color"→"colour" = 1)

- `EDIT_DISTANCE_SIMILARITY(str1, str2)` → normalized 0-100 score, easier to threshold across different string lengths

- `JARO_WINKLER_DISTANCE(str1, str2)` → 0 to 1, **optimized for short strings/names**, gives extra weight to matching prefixes; score >0.9 = strong name match. Better than EDIT_DISTANCE_SIMILARITY for names; EDIT_DISTANCE_SIMILARITY better for longer text (addresses/descriptions)

- **Performance is the big exam point**: fuzzy functions are computationally expensive (character-by-character comparison, no index usage) — **always pre-filter the candidate set first** (LIKE prefix match, exact match on related column) before applying fuzzy comparison
```sql
-- Best practice: narrow first, then fuzzy match
WHERE FirstName LIKE 'Jo%' AND LastName LIKE 'Sm%'
  AND JARO_WINKLER_DISTANCE('John', FirstName) > 0.85
```

- Available in **SQL Server 2025+, Azure SQL DB, Fabric SQL DB** — same version gate as regex functions

- **Exam angle**: EDIT_DISTANCE (raw count) vs EDIT_DISTANCE_SIMILARITY (0-100 normalized) vs JARO_WINKLER (0-1, name-optimized) — matching function to scenario; also the "prefilter before fuzzy match" performance principle

## Traverse relationships with graph queries
- Node tables: `CREATE TABLE ... AS NODE` → auto-adds hidden `$node_id`

- Edge tables: `CREATE TABLE ... AS EDGE` → auto-adds hidden `$edge_id`, `$from_id`, `$to_id`; can carry relationship properties (dates, weights, types)

- Insert edges by selecting `$node_id` from the connected node rows into `$from_id`/`$to_id`

- **`MATCH`** clause — ASCII-art-style pattern syntax replacing multi-way joins:
```sql
SELECT Person1.Name, Person2.Name
FROM Person AS Person1, Friendship, Person AS Person2
WHERE MATCH(Person1-(Friendship)->Person2);
```

- `(Node1)-(Edge)->(Node2)` = edge direction Node1→Node2; `(Node1)<-(Edge)-(Node2)` = reversed — **direction must match how edges were inserted**, or the query silently returns nothing

- **Multi-hop traversal**: chain patterns, e.g. `Person1-(k1)->Person2-(k2)->Person3` for "friends of friends"; can mix different edge types in one chain

- **Constraint: each edge alias can only appear once per MATCH pattern** — need separate aliases to traverse the same edge type twice

- **`SHORTEST_PATH`** — variable-length traversal; requires **`FOR PATH`** on all participating node/edge tables; quantifiers like `+` or `{1,3}` control depth; requires SQL Server 2019+

- **When to use graph vs relational**: graph when relationships are the focus, variable/unknown-depth traversal needed, data is naturally networked, or the relational equivalent needs many self-joins. Relational when relationships are simple/fixed-depth, filtering/aggregating attributes is the main task, or FK indexes suffice

- Troubleshooting table to remember: no results → usually **arrow direction mismatch**; syntax error → **repeated edge alias**; SHORTEST_PATH fails → **missing FOR PATH**; edge references bad nodes → used business key instead of `$node_id`

- **Exam angle**: arrow direction correctness, one-alias-per-edge-per-MATCH rule, and FOR PATH requirement for SHORTEST_PATH are the classic traps; graph tables available since **SQL Server 2017**, SHORTEST_PATH since **2019**

## Compare rows with correlated subqueries
- **Correlated** = subquery references an outer-query column → re-executes per outer row (conceptually a nested loop); **non-correlated** = subquery computes once, independent of outer row
```sql
-- correlated: references p1 from outer query
WHERE p1.ListPrice > (SELECT AVG(p2.ListPrice) FROM Product p2 WHERE p2.ProductCategoryID = p1.ProductCategoryID)
```

- Optimizer **often rewrites correlated subqueries as joins internally** — but reasoning through the logical row-by-row model is still how you write them correctly

- **`EXISTS`/`NOT EXISTS`** — boolean presence check, use `SELECT 1` (value doesn't matter); **stops at first match** → generally **outperforms `IN`** with subqueries, since `IN` may need to materialize all matching values first

- Correlated subquery in **SELECT clause** must return exactly **one value** — if multiple rows possible, wrap in `MAX()`/`MIN()`/`SUM()` etc.

- Practical patterns: outlier-vs-group-average filtering, top-N-per-group (via `TOP N ... IN (...)` or a `COUNT(*) WHERE higher-ranked < N` pattern — handles ties differently), consecutive-row comparison (previous order value, etc.)

- **When to prefer alternatives** (decision table to memorize):
    - Correlated subquery → per-row dynamic comparison, EXISTS checks, single related value with complex logic
    - **Join** → straightforward multi-table column retrieval
    - **Window function** (`LAG`/`LEAD`/ranking) → running totals, rankings, adjacent-row access — **more efficient** than correlated subqueries for these
    - **CTE** → reused calculated result, readability via named steps

- **Performance**: index the correlation column (the column linking subquery back to outer query) — composite index if subquery also filters/aggregates on another column; review actual execution plans (optimizer may or may not rewrite as a join)

- **Exam angle**: EXISTS vs IN performance reasoning, single-value requirement for SELECT-clause subqueries, and "when window function beats correlated subquery" are the top testable items

## Handle errors with TRY...CATCH
- `BEGIN TRY ... END TRY BEGIN CATCH ... END CATCH` — error in TRY jumps execution to CATCH

- **Cannot catch**: compilation/syntax errors, missing-object errors, or **severity ≥20** errors that terminate the connection

- Error info functions inside CATCH: `ERROR_NUMBER()`, `ERROR_MESSAGE()`, `ERROR_SEVERITY()` (0-25), `ERROR_STATE()`, `ERROR_LINE()`, `ERROR_PROCEDURE()`
    - **Important**: once you call `THROW`/`RAISERROR`, these functions return NULL if called again — **log error details before re-raising**

- **Transactions in CATCH**: always check **`@@TRANCOUNT > 0`** before `ROLLBACK TRANSACTION` — some errors auto-rollback before reaching CATCH, and rolling back with no active transaction throws its own error
```sql
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

- **`THROW`** (recommended for new code) — simpler, includes stack trace automatically; **custom error numbers must be ≥50000**
```sql
THROW 50001, 'Quantity must be greater than zero.', 1;
```

- **`RAISERROR`** — older, supports printf-style formatted messages (`%s`, `%d` substitution) — use when you need formatted output or legacy compatibility

- **Nested procedures**: let the **outer** procedure own the transaction and rollback; inner procedures should just `THROW` to propagate, not rollback themselves — keeps transaction control centralized

- **`SET XACT_ABORT ON`** — forces automatic full rollback on ANY error, even without TRY...CATCH; **best practice to combine with TRY...CATCH** for multi-statement/multi-procedure transactions (XACT_ABORT guarantees the rollback, TRY...CATCH still lets you log + control error propagation)

- **Exam angle**: `@@TRANCOUNT` check before ROLLBACK, THROW vs RAISERROR distinction (custom error number ≥50000, THROW has no format string but simpler/stack-trace), and what XACT_ABORT actually adds on top of TRY...CATCH are all classic DP-800 questions