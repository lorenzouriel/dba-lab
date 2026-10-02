# DP-900 — Describe an Analytics Workload on Azure

## 1. Large-scale analytics

### Remember

- Large-scale analytics = data warehousing (BI) + big data techniques combined.
- **OLTP-style transactional stores** feed analytical stores; you don't report directly off production transactional systems.
- ETL transforms **before** loading. ELT transforms **after** loading.
- **Microsoft Fabric** = unified SaaS analytics platform on shared storage **OneLake**.
- **Azure Databricks** = Spark-based lakehouse platform using **Delta Lake**.
- A **data lakehouse** combines data lake flexibility with data warehouse SQL querying.
- Fact tables hold numbers; dimension tables hold things you group by.

### Data warehousing architecture layers

1. **Data ingestion and processing** — ETL/ELT, batch or real-time, often distributed multi-node processing.
2. **Analytical data store** — data warehouse, data lake, or lakehouse.
3. **Analytical data model** — semantic model (tables, relationships, measures in DAX); Direct Lake reads Delta tables straight from OneLake.
4. **Data visualization** — reports, dashboards, KPIs.
5. **AI-assisted analytics** — Power BI Q&A, Copilot in Fabric, Genie in Databricks.

**Easy rule:** ingest → store → model → visualize (+ AI layered on top of all of it).

### ETL vs ELT

| Aspect | ETL | ELT |
|---|---|---|
| Transform happens | Before load | After load |
| Data lands in store | Already transformed | Raw, then transformed |
| Typical fit | Traditional data warehouse | Data lake / lakehouse |

### Microsoft Fabric vs Azure Databricks

| Aspect | Microsoft Fabric | Azure Databricks |
|---|---|---|
| Model | Unified SaaS, no servers to manage | Managed service inside your Azure subscription |
| Storage | OneLake (tenant-wide, shared) | Delta Lake (native open format) |
| Core store items | Lakehouse, Warehouse | Databricks Lakehouse, Databricks SQL |
| Code style | Low-code + notebooks | Code-first, notebook-centric (Python/SQL/Scala/R) |
| Governance | Fabric workspace | Unity Catalog |
| Natural-language query | Copilot in Fabric | Genie |

**Exam idea:** Fabric Lakehouse = Delta Lake storage + SQL analytics endpoint, auto-created. Fabric Warehouse = fully managed, SQL Server–compatible, strong schema enforcement — both sit on OneLake.

### Data ingestion tools

**Microsoft Fabric**
- **Fabric Data Factory**: Pipelines (orchestrate activities via linked services) + Dataflows Gen2 (low-code Power Query transforms).
- **OneLake Shortcuts**: live reference to external storage (ADLS Gen2, S3, GCS, another OneLake) — no copy, no movement.
- **Mirroring**: continuous near-real-time replication of an external database (Azure SQL DB, Snowflake, Cosmos DB) into OneLake, automatic, no pipeline needed.
- **Eventstream**: real-time ingestion from Event Hubs, Kafka, IoT Hub → Lakehouse, KQL database, or Real-Time Intelligence.
- **Fabric Notebooks**: Spark-based code-first ingestion (PySpark/Python/Scala/R/SQL) — the escape hatch when no connector fits.

**Azure Data Factory**: standalone Azure service for pipelines outside Fabric (Azure SQL DB destinations, on-prem hybrid sources). Same pipeline model as Fabric Data Factory — skills transfer.

**Azure Databricks**
- **Lakeflow Declarative Pipelines**: declarative, incremental, production-grade — you define outputs, Databricks handles execution order.
- **Databricks Notebooks**: ad-hoc/exploratory ingestion; can be scheduled as jobs or embedded in a Lakeflow pipeline.

### Analytical data stores

| Store | Structure | Best for |
|---|---|---|
| Data warehouse | Relational, star/snowflake schema | Structured data, SQL, strong schema enforcement |
| Data lake | Files, schema-on-read | Structured + semi-structured + unstructured, no enforcement on write |
| Data lakehouse | Files + SQL endpoint (Delta Lake) | Both — schema/transactions on top of lake files |

- **Star schema**: one fact table + dimension tables directly related to it.
- **Snowflake schema**: dimension tables further normalized into related sub-tables (e.g., Product → Category).
- **Fact table**: numeric/measurable events (sales amount, quantity).
- **Dimension table**: entities to aggregate/filter by (customer, product, store, time).

**Easy rule:** need SQL + strong schema → Warehouse. Need mixed/semi-structured data or ML/Spark → Lakehouse.

---

## 2. Real-time analytics

### Remember

- **Batch processing**: collect first, process together, higher latency (hours).
- **Stream processing**: process each event as it arrives, low latency (seconds/ms).
- Stream processing typically only sees recent data / a rolling window, not the whole dataset.
- General stream flow: **event → source/queue → perpetual query → sink**.
- **Event Hubs** = high-volume event ingestion, ordered per partition, at-least-once delivery.
- **Azure Stream Analytics** = PaaS streaming jobs (source → query → output), good outside Fabric.
- Lambda architecture = batch layer + speed (streaming) layer combined, serving both historical and real-time views.

### Batch vs stream processing

| Aspect | Batch | Stream |
|---|---|---|
| Data scope | Whole dataset | Recent data / rolling window |
| Data size | Large datasets | Individual records or micro-batches |
| Latency | Hours (typical) | Seconds/milliseconds |
| Analysis style | Complex analytics | Simple aggregates, running calculations |
| Example | Monthly credit card bill | Fraud alert as a transaction happens |

**Exam idea:** counting parked cars = batch; counting cars as they pass = stream.

### Lambda architecture (combining both)

1. Streaming source captured in real time.
2. Other sources batch-ingested into a data lake.
3. Streaming data also written to the lake for later batch processing (if real-time isn't needed).
4. Stream processing filters/aggregates over time windows for real-time analysis.
5. Batch processing periodically prepares data for the data warehouse.
6. Stream results may also land in the analytical store for history.
7. Visualization tools present both real-time and historical data.

**Note:** kappa architecture drops the separate batch layer — treats everything as a replayable stream (Fabric, Kafka make this practical).

### Stream processing architecture elements

1. **Event** — sensor signal, social post, log entry, etc.
2. **Source / queue** — captures event data, often ensures ordering and exactly-once/at-least-once processing.
3. **Perpetual query** — filters, projects, or aggregates over time **windows**.
4. **Sink** — file, database table, dashboard, or another queue.

### Sources and sinks on Azure

| Sources | Sinks |
|---|---|
| Azure Event Hubs (ordered per partition, at-least-once) | Azure Event Hubs (downstream queueing) |
| Azure IoT Hub (IoT-optimized) | ADLS Gen2 / OneLake / Blob storage (files) |
| ADLS Gen2 (usually batch, can stream) | Azure SQL DB / Databricks / Fabric (tables) |
| Apache Kafka (open-source, common with Spark) | Power BI (real-time dashboards) |

### Real-time analytics services

| Service | What it does |
|---|---|
| **Microsoft Fabric Real-Time Intelligence** | Eventstreams (ingest/route/transform) + Eventhouse (KQL time-series store) + Real-Time Dashboards + Activator (alerts on conditions) |
| **Spark Structured Streaming** | Open-source library; treat a live stream like a continuously growing table/dataframe; runs on Databricks or Fabric |
| **Azure Stream Analytics** | PaaS streaming jobs: ingest → perpetual query → output; solid for standalone/hybrid scenarios outside Fabric |

**Fabric Real-Time Intelligence pieces:**
- **Real-time hub**: centralized catalog to discover/share streaming data org-wide.
- **Eventhouse**: queried with **KQL** (Kusto Query Language) — built for logs/telemetry.
- **Activator**: triggers automated actions when stream data meets conditions.

### Spark Structured Streaming + Delta Lake

- Flow: streaming source → dataframe (keeps growing) → query (e.g., count per minute) → sink.
- **Delta Lake** adds to plain data lake files: reliability (tracked writes), schema enforcement, and a **unified batch + streaming** table (same Delta table serves both).

**Easy rule:** Delta Lake + Structured Streaming = one consistent store for both real-time ingestion and historical batch analysis.

---

## 3. Data visualization

### Remember

- **Power BI Desktop** = author reports/models. **Power BI service** = publish, schedule refresh, share, build dashboards/apps.
- A **dataset/semantic model** defines measures, relationships, hierarchies — reused across reports.
- **Dimension** = what you group/filter by. **Measure** = the number you aggregate.
- **Star schema** = fact + dimensions. **Snowflake schema** = dimensions further normalized.
- **Direct Lake mode** queries OneLake Delta tables directly — no import, no refresh cycle.
- Choose chart type by what you're comparing: categories → bar/column; trend over time → line; proportion → pie; correlation → scatter; geography → map.

### Power BI tools and workflow

1. **Power BI Desktop** (Windows app): import data, build the model, author reports.
2. **Power BI service** (cloud): publish reports, schedule data refresh, share, build **dashboards** and **apps** that bundle related reports.
3. Consumption: browser or **Power BI phone app**.

Web-based editing in the service exists but has less functionality than Desktop.

### Power BI in Microsoft Fabric

- Lives in shared **workspaces** alongside other Fabric items, backed by **OneLake**.
- **Semantic models**: measures/relationships/hierarchies, shareable across reports.
- **Direct Lake mode**: query OneLake files directly — speed of in-memory + scale of a lake, no import/refresh needed.
- Reports can be authored fully in-browser (no Desktop install required).

### Data modeling core concepts

- **Semantic model** = tables + measures + dimensions, built for analysis.
- **Fact table**: numeric measures, one row per recorded event (e.g., a sale).
- **Dimension table**: entities to group/filter by (product, customer, time) — unique key + descriptive attributes.
- **Time dimension**: present in almost every analytical model.
- **Star schema**: fact directly related to dimensions. **Snowflake schema**: dimension linked to further detail tables (Category → Product).
- **Hierarchy**: lets you drill up/down (Year → Month → Day; Category → Product; Country → City).
- Power BI stores the model in-memory using the **VertiPaq** engine; aggregations compute at **query time**.

**Exam idea:** define a hierarchy to enable drill-up/down analysis — not a plain relationship or measure.

### Visualization types — when to use what

| Visual | Best for |
|---|---|
| Table / card (text) | Detailed values / a single key metric |
| Bar / column chart | Compare discrete categories |
| Line chart | Trends over time |
| Pie chart | Proportions of a whole |
| Scatter plot | Correlation between two numeric measures |
| Map | Compare values across geographic areas |

Visuals in a Power BI report are **linked/interactive by default** — selecting a value in one visual cross-filters the others.

### AI features in Power BI

- **Copilot** (needs Fabric capacity F2+ or Premium P1+): summarize a report, generate report pages, write DAX measures from natural language.
- **Smart narrative**: auto-generated text summary of a visual, updates dynamically — no Copilot license needed.
- **Q&A visual**: ask plain-English questions, get an instant chart answer.
- **Key influencers**: shows what factors most drive a selected metric.
- **Decomposition tree**: interactive drill-down across multiple dimensions to explain a value.
