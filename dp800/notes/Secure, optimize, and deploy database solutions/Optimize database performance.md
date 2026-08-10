## Introduction

- Module theme = **performance diagnosis across layers**: infrastructure config → concurrency/isolation → execution plans/DMVs → historical monitoring (Query Store) → blocking/deadlocks
- **Exam angle**: this is one of the heaviest scenario-based modules — expect "throughput drops during peak load, what do you check first" style questions that chain across multiple units; know the systematic order: DMVs (find expensive/blocked queries) → execution plans (why) → Query Store (historical/regression) → config changes

## Recommend database configurations

- **Two resource models**: **vCore** (direct control of cores/memory/storage, maps to on-prem CPU/memory, supports reserved pricing + Azure Hybrid Benefit — **recommended for most new deployments and migrations**) vs **DTU** (bundled CPU+memory+I/O into one unit, Basic/Standard/Premium tiers, no fine-grained control)
- **vCore service tiers — know the exact numbers/architecture differences cold:**

|Feature|General Purpose|Business Critical|Hyperscale|
|---|---|---|---|
|Storage|Remote (Blob Storage)|Local SSD|Decoupled + local SSD cache|
|Max storage|4 TB|4 TB|**128 TB**|
|Max IOPS/vCore|320|4,000|5,500|
|Replicas|1 (no read replica)|3 + 1 free read replica|0–4 configurable|
|Latency|~5-10ms|~1-2ms (lowest)|varies|
|Best for|Budget workloads|Low-latency/high-I/O|Large DBs, flexible scaling|

- Business Critical costs **~2.7x** General Purpose for the same vCore count
- Hyperscale bills only for **allocated** storage, not max; scales compute without copying data
- **Compute tiers**: **Provisioned** (fixed vCores, fixed hourly rate, predictable workloads) vs **Serverless** (auto-scales, per-second billing, **can autopause** — autopause currently **General Purpose only**; serverless itself available on GP and Hyperscale)
- Decision factors: sub-2ms latency need → Business Critical; >4TB or rapid growth → Hyperscale (only option); read-heavy → BC free replica or Hyperscale named replicas; intermittent traffic → serverless
- **Database-level tuning settings** (independent of tier):
    - **MAXDOP**: default **8** in Azure SQL DB (was 0/unlimited pre-Sept 2020 — caused resource starvation). Never use **MAXDOP 0** in production. Set via `ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP`; per-query via `OPTION (MAXDOP n)`
    - **Automatic tuning** — three options:
        - `FORCE_LAST_GOOD_PLAN` — detects regressions, reverts to prior good plan — **ON by default**
        - `CREATE_INDEX` — auto-creates missing indexes, verifies improvement — OFF by default
        - `DROP_INDEX` — removes unused/duplicate indexes (never touches unique/PK-supporting indexes) — OFF by default
        - All changes go through a **30-minute to 72-hour validation window**; auto-reverted if worse

```sql
ALTER DATABASE CURRENT SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON, CREATE_INDEX = ON, DROP_INDEX = OFF);
```

- **Compatibility level**: new Azure SQL DBs default to **170** (highest); Microsoft **never auto-upgrades** existing DBs — a DB created in 2024 may still sit at 160; BACPAC imports inherit source DB's level
    - 150 → batch mode on rowstore, table variable deferred compilation, scalar UDF inlining
    - 160 → parameter sensitive plan (PSP) optimization, cardinality estimation feedback
    - 170 → optional parameter plan optimization
    - Best practice: baseline with Query Store before upgrading, test in non-prod first
- **`OPTIMIZE_FOR_AD_HOC_WORKLOADS`**: stores a small plan **stub** on first execution instead of full plan; only compiles/caches full plan on second execution of same query text → prevents plan cache bloat from one-off ad hoc queries
- **ADR (Accelerated Database Recovery)**: **always on in Azure SQL DB, cannot disable** — constant-time recovery regardless of transaction volume, instant rollback, aggressive log truncation. Uses **Persistent Version Store (PVS)** inside the DB (not tempdb) — in-row or off-row depending on row size. Write-heavy workloads → more page splits/log volume since every version is logged. Monitor via `sys.dm_tran_persistent_version_store_stats` (`persistent_version_store_size_kb` = **off-row only**, doesn't include in-row) — growth beyond baseline signals long-running transactions or high abort rates delaying cleanup
- **Exam angle**: the exact GP/BC/Hyperscale numbers (4TB/4TB/128TB, 320/4000/5500 IOPS), MAXDOP-8-default-never-0-in-prod, compatibility-level-never-auto-upgrades, and ADR-always-on-with-PVS-in-DB (not tempdb) are all classic direct-recall DP-800 questions

## Preserve data integrity with transaction isolation levels and concurrency controls

- Three side effects, **know the precise definitions**:
    - **Dirty read**: reading another transaction's **uncommitted** data
    - **Nonrepeatable read**: same transaction reads the **same row twice**, gets **different values** (another transaction committed a change in between)
    - **Phantom read**: same transaction **re-runs a query**, sees **new/different rows** (another transaction inserted matching rows in between)
- Isolation levels matter most for **multi-statement transactions** (read→decide→write patterns); single-statement transactions rarely surface these problems
- **Six isolation levels — the comparison table is the single highest-yield artifact in this unit, memorize exactly:**

|Level|Dirty reads|Nonrepeatable reads|Phantom reads|Reader/writer blocking|
|---|---|---|---|---|
|READ UNCOMMITTED|Yes|Yes|Yes|No|
|READ COMMITTED|No|Yes|Yes|Yes|
|REPEATABLE READ|No|No|Yes|Yes|
|SERIALIZABLE|No|No|No|Yes (range locks)|
|READ COMMITTED SNAPSHOT (RCSI)|No|Yes|Yes|**No**|
|SNAPSHOT|No|No|No|**No** (update conflicts possible)|

- First four = **pessimistic/lock-based**; last two = **optimistic/row-versioning**
- **READ COMMITTED** = SQL Server on-prem default; strikes basic balance (shared lock grabbed+released per read)
- **REPEATABLE READ** holds shared locks for the whole transaction (blocks changes to read rows) but still allows new matching rows (phantoms)
- **SERIALIZABLE** = range locks on key gaps too → prevents everything but causes the most blocking/deadlock risk — reserve for financial reconciliation/inventory reservation
- **RCSI** — changes READ COMMITTED's _implementation_: readers see a per-**statement** snapshot instead of taking locks; writers still lock, but **readers never block on writers**. **RCSI is ON by default in Azure SQL Database** (opposite of on-prem SQL Server default)
- **SNAPSHOT** — per-**transaction** snapshot (not per-statement) → consistent results across multiple queries in one transaction; requires `ALLOW_SNAPSHOT_ISOLATION ON` at DB level + explicit `SET TRANSACTION ISOLATION LEVEL SNAPSHOT` in session; concurrent modification of same row → **update conflict error**, not silent overwrite
- **Optimized locking** (Azure SQL DB, **always enabled**, works alongside RCSI) — reduces write-write blocking via two mechanisms:
    - **TID (Transaction ID) locking**: one lock on the transaction ID instead of per-row locks → far fewer locks held, less lock escalation
    - **Lock after qualification (LAQ)**: reads latest committed version **without locking** first to check predicate match; only qualifying rows get locked, and that lock releases **as soon as the row updates** (not held to end of transaction). **LAQ requires RCSI enabled**
- Decision guidance: defaults (RCSI + optimized locking) cover most workloads; SNAPSHOT for multi-query consistency needs (e.g., financial reports); SERIALIZABLE only when phantoms cause real business errors, accepting throughput/deadlock cost
- **Exam angle**: the isolation-level comparison table (which side effects each prevents, and reader/writer blocking column) is near-certain to appear; know **RCSI is Azure SQL DB's default** (contrast with on-prem READ COMMITTED default); LAQ requiring RCSI is a specific testable dependency

## Evaluate query performance with execution plans and DMVs

- **Estimated plan** (no execution, statistics-based row estimates — `SET SHOWPLAN_XML ON`) vs **Actual plan** (during execution, includes real row counts/timings/memory grants/warnings — `SET STATISTICS XML ON`)
- Plans read **left-to-right, top-to-bottom**; base tables accessed first, final operator = result
- **Key things to check in a plan**:
    - **Index Seek** (efficient, targeted) vs **Table/Index Scan** (reads everything — not automatically bad on small tables or when most rows qualify)
    - **Estimated vs actual row count mismatch** → indicates **stale statistics**; large divergence can cause optimizer to pick nested loop join over hash join, or under-allocate sort memory. Fix: `UPDATE STATISTICS` or enable auto-stats
    - **Key Lookup**: nonclustered index found the row but query needs extra columns from clustered index → extra round-trip per row. Fix: add missing columns as **included columns** in the nonclustered index (tradeoff: bigger index = slower writes)
    - **Thick arrows** = high row-count flow between operators — early thick arrows often mean a missing filter/index
    - **Missing index suggestions** — green text in SSMS graphical plan → right-click → "Missing Index Details" generates a ready `CREATE INDEX` statement
    - **Warnings (yellow ⚠ triangle)** — memorize each meaning:
        - Missing statistics → optimizer guessed row counts, no real distribution data
        - Excessive memory grant → over-allocated memory from overestimated rows
        - No Join Predicate → Cartesian product from a missing/bad `ON` clause
        - Implicit conversion → data type mismatch (e.g., nvarchar param vs varchar column) turns a seek into a scan — fix by matching types
        - **Sort or Hash spill** → operation ran out of granted memory, spilled to tempdb — **2nd most common CPU driver after scans**; usually caused by underestimated rows from stale stats
- **DMVs — require `VIEW DATABASE STATE` permission in Azure SQL DB**:
    - `sys.dm_exec_query_stats` (aggregate stats for cached plans) joined to `sys.dm_exec_sql_text` (query text) + `sys.dm_exec_query_plan` (plan) → find top queries by avg CPU/logical reads. **Consider both average cost AND execution count** — a cheap query run thousands of times can matter more than an expensive one run once
    - `sys.dm_exec_requests` → **currently executing** queries snapshot; includes `wait_type`, `wait_time`, `blocking_session_id` — essential for real-time troubleshooting; filter `session_id > 50` to exclude system sessions
    - `sys.dm_db_missing_index_details` + `sys.dm_db_missing_index_group_stats` (join via `sys.dm_db_missing_index_groups`) → system-wide missing index recommendations, ranked by `improvement_measure` (cost × impact × usage) — **these are suggestions, always test before applying**
    - `sys.dm_exec_sessions` (all authenticated sessions) + `sys.dm_os_waiting_tasks` (what's waiting on what) — for blocking/contention diagnosis
- Systematic workflow: **DMVs first (broad, find worst offenders) → execution plans second (narrow, understand why)**
- **Exam angle**: matching warning type → cause → fix is highly testable; Key Lookup vs Index Seek vs Scan distinction; and knowing which DMV answers which question (historical aggregate vs currently-running vs missing-index) are the top three testable areas

## Monitor and tune queries with Query Store and Query Performance Insight

- **Query Store** = enabled by default in Azure SQL DB, captures data **asynchronously** (low overhead), three internal stores:
    - **Plan store** — plans per query (a query can have multiple plans over time)
    - **Runtime stats store** — aggregated CPU/duration/reads/row counts per plan, per time interval
    - **Wait stats store** — wait stats **per query and plan** (not just server-wide) — big advantage over server-level wait stats since you can attribute waits to specific queries
- **Regressed Queries view** (SSMS: Object Explorer → DB → Query Store → Regressed Queries) — surfaces queries that got slower after a plan change; filter by metric/time range/aggregation; compare two plans side-by-side to spot the change (seek→scan, lost key lookup, new spilling sort)
- Other Query Store views: **Top Resource Consuming Queries** (most common day-to-day starting point), **Queries With High Variation** (parameter sensitivity signal), **Queries With Forced Plans**, **Query Wait Statistics**
- T-SQL access via catalog views: `sys.query_store_query_text`, `sys.query_store_query`, `sys.query_store_plan`, `sys.query_store_runtime_stats` — join all four for custom analysis
- **Plan forcing** — immediate fix without touching app code or the query itself:

```sql
EXEC sp_query_store_force_plan @query_id = 42, @plan_id = 17;
EXEC sp_query_store_unforce_plan @query_id = 42, @plan_id = 17;
```

- Use as a **short-term rollback** while investigating root cause (stats update, schema change, index change)
- **Query Store hints** — attach hints to a specific query **without modifying app code**:

```sql
EXEC sp_query_store_set_hints @query_id = 42, @query_hints = N'OPTION (MAXDOP 1)';
EXEC sp_query_store_clear_hints @query_id = 42;
```

- **Overrides** hard-coded statement-level hints and plan guides — highest precedence
- Enable **per-query wait stats capture**: `ALTER DATABASE CURRENT SET QUERY_STORE (WAIT_STATS_CAPTURE_MODE = ON);`
- **Query Performance Insight (QPI)** — Azure portal graphical view of Query Store data (Intelligent Performance → Query Performance Insight); shows top 5 CPU queries by default (customizable: Duration/Execution count, 5/10/20 queries, time range, aggregation); **limited to top 5-20 queries** — many small queries collectively significant won't show; **requires Query Store to be active** (fails if QS goes read-only)
- **Operational failure mode to remember**: Query Store can silently switch to **READ_ONLY** if it runs out of allocated storage → stops collecting new data. Detect via:

```sql
SELECT actual_state_desc, desired_state_desc, current_storage_size_mb, max_storage_size_mb, readonly_reason
FROM sys.database_query_store_options;
```

- Fix: `ALTER DATABASE CURRENT SET QUERY_STORE (MAX_STORAGE_SIZE_MB = 1024);` or clear old data
- Best practice: default capture mode **Auto** filters negligible/infrequent queries; pair with **Auto size-based cleanup**; check Regressed Queries after every deployment/stats update/index change
- **Exam angle**: the three Query Store internal stores, `sp_query_store_force_plan`/`set_hints` syntax, hints overriding statement-level hints/plan guides, and the actual_state_desc=READ_ONLY failure detection pattern are the top testable specifics

## Identify and resolve blocking and deadlocks

- **Blocking** = normal mechanism (one session holds a lock, another waits) — problem only when duration affects users. **RCSI (default in Azure SQL DB) eliminates reader-writer blocking** but **writer-writer blocking still happens**
- **Head blocker** = session blocking others but itself unblocked (`blocking_session_id = 0`). Find via:

```sql
SELECT r.session_id, r.blocking_session_id, r.wait_type, r.wait_time, r.wait_resource, t.text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;
```

- Trace the chain: find rows with nonzero `blocking_session_id` pointing to a session that itself has `blocking_session_id = 0` → that's the head blocker
- **Common blocking scenarios — know cause and fix for each:**
    - Long-running query holding locks → optimize the query (indexes, rewrite)
    - **Sleeping session with uncommitted transaction** (query timeout/cancel without ROLLBACK) → fix with **`SET XACT_ABORT ON`** (auto-rollback on runtime error)
    - Session not fetching all result rows → **mitigated by RCSI by default** in Azure SQL DB (SELECT doesn't take shared locks)
    - Session in rollback state (large modification being undone) → **mitigated by ADR** (near-instant rollback regardless of size)
    - Orphaned connection (crashed client, connection not detected as closed) → `KILL <session_id>`
    - **Note the pairing**: RCSI mitigates unfetched-rows blocking; ADR mitigates lengthy-rollback blocking; the other three (long queries, sleeping uncommitted txns, orphaned connections) are **not** automatically mitigated — still fully relevant
- Resolution steps: identify head blocker → determine if it'll finish on its own or is waiting on external input → `KILL` if orphaned/abandoned → review its execution plan for missing indexes
- Prevention: keep transactions short, `SET XACT_ABORT ON`, move user-facing logic **outside** transaction boundaries
- **Deadlock** = circular lock dependency (A holds lock B needs, B holds lock A needs) — genuinely different from blocking (blocking resolves eventually; deadlock never will without intervention)
    - Deadlock monitor checks cyclically — **default interval 5 seconds**, drops to as low as **100ms** when deadlocks are frequent
    - Engine picks the **cheapest-to-rollback** transaction as victim, rolls it back, returns **error 1205** to the app; the other transaction proceeds
    - Capture mechanism differs by platform:
        - **SQL Server / Azure SQL MI**: `system_health` Extended Events session captures deadlocks **by default**; query via `sys.dm_xe_session_targets`/`sys.dm_xe_sessions`
        - **Azure SQL Database**: must create a **custom** Extended Events session capturing `sqlserver.database_xml_deadlock_report`; query via database-scoped `sys.dm_xe_database_sessions`/`sys.dm_xe_database_session_targets`

```sql
CREATE EVENT SESSION [deadlocks] ON DATABASE
ADD EVENT sqlserver.database_xml_deadlock_report
ADD TARGET package0.ring_buffer
WITH (STARTUP_STATE = ON, MAX_MEMORY = 4 MB);
ALTER EVENT SESSION [deadlocks] ON DATABASE STATE = START;
```

- Deadlock graph = 3 sections: **victim-list** (which txn was killed), **process-list** (each process's query/isolation level/lock mode), **resource-list** (locked resources + owner/waiter)
- Azure SQL DB also supports **portal-configured deadlock alerts**
- **Deadlock prevention** — memorize this list:
    - Access objects in a **consistent order** across all transactions (standardize via stored procs)
    - Keep transactions short
    - Use **row-versioning isolation** (RCSI removes a common deadlock source; optimized locking helps further)
    - Add indexes to narrow lock scope (fewer rows scanned = fewer locks)
    - Use **plan forcing** if a plan regression caused wider scans/more locks
- **App-level handling**: always retry on **error 1205** — catch, `ROLLBACK`, brief randomized delay (e.g., 1-3s with jitter to avoid two transactions re-deadlocking each other immediately), retry

```sql
BEGIN CATCH
    IF ERROR_NUMBER() = 1205
    BEGIN
        ROLLBACK TRANSACTION;
        WAITFOR DELAY '00:00:01';
        -- retry
    END
    ELSE BEGIN ROLLBACK TRANSACTION; THROW; END
END CATCH;
```

- **Exam angle**: head-blocker identification logic, the RCSI-mitigates-vs-ADR-mitigates-vs-neither-mitigates mapping across the five blocking scenarios, error **1205** for deadlock victims, and the SQL Server-default vs Azure-SQL-DB-custom-session distinction for deadlock capture are all high-yield, specific, testable facts