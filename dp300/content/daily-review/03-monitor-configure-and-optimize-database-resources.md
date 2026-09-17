# DP-300 — Monitor, Configure, and Optimize Database Resources

## 1. Describe performance monitoring

### Remember

- Azure Monitor collects OS-level metrics (CPU, disk, network); SQL-specific detail needs Performance Monitor (`perfmon`) or DMVs.
- Metrics retain 93 days in Azure Monitor by default — archive to Storage for longer.
- A **baseline** is what lets you tell "normal" from "problem." No baseline = every issue looks equally urgent.
- Extended Events replaced Profiler/trace — lighter weight, filterable.
- Query Performance Insight (QPI) needs no setup — built into Azure SQL Database.
- Database watcher (preview) is Azure SQL/Managed Instance-specific, centralized, low-latency monitoring.

### Azure Monitor and Performance Monitor

- Azure VM agent → Azure Monitor → default OS metrics (CPU, network, disk).
- **Monitoring Insights** adds storage latency/memory/disk capacity, stored in Log Analytics (queried with KQL).
- SQL-specific metrics (file sizes, patching) come from the **SQL VM resource provider** (SQL IaaS Agent Extension), not the base VM metrics.
- `perfmon` counters can forward into Azure Monitor for a single cross-server view.

### Critical performance metrics and alerts

- Alerts scoped to: single resource, resource group, or subscription (per region).
- **Static threshold** (e.g., CPU > 80%) vs **Dynamic Threshold** (learns seasonality automatically).
- Action groups: notification (email/SMS/voice) vs automation (Runbook, Function, Logic App, webhook).
- Key SQL Server counters to baseline:

| Counter | Signal |
|---|---|
| `% Processor Time` | overall CPU load |
| `Paging File % Usage` | memory pressure spilling to disk |
| `Avg. Disk sec/Read`/`Write` | storage latency (<20ms normal, <10ms Premium) |
| `Processor Queue Length` | CPU pressure if > 0 |
| `Page Life Expectancy` | how long pages stay in buffer pool — watch for sudden drops |
| `Batch Requests/sec` | overall server busy-ness |
| `SQL Compilations/Recompilations per sec` | plan cache churn, ad-hoc/memory pressure |

- DMV `sys.dm_os_volume_stats` gives file read/write latency — not visible in perfmon.

### Establishing baseline metrics

- On Linux, use InfluxDB + Collectd + Grafana in place of Performance Monitor.
- **Easy rule:** correlate OS-level counters with `sys.dm_os_wait_stats` to separate hardware bottlenecks from query/code problems.

### Extended Events

- Four channels: **Admin** (actionable problems), **Operational** (diagnostics/triggers), **Analytic** (high-volume perf events), **Debug** (Microsoft support only).
- Common targets:

| Target | Processing |
|---|---|
| Event Counter | Synchronous |
| Event File | Asynchronous |
| Event Pairing | Asynchronous |
| ETW | Synchronous |
| Histogram | Asynchronous |
| Ring Buffer | Asynchronous (in-memory, not persisted) |

- Filter every event you capture — reduces overhead, sharpens focus.
- Causality tracking adds a GUID + sequence number to replay event order.

```sql
CREATE EVENT SESSION test_session ON SERVER
    ADD EVENT sqlos.async_io_requested,
    ADD EVENT sqlserver.lock_acquired
    ADD TARGET package0.etw_classic_sync_target
    WITH (MAX_MEMORY=4MB, MAX_EVENT_SIZE=4MB);
```

### Database watcher (preview)

- Azure SQL Database / Managed Instance only.
- Needs a data store: Azure Data Explorer cluster or Real-Time Intelligence (Fabric) database.
- Low-latency ingestion (seconds), single-pane dashboards, parameterized alert templates.

### Query Performance Insight

- Azure SQL Database only. Three views: **Resource Consuming Queries** (top 5 by CPU/Data IO/Log IO), **Long Running Queries** (top 5 by duration, 24h), **Custom**.
- Doesn't show the execution plan directly — but its query ID matches the Query Store query ID, so you jump there for the plan.

---

## 2. Explore performance-based database design

### Remember

- OLTP → normalize (fast, consistent writes). Data warehouse → denormalize (fewer joins, faster reads).
- Normalization prevents **update anomalies**; denormalization trades that risk for query speed.
- Wrong data types waste storage and can force implicit conversions that block index seeks.
- Clustered index = the table, physically ordered by key. Only one per table.
- **Exam idea:** columnstore index questions almost always hinge on the 102,400-row bulk-load threshold and 1,048,576-row rowgroup cap.

### Normalization

| Form | Requirement |
|---|---|
| 1NF | separate table per entity, no repeating groups, has a key |
| 2NF | non-key columns depend on the *whole* composite key |
| 3NF | non-key columns depend only on the key, not on each other (no transitive dependency) |

- 3NF is the typical OLTP target; going further isn't usually worth it.
- Denormalization trades CPU-heavy joins for read-simplicity — good for read-heavy/reporting workloads.

### Star vs snowflake schema

| Schema | Dimensions | Tradeoff |
|---|---|---|
| Star | denormalized | fewer joins, more storage |
| Snowflake | normalized | less storage, more joins/complexity |

- Fact table = measurements/events; dimension tables = descriptive attributes joined by key (e.g., `ProductKey`).

### Data types

- Implicit conversion can silently degrade a plan (index scan instead of seek); prefer explicit `CAST`/`CONVERT`.
- Oversized data types waste storage and extra page reads.
- Some conversions are simply impossible (e.g., date → bit).

### Design indexes

- **Clustered**: keep the key narrow, unique/high-cardinality, ideally the natural sort/access column. No clustered index = heap.
- **Nonclustered**: separate structure, key + pointer to the row; add `INCLUDE` columns to build a **covering index** and eliminate key lookups.
- Filtered index: index only a subset of rows (`WHERE CurrentFlag = 1`) — great when most rows share one value.
- Indexed views help when a view aggregates/joins heavily.

| Index type | Best for |
|---|---|
| Clustered (b-tree) | primary access path, range scans |
| Nonclustered (b-tree) | seeks on predicate/join columns |
| Filtered | large tables, skewed value distribution |
| Clustered columnstore | large analytical/fact tables |
| Nonclustered columnstore | HTAP: filtered + row insert alongside reporting |

- Columnstore: minimum 102,400 rows to bulk-load directly into the index; rowgroup max 1,048,576 rows; loads under the minimum go to a b-tree **delta store**, later moved by the async **tuple mover**.
- Batch execution mode processes ~900 rows at a time — big CPU win for columnstore-style analytics.
- Index design principles: know the workload, index for the most frequent queries, prefer integer/unique/non-null columns, keep nonclustered indexes narrow, weigh scan cost against table size.

---

## 3. Explore query performance optimization

### Remember

- SQL Server's optimizer is **cost-based** — bad statistics or missing indexes lead directly to bad plans.
- Query Store = per-database, persistent history of plans + runtime stats + wait stats. It's the first stop for regressions.
- SARGable predicates enable index seeks; non-SARGable ones force scans.
- Isolation level controls how *long* locks are held, not whether a write takes an exclusive lock.
- Blocking is normal; only *prolonged* blocking that hurts users is a problem. Deadlocks always kill a victim (error 1205).

### Query plans and the optimizer

- Flow: parse → Algebrizer (bind/validate) → plan cache lookup by `query_hash` → cost-based optimization if no cached plan → execute.
- Memory grant is based on row estimates; bad estimates cause `RESOURCE_SEMAPHORE` waits (too big) or tempdb spills (too small).
- Plan types:

| Plan type | Executes query? | Shows runtime stats? |
|---|---|---|
| Estimated | No | No |
| Actual | Yes | Yes |
| Live Query Statistics | Yes (animated) | Yes, refreshes live |

### Estimated vs actual plans

- Estimated: **Ctrl+L**, instant, no execution. Actual: **Ctrl+M**, requires execution.
- Plan flow reads right-to-left, top-to-bottom; thick connector lines = large row counts, a tuning signal.
- **Lightweight query profiling**: ~2% overhead vs ~75% for legacy profiling; on by default in SQL Server 2019+/Azure SQL.
- `sys.dm_exec_query_plan_stats` (with trace flag 2451 or `LAST_QUERY_PLAN_STATS` db-scoped option) retrieves the last actual plan for any cached query — cheap way to get actual-plan detail without re-running.

### Dynamic management views and functions

- DMVs/DMFs = `sys.dm_*`, server-scoped (needs `VIEW SERVER STATE`) or database-scoped (needs `VIEW DATABASE STATE`).
- Azure SQL Database has its own subset (e.g., `sys.dm_db_resource_stats`); some SQL Server DMVs (like `sys.dm_os_wait_stats`) are server-scoped and don't apply directly to Azure SQL DB.

### Query Store

- Three stores: **plan store**, **runtime stats store**, **wait stats store**.
- Default ON for Azure SQL DB and new SQL Server 2022 databases; enable manually pre-2022 (`ALTER DATABASE ... SET QUERY_STORE = ON`).
- Key views: Regressed Queries, Overall Resource Consumption, Top Resource Consuming Queries, Queries With Forced Plans, Queries With High Variation, Query Wait Statistics, Tracking Query.
- **Plan forcing** pins a known-good plan without touching app code:

```sql
EXEC sp_query_store_force_plan @query_id=73, @plan_id=79;
```

- Automatic plan correction reads `sys.dm_db_tuning_recommendations`; can auto-force via `ALTER DATABASE ... SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON)`.

### Identify problematic query plans

- **SARGability**: `WHERE lastName LIKE '%SMITH%'` or `WHERE CONVERT(...) = ...` block index seeks. `LIKE 'M%'` (no leading wildcard) is fine.
- Missing indexes surface via `sys.dm_db_missing_index_details`; check usage with `sys.dm_db_index_usage_stats` / `sys.dm_db_index_operational_stats` before dropping anything.
- Out-of-date statistics: `sys.dm_db_stats_properties` shows last update + modification count.
- **Parameter sniffing** — plan optimized for the first parameter value, bad for skewed data:

| Fix | Tradeoff |
|---|---|
| `RECOMPILE` hint / `WITH RECOMPILE` | always fresh plan, more CPU |
| `OPTIMIZE FOR UNKNOWN` | consistent but not best-case plan |
| Conditional `OPTION (RECOMPILE)` | precise but higher dev effort |

- Anti-patterns: cursors/`WHILE` loops (row-by-row), multi-statement TVFs and scalar functions (fixed row-count estimates pre-Intelligent Query Processing), using the DB for string/JSON manipulation instead of data access.

### Describe blocking and locking

- Blocking = one session holds an incompatible lock another session needs. Normal; only sustained blocking is a problem.
- Lock escalation: > 5,000 row locks on one object in one statement → escalates to a table lock.
- Deadlock = circular wait; engine kills the cheapest-to-rollback transaction (the **victim**), returns error `1205`. Logged in the `system_health` XEvent session by default.
- Row versioning (row-versioning isolation levels) stores prior row versions in tempdb to stop readers blocking writers.

| Isolation level | Behavior |
|---|---|
| Read Uncommitted | dirty reads allowed, no read locks |
| Read Committed (default) | no dirty reads, read locks released immediately |
| Repeatable Read | holds read+write locks until transaction end |
| Serializable | strongest; also locks ranges (no phantom rows) |
| Read Committed Snapshot (RCSI) | row versions instead of read locks — no reader/writer blocking |
| Snapshot | transaction-level consistent view; vulnerable to update conflicts |

- **Easy rule:** isolation level changes lock *duration*, not whether a write takes an exclusive lock.
- Monitor open transactions with `sys.dm_tran_active_transactions` + `sys.dm_tran_session_transactions`; monitor blocking with `sys.dm_tran_locks` joined to `sys.dm_exec_requests`, or Extended Events for ongoing capture.

---

## 4. Evaluate performance improvements

### Remember

- Wait statistics tell you what the engine spent time waiting on — the fastest way to find a systemic bottleneck.
- Tune indexes before hardware; missing indexes are the most common cause of CPU/storage/memory pressure.
- Query hints (`OPTION (...)`) override the optimizer — use sparingly, they age badly across SQL Server versions.
- Diagnostic decision tree: is the problem **Running** (high CPU) or **Waiting** (blocked on a resource)?

### Wait statistics

| Wait category | Example | Meaning |
|---|---|---|
| Resource wait | locks, latches, I/O | thread wants a resource another thread holds |
| Queue wait | deadlock monitor | thread idle, waiting for work |
| External wait | linked server, network | waiting on something outside SQL Server |

- Query with `sys.dm_os_wait_stats` (SQL Server) / `sys.dm_db_wait_stats` (Azure SQL DB); `sys.dm_exec_session_wait_stats` for active sessions.

| Wait type | Usually means |
|---|---|
| `RESOURCE_SEMAPHORE` | waiting on memory grant — bad stats/missing indexes/high concurrency |
| `LCK_M_X` | blocking — consider RCSI, better indexing, shorter transactions |
| `PAGEIOLATCH_SH` | missing indexes causing scans, or slow storage |
| `SOS_SCHEDULER_YIELD` | CPU pressure, often paired with `CXPACKET` |
| `CXPACKET` | parallelism — tune MAXDOP / cost threshold for parallelism, or fix the underlying CPU-heavy query |
| `PAGELATCH_UP` on `2:1:1` | tempdb PFS contention — add tempdb data files (1 per core, up to 8) |

### Tune and maintain indexes

- Workflow: check usage (`sys.dm_db_index_operational_stats`, `sys.dm_db_index_usage_stats`) → drop unused/duplicate indexes carefully → build indexes from Query Store/XEvents findings → test in non-prod → deploy.
- Leading index column should be the most selective and most frequently filtered; equality-comparison columns should precede inequality-comparison columns.
- **Resumable index** operations (2019+) let you `PAUSE`/resume a build instead of losing all progress on cancel:

```sql
CREATE INDEX IX_Customer_PersonID_ModifiedDate ON Sales.Customer (PersonID, StoreID)
WITH (RESUMABLE=ON, ONLINE=ON);

ALTER INDEX IX_Customer_PersonID_ModifiedDate ON Sales.Customer PAUSE;
```

### Understand query hints

- `OPTION (...)` clause forces optimizer behavior for `SELECT`/`INSERT`/`UPDATE`/`DELETE`.
- Common hints: `MAXDOP <n>`, `RECOMPILE`, `OPTIMIZE FOR`, `USE PLAN`, `{LOOP|MERGE|HASH} JOIN`, `FAST <n>`.
- **Query Store hints** (`sp_query_store_set_hints`) apply a hint by `query_id` without touching application code — useful when query text is hardcoded/generated.

### Explore performance scenarios

- Decision tree: **Running** (high CPU) vs **Waiting** (blocked on a resource).
- Running-scenario tools: Query Store, `sys.dm_exec_requests` (state `RUNNABLE` + `SOS_SCHEDULER_YIELD`), `sys.dm_exec_query_stats`, `sys.dm_exec_procedure_stats`.
- Waiting-scenario tools: `sys.dm_os_wait_stats`, `sys.dm_exec_requests`, `sys.dm_os_waiting_tasks` (live, per-task) vs `sys.dm_os_wait_stats` (aggregated over time).
- Azure SQL resource-usage DMVs: `sys.dm_db_resource_stats` (SQL DB, 15s snapshots), `sys.server_resource_stats` (Managed Instance), `sys.dm_user_db_resource_governance` (governance config).
- Azure-specific waits: `LOG_RATE_GOVERNOR` / `POOL_LOG_RATE_GOVERNOR` / `INSTANCE_LOG_GOVERNOR` (log throttling), `THREADPOOL` (worker limit, MI), `HADR_*` (Business Critical, expected — uses availability-group tech under the hood), `RBIO*` (Hyperscale page server reads).

---

## 5. Configure databases for optimal performance

### Remember

- Index maintenance thresholds: **5–30% fragmentation → reorganize**, **>30% → rebuild**.
- Rebuild updates statistics; reorganize does not.
- Compatibility level gates Intelligent Query Processing (IQP) features — 140/150/160 unlock progressively more.
- Azure SQL Database can auto-create/drop indexes and auto-force good plans; on-prem SQL Server cannot do index automation.

### Explore database maintenance checks

- Fragmentation = logical order no longer matches physical order after `INSERT`/`UPDATE`/`DELETE` churn.
- Reorganize = online, defrags leaf level, compacts by fill factor. Rebuild = can be online (parallel build then swap, more space) or offline (drop and recreate).
- Detect with `sys.dm_db_index_physical_stats` (b-tree) / `sys.dm_db_column_store_row_group_physical_stats` (columnstore).
- Statistics drive cardinality estimates → drive plan choice (seek vs scan). Keep `AUTO_CREATE_STATISTICS` on.
- Maintenance automation options: SQL VM → SQL Agent / Task Scheduler. Azure SQL DB → Azure Automation runbooks, remote SQL Agent job, or elastic jobs. Managed Instance → SQL Agent.

### Database scoped configuration options

- Two syntaxes, no functional distinction: `ALTER DATABASE` (recovery model, automatic tuning, auto stats, Query Store, snapshot isolation) vs `ALTER DATABASE SCOPED CONFIGURATION` (MAXDOP, Legacy Cardinality Estimation, Last Query Plan Stats, Optimize for Ad Hoc Workloads).
- Compatibility level controls which optimizer behaviors/IQP features are active — bump it deliberately, test first.

### Describe automatic tuning

- Driven by Query Store data. Two features: **automatic plan correction** (force last good plan) and **automatic index management** (Azure SQL DB only — create/drop indexes).
- Plan-forcing rule of thumb: forces the recommended plan when the old plan had a higher error rate, estimated CPU gain > 10 seconds, and the new plan performs better; reverts after 15 executions if it stops winning.

```sql
ALTER DATABASE [WideWorldImporters] SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON);
```

- Check recommendations: `sys.dm_db_tuning_recommendations`. Check enabled features: `sys.database_automatic_tuning_options`.
- Automatic index management monitors resource availability before creating an index, and re-creates a dropped index automatically if performance regresses.

### Describe intelligent query processing

- Enable by raising compatibility level (150+ for most IQP, 160 for the full set on SQL Server 2022/Azure SQL).

```sql
ALTER DATABASE [WideWorldImportersDW] SET COMPATIBILITY_LEVEL = 160;
```

| Feature | Fixes |
|---|---|
| Adaptive Joins | defers hash vs nested loops choice until row count is known (batch mode only) |
| Interleaved Execution | actual row count for multi-statement TVFs before compiling the rest of the plan |
| Memory Grant Feedback | corrects over/under memory grants from bad estimates |
| Table variable deferred compilation | fixes the "always 1 row" table variable estimate |
| Batch mode on rowstore | batch processing without requiring a columnstore index |
| Scalar UDF inlining | turns scalar functions into subqueries — enables costing + parallelism |
| Approximate count distinct | fast `COUNT(DISTINCT ...)` on huge tables, ~2% error / 97% confidence |

---

## 6. Configure SQL Server resources for optimal performance

### Remember

- Data/log files on Premium SSD v2/Ultra disk or Premium SSD; tempdb on local SSD (`D:\`) — it's rebuilt on restart, so no durability risk.
- Read caching: enable on data volume, never on the log volume.
- MAXDOP trades CPU parallelism for memory pressure — tune per workload, configurable at database, query-hint, or Resource Governor level.
- Resource Governor manages CPU/memory/IOPS per workload group — for multitenant instances or protecting user queries during maintenance windows.

### Optimize Azure storage for VMs

| Storage type | Typical SQL Server use |
|---|---|
| Blob Storage | backups (`BACKUP ... TO URL`) |
| File Storage | FCI storage target (mounted file share) |
| Disk Storage | data/log files (block storage) |

| Managed disk tier | Use case |
|---|---|
| Ultra disk | mission-critical, sub-ms latency, independently scalable IOPS/throughput/size |
| Premium SSD v2 | sub-ms latency at lower cost than Ultra, independently scalable — strong default |
| Premium SSD | most production workloads, single-digit ms latency, supports read caching |
| Standard SSD | dev/test, light web workloads |
| Standard HDD | infrequently accessed backups/files |

- Striping (Windows Storage Spaces, no redundancy — Azure already triples-replicates) sums IOPs and capacity across disks. Not applicable to Ultra disk (already independently scalable).
- Best practices: separate data/log volumes, read cache on data only, plan for +20% IOPS/throughput headroom, tempdb on local SSD, enable instant file initialization, move trace/error logs off the OS disk, use Ultra disk if you need sub-1ms latency.

### Virtual machine resizing

- SQL Server licensing is core-based; **constrained vCPU** SKUs give full memory/storage/IO bandwidth at a lower core (license) count — good for memory-hungry, not CPU-bound, workloads.
- Most production SQL Server runs on general purpose or memory-optimized VM families.
- Resizing requires a restart; some size changes require deallocate + resize first.

### Optimize database storage

- Azure SQL Database: one database file (Hyperscale has several), no file placement control — Azure guarantees IOPS/latency/throughput instead. Managed Instance allows adding files and user filegroups, still no physical placement.
- **Proportional fill**: SQL Server writes to files in proportion to their free space, not evenly — an unevenly sized tempdb can bottleneck on the largest file.
- tempdb file count: SQL Server auto-configures up to 8 files at setup (matching CPU count); Azure SQL DB scales file count with vCores (max 16); Managed Instance always gets 12 files regardless of vCores.
- tempdb metadata optimization (SQL Server 2019+, latch contention fix) is **not** available in Azure SQL DB/MI.
- **MAXDOP:** higher = more parallel threads = faster but more memory pressure; lower = less memory pressure, more storage headroom. Configurable via `ALTER DATABASE SCOPED CONFIGURATION`, query hint, `sp_configure` (MI), or Resource Governor (MI).

### Control SQL Server resources — Resource Governor

- Classifier function runs per new connection → assigns a **workload group** → mapped to a **resource pool** (physical resource limits).
- Always-present pools: `default`, `internal` (unrestrictable, critical engine functions).
- Per-pool limits: Min/Max CPU%, CPU cap, Min/Max memory%, NUMA affinity, Min/Max IOPS per volume.
- **Easy rule:** Min/Max CPU% only bites under contention — with no contention a pool can still use 100% CPU even if capped at 70%.
- Changes to a pool affect only new sessions, not in-flight ones (exception: external pools for ML Services).
- Primary use cases: multitenant instances needing consistent per-tenant performance; throttling maintenance jobs (index rebuilds, consistency checks) to protect user workloads.
