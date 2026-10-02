# DP-900 — Describe Considerations for Non-Relational Data on Azure

## 1. Azure Storage for non-relational data

### Remember

- Blobs = unstructured binary data. Containers group blobs; Entra ID + RBAC control access.
- Four blob access tiers: Hot, Cool, Cold, Archive — cost down, latency up as you go colder.
- Archive is offline. You must rehydrate (up to ~15 hours) before you can read it.
- Data Lake Storage Gen2 = Blob Storage + hierarchical namespace + POSIX ACLs.
- OneLake is Fabric's built-in, organization-wide data lake, built on ADLS Gen2, stored as Delta Parquet.
- Azure Files = cloud SMB/NFS file shares; Azure Table Storage = NoSQL key/value rows split into partitions.
- **Easy rule:** unstructured/binary → Blob. Hierarchical analytics files → Data Lake Gen2/OneLake. Network share → Files. Key/value rows → Table.

### Azure Blob Storage

- Stores massive unstructured data as **blobs** inside **containers** in a storage account.
- Entra ID is the recommended sign-in method; RBAC controls who can do what.
- "Folders" inside a container are virtual only — just `/` in the blob name, no real folder-level operations.

Blob types:

| Type | Structure | Best for | Max size |
|---|---|---|---|
| Block blob | Set of blocks (up to 4,000 MiB each) | Large binary objects, infrequent changes | ~190.7 TiB |
| Page blob | Fixed 512-byte pages | Random read/write (VM disks) | 8 TB |
| Append blob | Blocks appended to end only | Append-only logs | ~195 GB |

Access tiers:

| Tier | Storage cost | Access cost | Minimum retention | Notes |
|---|---|---|---|---|
| Hot | Highest | Lowest | — | Default; frequently accessed |
| Cool | Lower | Higher | 30 days | Infrequent access |
| Cold | Lower still | Higher | 90 days | Rarely accessed, still needs fast retrieval |
| Archive | Lowest | Highest | 180 days | Offline; rehydrate before reading (up to ~15h) |

- Lifecycle management policies auto-move blobs across tiers (Hot → Cool → Cold → Archive) based on days since modification, and can delete outdated blobs.
- **Exam idea:** to read an Archive blob you must change its tier to Hot/Cool/Cold and wait for rehydration — you cannot read it directly in Archive.

Redundancy:

| Option | What it does |
|---|---|
| LRS | 3 copies in a single datacenter |
| ZRS | Copies across 3 availability zones in the primary region |
| GRS | Async replication to a secondary region |
| GZRS | ZRS in primary + async replication to a secondary region |
| RA-GRS / RA-GZRS | Same as GRS/GZRS, plus read access to the secondary region |

### Azure Data Lake Storage Gen2

- Cloud-scale data lake built into Azure Storage: Blob scalability/tiers/lifecycle + a **hierarchical namespace**.
- Hierarchical namespace enables POSIX-compliant ACLs — fine-grained read/write/execute per file or folder, separate from RBAC.
- Must enable **Hierarchical Namespace** on the storage account (at creation, or upgrade later).
- **Easy rule:** enabling hierarchical namespace is one-way — you can't revert to a flat namespace.
- Analytics engines like Azure Databricks mount ADLS Gen2 as a distributed file system.

### Microsoft OneLake in Fabric

- Every Fabric tenant automatically provisions **OneLake** — a single, unified, organization-wide logical data lake, built on ADLS Gen2.
- Stores data in **Delta Parquet** format; supports existing ADLS Gen2 APIs/SDKs.
- Key benefits: one shared data lake org-wide (vs. many disconnected lakes), workspaces for distributed ownership/governance, open/compatible format, and OneLake File Explorer for easy navigation from Windows.
- **Remember:** no data movement/duplication needed across analytical engines — they all read the same OneLake data.

### Azure Files

- Cloud-based network file shares (the cloud equivalent of on-prem SMB shares).
- Up to 256 TiB per storage account (SSD tier; more for HDD), max single file size 4 TiB, up to 2,000 concurrent handles per file/directory.
- Two media tiers: **HDD** (lower cost) and **SSD** (higher throughput, higher cost).
- Two protocols:

| Protocol | OS support | Notes |
|---|---|---|
| SMB | Windows, Linux, macOS | Common cross-platform sharing |
| NFS | Linux (kernel 4.3+) only | Requires SSD tier + virtual network |

- Upload/manage via Azure portal or **AzCopy**; **Azure File Sync** keeps local cached copies in sync with the cloud share.

### Azure Table storage

- NoSQL **key/value** store: rows with columns, but no fixed schema across rows, no FKs/relationships/views/stored procedures.
- Every row needs a unique key made of **PartitionKey** + **RowKey**; a **Timestamp** column auto-records last modification.
- Data is typically **denormalized** — one row holds the whole logical entity (vs. spreading across relational tables).
- Rows sharing a PartitionKey live in the same **partition**; within a partition, rows are stored in RowKey order.
- Partitioning improves scalability/performance: partitions grow/shrink independently, and including the PartitionKey in a query narrows the search, cutting I/O.
- Supports fast **point queries** (single row by full key) and **range queries** (contiguous rows in a partition).
- **Exam idea:** Azure Cosmos DB for Table uses the same key/value model but adds better performance and global availability — it's the recommended choice for new key-value workloads.

---

## 2. Azure Cosmos DB fundamentals

### Remember

- Cosmos DB = fully managed, schema-agnostic, globally distributed NoSQL database (PaaS).
- Resource hierarchy: **Account → Database → Container → Items**. Partition key, throughput, indexing, TTL are set at the **container** level.
- Five consistency levels, ordered strongest→weakest: Strong, Bounded staleness, Session, Consistent prefix, Eventual. **Session** is the default/most common.
- Throughput is measured in **RU/s** (Request Units per second); every operation costs some RUs.
- Three throughput modes: Dedicated, Shared (DB-level, up to 25 containers), Serverless (pay-per-request, single region only).
- Five APIs: **NoSQL, MongoDB, Table, Cassandra, Gremlin** — same engine, different wire protocol/query language.
- **Easy rule:** new app with no legacy constraints → NoSQL API. Migrating an existing DB → pick the matching API (Mongo/Cassandra/Table/Gremlin).

### Describe Azure Cosmos DB

- PaaS: Microsoft handles infrastructure, provisioning, patching, backups.
- **Schema-agnostic**: items in the same container can have completely different properties.
- Indexes are created and maintained automatically on all item properties — no manual schema/index design required.

Resource hierarchy:

| Level | Role |
|---|---|
| Account | Top-level resource; can contain unlimited databases |
| Database | Logical namespace grouping containers |
| Container | Unit of storage/scaling; partition key, throughput, indexing, TTL configured here |
| Items | Individual entities (documents, rows, nodes, or edges depending on API) |

- **Partition key**: property chosen to spread data across logical partitions; each logical partition caps at 20 GB. Pick a key with many distinct values and even distribution.
- Global distribution: add/remove regions anytime; data auto-replicates; users read/write the nearest replica. Multi-region write accounts give high availability with ~4 ms read / ~5 ms write at the 99th percentile.

Consistency levels:

| Level | Guarantee |
|---|---|
| Strong | Reads always see the latest write |
| Bounded staleness | Reads lag writes by a configurable time/version window |
| Session | Consistent within a single client session (most common) |
| Consistent prefix | No out-of-order writes seen, but can be stale |
| Eventual | Weakest guarantee, highest availability |

Throughput modes:

| Mode | Description |
|---|---|
| Dedicated | Throughput reserved for one container |
| Shared | Throughput shared across up to 25 containers in a database |
| Serverless | No upfront provisioning, pay per request; single region only |

- **Autoscale**: set a max RU/s and Cosmos DB scales within that range automatically.
- **Exam idea:** Serverless accounts can't span multiple regions — need provisioned throughput for global distribution.

When to use / not use:

- Good fit: IoT/telemetry ingestion, gaming (leaderboards, profiles), retail/e-commerce catalogs and carts, web/mobile apps needing low latency at scale.
- Not a fit: complex multi-table joins (use Azure SQL Database) or large-scale historical analytics (use Fabric/Synapse).

### Identify Azure Cosmos DB APIs

- Cosmos DB stores data internally in its own format; the chosen **API** is just the wire-protocol/abstraction layer on top — chosen when you create the account.
- Main benefit: portability — point an existing MongoDB/Cassandra app at Cosmos DB with minimal code changes, and gain global distribution + managed throughput + SLAs.

| API | Data model | Query language | Best for |
|---|---|---|---|
| NoSQL | JSON documents | SQL-like syntax | New applications (recommended default) |
| MongoDB | BSON documents | MongoDB Query Language (MQL) | Existing MongoDB apps/teams |
| Table | Key-value rows | REST endpoint (PartitionKey/RowKey) | Existing Azure Table Storage apps, new key-value workloads |
| Cassandra | Column-family | CQL (Cassandra Query Language) | Existing Apache Cassandra workloads |
| Gremlin | Graph (vertices/edges) | Gremlin traversal | Relationship-heavy data: social networks, recommendations, fraud detection |

- **NoSQL API** was formerly called the "SQL API" (renamed 2023 — same service). Supports **Fabric mirroring**: replicates operational data into Fabric automatically, no pipeline needed.

```sql
SELECT * FROM customers c WHERE c.id = "joe@litware.com"
```

- **MongoDB API**: data as BSON, queried with MQL method calls on collections.

```javascript
db.products.find({id: 123})
```

- **Table API**: same PartitionKey/RowKey model as Azure Table Storage, but adds global distribution, automatic secondary indexes, and instant autoscale.

```text
https://endpoint/Customers(PartitionKey='1',RowKey='124')
```

- **Cassandra API**: column-family model — rows in the same table don't need the same columns. Query with CQL, syntax close to SQL.
- **Gremlin API**: entities = vertices, relationships = edges; use for multi-hop, relationship-centric queries.

```text
g.V().hasLabel('employee').order().by('id')
```

- **Exam idea:** matching an existing workload's API (MongoDB/Cassandra/Table/Gremlin) to Cosmos DB is the low-friction migration path; NoSQL API is the native/greenfield choice.
