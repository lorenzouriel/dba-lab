# DP-900 — Identify Considerations for Relational Data on Azure

## 1. Fundamental relational data concepts

### Remember

- A table models an *entity*; each row = one instance, each column = one discrete attribute.
- Normalization removes duplication: one entity per table, one attribute per column.
- A *primary key* uniquely identifies a row; a *foreign key* links to another table's primary key.
- SQL statements split into three families: DDL (structure), DCL (permissions), DML (data).
- `SELECT`/`UPDATE`/`DELETE` without a `WHERE` clause act on **every row** — no confirmation prompt.
- A view = virtual table from a `SELECT`. A stored procedure = reusable SQL logic. An index = fast lookup structure.
- Indexes speed up reads but cost storage and slow down writes (insert/update/delete must maintain them).

### Relational data model

- Table = collection of rows representing the same entity (customers, products, orders...).
- Not every column needs a value — an empty cell is `NULL` (e.g., optional `MiddleName`).
- Column data type constrains what can be stored (text, decimal, integer, date/time...).
- Available data types depend on the DBMS, though ANSI defines common standard types.

### Normalization

Practical definition:

1. Separate each *entity* into its own table.
2. Separate each discrete *attribute* into its own column.
3. Uniquely identify each row with a *primary key*.
4. Use *foreign key* columns to link related entities.

- Removes duplicated data (e.g., customer address stored once, not per order line).
- Confines each value to the right data type and enables precise filtering/querying.
- RDBMS enforces **referential integrity**: a foreign key value must match an existing primary key (no orders for a nonexistent customer).
- A *composite key* is a unique combination of multiple columns (e.g., `OrderNo` + `ItemNo`).

**Easy rule:** unnormalized data repeats customer/product details on every row; normalized data stores each fact exactly once and links via keys.

### SQL statement types

| Group | Purpose | Key statements |
|---|---|---|
| DDL | Create/modify/remove structures | `CREATE`, `ALTER`, `DROP`, `RENAME` |
| DCL | Manage permissions | `GRANT`, `DENY`, `REVOKE` |
| DML | Manipulate row data | `SELECT`, `INSERT`, `UPDATE`, `DELETE` |

- SQL = *Structured Query Language*, standardized by ANSI (1986) / ISO (1987), but every vendor adds proprietary extensions.
- Dialects: **T-SQL** (SQL Server, Azure SQL family), **pgSQL** (PostgreSQL), **PL/SQL** (Oracle).
- `NOT NULL` marks a column as mandatory; omit it and rows can store `NULL` there.

```sql
CREATE TABLE Product (
    ID INT PRIMARY KEY,
    Name VARCHAR(20) NOT NULL,
    Price DECIMAL NULL
);
```

**Exam idea:** `DROP` deletes the object and all its data — irreversible without a backup.

### Querying with SQL

- `SELECT` reads rows; `*` returns all columns, or list specific columns.
- `WHERE` filters rows; `ORDER BY` sorts results.
- `JOIN` combines rows from multiple tables, typically matching a foreign key to its primary key.

```sql
SELECT o.OrderNo, c.City
FROM Order AS o
JOIN Customer AS c ON o.Customer = c.ID;
```

Common join types (not just plain `JOIN`):

| Join | Returns |
|---|---|
| `INNER JOIN` | Only rows that match in both tables |
| `LEFT JOIN` | All left-table rows, matched right-table data or `NULL` |
| `RIGHT JOIN` | All right-table rows, matched left-table data or `NULL` |
| `FULL JOIN` | All rows from both tables, unmatched sides as `NULL` |

- `INSERT` adds rows: `INSERT INTO Table(cols) VALUES (...)` — standard SQL inserts one row at a time.
- `UPDATE ... SET ... WHERE ...` modifies matching rows only.
- `DELETE FROM Table WHERE ...` removes matching rows only.

**Warning (exam favorite):** omit `WHERE` on `UPDATE`/`DELETE` and the statement hits **every** row in the table.

### Database objects

**View**
- Virtual table defined by a stored `SELECT` query.
- Query it like a table; simplifies repeated joins and hides underlying complexity.

**Stored procedure**
- Named, reusable block of SQL, optionally parameterized.
- Executed on demand with `EXEC`; encapsulates logic apps would otherwise repeat.

**Index**
- Sorted copy of a column's data with pointers back to the table rows.
- Dramatically speeds up lookups on large tables; on small tables the optimizer may ignore it.
- Trade-off: extra storage, and slower inserts/updates/deletes since indexes must stay in sync.

---

## 2. Relational database services in Azure

### Remember

- **SQL Server on Azure VM** = IaaS, full OS/SQL Server control, lift-and-shift, you patch everything.
- **Azure SQL Managed Instance** = PaaS, near-100% SQL Server compatibility, instance-level features, low admin.
- **Azure SQL Database** = PaaS, most managed, best for new cloud-native apps, not fully SQL Server compatible.
- More control and compatibility → VM. Less administration and fastest to build → SQL Database.
- Azure SQL Database supports **Single Database** and **Elastic Pool** deployment models, plus **Hyperscale** for very large databases (up to 100 TB).
- Open-source workloads: **Azure Database for MySQL** (LAMP-stack migrations) and **Azure Database for PostgreSQL** (relational + object features, geometric data).
- Both open-source services offer a **Flexible Server** deployment option with more granular control and cost optimization.

### Azure SQL family overview

| Service | Cloud model | Compatibility | Admin burden |
|---|---|---|---|
| SQL Server on Azure VM | IaaS | Fully compatible on-prem SQL Server | You manage OS + SQL Server |
| Azure SQL Managed Instance | PaaS | Near-100% SQL Server compatible | Mostly automated |
| Azure SQL Database | PaaS | Core SQL Server capabilities only | Fully automated |

**Easy rule:** more control/compatibility needed → VM or Managed Instance. Minimal admin, new cloud app → SQL Database.

### SQL Server on Azure VMs

- IaaS: a VM running a full installation of SQL Server — same as on-prem, just hosted in Azure.
- Best for *lift-and-shift* migrations, hybrid deployments, or apps needing OS-level access unsupported by PaaS.
- You retain full administrative rights over both the OS and SQL Server — and full responsibility for patching/updates/backups.
- Easy to scale by resizing the VM (more CPU/memory/disk) without reinstalling software.

### Azure SQL Managed Instance

- PaaS: a fully controllable SQL Server *instance* in the cloud; one instance can host multiple databases.
- Automates backups, patching, and monitoring, but you keep full control over security and resource allocation.
- Near-100% compatible with SQL Server Enterprise Edition — the go-to choice for on-prem lift-and-shift with minimal app changes.
- Supports SQL Server logins and Microsoft Entra ID (Azure AD) integrated logins.
- Use **Data Migration Assistant (DMA)** to check compatibility before migrating.

### Azure SQL Database

- PaaS: you get a managed logical **SQL Database server**, then deploy databases onto it.
- **Single Database**: dedicated resources for one database; supports a *serverless* option that auto-scales/pauses.
- **Elastic Pool**: multiple databases share a resource pool — useful when demand varies over time between databases.
- **Hyperscale**: tier for very large databases (up to 100 TB), fast backup/restore regardless of size.
- Best availability of the three options (99.995%), but least on-prem compatibility.
- Built-in: automatic patching, point-in-time restore, geo-replication, advanced threat protection, auditing, encryption at rest and in motion.

### Comparison table

| | SQL Server on Azure VM | Azure SQL Managed Instance | Azure SQL Database |
|---|---|---|---|
| Type | IaaS | PaaS | PaaS |
| Availability SLA | 99.99% | 99.99% | 99.995% |
| Compatibility | Full | Near-100% | Core capabilities only |
| Management | Manual (you patch/back up) | Mostly automated | Fully automated |
| Best for | Full control, hybrid, OS-level needs | Lift-and-shift with minimal changes | New cloud-native apps |

### Open-source database services

**MySQL vs PostgreSQL**
- MySQL: simple, popular for LAMP-stack web apps; editions are Community (free), Standard, Enterprise.
- PostgreSQL: hybrid relational/object database — custom data types, extensible, strong at geometric data; uses the **pgsql** dialect.

**Azure Database for MySQL**
- PaaS based on MySQL Community Edition.
- Built-in high availability, automatic backups with point-in-time restore (up to 35 days, 7 by default).
- **Flexible Server**: recommended for new workloads, more granular control, cost optimization.

**Azure Database for PostgreSQL**
- PaaS with the same availability/scaling/security benefits as the MySQL service.
- Some on-prem extensions unavailable (server-managed by Microsoft); core extension set supported.
- **Flexible Server**: recommended deployment, high configurability, cost optimization.
- Query performance data lives in the `azure_sys` database, viewable via `query_store.qs_view`.
- `pgAdmin` still works for day-to-day database management (not server-level backup/restore).

**Exam idea:** "migrate a LAMP application" → Azure Database for MySQL. "Need geometric/spatial or extensible data types" → Azure Database for PostgreSQL.

### When to use what

| Need | Choose |
|---|---|
| Full OS/instance control, hybrid setup | SQL Server on Azure VM |
| Lift-and-shift on-prem SQL Server, minimal changes | Azure SQL Managed Instance |
| New cloud app, least admin, highest availability | Azure SQL Database |
| Very large database (up to 100 TB) | Azure SQL Database — Hyperscale |
| Variable load across several databases | Azure SQL Database — Elastic Pool |
| LAMP-stack migration | Azure Database for MySQL |
| Relational + object/geometric data needs | Azure Database for PostgreSQL |
