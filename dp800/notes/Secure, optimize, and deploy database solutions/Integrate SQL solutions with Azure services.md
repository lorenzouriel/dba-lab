## Introduction
- Module theme = **Data API Builder (DAB)** — auto-generates REST + GraphQL APIs from DB schema via a single config file, no backend code
- Covers: config files → entity definitions (mappings/caching/pagination/filtering) → REST/GraphQL endpoint config → views/stored procs/relationships → deployment (Container Apps/App Service/Static Web Apps) → Azure Monitor observability → event-driven change patterns (CDC/Change Tracking/CES)
- **Exam angle**: heavily config-syntax and JSON-structure driven — expect "what does this config property do" and "which section controls X" questions; also platform-comparison questions among the three deployment targets and among CDC/Change Tracking/CES

## Create configuration files for data API builder

- Config = single JSON file, **four main sections**: `$schema` (validation/IntelliSense), `data-source` (connection), `runtime` (host/auth/caching behavior), `entities` (what's exposed)
- `database-type: "mssql"` for SQL Server/Azure SQL/Fabric SQL DB
- **Never hardcode connection strings** — use `"connection-string": "@env('DATABASE_CONNECTION_STRING')"` to pull from environment variables, keeping secrets out of source control
- `"options": {"set-session-context": true}` — passes user identity to SQL Server via session context so stored procs/functions can read it via `SESSION_CONTEXT()` — enables RLS or audit logging tied to the calling user
- Runtime `rest`/`graphql` sections each have `enabled` + `path`; `graphql.allow-introspection` — helpful in dev, **security risk in production** (schema discovery)
- `host.cors` controls which origins can call the API from browsers; `host.mode` toggles dev vs production behavior (e.g., error detail verbosity)
- **DAB CLI** for config management (reduces manual JSON errors, keeps formatting consistent for PR review):

```bash
dab init --database-type mssql --connection-string "@env('DATABASE_CONNECTION_STRING')" --host-mode development
dab add Product --source dbo.Products --permissions "anonymous:read"
```

- **Multi-environment config**: base `dab-config.json` + environment-specific override files (`dab-config.development.json`, `.staging.json`, `.production.json`) — DAB **merges** them, environment-specific values take precedence; only differences need to be in the override file:

```bash
dab start --config dab-config.production.json
```

- **Exam angle**: the four config sections, `@env()` for credential safety, `set-session-context` enabling RLS/audit via `SESSION_CONTEXT()`, and the config-merge behavior for multi-environment setups are the top testable specifics

## Define entities for REST and GraphQL

- Entity definition = `name` + `source` (object + `type`: `table`/`view`/`stored-procedure`) + `permissions` (role-based, `actions` array)
- **Type capability differences**: tables → full CRUD; views → typically read-only; stored procedures → custom logic via `execute`
- Naming convention: entity `Product` → REST at `/api/Product`; GraphQL as `product` (singular query) / `products` (plural, paginated)
- **`mappings`** — rename DB columns for the API surface (e.g., `ProductID`→`id`) — once mapped, **clients must use the mapped names**, original column names become internal-only
- **Caching** — configurable globally (`runtime.cache`) or per-entity (`graphql.cache`), with `enabled` + `ttl-seconds`; REST caching keys on full URL+params, GraphQL caching keys on query structure; use longer TTL for stable data (catalogs), shorter/disabled for volatile data (inventory counts)
- **Pagination** — built-in, uses cursor-based paging:
    - REST: `$first` and `$after` query params (`$after` = cursor pointing to last item of previous page, auto-generated from the primary key)
    - GraphQL: `first`/`after` arguments; response includes `hasNextPage` + `endCursor`
- **Filtering** — auto-generated per field type, no config needed:
    - REST: OData-style — `$filter=price gt 100 and stockQuantity gt 0`
    - GraphQL: typed input objects — `filter: { price: { gt: 100 } }`
    - Numeric fields → `gt/gte/lt/lte/eq/neq`; string fields → additionally `contains/startsWith/endsWith`
    - Complex filtering beyond standard operators → wrap logic in a view/stored proc and expose that instead
- **Relationships (GraphQL only)** — map to FK relationships, enable single-query traversal:

```json
"relationships": {
  "category": {"cardinality": "one", "target.entity": "Category", "source.fields": ["CategoryID"], "target.fields": ["CategoryID"]}
}
```

- `cardinality: "one"` = many-to-one (product→category); `cardinality: "many"` = one-to-many (category→products)
- **REST endpoint auto-generation table — memorize the verb mapping:**

|Method|URL|Operation|
|---|---|---|
|GET|`/api/Product`|List (paginated)|
|GET|`/api/Product/id/123`|Get by ID|
|POST|`/api/Product`|Create|
|PUT|`/api/Product/id/123`|Full update/create|
|PATCH|`/api/Product/id/123`|Partial update|
|DELETE|`/api/Product/id/123`|Delete|

- Composite keys chain segments: `/api/OrderDetail/orderId/100/productId/50`
- `rest.path` overrides default URL (e.g., `/products` instead of `/api/Product`)
- `rest.methods` object can **disable individual HTTP verbs** even if permissions would allow them — **defense in depth**: e.g., disable `put` to prevent full-record overwrite while still allowing `patch`
- **GraphQL config**: single endpoint (`/graphql`); `allow-introspection` (dev-friendly, prod-risk — same tradeoff as config file unit); **`depth-limit`** — caps nested query depth to prevent DoS via deeply nested relationship traversal (default example: 8); per-entity `graphql.type.singular/plural` overrides naming; `graphql.operation`: `"query"` (read-only, e.g. views) vs `"mutation"` (write-capable)
- **Exam angle**: REST verb→operation mapping table, cursor-based pagination mechanics (`$after`/`endCursor`), `depth-limit` as the GraphQL DoS guard, and disabling methods as defense-in-depth (even when permissions would allow) are the most testable specifics

## Expose database objects, stored procedures, and views

- **Views**: `type: "view"` requires explicit **`key-fields`** — DAB **cannot auto-detect primary keys on a view**, so you must specify which columns uniquely identify each row. Typically paired with `graphql.operation: "query"` (read-only, no mutations generated)
- **Stored procedures**: `type: "stored-procedure"` + `parameters` mapping (proc param name → API param name)
    - REST: callable via GET query params or POST body
    - GraphQL: exposed as `executeProcName(...)` query/mutation
    - **`operation: "query"`** for read-type procs vs **`operation: "mutation"`** for data-modifying procs — this placement is purely a GraphQL-schema-organization choice, doesn't change proc behavior
    - **Critical security note**: stored procedures execute with the **permissions of the database connection, not the calling user** — authorization/validation logic must live inside the proc itself (or use session context) since DAB's permission model doesn't automatically constrain proc-internal behavior
- **Relationships across multiple entities** — chain them for real-world nested queries (Order→Customer, Order→OrderDetail→Product), letting one GraphQL query replace what would otherwise be multiple REST round-trips
- **Many-to-many via junction table**: model as two "one" relationships through an explicit junction entity (Product→ProductSupplier→Supplier) — accurately represents the DB structure, requires one extra traversal level in the query but preserves referential integrity
- **Exam angle**: `key-fields` requirement for views, "stored procs run as the connection identity not the caller" security implication, and query-vs-mutation operation placement for procs are the top testable points

## Explore deployment options for data API builder

- **Three Azure hosting options — know the distinguishing characteristics of each:**
    - **Azure Container Apps**: serverless container platform, **scales to zero when idle**, auto-scales on request volume — best fit for DAB's typical workload pattern. Deploy via custom Docker image built `FROM mcr.microsoft.com/azure-databases/data-api-builder:latest` + config copied in; secrets via Key Vault reference (`secretref:`) rather than plaintext env vars; **managed identity + Entra auth** eliminates stored credentials entirely
    - **Azure App Service**: mature platform, deployment slots, custom domains, built-in monitoring — familiar pattern for teams already on App Service; runs the same DAB container image; Key Vault reference syntax in app settings: `@Microsoft.KeyVault(SecretUri=...)`
    - **Azure Static Web Apps**: DAB built-in as **"database connections"** feature — simplest option when API complements a static frontend; config file is `staticwebapps.database.config.json` (same structure as standalone DAB); auth auto-integrates with Static Web Apps' built-in auth providers (routes under `/.auth/` and `/data-api/`); **limitation: restricted stored procedure support** compared to standalone DAB
- **CI/CD deployment** (GitHub Actions pattern): trigger on config/Dockerfile changes → build+push container to ACR → deploy to Container Apps via `azure/container-apps-deploy-action`
- **Environment-specific builds**: multiple config files (`dab-config.{env}.json`) + Dockerfile `ARG ENVIRONMENT` + `docker build --build-arg ENVIRONMENT=production` — same merge-config pattern as the earlier config-file unit, now baked into image builds
- **Health probes** — memorize the distinction:
    - **Liveness probe**: checks DAB is responding at all (simple root path check)
    - **Readiness probe**: verifies actual **database connectivity** by making a real API request (e.g., `/api/Product?$first=1`) — deeper check than liveness
- **Exam angle**: matching deployment platform to scenario (scale-to-zero → Container Apps; static frontend companion → Static Web Apps; existing App Service shop → App Service), Static Web Apps' stored-proc limitation, and liveness-vs-readiness distinction are the top testable points

## Recommend Azure monitor configurations

- **Application Insights** integration via `APPLICATIONINSIGHTS_CONNECTION_STRING` env var — auto-detected by DAB, no code changes
- Tracks four telemetry types: **request telemetry** (timing/status/size per REST+GraphQL call), **dependency telemetry** (DB query execution time/success), **exception telemetry** (unhandled errors+stack traces), **custom metrics** (cache hit rates, connection pool usage)
- **Adaptive sampling** — reduces cost at high volume while preserving visibility, auto-adjusts to traffic
- **KQL query patterns to recognize** (won't need to write from scratch, but recognize purpose):
    - Request health summary: `requests | summarize RequestCount, AvgDuration, P95Duration, FailureRate`
    - Top slow endpoints: `requests | summarize AvgDuration by name | top 10 by AvgDuration desc`
    - DB query performance: `dependencies | where type == "SQL" | summarize AvgDuration by data`
- **Log Analytics** — central log repository; Container Apps logs routed via `--logs-workspace-id`; query container logs via `ContainerAppConsoleLogs_CL`; correlate with App Insights telemetry via shared **operation IDs**
- **Alert rules** — two patterns to know:
    - Metric-based: `az monitor metrics alert create` with a condition like `avg requests/failed > 5` over a time window → notifies via **action groups** (email/SMS/webhook)
    - Log-based (KQL): e.g., P95 duration > 2000ms — catches degradation even when requests still technically succeed (not failures, just slow)
    - Best practice: start with high-severity thresholds only, tune from there — avoid **alert fatigue**
- **Distributed tracing**: `traceparent` header propagates trace context from client through DAB to DB, correlated in Application Insights **Transaction Search** — useful for GraphQL queries resolving multiple entities (shows per-relationship DB call timing)
- **Resource-level metrics** (Container Apps/App Service): CPU %, memory %, network in/out, replica count — feed autoscaling rules to balance responsiveness vs cost
- **Exam angle**: request vs dependency vs exception telemetry distinction, metric-alert vs log-based-alert mechanics, and P95-latency-based alerting catching "slow but succeeding" degradation (vs simple failure-rate alerts) are the most testable specifics

## Handle changes with event-driven patterns

- Three change-capture mechanisms — **the comparison table is the highest-yield artifact here, memorize exactly:**

|Feature|CDC|Change Tracking|CES (Change Event Streaming)|
|---|---|---|---|
|Captures changed values|Yes|**No**|Yes|
|Polling required|Yes|Yes|**No**|
|Historical data|Yes|Limited|Stream only|
|Setup complexity|Moderate|Low|Moderate|

- **CDC (Change Data Capture)**: full before/after row values in dedicated change tables — for audit/compliance/data-sync scenarios

```sql
EXEC sys.sp_cdc_enable_db;
EXEC sys.sp_cdc_enable_table @source_schema='dbo', @source_name='Orders', @role_name=NULL, @capture_instance='dbo_Orders', @supports_net_changes=1;
```

- Query via `cdc.fn_cdc_get_all_changes_<capture_instance>(@from_lsn, @to_lsn, 'all')` with LSN range from `sys.fn_cdc_get_min_lsn`/`sys.fn_cdc_get_max_lsn`
- `__$operation` column indicates insert/update/delete
- **Requires SQL Server Agent running** (capture + cleanup jobs run on schedules) — testable dependency
- **Change Tracking**: lightweight — records **which rows changed**, not the actual values; apps query separately to pull current state for sync

```sql
ALTER DATABASE [YourDatabase] SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON);
ALTER TABLE dbo.Orders ENABLE CHANGE_TRACKING;
```

- **Azure Functions SQL trigger binding requires Change Tracking specifically, NOT CDC** — critical distinction. If you need both real-time triggers AND historical CDC data, enable **both** features

```csharp
[FunctionName("OrderChangedTrigger")]
public static void Run(
    [SqlTrigger("[dbo].[Orders]", "SqlConnectionString")] IReadOnlyList<SqlChange<Order>> changes, ILogger log)
```

- `SqlChange<T>` wraps each row with its `Operation` type; function receives **batches** for efficiency
- **CES (Change Event Streaming)**: newest option — pushes changes directly to **Azure Event Hubs**, **no polling**, scales to millions of events/sec — for sub-second latency / high-throughput streaming needs

```sql
CREATE EVENT STREAMING GROUP MyOrderStream WITH (TARGET_TYPE = 'eventhub', TARGET_NAME = 'orders-eventhub', TARGET_CONNECTION = '<conn-string>');
ALTER EVENT STREAMING GROUP MyOrderStream ADD TABLE dbo.Orders;
```

- Event payload includes: operation type, timestamp, full row data (insert/update), key values only (delete)
- **Decision guidance**: CDC → need full history for compliance, batch sync OK; Change Tracking + Functions → real-time response needed, current-value-only, event-driven microservices; CES → sub-second latency, high transaction volume, real-time analytics pipelines. **Can combine** (CDC for audit + Functions triggers for real-time notification simultaneously)
- **Exam angle**: the CDC/Change Tracking/CES comparison table (especially "captures values" and "polling required" columns), the **Azure Functions SQL trigger requires Change Tracking not CDC** gotcha, and matching each mechanism to its ideal use case are the highest-yield testable points in this unit