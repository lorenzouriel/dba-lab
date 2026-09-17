# DP-300 — Plan and Implement Data Platform Resources

## 1. Deploy IaaS solutions with Azure SQL

### Remember

- IaaS = SQL Server on an Azure VM. You own OS patching, SQL install/config, storage, networking.
- Choose IaaS when you need OS-level access, older SQL versions, CLR, replication, or AD auth.
- The SQL Server IaaS Agent Extension automates backup, patching, Key Vault integration, and licensing.
- Premium SSD (pooled) is the baseline recommendation; Ultra Disk only for sub-millisecond latency needs.
- Availability Zones (99.99%) beat Availability Sets (99.95%) when the region supports zones.
- Always On AG works instance-independent (per database group); FCI protects the whole instance but needs shared storage.
- Azure Site Recovery is best for stateless VMs, not transactional databases (RTO ≈ RPO there).

### Licensing and deployment

- **Pay as You Go** — license bundled with the VM, per-minute billing, no Software Assurance needed.
- **BYOL** — requires Software Assurance; report usage via License Mobility form within 10 days.
- **Azure Hybrid Benefit (AHB)** — reuse existing Windows Server licenses.
- **Reserved Instances** — 1–3 year commitment, no upfront payment required, big savings on large VMs.
- Azure Marketplace = fastest way to deploy a preconfigured SQL Server image; not easily repeatable (use ARM/Bicep/CLI for that).

### VM families

| Family | Best for |
|---|---|
| General purpose | Balanced CPU/memory, small-medium DBs |
| Compute optimized | High CPU:memory ratio, batch/app servers |
| Memory optimized | Most database workloads (up to 4 TB RAM) |
| Storage optimized | Ephemeral NVMe, scale-out workloads (needs AG/log shipping for protection) |
| GPU | Rendering, parallel ML |
| FPGA accelerated | Compute-intensive workloads |
| High performance compute | Thousands of cores, RDMA networking |

**Easy rule:** memory-optimized is the default answer for "which VM family for SQL Server?"

### Storage

- Every VM has an OS disk (C:) and a temporary disk (D:) — **never** put data/log files on the temp disk.
- Data disks are extra managed disks; pool them (Storage Spaces / LVM) for more IOPS and capacity.

| Disk | Best for | Max IOPS |
|---|---|---|
| Ultra Disk | IO-intensive, lowest latency | 400,000 |
| Premium SSD v2 | Performance-sensitive | 80,000 |
| Premium SSD | Performance-sensitive (standard pick) | 20,000 |
| Standard SSD | Lightweight workloads | 6,000 |
| Standard HDD | Backups, non-critical | 2,000 |

- Data files → their own pool with read caching. Log files → separate pool, **no caching**. TempDB → own pool or the VM's local temp disk.
- Two encryption layers: Azure Server-side encryption (storage-level, at rest) and Azure Disk Encryption (BitLocker/DM-Crypt, in-VM), both integrate with Key Vault.

### Performance features

- Table partitioning: filegroups → partition function → partition scheme → partitioned table. Reduces maintenance scope and speeds filtered queries.
- Data compression is at the object level (table/index/partition):
  - **Row compression** — minimal overhead, stores values in minimal space.
  - **Page compression** — row compression + prefix/dictionary compression; bigger savings, more CPU.
  - **Columnstore archival compression** — XPRESS algorithm, best for cold/rarely-read data.
- `sp_estimate_data_compression_savings` to preview savings before applying.
- Production checklist: enable backup compression and instant file initialization, limit autogrowth, disable autoshrink/autoclose, set max server memory, enable lock pages in memory, enable Query Store.

### Security

- **Microsoft Defender for SQL** — vulnerability assessment + alerts, scoped to the SQL instance/database.
- **Microsoft Defender for Cloud** — broader unified security posture management across hybrid workloads.

### High availability and disaster recovery

| Option | Scope | Availability |
|---|---|---|
| Availability Zones | Spread across data centers in a region | 99.99% |
| Availability Sets | Spread across racks/hosts in one data center | 99.95% |
| Always On AG | Group of databases, up to 9 replicas, HA + DR | Depends on config |
| FCI | Whole instance, single region, needs shared storage | HA only, no DR |

- AG sync mode: **synchronous** when replicas are close (same region, latency tolerable); **asynchronous** when geographically spread or latency-sensitive.
- **Exam idea:** the unit of failover for an AG is the database group, not the instance — that's the key AG vs. FCI distinction.
- Native SQL Server backups can go straight to a URL (Azure Blob); use GRS/RA-GRS for geo-resilience.
- Azure Backup for SQL Server = agent-based, centralized, more complete (and costlier) than native backups.
- Azure Site Recovery = block-level VM replication; good for stateless VMs, weaker fit for transactional DBs.

### Hybrid scenarios

- Most common hybrid use case: **Disaster Recovery** — on-prem stays primary, Azure is the DR target.
- Backups to Azure Storage (URL/SMB) protect against local backup-storage failure; can also store user database files (not system DBs) in Azure Storage.
- **Azure Arc-enabled SQL Server** — centralizes inventory, config assessment, security alerts across on-prem/edge/multicloud SQL Servers.
- Secure connectivity: Site-to-Site VPN (cheaper, more latency) or ExpressRoute (private, low-latency, costlier, no cross-cloud).

---

## 2. Deploy PaaS solutions with Azure SQL

### Remember

- PaaS = Microsoft manages OS + SQL Server engine; you manage databases, users, data.
- Azure SQL Database = single-database focus, low admin. Azure SQL Managed Instance = near-100% SQL Server compatibility, best for lift-and-shift migrations.
- Two purchasing models: **DTU** (bundled, simple) and **vCore** (default, decoupled compute/storage, supports AHB).
- Three vCore service tiers: General Purpose, Business Critical, Hyperscale.
- Serverless = autoscale + autopause compute tier; still deployed to a logical server.
- Automated backups are default and mandatory — manual `RESTORE DATABASE` isn't supported in Azure SQL Database.

### Deployment models and purchasing

- **Single database** — dedicated resources, billed/managed individually.
- **Elastic pool** — shared compute/storage across many databases; think "SQL Server instance with many user DBs." Great for multi-tenant SaaS.

| Service tier | Best for | Storage | Latency | Compute options | Max size |
|---|---|---|---|---|---|
| General Purpose | General workloads | Premium storage | Higher | Provisioned, Serverless | 4 TB |
| Business Critical | High-performance | Local SSD | Lowest | Provisioned | 4 TB |
| Hyperscale | Large-scale DBs | Premium storage | Varies | Provisioned | 100 TB |

**Easy rule:** need >4 TB or fast backup/restore at scale → Hyperscale. Need lowest latency + built-in readable replica → Business Critical.

### Serverless

- Autopause delay: min 60 minutes, max 7 days of inactivity before pausing (storage-only billing while paused).
- You set min/max vCores; memory and I/O scale proportionally.
- Available in General Purpose **and** Hyperscale tiers, but auto-pause/auto-resume only works in General Purpose.
- Not compatible with: geo-replication, long-term retention, elastic jobs database, SQL Data Sync database.
- App must handle the connection error on resume — add retry logic.

### Backups and continuity

- Backup schedule (fixed, not adjustable for MI): Full weekly, Differential every 12 hours, Log every 5–10 minutes.
- Default retention 7–35 days depending on tier; Long-Term Retention (LTR) extends up to 10 years.
- Can't restore over an existing database — drop/rename first.
- **Active geo-replication** — up to 4 readable secondaries, asynchronous, manual/programmatic failover.
- **Failover groups** — built on geo-replication, adds a single stable endpoint so apps don't need connection string changes after failover.
- SQL MI–only backup quirk: supports manual **copy-only** backup to URL (SQL DB does not).

### Elastic pools

- Shared CPU/memory/storage pool across databases; DTU or vCore based.
- Good fit: multi-tenant apps, unpredictable per-database usage.
- Monitor per-database utilization so one database doesn't starve the pool.

### Hyperscale

- Separates compute (query engine) from storage layer → storage scales independently, near-instant backups via file snapshots.
- One-way conversion: standard Azure SQL DB → Hyperscale can't be reverted.
- Scale **up/down** = more/less primary compute (fast, independent of data volume). Scale **in/out** = add read-only replicas (also serve as hot standby).
- Connect to read replicas via `ApplicationIntent=ReadOnly` in the connection string.
- **Exam idea:** "100 TB+ database" or "need near-instant backup/restore regardless of size" → Hyperscale.

### Azure SQL Managed Instance

- Near-100% SQL Server compatible: SQL Agent, tempdb access, cross-database queries, CLR — things Azure SQL DB doesn't support.
- Supports up to 100 databases per instance, plus system databases.
- Two tiers: **General Purpose** and **Business Critical** (BC adds In-Memory OLTP + readable secondary, uses Always On AG under the hood).
- **Managed Instance Link** — hybrid replication from on-prem SQL Server to MI using distributed AGs; also usable for DR failover and read-offload.
- **Instance pools** — pre-provision shared VM resources for many small instances; fast (~10 min) deployment, avoids consolidation planning.
- HA: 99.99% SLA. DR: auto-failover groups (one secondary, same paired region only).
- Failover group endpoints differ from SQL DB: MI uses `<fog-name>.dns-zone.database.windows.net` (RW) and `.secondary.dns-zone...` (RO).

---

## 3. Migrate SQL Server workloads to Azure SQL Database

### Remember

- Azure SQL Database fits: intermittent/unpredictable usage, no usage history to size against, storage needs beyond MI, low deployment complexity tolerance.
- Migration is **online** (near-zero downtime) or **offline** (planned downtime window).
- **Transactional replication is the only online migration method** into Azure SQL Database.
- Azure Database Migration Service (DMS) is Microsoft's recommended tool for large offline migrations.
- Always run a pre-migration assessment (Azure Migrate / DMA) before executing.

### Choosing the right feature / migration tool

| Tool | Mode |
|---|---|
| Azure Database Migration Service | Offline |
| Transactional replication | Online |
| Azure Migrate | Offline |
| Import/Export (BACPAC) | Offline |
| bcp utility | Offline |
| Azure Data Factory | Offline |

- Exclusive to Azure SQL Database: Hyperscale, Serverless auto-scale, Automatic tuning (indexes), Elastic query, Elastic jobs, Query Performance Insight.
- Performance tips: scale target up before migrating (Business Critical Gen5 8 vCore or Hyperscale), disable auto-stats during load, drop/recreate indexed views, migrate cold data to a separate DB queried via elastic query.
- Retry logic: wait ≥5 seconds on first retry, back off exponentially up to 60 seconds. A failed `SELECT` should be retried on a **new connection**, not the same one.

### Azure Database Migration Service (CLI/PowerShell)

- `az extension add --name datamigration` to get the `az datamigration` commands.
- Flow: create the migration service → migrate schema (`az datamigration sql-server-schema`) → create the migration (`az datamigration sql-db create`) → monitor (`sql-db show` / `wait`) → cancel if needed.
- Can target specific tables with `--table-list`; empty tables are skipped automatically.
- Statuses: Preparing for copy → Copying → Copy finished → Rebuilding indexes → Succeeded.
- Recommended max ~10 concurrent migrations per self-hosted integration runtime host.

### BACPAC migration

- A `.bacpac` = compressed metadata + data; can import from Blob Storage or local storage.
- `SqlPackage` is faster than the portal and is the recommended tool for production-scale import/export; can run several in parallel.
- Scale the target DB up before import, scale down after, to speed up the load.

```console
SqlPackage.exe /a:import /tcs:"..." /sf:AdventureWorks2019.bacpac /p:DatabaseEdition=Premium /p:DatabaseServiceObjective=P6
```

### Online migration (transactional replication)

- Roles: **Publisher** (source), **Distributor** (routes changes), **Subscriber** (target), organized as **Articles** inside a **Publication**, requested via a **Subscription**.
- Only SQL Server authentication logins can connect to Azure SQL Database as subscriber.
- Must be configured via SSMS/T-SQL — **not** available from the Azure portal.
- Sequence: `sp_adddistributor` → `sp_adddistributiondb` → `sp_adddistpublisher` → `sp_addsubscriber` → `sp_addpublication`/`sp_addarticle` → `sp_addsubscription` (push).
- Monitoring/management happens from SQL Server side, not from Azure SQL Database.

### Moving a subset of data

- **bcp utility** — bulk export/import between SQL Server and flat files; know your schema/data types or use a format file.
- **Azure Data Factory** — good for partial/transformed data movement, common for BI scenarios, not a full database migration tool.

---

## 4. Migrate SQL Server workloads to Azure SQL Managed Instance

### Remember

- SQL MI's goal: PaaS with near-100% SQL Server compatibility — true lift-and-shift, minimal app rewrite.
- Migration modes: **online** (Managed Instance Link, near-zero downtime) vs **offline** (Log Replay Service, native backup/restore).
- Managed Instance Link uses **distributed availability groups** — same underlying tech as Always On AG.
- Log Replay Service (LRS) migrations must finish within **30 days** or the job auto-cancels.
- Azure Arc gives a unified portal experience (assess → select target → migrate → cutover) wrapping Link or LRS underneath.

### Why Managed Instance over the alternatives

- Before MI existed, migrating an app needing instance-scoped features (SQL Agent, cross-DB joins, SSIS, CLR) meant either full IaaS (heavy admin) or rewriting for Azure SQL Database (heavy dev cost). MI removes that tradeoff.
- Backward compatible down to SQL Server 2008 (SQL Server 2005 databases migrate at compatibility level 2008).
- Network isolation: default deployment only exposes a **private IP**; on-prem apps need ExpressRoute or VPN gateway to reach it. A **public endpoint** can be enabled separately (port 3342), with Separation of Duties between a DB admin and a network admin.
- **Instance failover groups** protect the whole instance's databases as a unit across regions.

### Migration options supported

| Tool | Mode | Notes |
|---|---|---|
| Log Replay Service | Online | Log-shipping based, custom control |
| Managed Instance Link | Online | Distributed AG, near-zero cutover |
| SQL Server migration via Azure Arc | Either | Portal-driven wrapper over Link/LRS |
| Native backup and restore | Offline | Simplest, needs backups on Blob Storage |
| Transactional replication | Either | Good for large/complex DBs, table-level (article) granularity |

### Azure Arc migration

- Four stages in the portal: Assess source → Select target → Migrate data → Monitor and cutover.
- Automatic readiness assessment runs weekly (also triggerable manually); flags compatibility blockers and right-sizes the target.
- Supports SQL Server 2012+ (exact minimum depends on chosen method).
- Copilot is integrated to help compare methods and monitor progress.

### Log Replay Service (LRS)

- Use when: you need fine control, near-zero downtime tolerance, can't install/run DMS, or can't open network ports to Azure.
- Two modes:

| Mode | Behavior | Best for |
|---|---|---|
| Autocomplete | Finishes automatically once the last backup restores | Passive workloads, full backup chain ready upfront |
| Continuous | Keeps scanning/restoring new backups | Active workloads, backup chain can grow during migration |

- Requires RBAC role: Subscription Owner, SQL MI Contributor, or custom role with `Microsoft.Sql/managedInstances/databases/*`.
- Needs an Azure Blob Storage intermediary; use **either** SAS token **or** managed identity, not both.
- Speed tips: split full/differential backups into multiple files for parallel I/O, enable backup compression, enable `CHECKSUM` to skip the extra integrity check on restore.

### Managed Instance Link

- One link = one database, but you can chain multiple links (many DBs, many MIs).
- Replication direction:

| Type | SQL Server version | Failover |
|---|---|---|
| One-way | 2016, 2019 | On-prem → MI only |
| Two-way | 2022 | Online failover to MI **and** online failback to on-prem |

- Also usable beyond migration: offload read-only workloads, automated backups of the MI secondary, business continuity/DR.
- Configure via SSMS wizard or T-SQL/PowerShell scripts (scripts = automatable).
- Some features unsupported (e.g., FileTables, FILESTREAM) — check limitations before committing to Link.

### Choosing Link vs. LRS

| Consideration | Managed Instance Link | Log Replay Service |
|---|---|---|
| Downtime | Best — cutover in seconds | Longer, especially Business Critical |
| Read during migration | Supported | Not available (DB is restoring) |
| Min SQL Server version | 2016+ | 2012+ |
| Edition | Enterprise, Standard, Developer | All editions |
| Networking | VPN / private endpoint | Public endpoint works by default |
| Duration limit | Unlimited | 30 days max |
| Reverse migration | Supported | Not supported |

**Exam idea:** minimal-downtime + need-to-read-during-migration → Managed Instance Link. Older edition or acceptable planned downtime → LRS.

### Synchronizing data during a staged migration

- Connectivity options: Point-to-Site VPN (single client), Site-to-Site VPN (whole on-prem site), ExpressRoute (private, fastest, priciest).
- Native backup/restore to Azure Blob via SAS — use `COPY_ONLY`; striped backups (multiple URLs) for databases over 200 GB.

```sql
BACKUP DATABASE YourDatabase TO URL = 'https://.../yourdatabase.bak' WITH COPY_ONLY
```

- BACPAC via `SqlPackage` — SQL MI does **not** support BACPAC import through the Azure portal.
- BCP — good for migrating/syncing a single database's tables back and forth.
- Azure Data Factory — ingestion-focused, supports SSIS packages via integration runtime, reaches MI over the public endpoint.
- Transactional replication — MI can act as Publisher, Distributor, **and** Subscriber (more flexible than SQL DB). Needs SQL auth, an Azure Storage file share for the working directory, and outbound ports 445 (file share) / 1433 (cross on-prem-to-MI) opened on the MI subnet.
- MI must live in its own dedicated VNet subnet; all client connections are certificate-encrypted and continuously checked against revocation lists.
