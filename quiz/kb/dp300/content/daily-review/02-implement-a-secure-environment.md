# DP-300 — Implement a Secure Environment

## 1. Configure database authentication and authorization

### Remember

- Azure SQL relies on **Microsoft Entra ID** instead of Windows Server Active Directory.
- Entra authentication > SQL authentication: centralized identity, MFA, no per-server password sprawl.
- Logins live at the **instance** level (master DB); users live at the **database** level.
- `DENY` always beats `GRANT` for the same principal/permission.
- Server roles can't grant access to objects inside a database (SQL Database has no server roles at all).
- Ownership chaining lets a procedure access a table the caller can't — **dynamic SQL breaks the chain**.
- Principle of least privilege: only grant what the task needs (e.g., `EXECUTE` on procs, not table access).

### Authentication identities

| Method | Notes |
|---|---|
| SQL Server authentication | Login/password stored in SQL Server |
| Windows / Microsoft Entra authentication | Uses Entra ID accounts, supports MFA |

- Entra admin account should be a **group**, not a single login — access doesn't depend on one person.
- Entra admin is set via Azure Resource Manager only (portal/PowerShell/CLI), not at the database level; it grants `sysadmin`-like rights over the whole server.
- MFA in SSMS requires the **Microsoft Entra MFA** connection option.

**RBAC vs SQL permissions:** RBAC controls Azure-level operations (deploy/manage), decoupled from in-database security.

| Built-in RBAC role | Can do | Can't do |
|---|---|---|
| SQL DB Contributor | Create/manage databases | Access data |
| SQL Security Manager | Manage security policies (e.g., auditing) | Access data |
| SQL Server Contributor | Manage servers/databases | Access data |

### Security principals: schemas and securables

- Securable scopes, nested: **server → database → schema**.
- No schema specified on a query → user's default schema, then `dbo`, then error.
- **Easy rule:** always qualify object names with schema (`SalesSchema.customers`) — avoids ambiguity and is a best practice.

### Logins and users

```sql
CREATE USER [dba@contoso.com] FROM EXTERNAL PROVIDER;
```

- `FROM EXTERNAL PROVIDER` = Microsoft Entra user.
- Contained database users require **partial containment** (default in Azure SQL Database).
- Best practice in Azure SQL Database: create users at the database scope, not in `master`.
- Classic pattern: `CREATE LOGIN` in master → `CREATE USER ... FROM LOGIN` in the target database.

### Database roles

```sql
CREATE ROLE [SalesReader]
ALTER ROLE [SalesReader] ADD MEMBER [DP300User1]
GRANT SELECT, EXECUTE ON SCHEMA::Sales TO [SalesReader]
```

- **Application roles**: not membership-based — activated by password, permissions apply until deactivated.
- All users are automatically in `public`; grant nothing to it by default (would apply to everyone, incl. `guest`).

**Built-in database roles**

| Role | Gives |
|---|---|
| `db_datareader` / `db_datawriter` | Read / write all tables & views |
| `db_ddladmin` | Modify object definitions, no data access |
| `db_accessadmin` | Create users, no data/schema access |
| `db_securityadmin` | Grant access to others (can self-escalate — trusted users only) |
| `db_denydatareader` / `db_denydatawriter` | Explicitly block read/write despite other grants |
| `db_owner` | Full control by default |
| `db_backupoperator` | Backup (SQL Server/MI only — no effect in Azure SQL Database) |

**Azure SQL Database–only roles (virtual master):**

| Role | Equivalent to |
|---|---|
| `loginmanager` | `securityadmin` fixed server role |
| `dbmanager` | `dbcreator` fixed server role |

**Exam idea:** `db_owner` members can still be blocked via `db_denydatareader` or explicit denies — ownership ≠ untouchable.

**Fixed server-level roles** (SQL Server/MI only, not Azure SQL Database): `sysadmin`, `serveradmin`, `securityadmin` (treat as equal to sysadmin), `processadmin`, `setupadmin`, `bulkadmin`, `diskadmin`, `dbcreator`, `public`.

Azure SQL Database instead exposes: `MS_DatabaseConnector`, `MS_DatabaseManager`, `MS_DefinitionReader`, `MS_LoginManager`, `MS_SecurityDefinitionReader`, `MS_ServerStateReader`, `MS_ServerStateManager`.

### Object permissions

| DML permission | Effect |
|---|---|
| `SELECT` / `INSERT` / `UPDATE` / `DELETE` | Basic CRUD, grantable per object |

| Other object permission | Effect |
|---|---|
| `CONTROL` | Full rights, including delete the object |
| `REFERENCES` | View foreign keys |
| `TAKE OWNERSHIP` | Take ownership |
| `VIEW DEFINITION` | View object's definition |
| `VIEW CHANGE TRACKING` | View change tracking setting |

Functions/procs: `ALTER`, `CONTROL`, `EXECUTE`, `VIEW DEFINITION`, `VIEW CHANGE TRACKING`.

### EXECUTE AS and ownership chains

```sql
EXECUTE AS USER = 'DP300User1';
EXECUTE Sales.DemoProc;
```

- Unbroken ownership chain (same owner on proc + table) → caller doesn't need direct table rights.
- **Dynamic SQL breaks the chain** — `sp_executesql` runs outside the calling proc's context, so the executing user needs direct table rights.
- `REVOKE` removes a `GRANT` or `DENY`.

### Authentication/authorization failures

- **Transient faults**: brief (usually <60s) errors during Azure reconfiguration events — retry, don't fail immediately.
- Retry guidance: wait ≥5s on first retry, back off exponentially up to 60s, cap max retries.
- A failed `SELECT` should be retried on a **new connection**, not blindly resent.
- "Login failed" troubleshooting order: check `sys.sql_logins` → `ALTER LOGIN ... ENABLE` → `CREATE LOGIN` if missing → `CREATE USER` in the target DB → assign role/grant.

---

## 2. Implement compliance controls for sensitive data

### Remember

- Data classification is **column-by-column**, stored in `sys.sensitivity_classifications` (SQL Server 2019+).
- Auditing captures logins, permission changes, and data access — store it separately from the audited system.
- Dynamic Data Masking (DDM) hides values at the **presentation layer only** — it is not encryption, and privileged users always see real data.
- Row-Level Security (RLS) filters rows like an invisible `WHERE` clause — no encryption involved.
- Microsoft Defender for SQL = vulnerability assessment + Advanced Threat Protection.
- Ledger gives cryptographic, blockchain-style tamper-evidence, set only at database/table creation.
- Microsoft Purview is the governance/cataloging layer: discovery, classification, lineage — across the whole data estate, not just SQL.

### Data classification

```sql
ADD SENSITIVITY CLASSIFICATION TO
    [Application].[People].[EmailAddress]
WITH (LABEL='PII', INFORMATION_TYPE='Email');
```

- Portal path: **Data Discovery & Classification** (part of Microsoft Defender for Cloud).
- Recommendations are based on **column name** — a mislabeled column (`column1` holding emails) won't be auto-flagged.
- Custom taxonomy/sensitivity labels require **administrative rights on the org's root management group**.
- Classification feeds easier auditing and helps pick which columns need encryption.

### Server and database audit

- Destinations: Azure Storage, Log Analytics workspace, Event Hubs.
- Server-level audit covers all (including future) databases automatically.
- **Easy rule:** if server auditing is on, database auditing is usually redundant — enable both only when a database needs a different retention/storage/event scope.
- Default action groups: `BATCH_COMPLETED_GROUP`, `SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP`, `FAILED_DATABASE_AUTHENTICATION_GROUP`.
- Combined with classification: `data_sensitivity_information` field logs access to classified columns.
- Auditing on read-only replicas is automatic.

### Dynamic Data Masking

```sql
ALTER TABLE [Customer] ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()')
```

| Function | Behavior |
|---|---|
| `default()` | Full mask (XXXX / 0 / 01.01.1900) |
| `partial(...)` | Custom prefix/suffix reveal (e.g., credit card last 4) |
| `email()` | `aXXX@XXXXXXX.com` |
| `random(min,max)` | Random numeric value per query |

- `UNMASK` permission reveals the real value; without it, exports/copies (`SELECT INTO`, import/export) stay masked.
- **Exam idea:** DDM alone can leak data via inference — pair with auditing, encryption, and RLS, and restrict ad hoc querying.

### Row-Level Security

- **Filter predicate** → blocks `SELECT`/`UPDATE`/`DELETE` on rows that don't match (not applicable to `INSERT`).
- **Block predicate** → four variants: `AFTER INSERT`, `AFTER UPDATE`, `BEFORE UPDATE`, `BEFORE DELETE`.
- Implementation steps: create users/groups → inline table-valued function (predicate) → `CREATE SECURITY POLICY` binding the function to the table.

```sql
CREATE SECURITY POLICY sec.SalesPolicy
ADD FILTER PREDICATE sec.tvf_SecurityPredicatebyTenant(TenantName) ON [dbo].[Sales]
WITH (STATE = ON);
```

- **Exam idea:** side-channel/inference attacks are possible (e.g., divide-by-zero crafted in `WHERE`) — limit ad hoc querying.
- Best practices: dedicated schema for predicate functions/policies; avoid type conversions, joins, recursion in predicates.

### Microsoft Defender for SQL

- **SQL vulnerability assessment**: scans for misconfigurations, excessive permissions, sensitive data exposure against a rules knowledge base.
- **Advanced Threat Protection**: monitors live connections/queries for threats — SQL injection (vulnerable & active), unusual location/data center, unfamiliar principal, harmful application, brute force.
- Needs Defender for SQL enabled at the **subscription** level; role required: SQL security manager or db/server admin.
- Enable auditing alongside it for deeper investigation of alerts.

### Azure SQL Database Ledger

| Table type | Use case |
|---|---|
| Updatable ledger tables | System-of-record apps needing insert/update/delete with full history |
| Append-only ledger tables | Insert-only apps (accounting, SIEM) — blocks updates/deletes at API level |

- Each transaction is SHA-256 hashed and chained, blockchain-style.
- **Easy rule:** ledger can only be enabled at database creation (or per-table via T-SQL) — can't retrofit onto an existing database after the fact.
- Benefits: eases audits, builds trust between parties, provides data integrity without blockchain performance overhead.

### Microsoft Purview

- Unified governance across on-prem, multicloud, SaaS: discovery, classification, lineage.
- Firewall access options for scanning: allow Azure connections, self-hosted integration runtime, or managed virtual network.
- Auth options for scans: **system-assigned managed identity (recommended)**, user-assigned managed identity (preview), service principal, SQL authentication.
- Self-hosted integration runtime → managed identities won't work; use service principal or SQL auth instead.
- Lineage extraction needs the Purview identity granted `db_owner` and a `CREATE MASTER KEY` on the target database; runs incremental scans every 6 hours based on stored procedure execution.
- Roles needed to register/manage a source: **Data Source Administrator** and **Data Reader**.

---

## 3. Protect data in-transit and at rest

### Remember

- Three protection scenarios: **data at rest** (storage), **data in transit** (network), **data in use** (RAM/CPU).
- TDE encrypts the whole database at the page level — transparent to apps, doesn't stop an authorized user from reading data.
- Always Encrypted encrypts specific columns client-side — even DBAs/admins can't see plaintext.
- TLS protects data crossing the network; use the highest supported version.
- Firewalls (server/database rules, VNet endpoints, Private Link) gate who can even reach the server.
- Azure Key Vault centralizes secrets/keys/certs for TDE, Always Encrypted, and backup encryption.
- SQL injection is a coding problem first — parameterize/validate input; Advanced Threat Protection is a backstop, not a fix.

### Transparent Data Encryption (TDE)

```sql
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<your-pwd>';
CREATE CERTIFICATE MyServerCert WITH SUBJECT = 'TDEDemo_Certificate';
CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256 ENCRYPTION BY SERVER CERTIFICATE MyServerCert;
ALTER DATABASE TDE_Demo SET ENCRYPTION ON;
```

- Encrypts at the **page** level, not table/column level — anyone with permission still reads plaintext through normal queries.
- Azure SQL Database: on by default for DBs created after **May 2017**; Managed Instance: default after **Feb 2019**. Older DBs need it enabled manually.
- Default = service-managed key. **BYOK** (customer-managed key in Key Vault) enables: granular control, separation of duties, revocable access, automatic key rotation (within 24h of new key version).
- Certificate must be backed up — losing it makes backups unrestorable.
- Azure Disk Encryption adds an extra VM-level layer on top of TDE.

### Server and database firewall

| Level | Configured via | Scope |
|---|---|---|
| Server-level | Portal or `sp_set_firewall_rule` (in master) | All databases on the server |
| Database-level | `sp_set_database_firewall_rule` (T-SQL only) | Single database |

- Lookup order on connect: database-level rule first, then server-level.
- **VNet service endpoints**: server-level only, region-bound, need outbound access via service tags.
- **Private Link**: private endpoint, traffic stays on Azure backbone (no public internet), supports cross-region connectivity and ExpressRoute.

### Always Encrypted and secure enclaves

| Encryption type | Same plaintext → | Supports |
|---|---|---|
| Deterministic | Same ciphertext | Equality, joins, grouping, indexing |
| Randomized | Different ciphertext each time | Strongest confidentiality, minimal query support |

- Column master key (CMK) encrypts column encryption keys (CEK); the **database engine never stores the CMK**, only metadata about where it lives (Key Vault, Windows Cert Store, HSM).
- Client app needs an Always Encrypted driver + `Column Encryption Setting=enabled` in the connection string.
- **Secure enclaves**: trusted memory region inside SQL Server for processing encrypted data — enables richer querying (pattern matching, comparisons, indexing) even on randomized-encrypted columns.
- Deployment scenarios: client+data on-prem, client on-prem/data in Azure (keys kept on-prem to exclude cloud admins), client+data fully in Azure.

### Encrypted connections (TLS)

- Certificate requirements: in local/current-user cert store, SQL Server service account has access, cert within valid period.
- Config steps: SQL Server Configuration Manager → Protocols → set certificate → **ForceEncryption = Yes** → restart service.
- **Exam idea:** TLS 1.2 is the most secure of the commonly tested options (vs 1.0/1.1).

### SQL injection

```sql
SELECT * FROM Orders WHERE OrderID=25; DELETE FROM Orders;
```

- Root cause: dynamically built SQL concatenating unvalidated user input.
- Primary defense: validate input type/length at the client, use parameterized queries — keyword filtering alone is insufficient (binary-encoded payloads bypass it).
- Advanced Threat Protection can flag both vulnerable code patterns and active injection attempts as a secondary layer.

### Azure Key Vault

- Stores secrets, certificates, and keys with its **own RBAC**, separate from subscription-level RBAC — a subscription admin has no automatic Key Vault access.
- Backs TDE (BYOK), Backup Encryption, and Always Encrypted key storage.
- SQL Server integration pattern: create a SQL login → create a `CREDENTIAL` mapped to the login (identity = key vault name, secret = app ID) → `CREATE ASYMMETRIC KEY ... FROM PROVIDER` to link to the Key Vault key.
