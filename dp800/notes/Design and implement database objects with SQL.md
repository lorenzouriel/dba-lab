## Introduction
- Database object design decisions are **more permanent** than app code — changing rowstore→columnstore, adding temporal, switching IDENTITY→SEQUENCE = migrations that can lock tables for hours
- Module spans four platforms: SQL Server, Azure SQL DB, Azure SQL MI, SQL DB in Fabric
- Core areas: table design, specialized table types, constraints/validation, advanced features (JSON, indexing, SEQUENCE), partitioning
- **Exam angle**: expect platform-comparison questions (which platform supports what) and "which object type fits this scenario" questions

## Understand your SQL platform choices
- **IaaS vs PaaS**: PaaS (Azure SQL DB, MI, Fabric SQL DB) = Microsoft manages below the DB layer (servers, OS, patching, engine); you manage tables/indexes/data. IaaS (SQL Server on Azure VMs) = you control the OS + engine.

- **Azure SQL Database** tiers:
    - **Hyperscale**: no fixed max size, storage auto-expands, pay for what you use, fast read-scale via replicas
    - **Serverless**: auto-scales compute, auto-pauses when idle (billed only for storage) → **remember: design connection retry logic for resume delays, avoid long transactions that block autopause**
    - Built-in intelligent query processing / automatic tuning / automatic plan correction
    - 99.99% SLA HA built-in

- **Azure SQL Managed Instance**: near-100% compat with latest SQL Server Enterprise, auto-patched, native VNet integration
    - Instance-level features PaaS lacks in Azure SQL DB: **SQL Agent, Service Broker, linked servers, cross-DB queries (3-part naming), DB mail**
    - Managed Instance **link** = distributed availability groups, near real-time sync SQL Server↔Azure (hybrid, read offload, DR, minimal-downtime migration)
    - In-Memory OLTP only in Business Critical tier

- **SQL Server on Azure VMs (IaaS)**: full control of engine/OS; SQL IaaS Agent extension → automated backups, patching, Key Vault integration, tempdb config, best-practices assessment

- **SQL Database in Fabric**: same engine as Azure SQL DB + auto **mirroring** to OneLake as **Delta Parquet** (no ETL needed) → analytics run against the Parquet copy via **SQL analytics endpoint**, not the live OLTP table (so reporting doesn't slow transactions)
    - Cross-database 3-part-name queries across Fabric warehouses/lakehouses
    - Auto index creation, GraphQL API, SqlPackage (.bacpac/.dacpac), git integration

- **Exam angle**: know exactly which platform gives you SQL Agent / linked servers / cross-DB queries vs which auto-mirrors to OneLake — classic distractor territory

## Build effective tables
- Data type choice is **hard to change later** (table rebuilds = downtime) — pick right at design time

- **DECIMAL not FLOAT for money** — FLOAT introduces rounding errors that can corrupt every downstream calc

- **INT over UNIQUEIDENTIFIER for PK when possible** — GUID triples index size, slows every JOIN

- Type cheat sheet: INT(4B)/BIGINT(8B)/DECIMAL, VARCHAR(1B/char) vs NVARCHAR(2B/char, Unicode) vs CHAR(fixed), DATE(3B)/DATETIME2(6-8B, better precision than legacy DATETIME)/DATETIMEOFFSET(10B), VARBINARY(MAX), UNIQUEIDENTIFIER(16B), native JSON type (SQL Server 2025+)

- **VARCHAR vs NVARCHAR**: use VARCHAR when ASCII-only (halves storage — e.g., ~300MB saved on 10M rows), NVARCHAR only when you need Unicode/international data

- Row size math matters for exam: sum fixed columns + avg variable columns + ~7 bytes row overhead

- Design best practices to memorize: appropriate types, plan for table size, meaningful constraints, plan for growth, index strategically, **columnstore for analytics**, normalize appropriately, monitor row/page compression

## Optimize with indexes
- Indexes speed reads but **cost storage + slow INSERT/UPDATE/DELETE** (maintenance overhead) — classic tradeoff question

- **Clustered index**: defines physical row order, only ONE per table, best for range queries/narrow stable keys (identity, date)

- **Nonclustered index**: separate structure with pointers to data rows, MULTIPLE allowed, best for selective lookups/joins/covering queries (INCLUDE columns)

- **Columnstore**:
    - Stores data column-by-column in **rowgroups** (up to 1,048,576 rows each), each column compressed independently
    - Inserts go to **deltastore** (B+ tree) until ≥102,400 rows accumulate → **tuple-mover** background process compresses into columnstore; bulk loads of ≥102,400 rows skip deltastore entirely
    - **CCI (Clustered Columnstore Index)**: replaces the rowstore entirely, becomes primary storage — no row-based storage left
    - **NCCI (Nonclustered Columnstore Index)**: secondary columnar copy alongside rowstore — best of both for mixed OLTP+analytics on same table
    - **Use when**: data warehouse fact tables, reporting, historical/archive data (millions+ rows)
    - **Avoid when**: <1M rows, high-frequency updates/deletes (causes fragmentation via delete-marking), single-row lookups

- Monitor via `sys.dm_db_column_store_row_group_physical_stats` — watch for high deleted_rows or many small rowgroups → fix with `ALTER INDEX REORGANIZE`

- **Exam angle**: memorize the 102,400-row deltastore threshold and CCI vs NCCI distinction — this is prime exam bait

## Use specialized table types
- **In-Memory OLTP**: `MEMORY_OPTIMIZED = ON`, data in RAM, lock-free optimistic concurrency; can't use MAX types (VARCHAR(MAX) etc.); still durable — transaction log still written to disk (`DURABILITY = SCHEMA_AND_DATA`); use for session state, high-freq OLTP, caching, ETL staging

- **Temporal tables**: `SYSTEM_VERSIONING = ON` + `PERIOD FOR SYSTEM_TIME` with two GENERATED ALWAYS DATETIME2 columns; auto-creates a linked history table; query with `FOR SYSTEM_TIME AS OF`; **roughly doubles storage**; zero app code changes needed; use for compliance/audit, point-in-time queries, Type 2 SCD automation

- **External tables**: `CREATE EXTERNAL TABLE ... WITH (LOCATION, DATA_SOURCE, FILE_FORMAT)` — query data lake files (Parquet/CSV) without moving them; **read-only**, slower (network+parsing latency), limited indexing; use for data lake integration, federated queries, cost-avoidance on duplication

- **Ledger tables**: `LEDGER = ON` — cryptographic tamper-evidence, blockchain-inspired
    - **Updatable ledger**: allows INSERT/UPDATE/DELETE, tracks history like temporal tables + crypto verification
    - **Append-only ledger**: `APPEND_ONLY = ON` — INSERT only, true immutability
    - Can combine ledger + temporal on same table
    - Verify integrity via `sys.database_ledger_transactions` and `sp_verify_database_ledger`
    - Use for financial transactions, legal records, supply chain, healthcare, government

- **Graph tables**: `AS NODE` / `AS EDGE` syntax; node tables get hidden `$node_id`; edge tables get `$edge_id`, `$from_id`, `$to_id`; query relationships with `MATCH` syntax
    - Use for highly connected data (multi-hop relationship queries); avoid for simple FK parent-child or stable structured schemas

- **Exam angle**: match scenario → table type (compliance = ledger, audit history = temporal, lakehouse files = external, RAM-speed = in-memory, relationships = graph). Know the exact syntax keywords: `MEMORY_OPTIMIZED`, `SYSTEM_VERSIONING`, `LEDGER`, `APPEND_ONLY`, `AS NODE`/`AS EDGE`

## Enforce data integrity with constraints
- Constraints enforce rules at the **engine level** — can't be bypassed by app code, bulk imports, or ad-hoc queries (unlike app-level validation)

- **PRIMARY KEY**: auto-creates unique index, only one per table, all columns must be NOT NULL

- **FOREIGN KEY**: referential integrity; supports `CASCADE`, `SET NULL`, `SET DEFAULT` on delete/update; indexing FK columns isn't automatic/required but recommended (frequently used in JOINs)

- **UNIQUE**: unlike PK, **allows NULL** (only one NULL per column); auto-creates unique nonclustered index

- **CHECK**: any boolean expression; **gotcha — NULL evaluates to UNKNOWN, not FALSE**, so `CHECK (MyColumn = 10)` still allows NULL inserts

- **DEFAULT**: supplies value when none given; best practice = **explicit constraint names** (`CONSTRAINT DF_...`) not system-generated (differ across environments)

- **SEQUENCE objects** — key exam differentiator vs IDENTITY:

|Feature|Sequence|Identity|
|---|---|---|
|Tied to one table|No|Yes|
|Shared across tables/columns|Yes|No|
|Get next value before INSERT|Yes|No|
|Custom min/max|Yes|Limited|
|Retrieve multiple at once|Yes (`sp_sequence_get_range`)|No|
|Cycle/restart|Yes|No|
|Change increment after creation|Yes|No|

- Sequence values **not automatically unique** — must add UNIQUE constraint yourself if needed

- Sequence numbers generated **outside transaction scope** — consumed even on rollback (gaps possible)

- Syntax: `CREATE SEQUENCE ... START WITH ... INCREMENT BY ... MINVALUE ... MAXVALUE ... NO CYCLE`; use `NEXT VALUE FOR`; `ALTER SEQUENCE ... RESTART WITH`

- **Exam angle**: the NULL+CHECK gotcha and the Sequence-vs-Identity table are very testable

## Manage JSON columns and indexes
- **Native `json` data type** (SQL Server 2025+) — binary format, faster reads (pre-parsed) and writes (partial updates), better compression than NVARCHAR(MAX). Pre-2025: store JSON as NVARCHAR(MAX)

- `JSON_VALUE` → extract scalar; `JSON_QUERY` → extract object/array; `.modify()` (2025+ preview) → update single property in place without rewriting doc; `JSON_MODIFY` → works with both native json and NVARCHAR(MAX)

- **Can't index the json type column directly** — create a **computed column** via `JSON_VALUE` extraction, then index the computed column

- `JSON_PATH_EXISTS` in a CHECK constraint → validate required JSON properties exist

- Design principle: keep predictable/consistent fields as regular typed columns; JSON only for - variable/flexible parts (multi-tenant custom fields, API responses, audit before/after states, user prefs)

- **Exam angle**: remember you must index via a **computed column**, not the JSON column itself — common trick question

## Partition tables for scale
- Partitioning decisions are **nearly permanent** — bad partition key = worse than no partitioning, and repartitioning multi-TB tables = hours of downtime

- Three components: **partition function** (how data divides), **partition scheme** (maps partitions→filegroups), **partition column**

- Benefits: partition elimination, parallel processing across partitions, per-partition stats, shallower B-trees; operationally — granular maintenance (rebuild current partition only), fast archival via **partition switching** (metadata op = seconds vs hours-long DELETE/lock), tiered storage

- **Use partitioning when**: queries filter on one column 80%+ of the time, regular archival cadence, need to rebuild indexes on recent data only, multi-TB with tiering needs

- **Don't partition when**: full-table scans or filters vary, single-row lookups dominate, no column aligns with query pattern

- Syntax pattern to remember:
```sql
CREATE PARTITION FUNCTION PF_X (DATETIME2) AS RANGE RIGHT FOR VALUES (...);
CREATE PARTITION SCHEME PS_X AS PARTITION PF_X ALL TO ([PRIMARY]);
CREATE TABLE T (... ) ON PS_X(PartitionColumn);
```

- **RANGE RIGHT** typically used for dates (keeps same-day values together); **RANGE LEFT** used for categorical/string boundaries

- **Partition column must be part of the PRIMARY KEY** for clustered index alignment — required, testable

- Partition key selection criteria: appears in WHERE 80%+ of time, balanced distribution, matches archival pattern, **immutable after insert**

- Common granularity: daily (high volume/short retention) → weekly → monthly (most common) → quarterly → yearly (archive)

- **Aligned vs nonaligned indexes**: aligned = same partition scheme as table → enables partition switching, independent rebuilds. Nonaligned = different/no partitioning → **cannot** use partition switching, unsupported beyond 1,000 partitions

- Managing partitions:
    - `$PARTITION.PF_X(column)` → view partition assignment/stats
    - `ALTER PARTITION FUNCTION PF_X() SPLIT RANGE (...)` → add new partition boundary
    - `ALTER PARTITION FUNCTION PF_X() MERGE RANGE (...)` → archive/remove boundary

- Best practice: target **millions of rows per partition, not thousands** — over-partitioning adds overhead

- **Exam angle**: RANGE RIGHT vs LEFT, partition key must be in PK, aligned index requirement for switching, and the SPLIT/MERGE syntax are all classic DP-800 targets