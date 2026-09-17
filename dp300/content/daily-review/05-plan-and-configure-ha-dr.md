# DP-300 — Plan and Configure a High Availability and Disaster Recovery (HA/DR) Environment

## 1. Describe high availability and disaster recovery strategies

### Remember

- RTO = how long you're allowed to be down. RPO = how much data you're allowed to lose.
- HA = local, fast recovery (seconds). DR = another site/region, slower recovery (hours+).
- Overall RTO is set by the **slowest** component, not the fastest.
- Instance-level protection (FCI) vs database-level protection (AG, log shipping) — know the difference cold.
- IaaS = you choose and configure the HADR feature. PaaS = HADR is mostly built-in, just enable/configure.
- A backup/recovery strategy is mandatory even if you also use AGs or geo-replication.

### RTO and RPO

- **RTO (Recovery Time Objective):** max time to bring things back online.
- **RPO (Recovery Point Objective):** max acceptable data loss, measured in time.
- Define RTO/RPO separately for HA and for DR — DR objectives are typically looser.
- **Easy rule:** RTO = time, RPO = data. If log backups run every 30 min but RPO is 15 min, you cannot meet RPO.
- Both are business decisions driven by cost of downtime, then matched to technology.

### HA vs DR — solution map

| Feature | Protects | Scope |
|---|---|---|
| Always On Failover Cluster Instance (FCI) | Instance | HA (needs log shipping/storage replica for DR) |
| Always On Availability Group (AG) | Database | HA and/or DR (single or multi-region) |
| Log Shipping | Database | Mostly DR, can help local availability |
| Azure Site Recovery | VM (disk-level) | DR |
| Availability Sets / Zones | VM placement | HA against datacenter/hardware failure |

**Exam idea:** FCI needs shared storage and one copy of the data (single point of failure). AG needs no shared storage but each replica has its own full copy of the data (more storage cost).

### Always On Failover Cluster Instances (FCI)

- Configured at SQL Server install time — a standalone instance can't be converted.
- Unique name + IP, different from the nodes and from the WSFC itself.
- Azure requires an **Internal Load Balancer (ILB)** for the FCI name (unless using DNN).
- Failover = full stop/restart of the instance on another node; clients disconnect.
- Requires shared storage (Azure Premium File Share, iSCSI, Azure Shared Disk, S2D, or third-party).
- Standard Edition FCIs: max 2 nodes. Requires AD DS + DNS.

### Always On Availability Groups (AG)

- Database-level protection; primary (read/write) + up to 8 secondaries (Enterprise Ed.).
- Standard Edition: 1 database per AG, max 2 replicas (1 primary + 1 secondary).
- Data movement: synchronous or asynchronous.
- Uses a **listener** (name + IP) for client abstraction — like the FCI's virtual name.
- No shared storage needed, but every replica stores a full copy of the data.
- Objects outside the database (Agent jobs, logins, linked servers) are **not** replicated — must be created manually on each replica.
- Secondary replicas in Enterprise Edition can be readable (reporting, DBCC, backups).

### Log Shipping

- Oldest HADR mechanism: backup → copy → restore, on a timer.
- Database-level protection, no built-in name abstraction (use a DNS alias to mask the name change).
- Secondary is restored `WITH STANDBY` or `WITH NORECOVERY` (warm standby).
- Great for DR: simple, tolerant of unreliable networks, good pairing with FCI (protects FCI's single storage copy).

### Azure availability features (IaaS, VM-level)

These are external to the VM — they don't know SQL Server is running inside.

| Feature | Protects against | Notes |
|---|---|---|
| Availability Set | Rack/host-level failure in one datacenter | Fault domains (power/network) + update domains (patch groups); can't combine with zones |
| Availability Zone | Datacenter-level failure | Different physical datacenters in a region; low latency (<1ms typical), supports sync AG |
| Azure Site Recovery | Region-level failure (DR) | Replicates VM disks to another region; knows nothing about transactions |

**Important:** Availability Sets/Zones do **not** protect against in-guest failures (OS crash, SQL Server crash) — you still need AG/FCI for that.

Azure Site Recovery: stated monthly RTO of ~2 hours; may meet RTO but not RPO since it's transaction-unaware. Can also help recover from ransomware by rolling back to a pre-infection point.

### PaaS built-in HA (Azure SQL DB / Managed Instance)

- Azure SQL Database SLA: 99.99% availability.
- Node failure → new node auto-created, storage reattached; connections drop (app must retry).
- **Accelerated Database Recovery (ADR):** aggressive log truncation + persisted version store (PVS); instant rollback of long transactions, faster recovery. On by default, can't be disabled.
- `OFFLINE`/`EMERGENCY` states aren't available (you can't attach files); `RESTRICTED_USER` and DAC still work.
- Automatic page repair and `CHECKSUM` (on by default) protect against lost writes / stale reads.

### Architecture patterns worth knowing

- **Single-region HA:** AG (no shared storage, standardized client access) or FCI (shared storage, still valid in Azure).
- **Multi-region/hybrid AG:** all replicas in one WSFC spanning regions/on-prem — needs AD DS + DNS everywhere, careful witness placement.
- **Distributed AG:** "an AG of AGs" — Enterprise-only; global primary → forwarder → secondary AG; each side keeps its own WSFC/quorum. Good for failback scenarios.
- **Log shipping for DR:** always assume some data loss with DR.
- **Azure Site Recovery:** works for any VM workload, not SQL-specific.

### Hybrid solutions

- Hybrid = spans on-prem + Azure (or Azure + another cloud); inherently **IaaS-based** (PaaS HADR is Azure-infrastructure-only).
- Exception: transactional replication can publish on-prem → Azure SQL Managed Instance subscriber (one direction only).
- Common use: DR for an on-prem system via a secondary AG replica in Azure.
- Networking is the top consideration: prefer ExpressRoute, else a secure site-to-site VPN. Don't expose VMs directly to the internet.
- Azure can also just be cold/archival storage for backups without being a full hybrid architecture.

---

## 2. Explore IaaS and PaaS solutions for high availability and disaster recovery

### Remember

- Every AG/FCI needs an underlying cluster: **WSFC** on Windows, **Pacemaker** on Linux.
- In Azure, the WSFC/listener IP can't be reserved at the Azure level — configure it in Azure, not inside the VM.
- AG listener in Azure needs an **Internal Load Balancer** with a probe port, unless using a Distributed Network Name (DNN).
- Azure SQL Database: **active geo-replication**. Azure SQL DB or Managed Instance: **auto-failover groups**. MI does NOT support active geo-replication.
- Auto-failover groups add a listener + automatic failover policy on top of geo-replication concepts.

### WSFC in Azure

- **Witness** is critical for quorum — prefer a **cloud witness** (Windows Server 2016+), especially for multi-region/hybrid.
- Most deployments need AD DS + DNS; FCIs always do. AGs can run without AD DS (Workgroup Cluster, AGs only) but still need DNS.
- Enable the feature per node:

```powershell
Install-WindowsFeature Failover-Clustering -IncludeManagementTools
```

- Can't use the Failover Cluster Manager wizard to create the WSFC in Azure (pre–Windows Server 2019 default) — use PowerShell with a static IP:

```powershell
New-Cluster -Name MyWSFC -Node Node1,Node2 -StaticAddress w.x.y.z -NoStorage
```

- Windows Server 2019+ defaults to a **Distributed Network Name (DNN)** instead of a traditional VNN + IP — removes the need for a load balancer for the WSFC name itself.
- Cluster validation must pass (errors block support; warnings may be acceptable, e.g., missing shared disks for AG-only clusters).

### Failover Cluster Instance (FCI) specifics

- Appears as one virtual network name to clients — transparent failover, no app reconfiguration.
- Multi-subnet FCI: each subnet gets its own virtual IP; DNS updates on failover.
- **DNN (Distributed Network Name)** replaces the VNN as the FCI connection point — removes the ILB requirement for FCI too.

### Configuring Always On Availability Groups in Azure

- Enable the AG feature first (SQL Server Configuration Manager or `Enable-SqlAlwaysOn`) — requires a service restart.
- Creating the AG itself (SSMS/T-SQL/PowerShell) is the same as on-prem.
- Listener requires an **Internal Load Balancer (ILB)**:
  - Standard LB is required if using Availability Zones.
  - Each listener IP needs a unique **probe port** (high port, e.g. 59999) or the listener won't work.
  - Verify with `Test-NetConnection NameOrIPAddress -Port PortNumber` from outside the primary VM.
- Multi-subnet AG: one load balancer + probe port per subnet/region.

### Distributed availability groups

- No WSFC/Pacemaker needed for the distributed AG itself — fully managed inside SQL Server.
- Azure-specific: add the AG endpoint port (default **5022**) to the load balancer in each region.

### Azure Site Recovery (VM replication)

- Works regardless of whether SQL Server is inside the VM; replicates disks, not transactions.
- Crash-consistent recovery points every 5 minutes; app-consistent points per policy (**App consistent snapshot frequency**).
- Lowering the app-consistent snapshot interval too much can hurt SQL Server (VSS freeze/thaw I/O pause).
- Multi-VM consistency = shared consistent recovery points across VMs, but costs performance — only use if truly needed.
- Lets you test DR without impacting production. After failover, replica VMs are **not** auto-reprotected.

### Active geo-replication (Azure SQL Database only)

- Creates a readable secondary in another region, kept up to date **asynchronously**.
- Built on AG technology under the hood.
- Primary and secondary(ies) must share the same service tier; matching compute size on the secondary avoids replication lag under heavy writes.
- Manual or programmatic failover; roles swap (secondary becomes primary).
- **Not supported on Managed Instance** — use auto-failover groups instead.
- Cross-subscription geo-replica exists, but programmatic-only.

### Auto-failover groups (Azure SQL DB and Managed Instance)

- Adds a **listener** with two endpoints: read-write and read-only.
- Two policies:
  - **Automatic** failover (can be disabled).
  - **Read-Only** access after failover (disabled by default to protect new-primary performance).
- `GracePeriodWithDataLossHours` (default 1 hour) — controls how long Azure waits before an unplanned failover; raise it if you need a tighter RPO (more time to sync = less potential loss).
- Secondary database is created via **seeding** — can take time depending on size.
- MI supports only **one** auto-failover group.

### Geo-replication vs auto-failover groups

| Feature | Active geo-replication | Auto-failover groups |
|---|---|---|
| Automatic failover | No | Yes |
| Fail over multiple DBs at once | No | Yes |
| App must update connection string | Yes | No (listener) |
| Managed Instance support | No | Yes |
| Secondary in same region as primary | Yes | No |
| Multiple replicas | Yes | No |
| Read-scale | Yes | Yes |

**Easy rule:** need MI support or a single connection string that survives failover → auto-failover groups. Need same-region or multiple readable replicas → geo-replication.

### Monitor availability

- Key questions: backup retention need, RTO/RPO targets, service tier vs SLA, need for zones, need for geo-HADR, **is the application ready** (retry logic, co-locate app and data to cut latency).
- Tools: Azure portal, T-SQL, PowerShell, Azure CLI, REST APIs.
- **Azure status** = global service health dashboard (RSS feed available). **Azure Service Health** = personalized, portal-based, supports alerts.
- `az sql mi list`, `az sql db list`, `Get-AzSQLDatabase` for status; resource health explains failover/unavailability causes.
- Replica status: `sys.dm_database_replica_states` (Business Critical tier).
- Restores via PITR create a **new** database — track via Azure Activity Log.

---

## 3. Back up and restore databases

### Remember

- Three core backup types: **full**, **differential**, **transaction log**.
- Recovery model decides what's possible: **SIMPLE** = no log backups; **FULL**/**BULK_LOGGED** = full backup chain support.
- `WITH NORECOVERY` / `WITH STANDBY` after a restore = more backups can still be applied. No option = database is recovered, chain closed.
- Azure SQL DB/MI backups are automatic: full weekly, differential every 12h, log every 5–10 min, stored RA-GRS.
- PITR default retention is 7 days, configurable up to 35 days; restores always create a **new** database (no restore in place).
- Backups are useless until tested with an actual restore.

### Backup types and recovery models

| Backup type | Contains |
|---|---|
| Full | All data pages as of backup completion |
| Differential | Pages changed since the last full backup |
| Transaction log | Log records since the last log backup; also truncates the log |

| Recovery model | Log backups allowed | Point-in-time restore |
|---|---|---|
| SIMPLE | No | No |
| FULL | Yes | Yes |
| BULK_LOGGED | Yes (minimally logged bulk ops) | Limited during bulk operations |

**Exam idea:** tight RPO requires FULL recovery model + frequent log backups — SIMPLE can't get you granular point-in-time recovery.

### Backing up SQL Server on Azure VMs (IaaS)

Three main mechanisms — pick **one**, don't mix log-backup methods or you break the log chain:

- **Azure Backup (VM-level):** application-aware/consistent; backs up the whole VM, good ransomware protection. Combine carefully with snapshots (`USEVSSCOPYBACKUP=TRUE` registry fix if snapshot delays cause failures).
- **Local disk / network share (incl. Azure Files):** avoid ephemeral storage; copy backups off-VM to avoid a single point of failure.
- **Backup to URL:** stores directly in an Azure Storage account/container as a blob.
- **Automated backups via the SQL Server resource provider:** Azure manages schedule + retention (Windows-only); restores are still manual.

Backup/restore to URL syntax:

```tsql
BACKUP LOG contoso
TO URL = 'https://myacc.blob.core.windows.net/mycontainer/contoso202003271200.trn'

RESTORE DATABASE contoso
FROM URL = 'https://myacc.blob.core.windows.net/mycontainer/contoso20200327.bak'
WITH NORECOVERY
```

- Authenticate via a SQL Server Credential: storage account key (→ page blob, legacy) or **Shared Access Signature** (→ block blob, preferred since SQL Server 2016 — cheaper, more secure).

### Backup and restore for Azure SQL Database / Managed Instance

- Fully automatic: full weekly, differential every 12h, log every 5–10 min; all stored RA-GRS (survives a single datacenter outage).
- Retention policies configurable per database for compliance (**LTR — long-term retention**).
- Deleting the **server** deletes all backups permanently; deleting just the database still allows restore.
- ADR (Accelerated Database Recovery) applies here too — on by default.
- MI supports manual backup-to-URL as well, but only as `COPY_ONLY` (MI itself owns the log chain):

```sql
BACKUP DATABASE contoso
TO URL = 'https://myacc.blob.core.windows.net/mycontainer/contoso.bak'
WITH COPY_ONLY
```

- SQL Database backups and MI backups are **not** cross-restorable in either direction.

### Point-in-time restore (PITR) and geo-restore

- PITR (Azure portal, PowerShell, CLI, or REST) always creates a **new** database — no restore-in-place on SQL DB/MI.
- Default retention window: 7 days, extendable up to 35 days.
- **Restore a deleted database:** restores to the point just before `DROP DATABASE`, via the server's **Deleted databases** blade — needs a new name for the restored copy.
- Geo-redundant backup storage (RA-GRS) is what enables **geo-restore** — recovering into another region using the geo-replicated backups when a full region is unavailable.

### Backup history and validation

- No standard backup history UI for Azure SQL DB; use the portal/CLI for LTR history, or XEvents on Managed Instance to track backup activity.
- Always validate DR readiness by actually performing test restores, not just confirming a backup job "succeeded."
