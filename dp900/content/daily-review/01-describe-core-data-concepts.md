# DP-900 — Describe Core Data Concepts

## 1. Explore core data concepts

### Remember

- Data is structured, semi-structured, or unstructured.
- Structured = fixed schema, tabular. Semi-structured = flexible schema (JSON/XML). Unstructured = no schema (docs, images, audio, video, vector/embeddings).
- Two broad data store categories: **file stores** and **databases**.
- Relational databases use keys + SQL. Nonrelational (NoSQL) databases skip the fixed relational schema.
- OLTP = transactional, many small read/write operations, ACID. OLAP = analytical, read-heavy, aggregated.
- ETL = transform before load. ELT = load first, transform after (common in lakehouses).
- Medallion architecture: Bronze (raw) → Silver (cleansed) → Gold (business-ready).

### Structured / semi-structured / unstructured

| Type | Schema | Examples |
|---|---|---|
| Structured | Fixed, tabular | Rows/columns in a relational table |
| Semi-structured | Flexible, self-describing | JSON, XML documents |
| Unstructured | None | Images, audio, video, free text, vector data |

**Easy rule:** if every record must have the exact same fields, it's structured. If fields can vary between records, it's semi-structured.

### File storage formats

- **Delimited text (CSV/TSV):** human-readable, simple, widely compatible.
- **JSON:** hierarchical, good for structured and semi-structured data.
- **XML:** older, verbose, tag-based (`<Element attr="value"/>`); mostly superseded by JSON.
- **BLOB (Binary Large Object):** raw binary — images, video, audio, app-specific files.

```json
{ "firstName": "Joe", "contact": [{ "type": "email", "address": "joe@litware.com" }] }
```

**Optimized formats:**

| Format | Layout | Best for |
|---|---|---|
| Parquet | Columnar | Analytics, compression, nested data — de facto lakehouse standard |
| Avro | Row-based | Compact storage, network transfer, schema stored as JSON header |
| Delta Lake | Parquet + transaction log | ACID transactions, versioning, reliable updates on a data lake |

### Databases: relational vs nonrelational

**Relational**
- Data in tables (entities), rows = instances, columns = attributes.
- Primary keys uniquely identify rows; referenced elsewhere as foreign keys.
- *Normalization* removes duplicate data.
- Queried with SQL (ANSI standard, portable across systems).

**Nonrelational (NoSQL)** — four common types:

| Type | Shape |
|---|---|
| Key-value | Unique key + value in any format |
| Document | Key-value where the value is a JSON document |
| Column family | Rows/columns grouped into column-families |
| Graph | Nodes (entities) + edges (relationships) |

**Exam idea:** "NoSQL" doesn't mean "no SQL support" — some nonrelational databases still support a SQL-like query language.

### OLTP — transactional processing

- Records discrete business *transactions* (CRUD), often high volume.
- Optimized for fast reads **and** writes.
- Supports line-of-business (LOB) applications.

**ACID:**

| Property | Meaning |
|---|---|
| Atomicity | Transaction fully succeeds or fully fails |
| Consistency | Only moves the database from one valid state to another |
| Isolation | Concurrent transactions don't interfere with each other |
| Durability | Once committed, a transaction survives even a system crash |

**Easy rule:** debit + credit in a bank transfer either both happen or neither happens — that's atomicity in one line.

### OLAP — analytical processing

- Read-only / read-mostly, works on historical data or business metrics.
- Typical flow: source systems → **ETL/ELT** → data lake → data lakehouse/warehouse → OLAP model (semantic model) → reports/dashboards.
- **Data lake:** flexible, large-scale file storage.
- **Data warehouse:** relational schema optimized for read/reporting.
- **Data lakehouse:** data lake storage + data warehouse-style relational querying.
- **OLAP/semantic model (cube):** preaggregated measures across dimensions; supports drill up/down; fast because it's precomputed.

| Concept | Role |
|---|---|
| Data lake | Raw/flexible file-based storage |
| Data warehouse | Relational, read-optimized schema |
| Data lakehouse | Lake storage + warehouse-style querying |
| OLAP/semantic model | Preaggregated measures for fast reporting |

**Modern analytics platforms:**
- **Microsoft Fabric:** unified SaaS analytics platform (storage, engineering, warehousing, reporting in one workspace).
- **Azure Databricks:** cloud analytics platform for large-scale engineering/data science, built on Delta Lake.
- **Microsoft Purview:** data governance — discover, classify, protect data across sources.

**Medallion architecture:**

| Layer | Content |
|---|---|
| Bronze | Raw, as-ingested, no transformation |
| Silver | Cleansed, deduplicated, standardized |
| Gold | Aggregated, business-ready |

**Exam idea:** keeping Bronze untouched lets you reprocess data from scratch if downstream requirements change.

---

## 2. Explore data roles and services

### Remember

- Four key data roles: **DBA**, **data engineer**, **data analyst**, **AI engineer**.
- DBA = keeps databases running, secure, backed up. Data engineer = builds pipelines. Data analyst = turns data into insights/reports. AI engineer = builds AI-powered features/workflows.
- One person can wear multiple role "hats" in smaller orgs.
- PaaS = Microsoft manages infrastructure, you manage data/app. SaaS = fully managed, ready-to-use product.
- Azure SQL family, Cosmos DB, and Azure Storage are the core transactional/storage building blocks; Fabric, Power BI, Databricks are the core analytics building blocks.

### Data roles

| Role | Focus | Typical tasks |
|---|---|---|
| Database Administrator | Keep databases available, secure, performant | Provisioning, backup/restore, permissions |
| Data Engineer | Move and prepare data | Pipelines, ETL/ELT, data cleansing, governance |
| Data Analyst | Turn data into insight | Exploration, modeling, reports, visualizations |
| AI Engineer | Build AI-powered features | LLMs, ML pipelines, chat-over-your-data, Microsoft Foundry |

**Easy rule:** DBA guards the data, data engineer moves the data, data analyst explains the data, AI engineer builds on top of the data.

### Azure data services by role

**PaaS vs SaaS:** PaaS = Microsoft manages servers/patching/backups, you manage data and app (e.g., Azure SQL Database). SaaS = fully managed end-to-end product, no infra to think about (e.g., Microsoft Fabric).

| Service | What it is | Who mainly uses it |
|---|---|---|
| Azure SQL (Database / Managed Instance / VM) | Relational DB family on SQL Server engine | DBA (provision/manage), data engineer (ETL source), data analyst (query) |
| Azure Database for MySQL / PostgreSQL | Managed open-source relational DBs | DBA, data engineer, data analyst |
| Azure Cosmos DB | Global-scale NoSQL (document, key-value, column-family, graph APIs) | Developers, DBA; data engineer integrates into analytics |
| Azure Storage | Blob containers, file shares, tables | Data engineer (hosts data lakes) |
| Azure Data Factory | Pipeline orchestration for ETL | Data engineer |
| Microsoft Fabric | Unified SaaS analytics platform (OneLake-based) | Data engineer, data analyst, data scientist |
| Power BI | Business intelligence / visualization | Data analyst |
| Azure Databricks | Spark-based analytics platform (Delta Lake) | Data engineer, data analyst |
| Azure Stream Analytics | Real-time stream processing | Data engineer |
| Azure Data Explorer | High-performance querying of log/telemetry (timestamped) data | Data analyst |
| Microsoft Purview | Enterprise data governance, lineage, discovery | Data engineer |
| Microsoft Foundry | Unified PaaS for enterprise AI (models, agents, deployment) | AI engineer |

**Azure SQL: three flavors, one rule**

| Option | Control vs. management |
|---|---|
| Azure SQL Database | PaaS, minimal admin |
| Azure SQL Managed Instance | More configurability, more admin responsibility |
| Azure SQL VM | Full OS/SQL Server control, full management responsibility |

**Exam idea:** Azure Data Factory = pipelines/ETL → data engineer territory. Power BI = reports/dashboards → data analyst territory. Backup/restore → DBA territory.

**Fabric building blocks:** Fabric Data Factory (ingestion/ETL), Fabric Lakehouse, Fabric Warehouse, Power BI (via semantic models), Real-Time Intelligence, plus governance — all on shared **OneLake** storage.
