# DP-800 — Design and Develop Database Solutions

## 1. Design and implement database objects

### Remember

- Pick the right Azure SQL platform for the workload.
- Use the smallest correct data type.
- Use `DECIMAL` for money, not `FLOAT`.
- `INT` keys are smaller and usually faster than GUID keys.
- Rowstore is usually for OLTP. Columnstore is usually for analytics.
- Constraints protect data inside the database.

### Azure SQL choices

| Option | Use it when |
|---|---|
| Azure SQL Database | You want PaaS and minimal administration |
| Serverless | Workload is intermittent and should scale/pause automatically |
| Hyperscale | Database is very large or needs strong read scaling |
| Managed Instance | You need high SQL Server compatibility in Azure |
| SQL Server on Azure VM | You need OS/SQL Server instance control |
| SQL Database in Fabric | You want operational SQL integrated with Fabric/OneLake |

**Easy rule:** more control → VM. Less administration → Azure SQL Database.

### Data types

- `INT` / `BIGINT`: whole numbers.
- `DECIMAL`: exact numbers. Best choice for money.
- `FLOAT`: approximate numbers.
- `VARCHAR`: non-Unicode text.
- `NVARCHAR`: Unicode text.
- `DATETIME2`: preferred over old `DATETIME`.
- `UNIQUEIDENTIFIER`: GUID; useful, but larger than `INT`.

### Indexes

**Clustered index**
- Controls how table rows are organized.
- One per table.
- Good for ranges and ordered access.

**Nonclustered index**
- Separate structure that points to rows.
- You can have many.
- Good for selective searches.
- `INCLUDE` can cover a query and reduce key lookups.

**Columnstore**
- Stores data by column instead of row.
- Great for large analytical queries and aggregations.
- Usually not ideal for frequent single-row lookups or heavy updates.

**CCI:** table itself is columnstore.  
**NCCI:** columnstore copy exists beside the normal rowstore table.

### Specialized tables

| Type | Main purpose |
|---|---|
| In-memory optimized | Very high transaction throughput |
| Temporal | Automatically keep row history |
| External | Query external files/data without loading them |
| Ledger | Detect tampering using cryptographic history |
| Graph | Model nodes and relationships |

**Remember:** specialized tables solve specific problems and usually add a trade-off.

### Constraints

| Need | Use |
|---|---|
| Unique row identifier | `PRIMARY KEY` |
| Prevent orphan rows | `FOREIGN KEY` |
| Prevent duplicates | `UNIQUE` |
| Validate values | `CHECK` |
| Require a value | `NOT NULL` |
| Supply a default | `DEFAULT` |

Important:
- Foreign key columns are **not automatically indexed**.
- `CHECK` does not reject `NULL` unless `NOT NULL` is also used.
- A `SEQUENCE` is independent from a table.
- `IDENTITY` belongs to one table.

---

## 2. AI-assisted SQL development

### Remember

AI can help write SQL, but you still review the SQL before running it.

### GitHub Copilot

Can help with:
- SQL completion
- natural language → SQL
- explaining queries
- troubleshooting
- optimization ideas

### MCP

MCP lets an AI assistant use live tools or database context instead of only the text currently open in the editor.

**Security rule:** give MCP the minimum permissions it needs. Prefer read-only access where possible.

### Safe usage

- Never paste credentials into prompts.
- Review generated `GRANT`, `REVOKE`, or `DENY`.
- Check dynamic SQL for injection risks.
- Check generated queries for accidental data exposure.
- Use repository instructions for team-wide AI rules.

---

## 3. SQL programmability objects

### Remember

- **View** = reusable query.
- **Stored procedure** = execute database logic.
- **Function** = return a value or table and use it inside a query.
- **Trigger** = run automatically after/before certain database events.

### Views

Use views to:
- simplify joins
- hide columns/rows
- give applications a stable interface

Avoid `SELECT *`.

`WITH CHECK OPTION` prevents changes through the view that would make rows disappear from that view.

### Stored procedures

Use when you need:
- parameters
- transactions
- data modification
- procedural logic

Good habits:
- `SET NOCOUNT ON`
- validate parameters early
- schema-qualify object names
- use `TRY...CATCH`
- do not name your own procedures with `sp_`

### Functions

**Scalar function:** returns one value.  
**Inline TVF:** returns a table from one query. Usually optimizer-friendly.  
**Multi-statement TVF:** more flexible, but harder for the optimizer to estimate.

**Exam idea:** inline TVFs are usually easier for SQL Server to optimize than multi-statement TVFs.

### Triggers

Run automatically on database events.

- `AFTER`: runs after the statement.
- `INSTEAD OF`: replaces the original statement.

Use `inserted` and `deleted` pseudo-tables.

Keep trigger logic small because triggers are automatic and less visible during debugging.

### Quick comparison

| Feature | View | Procedure | Function | Trigger |
|---|---:|---:|---:|---:|
| Parameters | No | Yes | Yes | No |
| Modify data | Limited | Yes | No | Yes |
| Use in `SELECT` | Yes | No | Yes | No |
| Transaction logic | No | Yes | No | Yes |
| Runs automatically | No | No | No | Yes |

---

## 4. Advanced T-SQL

### CTEs

A CTE is a temporary named result used by the **next statement only**.

Use recursive CTEs for hierarchies such as:
- org charts
- parent/child structures
- generated sequences

Default recursion limit is 100.

### Window functions

Window functions calculate across related rows **without collapsing rows** like `GROUP BY`.

Important functions:
- `ROW_NUMBER()` → unique sequence
- `RANK()` → ties share rank and create gaps
- `DENSE_RANK()` → ties share rank, no gaps
- `LAG()` / `LEAD()` → previous/next row
- `SUM() OVER(...)` → running or partitioned totals

### JSON

- `JSON_VALUE` → get one scalar value.
- `JSON_QUERY` → get an object or array.
- `OPENJSON` → turn JSON into rows.
- `FOR JSON PATH` → turn SQL rows into JSON.
- `ISJSON` → validate JSON.

### Regex

Modern SQL versions support functions such as:
- `REGEXP_LIKE`
- `REGEXP_REPLACE`
- `REGEXP_SUBSTR`

Use regex for structured text matching, validation, extraction, and replacement.

### Fuzzy matching

- `EDIT_DISTANCE` → how many character edits separate two strings.
- `EDIT_DISTANCE_SIMILARITY` → similarity score.
- Jaro-Winkler → useful for names and short strings.

**Performance:** fuzzy matching is expensive. Filter candidates first.

### Graph queries

- `AS NODE` → entity.
- `AS EDGE` → relationship.
- `MATCH` → query relationships.

Use graph when relationships and multi-hop traversal are central to the problem.

### Error handling

Use:

```sql
BEGIN TRY
    -- work
END TRY
BEGIN CATCH
    -- handle error
    THROW;
END CATCH
```

Prefer `THROW` for modern code.
