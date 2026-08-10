## Introduction
- Module theme = **defense-in-depth** for data security: encryption + masking + row-level filtering + auditing + permissions + AI-endpoint security, each addressing a different threat vector
- **Exam angle**: expect layered-scenario questions ("which combination of features satisfies this compliance requirement") more than isolated syntax; know that no single control is sufficient on its own — this framing recurs across every unit below

## Protect data with encryption
- Three distinct layers — **know exactly what each protects and against whom**:
    - **TDE (Transparent Data Encryption)**: encrypts data at rest (files, logs, backups); **zero app code changes**; DB engine key protected by a cert in master DB; does **NOT** protect against users with legitimate DB connection permissions — only against disk/backup theft
    - **Column-level encryption**: explicit T-SQL-managed encrypt/decrypt via symmetric/asymmetric keys — granular, more dev effort, but DBAs _can_ still decrypt if they have key access
    - **Always Encrypted**: keys live entirely **outside the DB engine** (client-side) — DB engine only ever sees ciphertext, so **even sysadmins can't view plaintext**. Requires client driver support and limits query operations on encrypted columns
- **Always Encrypted key hierarchy**: **Column Master Key (CMK)** — stored external (Azure Key Vault, Windows Cert Store, HSM), protects → **Column Encryption Key (CEK)** — stored in DB but only in encrypted form, actual key used to encrypt column data

```sql
CREATE COLUMN MASTER KEY MyCMK WITH (KEY_STORE_PROVIDER_NAME = 'AZURE_KEY_VAULT', KEY_PATH = '...');
CREATE COLUMN ENCRYPTION KEY MyCEK WITH VALUES (COLUMN_MASTER_KEY = MyCMK, ALGORITHM = 'RSA_OAEP', ENCRYPTED_VALUE = 0x...);
```

- **Always Encrypted encryption types — critical distinction**:
    - **DETERMINISTIC**: same plaintext → same ciphertext always → supports equality comparison, JOIN, WHERE filtering, grouping — but weaker (pattern analysis possible)
    - **RANDOMIZED**: stronger security, but **cannot** be used in equality/join/filter operations
- Column-level encryption manual flow: `CREATE MASTER KEY` → `CREATE CERTIFICATE` → `CREATE SYMMETRIC KEY ... ENCRYPTION BY CERTIFICATE` → `OPEN SYMMETRIC KEY ... DECRYPTION BY CERTIFICATE` → `ENCRYPTBYKEY()`/`DECRYPTBYKEY()` → `CLOSE SYMMETRIC KEY`
- Choosing: TDE = compliance baseline / no app changes; Always Encrypted = protect from DBAs / during query processing; column-level = granular control without Always Encrypted's infrastructure. **Can combine** (TDE baseline + Always Encrypted for most sensitive columns)
- **Fabric note**: TDE is **on by default, fully managed** — your encryption design work in Fabric focuses on column-level (Always Encrypted or symmetric keys)
- **Exam angle**: "TDE doesn't protect from users with valid DB access" and "Always Encrypted hides data even from admins" are the two most-tested conceptual traps; DETERMINISTIC-vs-RANDOMIZED and what operations each supports is very testable

## Configure dynamic data masking
- **DDM masks data only in query results — underlying data is unchanged**, presentation-layer only (not real protection against determined inference attacks)
- **Four masking functions — memorize the exact syntax and behavior**:
    - `default()` — full obfuscation: strings→"XXXX", numbers→0, dates→"01-01-1900"
    - `email()` — `jXXX@XXXX.com` pattern (first char + domain suffix preserved)
    - `random(low, high)` — numeric, **different value every query** — good for financial/statistical fields where realism matters but real value doesn't
    - `partial(prefix_len, padding_string, suffix_len)` — precise control, e.g. `partial(3, "-XXX-XX", 2)`

```sql
CREATE TABLE Customers (
    Email varchar(100) MASKED WITH (FUNCTION = 'email()'),
    Phone varchar(20) MASKED WITH (FUNCTION = 'partial(3, "-XXX-XX", 2)'),
    Income decimal(18,2) MASKED WITH (FUNCTION = 'random(10000, 100000)'),
    SSN char(11) MASKED WITH (FUNCTION = 'default()')
);
```

- Add/remove on existing columns: `ALTER TABLE ... ALTER COLUMN x ADD MASKED WITH (...)` / `... DROP MASKED`
- **`UNMASK` permission** controls who sees real values:
    - `GRANT UNMASK TO user` = database-wide unmask (all masked columns)
    - **SQL Server 2022+**: granular `GRANT UNMASK ON SCHEMA::x` / `ON TableName` / `ON TableName(ColumnName)` — least-privilege unmask scoping
- **Security gotcha to remember**: a user with SELECT + ALTER permission can **bypass masking by altering the column definition** — permission hygiene matters
- Masking should be **layered** with encryption and/or Row-Level Security for real sensitive-data protection, not relied on alone
- **Exam angle**: matching function to scenario (email/partial/random/default), the column-level UNMASK grant (2022+), and the ALTER-permission bypass risk are the top three testable points

## Implement row-level security
- **RLS filters rows dynamically per-user** — different from object-level permissions (all-or-nothing on the whole table)
- Two components:
    - **Security predicate**: inline table-valued function (`RETURNS TABLE`, `WITH SCHEMABINDING`) returning a row when access is allowed — this is the access-decision logic
    - **Security policy**: binds predicate function(s) to specific tables, specifies predicate type
- **Filter predicate** vs **block predicate** — key distinction:
    - **Filter**: silently removes inaccessible rows from SELECT/UPDATE/DELETE results — no error, just fewer rows
    - **Block**: raises an **error** on unauthorized INSERT/UPDATE/DELETE attempts — needed so a user can't insert a row they'd then be unable to see (specify direction: `AFTER INSERT`, `AFTER UPDATE`)

```sql
CREATE FUNCTION Security.fn_TenantAccessPredicate(@TenantID int)
RETURNS TABLE WITH SCHEMABINDING
AS RETURN SELECT 1 AS result WHERE @TenantID = CAST(SESSION_CONTEXT(N'TenantID') AS int);

CREATE SECURITY POLICY TenantSecurityPolicy
ADD FILTER PREDICATE Security.fn_TenantAccessPredicate(TenantID) ON dbo.Orders
WITH (STATE = ON);
```

- Common context sources for the predicate: `SESSION_CONTEXT()` (app sets via `sp_set_session_context`) for multi-tenant apps, or `DATABASE_PRINCIPAL_ID()` / `IS_MEMBER('RoleName')` for DB-user-based access
- **Hierarchical access pattern**: predicate function can use a **recursive CTE** internally to walk a manager→employee hierarchy — same recursion mechanics as the CTE module (anchor + recursive member)
- Management: `ALTER SECURITY POLICY ... WITH (STATE = OFF)` to disable temporarily without dropping; `ADD`/`DROP FILTER PREDICATE` to modify; query `sys.security_policies` + `sys.security_predicates` to inspect
- RLS is **transparent** — works automatically through views, stored procs, any query path touching the protected table
- **Exam angle**: filter vs block predicate distinction (silent removal vs error), WHY block predicates matter (prevent insert-then-can't-see-it scenario), and `SCHEMABINDING` requirement on the predicate function are the top testable points

## Manage permissions and secure access
- **Permission hierarchy cascades**: server → database → schema → object; granting at schema level covers **future objects too** (`GRANT SELECT ON SCHEMA::Sales TO Role`)
- **Three permission statements — know the exact difference**:
    - `GRANT` — allow
    - `REVOKE` — remove a specific grant (doesn't block access from _other_ grants the user might have)
    - `DENY` — explicit block that **overrides any GRANT**, regardless of source
- **RBAC pattern**: create roles (`CREATE ROLE`) → grant permissions to roles → add users via `ALTER ROLE ... ADD MEMBER`; roles can nest (parent role membership inherits child role permissions)
- Schema-based permission grouping: `CREATE SCHEMA X AUTHORIZATION dbo` then grant at schema level for department/function separation
- **Microsoft Entra (passwordless) authentication** — the modern recommended approach over SQL auth:

```sql
CREATE USER [developer@contoso.com] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [developer@contoso.com];
```

- Supported on: Azure SQL DB, Azure SQL MI, **SQL Server 2022+**, Fabric SQL DB
- **Managed Identity** = most secure option for Azure-hosted apps — no credentials to leak, Azure manages lifecycle automatically
    - System-assigned (1:1 with a resource) vs **user-assigned** (shared across multiple apps needing same permissions — reduces DB user management overhead)
    - Connection string pattern: `Authentication=Active Directory Managed Identity;Encrypt=True;`
- Connection string security best practices: store in Key Vault/env vars (never in code), prefer Managed Identity to eliminate credentials entirely, `Encrypt=True;TrustServerCertificate=False`, restrict via firewall/private endpoints
- Auditing permissions: query `sys.database_permissions` joined to `sys.database_principals`/`sys.objects`, or `fn_my_permissions('object', 'OBJECT')` for effective-permission checks on the current user
- **Exam angle**: GRANT/REVOKE/DENY precedence (DENY always wins) is the single most classic SQL security exam question; also know Entra auth platform support list and user-assigned vs system-assigned managed identity use case

## Implement auditing
- Platform-specific backend — **know which platform uses what**:
    - **SQL Server**: Extended Events infrastructure → writes to file, Windows Security log, or Windows Application log
    - **Azure SQL**: writes to **Blob Storage, Log Analytics, or Event Hubs**
    - **Fabric SQL DB**: uses Fabric activity logging + **Microsoft Purview** for unified cross-estate auditing
- SQL Server setup flow: `CREATE SERVER AUDIT` (defines destination) → `ALTER SERVER AUDIT ... WITH (STATE = ON)` (enable) → `CREATE SERVER AUDIT SPECIFICATION` (server-level events) and/or `CREATE DATABASE AUDIT SPECIFICATION` (database-level events, e.g. specific table SELECT/INSERT/UPDATE/DELETE)

```sql
CREATE SERVER AUDIT SecurityAudit
TO FILE (FILEPATH = 'C:\AuditLogs\', MAXSIZE = 100 MB, MAX_ROLLOVER_FILES = 10)
WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE);
```

- **`QUEUE_DELAY`**: ms buffered before write — lower = more real-time but more perf impact
- **`ON_FAILURE`**: `CONTINUE` vs **`SHUTDOWN`** — use SHUTDOWN when missing audit records is unacceptable for compliance (fails closed)
- Common audit action groups to recognize: `FAILED_LOGIN_GROUP`/`SUCCESSFUL_LOGIN_GROUP` (auth events), `DATABASE_PERMISSION_CHANGE_GROUP`/`DATABASE_ROLE_MEMBER_CHANGE_GROUP` (permission changes), `SCHEMA_OBJECT_CHANGE_GROUP` (DDL), `BATCH_COMPLETED_GROUP` (all batches — **high volume**, use cautiously)
- Query audit logs: `fn_get_audit_file()` (file-based SQL Server audits) or **KQL** against Log Analytics for Azure SQL (`AzureDiagnostics | where Category == "SQLSecurityAuditEvents"`)
- **Best practice — testable**: start with a **focused set** of audit actions, not everything — high-volume auditing hurts performance and makes logs unreviewable
- **Retention/integrity best practices**: store audit logs **separately from the monitored database** (so a compromised DB can't let attackers tamper with its own audit trail), use immutable storage, define retention per compliance needs (financial data often ~7 years)
- **Exam angle**: which platform writes audit logs where (file/Windows logs vs Blob/LogAnalytics/EventHubs vs Purview), the QUEUE_DELAY/ON_FAILURE=SHUTDOWN tradeoffs, and "store audit logs separately from the DB" are the key testable facts

## Configure secure access to AI services
- **Managed Identity is the recommended pattern** for DB→AI-service calls — eliminates API keys stored in DB/app code
- Flow: enable managed identity on the SQL resource → assign Azure RBAC role (e.g., **Cognitive Services User**) on the target AI resource → `CREATE DATABASE SCOPED CREDENTIAL ... WITH IDENTITY = 'Managed Identity'` → `CREATE EXTERNAL DATA SOURCE ... TYPE = REST` pointing at the AI endpoint

```sql
CREATE DATABASE SCOPED CREDENTIAL AzureOpenAICredential
WITH IDENTITY = 'Managed Identity', SECRET = '{"resourceId": "https://cognitiveservices.azure.com/"}';

CREATE EXTERNAL DATA SOURCE AzureOpenAI
WITH (TYPE = REST, LOCATION = 'https://myopenai.openai.azure.com', CREDENTIAL = AzureOpenAICredential);
```

- **`sp_invoke_external_rest_endpoint`** — the system proc that actually makes the HTTP call to the AI service from T-SQL, taking url/method/payload/credential and returning the response via OUTPUT param
- Access control: create a dedicated role (e.g., `AIFeatureUsers`) and **only** grant EXECUTE on the AI-calling procedure to that role — AI calls have real $ cost and data-exposure risk, so least-privilege matters more than usual
- **Monitoring pattern**: log every AI call (caller principal via `ORIGINAL_LOGIN()`, timestamp, duration, status) to a table; query for `COUNT(*) > threshold` per principal per time window to catch cost/anomaly spikes
- **Fabric AI security model is different**: no database-scoped credentials — access is controlled via **workspace roles** (Contributor+) and **capacity-based access control** instead
- **Exam angle**: know the Managed Identity → RBAC role → scoped credential → external data source chain, that `sp_invoke_external_rest_endpoint` is the actual call mechanism, and that Fabric AI security is workspace-role-based rather than credential-based (common point of confusion vs Azure SQL)

## Secure data API endpoints
- Three endpoint types, each with distinct risk profile:
    - **GraphQL**: flexible client-driven queries → risk = schema exposure via introspection, and DoS via deeply nested/complex queries
    - **REST**: structured, predefined operations → risk = standard auth/authorization/input-validation concerns (well-established patterns)
    - **MCP**: AI-driven interaction → risk = AI attempting unexpected operations, **prompt injection** manipulating AI behavior
- **GraphQL security (via Data API builder / Fabric GraphQL API)**:
    - **`allow-introspection: false` in production** — prevents attackers from discovering full schema/type structure via introspection queries
    - Entity-level + field-level permissions: role-based `actions` (`read`/`create`/`update`/`*`) plus explicit `fields.include`/`fields.exclude` to hide sensitive columns even from authenticated roles
    - Built-in query depth/complexity limits guard against nested-query DoS
- **REST security (Data API builder)**: role-based `actions` per entity; **row-filtering policies** even for anonymous role (e.g., `"policy": {"database": "@item.IsPublic eq true"}`); for custom stored-proc-based REST endpoints, enforce authorization checks inside the proc itself (e.g., verify `ORIGINAL_LOGIN()` against an access table) before returning data
- **MCP security — the newest/most exam-relevant risk area**:
    - Config-level restrictions: `allowedOperations: ["read"]` (read-only by default), `deniedTables` (explicit blocklist for credential/config tables), `maxRowsReturned` (limit exfiltration via large result sets)
    - **Prompt injection defense**: never trust AI-generated queries — validate against **denylist of system objects** (`sys.*`, `INFORMATION_SCHEMA`) and **write-operation keywords** (INSERT/UPDATE/DELETE/DROP) before execution; **prefer allow-lists over block-lists** for permitted tables/operations — this is explicitly called out as the more robust approach
- **Network-layer defense-in-depth** (applies regardless of endpoint type): Azure SQL firewall rules (`sp_set_firewall_rule`, deny-by-default + explicit IP/VNet allow), **Private Link/Private Endpoints** to keep traffic off the public internet, VNet integration for App Services, Fabric managed private endpoints
- **Exam angle**: `allow-introspection: false`, prefer-allow-list-over-block-list for MCP query validation, and matching endpoint type (GraphQL/REST/MCP) to its distinct primary risk are the most testable specifics in this unit