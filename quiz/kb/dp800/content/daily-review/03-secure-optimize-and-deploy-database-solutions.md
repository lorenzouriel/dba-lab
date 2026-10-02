# DP-800 — Secure, Optimize, and Deploy Database Solutions

## 1. CI/CD with SQL Database Projects

### Remember

A SQL Database Project describes the **desired database schema**.

Build it once into a `.dacpac`, then deploy the **same artifact** through every environment.

### SQL Database Project

Typical structure:
- one `.sql` file per database object
- project describes the final schema
- build validates SQL and object references
- build produces a `.dacpac`

### `.dacpac`

Think of a `.dacpac` as the deployable package for your database schema.

```text
Source SQL
   ↓
Build
   ↓
.dacpac
   ↓
Dev → Test → Production
```

### Deployment

`SqlPackage` compares:
- what the `.dacpac` says should exist
- what the target database currently has

It then creates a deployment plan.

Useful actions:
- `Publish` → deploy
- `Script` → show SQL before deploying
- `DeployReport` → summarize proposed changes

### Pre- and post-deployment

**Pre-deployment:** work that must happen before schema deployment.

**Post-deployment:** common place for lookup/reference data.

Post-deployment scripts run every deployment, so they must be **idempotent**.

### Git and PRs

Recommended flow:

```text
Feature branch → PR → CI build → main → deploy
```

Always rebuild after resolving a merge conflict.

### Schema drift

Schema drift means:

```text
Live database != database project
```

Common cause: someone changes production manually.

Detect drift with schema comparison or by extracting the live schema and comparing it with source control.

### CI/CD security

Never hardcode connection strings or passwords in YAML.

Prefer:
- OIDC/federated authentication
- Managed Identity
- Azure Key Vault
- protected deployment environments

### Testing

Think in three levels:

```text
Build validation → Unit tests → Integration tests
```

A failing test should block promotion.

---

## 2. Security and compliance

### Remember

- Encryption protects data.
- Masking changes what users see.
- RLS controls which rows users see.
- Permissions control what users can do.
- Auditing records what happened.

### Encryption

| Method | Protects |
|---|---|
| TDE | Data files, logs, backups at rest |
| Always Encrypted | Sensitive column values, even from DB administrators |
| Column-level encryption | Specific columns with manual key/control logic |

**TDE**
- transparent to applications
- protects storage
- does not stop an authorized SQL user from reading data

**Always Encrypted**
- encryption/decryption happens outside the database engine
- database engine does not see plaintext
- requires compatible client drivers

Deterministic encryption:
- same plaintext → same ciphertext
- equality comparisons can work

Randomized encryption:
- stronger confidentiality
- limited query operations

### Dynamic Data Masking

DDM changes how data appears to users without changing stored data.

Examples:
- hide email
- hide part of a phone number
- replace a value with a default mask

Users with `UNMASK` can see the original value.

**Important:** masking is not encryption.

### Row-Level Security

RLS automatically filters rows based on the user/session.

- **Filter predicate** → hides unauthorized rows.
- **Block predicate** → prevents unauthorized writes.

Good for:
- multi-tenant applications
- department-level access
- user-specific data

### Permissions

- `GRANT` → allow.
- `REVOKE` → remove a grant.
- `DENY` → explicitly block.

Prefer roles instead of individual user permissions.

Granting permissions at schema level can simplify administration.

### Identity and secrets

Prefer Microsoft Entra authentication and Managed Identity for Azure-hosted applications.

Managed Identity means no password or secret needs to be stored in the application.

### Auditing

Auditing records security-relevant events such as:
- logins
- permission changes
- object changes
- data access

Store audit data separately and protect it from modification.

---

## 3. Integrate SQL with Azure services

### Data API Builder (DAB)

### Remember

DAB can expose database objects as REST and GraphQL APIs without writing a traditional backend.

Configuration defines:
- database connection
- runtime options
- entities
- permissions

Never hardcode the database connection string in the config file. Use environment variables/secrets.

### Entities

DAB can expose:
- tables
- views
- stored procedures

Tables can support CRUD.

Views usually need explicit key fields.

Stored procedures run using the database connection's permissions, so authorization inside the procedure or session context still matters.

### Deployment

Common hosting:
- Azure Container Apps
- Azure App Service
- Azure Static Web Apps database integration

Use health checks and Application Insights.

### Change technologies

| Technology | What it gives you |
|---|---|
| CDC | Before/after change data and history |
| Change Tracking | Lightweight signal that a row changed |
| Change Event Streaming | Push changes to Event Hubs |

Easy distinction:

```text
CDC = detailed history
Change Tracking = lightweight polling
CES = push/event stream
```

---

## 4. Optimize database performance

### Remember

Performance troubleshooting should move from **symptom → query → plan → root cause**.

### Compute and scaling

Choose enough compute for:
- CPU
- memory
- I/O
- concurrency

Scale up when one database needs more resources.  
Scale out when reads or workload distribution can be separated.

### Automatic tuning

Azure SQL can help:
- force a previous good plan
- create useful indexes
- remove indexes in supported scenarios

Automatic changes can be reverted if they make performance worse.

### Compatibility level

Compatibility level controls which SQL optimizer/query-processing features are available.

Before increasing it in production:
1. capture a baseline
2. use Query Store
3. test important queries
4. monitor regressions

### Isolation levels

Three common concurrency problems:

- **Dirty read** → read uncommitted data.
- **Nonrepeatable read** → same row changes between reads.
- **Phantom read** → new matching rows appear between reads.

| Isolation | Main idea |
|---|---|
| Read Uncommitted | Fastest/least protection |
| Read Committed | Normal default lock-based behavior |
| Repeatable Read | Protect rows already read |
| Serializable | Strongest locking; protects ranges too |
| RCSI | Read Committed using row versions |
| Snapshot | Consistent transaction-level snapshot |

**RCSI**
- readers use row versions
- reduces reader/writer blocking

**Snapshot**
- transaction sees a consistent point in time
- concurrent updates can cause update conflicts

**Serializable**
- strongest protection
- highest blocking/deadlock risk

Keep transactions short.

### Execution plans

Important operators/signals:

**Index Seek**
- targeted access
- usually efficient

**Scan**
- reads many/all rows
- can be fine for small tables
- suspicious on large selective queries

**Key Lookup**
- index found the row but needs extra columns
- a covering index with `INCLUDE` may help

**Warnings**
Watch for:
- missing statistics
- implicit conversions
- memory grant problems
- spills to tempdb
- missing join predicates

### Useful DMVs

- `sys.dm_exec_requests` → what is running now
- `sys.dm_exec_query_stats` → aggregate query performance
- `sys.dm_exec_sessions` → session information
- `sys.dm_os_waiting_tasks` → current waits
- missing-index DMVs → possible index opportunities

### Query Store

Query Store keeps:
- query text
- execution plans
- runtime statistics
- wait statistics

Use it to find:
- regressed queries
- high-resource queries
- plan changes
- parameter sensitivity

You can force a known good plan without changing application code.

### Blocking

Blocking happens when one session waits for another session's lock.

Troubleshooting:

```text
Find blocked session
   ↓
Find head blocker
   ↓
Check transaction/query
   ↓
Fix cause or terminate abandoned session
   ↓
Review query/index design
```

Blocking is not always a problem. Long blocking that affects users is the problem.

### Deadlocks

A deadlock happens when transactions wait on each other in a cycle.

SQL Server chooses one transaction as the victim and returns error `1205`.

Reduce deadlocks by:
- accessing objects in a consistent order
- keeping transactions short
- using good indexes
- reducing unnecessary lock scope
- using row-versioning where appropriate

Applications should retry deadlock victims.
