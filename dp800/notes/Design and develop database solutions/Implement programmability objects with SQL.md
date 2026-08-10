## Introduction
- Module scenario: e-commerce SQL Server DB with repeated JOINs, scattered business logic, need for auto-validation/logging, duplicated calculations → solved via views, stored procs, functions, triggers

- **Exam angle**: this module is really a decision-matrix test — expect scenario questions asking "which object type fits this" rather than pure syntax recall

## Create views
- **Virtual table** based on a SELECT — no data stored, re-executes underlying query each time

- Two main use cases: **simplify complex JOINs** (write once, query many times) and **security boundary** (expose specific columns/rows, hide underlying tables)

- Design best practices:
    - **Explicit column list, never `SELECT *`** — keeps view stable if base table changes
    - **`WITH CHECK OPTION`** — when a view is used for INSERT/UPDATE, this ensures modified/inserted rows still satisfy the view's WHERE clause (e.g., can't insert TotalAmount=500 into a view filtered `WHERE TotalAmount > 1000`)
    - Keep views focused/single-purpose; avoid nesting views deeply (hard to optimize/maintain)

- **Data modification through views** is limited — only works cleanly when the view touches a **single base table**

- When NOT to use a view: performance-critical repeated query → **indexed view** (materialized, stores data physically) instead; parameterized calc → function; data modification logic → stored procedure

- **Exam angle**: `WITH CHECK OPTION` behavior and single-base-table update limitation are classic trick points; know indexed view = materialized/physically stored vs regular view = virtual/no storage

## Create stored procedures
- Precompiled, cached execution plan → faster on repeat runs vs ad-hoc queries (parsed/optimized every time)

- Structure: `CREATE PROCEDURE schema.name @params AS BEGIN ... END`

- **`SET NOCOUNT ON`** — suppresses "rows affected" message → reduces network traffic, standard best practice, expect this to appear as a "why include this line" question

- **Parameters**:
    - Input params can have defaults (`@StartDate datetime = NULL`) → makes them optional
    - **Output params** use `OUTPUT` keyword — caller must declare a variable and also specify `OUTPUT` in the EXEC call to receive the value

- **Error handling** via `TRY...CATCH`:
    - Check `@@TRANCOUNT > 0` before `ROLLBACK TRANSACTION` (avoids error if no active transaction)
    - Capture `ERROR_MESSAGE()`, `ERROR_SEVERITY()`, `ERROR_STATE()` and re-raise with `RAISERROR`

- Best practices to memorize:
    - **Schema-qualify names** (`dbo.Orders`) — avoids ambiguity + resolution overhead
    - Validate parameters at the top, fail fast
    - Avoid `SELECT *`
    - Meaningful verb-based names (Get/Insert/Update/Delete/Calculate)
    - **Never prefix with `sp_`** — reserved for system procs in master DB; SQL Server checks master first, adding overhead

- **Exam angle**: the `sp_` prefix penalty and `@@TRANCOUNT` check before ROLLBACK are prime distractor material

## Create scalar functions
- Accepts 0+ params, returns **exactly one value**; can be embedded inline in SELECT/WHERE/JOIN expressions (unlike stored procs)

- Syntax: `CREATE FUNCTION schema.name (@params) RETURNS datatype AS BEGIN ... RETURN @result END`

- **Determinism matters**: deterministic = same input → same output always. Non-deterministic (e.g., uses `GETDATE()`) → **cannot be used in indexed views or indexes on computed columns**

- No side effects allowed — can't modify database state (SQL Server may execute the function multiple times/out of order)

- **Performance trap**: scalar function called in WHERE/SELECT against large tables → **executes once per row**, tanks performance. Alternative: inline table-valued function

- Managed via `ALTER FUNCTION` (preserves permissions/dependencies) and `DROP FUNCTION IF EXISTS`; check `sys.sql_expression_dependencies` before dropping

- **Exam angle**: the determinism rule (GETDATE = non-deterministic = blocked from indexed views/computed column indexes) and the row-by-row WHERE-clause performance trap are both very testable

## Create table-valued functions
- Two types — **know the distinction cold**:
    - **Inline TVF**: single SELECT statement, `RETURNS TABLE`, no explicit table structure (inferred from SELECT) → optimizer treats it like a **parameterized view**, expands into the query plan → **better performance**
    - **Multi-statement TVF**: `RETURNS @TableVar TABLE (explicit columns)`, uses `BEGIN...END` block, built with INSERT statements → more flexible (multi-step logic) but **worse optimizer visibility** (treated as black box)

- Can be used in JOIN/SELECT like a table — unlike stored procedures

- **`CROSS APPLY`** — calls the TVF once per outer row, essential when the function parameter depends on a column from the outer query (correlated); acts like a correlated subquery but more readable/reusable

- Inline TVFs (non-correlated) can also use plain `INNER JOIN ... ON 1=1`

- **Exam angle**: inline vs multi-statement (plan-caching/optimizer visibility difference) and when CROSS APPLY is required vs a regular JOIN are the two big testable points here

## Create triggers
- Execute **automatically** in response to events — never called explicitly (this is the defining difference vs stored procs)

- Two categories: **DML triggers** (INSERT/UPDATE/DELETE) and **DDL triggers** (CREATE/ALTER/DROP)

- DML trigger timing types:
    - **AFTER trigger**: fires after the data modification completes — used for validation, logging, updating related tables
    - **INSTEAD OF trigger**: replaces the original statement entirely — used to make normally non-updatable views updatable, or to inject custom logic before any write happens

- **`inserted` and `deleted` pseudo-tables**:
    - INSERT → populates `inserted`
    - DELETE → populates `deleted`
    - UPDATE → populates **both** (old values in `deleted`, new values in `inserted`)

- **`UPDATE(ColumnName)`** function — check if a specific column was part of the update, avoid unnecessary trigger logic

- Can combine events: `AFTER INSERT, UPDATE, DELETE` on one trigger — then use presence/absence in `inserted`/`deleted` to determine which operation occurred

- Best practices:
    - Keep trigger logic minimal — offload heavy/slow work to an async queue table + separate job
    - Guard against **recursive triggers** (`RECURSIVE_TRIGGERS` DB option)
    - Unhandled errors in a trigger **roll back both the trigger AND the original triggering statement**

- **Exam angle**: AFTER vs INSTEAD OF, and correctly reading `inserted`/`deleted` state to identify INSERT vs UPDATE vs DELETE in a combined trigger, are heavily tested

## Choose when to use each option
**Capability comparison table (memorize this cold — high-yield for exam):**

|Capability|Views|Stored Procs|Functions|Triggers|
|---|---|---|---|---|
|Accept parameters|No|Yes|Yes|No|
|Modify data|Limited (single base table)|Yes|No|Yes|
|Return result sets|Yes|Yes|Yes (TVFs)|No|
|Use in SELECT/JOIN|Yes|No|Yes|No|
|Transaction control|No|Yes|No|Yes|
|Automatic execution|No|No|No|Yes|
|Execution plan caching|No|Yes|Varies*|Yes|

*Inline TVFs cache/expand well (optimizer sees inside); multi-statement TVFs and scalar functions are "black boxes" → inaccurate row estimates, worse plans

- **Decision scenarios to memorize**:
    - Simplify a 5-table join, no params → **View**
    - Multi-step transactional logic (validate → insert → update inventory) → **Stored procedure**
    - Reusable calc used inside a query → **Scalar function**
    - Parameterized result set used in a JOIN → **Table-valued function**
    - Automatic audit logging on data change → **Trigger**
    - Restrict column access (e.g., hide SSN) → **View**

- **Common mistakes to flag on exam**:
    - Scalar function in WHERE clause on large table → per-row execution penalty
    - Using a trigger where a stored procedure would be clearer/more debuggable
    - Deeply nested views → hard to optimize
    - Choosing a stored procedure when the result needs to go directly into a SELECT → function is cleaner
- **Exam angle**: this comparison table is the single highest-yield artifact in this module — expect direct "which object supports X capability" questions pulled straight from it