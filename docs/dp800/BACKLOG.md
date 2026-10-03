# Backlog: DP-800 hands-on coverage for the DBA lab

**Status: backlog only. Nothing in this document has been built.** Items marked **[verify]** are assumptions to confirm before (or while) building the story. Each one says what to check.

Goal: every DP-800 module in [`quiz/kb/dp800/content/`](../../quiz/kb/dp800/content/) gets at least one thing you build, break and fix on `fin_pulse`, so studying stops being read-only.

Related: [../azure/SETUP.md](../azure/SETUP.md) (Azure SQL pipeline), [../aws/PLAN.md](../aws/PLAN.md) (RDS plan), [../../infra/README.md](../../infra/README.md) (Docker lab).

---

## How to read this backlog

- **Epic** = one DP-800 module (or a shared foundation). **Story** = one deliverable you can finish in one sitting or a weekend.
- Story IDs are `E<epic>.<n>`, for example `E4.3`. Reference them in commit messages (`feat(E4.3): ai.text_embeddings table`).
- **Size:** S = up to 2 h · M = half a day · L = 1 to 2 days.
- **Where it runs:** 🐳 Docker lab (SQL Server 2025) · ☁️ Azure SQL Database · both.
- Each story has: *Why* (exam angle), *Tasks*, *Done when* (acceptance criteria) and *Suggestions and gotchas*.
- After finishing an epic, run `/dp800-quiz <module>` on the matching module to check that the concept stuck.

## Current coverage (starting point)

| DP-800 module | Already in the lab | Main gap |
|---|---|---|
| Database objects | Tables, CHECK/FK/DEFAULT constraints, partitioning (`ps_monthly_date`), extended properties | Temporal, ledger, graph, columnstore, JSON |
| Programmability | `sec.fn_user_access_predicate` | `Views/` and `StoredProcedures/` are empty; no triggers or TVFs |
| Advanced T-SQL | None | Everything |
| AI-assisted tools | DAB `/mcp` enabled | No Copilot instructions, no `mcp.json` |
| Intelligent search | None | Full-text, vector, hybrid |
| Models and embeddings | [`10-ai-model.sql`](../../infra/scripts/10-ai-model.sql) (all commented out, placeholder `dbo.invoice`) | Nothing runs |
| RAG | None | Everything |
| CI/CD | dacpac build, dev/qa/prod, xUnit tests, OIDC | Drift detection, reference data, code analysis |
| Security | RLS, DDM, Always Encrypted, TDE, roles | Auditing, endpoint permissions, data classification |
| Azure integration | DAB config with claim policies | Only tables exposed, `Unauthenticated` provider, no change events |
| Performance | [`99-stress-test.sql`](../../infra/scripts/99-stress-test.sql), instance config | Query Store, blocking, deadlocks, isolation levels |

## Epics at a glance

| Epic | Module | Stories | Priority | Depends on |
|---|---|---|---|---|
| [E0](#e0--foundations) | Foundations | 6 | P0 | none |
| [E1](#e1--programmability-objects) | Implement programmability objects | 6 | P1 | E0 |
| [E2](#e2--advanced-t-sql) | Write advanced T-SQL code | 6 | P1 | E0.3 |
| [E3](#e3--specialized-tables) | Design and implement database objects | 5 | P2 | E0.2 |
| [E4](#e4--models-and-embeddings) | Models and embeddings | 6 | P1 | E0.3 |
| [E5](#e5--intelligent-search) | Intelligent search | 5 | P1 | E4 |
| [E6](#e6--rag) | RAG with SQL | 6 | P1 | E5 |
| [E7](#e7--security-and-compliance) | Data security and compliance | 7 | P2 | E1 |
| [E8](#e8--dab-and-azure-integration) | Integrate SQL solutions with Azure services | 5 | P2 | E1, E7.4 |
| [E9](#e9--performance) | Optimize database performance | 8 | P2 | E0.3 |
| [E10](#e10--cicd) | CI/CD with SQL database projects | 7 | P3 | E1 |
| [E11](#e11--ai-assisted-development) | AI-assisted tools | 3 | P3 | E8.2 |

**Suggested order (milestones):**

1. **M1: data worth querying.** E0 (all). Without realistic text, E2, E4, E5 and E6 have nothing to work on.
2. **M2: programmability + T-SQL.** E1, E2. Cheap and used by every later epic.
3. **M3: AI track.** E4, then E5, then E6. This is the DP-800-specific content and the biggest gap.
4. **M4: secure and expose.** E7, E8.
5. **M5: operate.** E9, E3, E10, E11.

---

## E0 · Foundations

### E0.1 · Decide where exercise code lives · S · 🐳
**Why:** today `database/` is "what ships", `infra/scripts/` is "instance setup". Exam drills (deadlock repros, regex playgrounds) belong in neither.
**Tasks**
- [ ] Create `exercises/dp800/<NN-module-slug>/` with one numbered `.sql` file per drill and a short `README.md` per module.
- [ ] Rule of thumb, written in `exercises/README.md`: an object the app would really use goes to `database/` (deployed, tested). A drill or demo goes to `exercises/` (run by hand, idempotent, never deployed).
- [ ] Each exercise file starts with a header like the infra scripts: purpose, target instance, how to run with `sqlcmd`.
**Done when:** folder exists with README, and the root README links it.
**Suggestions:** mirror the module names from `quiz/kb/dp800/content/` so the quiz explanations and the exercises line up.

### E0.2 · Confirm the toolchain builds SQL Server 2025 syntax · M · both · spike
**Why:** `database.sqlproj` uses `Microsoft.Build.Sql` 2.3.0 with `SqlAzureV12DatabaseSchemaProvider`. Several later stories add `vector`, `json`, `REGEXP_LIKE` in a CHECK, `LEDGER = ON` and graph tables to the project.
**Tasks**
- [ ] On a throwaway branch, add one table using each feature and run `dotnet build database/database.sqlproj`.
- [ ] Record per feature: builds / builds with warning / fails. **[verify]** whether the SDK version or a `Sql170` DSP is needed.
- [ ] Decide: keep `SqlAzureV12` (Azure is the real target) and put unsupported features in `exercises/`, or bump the SDK.
- [ ] Write the result as a table in `exercises/README.md`.
**Done when:** every later story knows whether its objects go in the dacpac or in a script.

### E0.3 · Realistic text in `datagen` · M · 🐳
**Why:** [`generate.py`](../../infra/data_gen/datagen/generate.py) writes every expense description as `f"Gasto com {category.lower()}"`, which gives only 8 distinct strings (one per `EXPENSE_CATEGORIES`). Embeddings, full-text, fuzzy matching and RAG would all return trivial results.
**Tasks**
- [ ] Add a `MERCHANTS` catalog per category with realistic Brazilian merchants, including the messy variants real bank exports have: `UBER *TRIP 4F2K`, `Uber Eats`, `UBER* EATS SAO PAULO`, `IFOOD *RESTAURANTE X`, `Pao de Acucar 123`, `PAG*JoseDaSilva`.
- [ ] Add a column (or reuse `description`) with a free-text sentence generated from templates: `"Almoço com o time no {merchant}"`, `"Renovação anual {service}"`. Keep the seed deterministic.
- [ ] Inject typos in about 5% of rows (swap, drop, duplicate letters) for the fuzzy-matching stories.
- [ ] Give `plan.goals.description` and `plan.budgets.description` 2 to 3 sentence texts (long enough to chunk).
- [ ] Add a `--whale` option: one user with 50 to 100x the normal row count (needed for E9.2 parameter sniffing).
**Done when:** `SELECT COUNT(DISTINCT description) FROM finance.expenses` returns thousands, not 8, and backfill is still under about 30 s.
**Suggestions:** if you add a `merchant` column, do it through the dacpac (new column, nullable) and backfill in datagen; that also gives E10.4 a real refactor case.

### E0.4 · Fix stale docs · S
**Tasks**
- [ ] Root `README.md`: replace the `lab-ag-&-cicd/`, `lab-octopus/`, `dp800/` layout with the real one (`database/`, `database.tests/`, `infra/`, `api/`, `docs/`, `quiz/`, `exercises/`).
- [ ] `database/README.md`: says `Sql150DatabaseSchemaProvider`; the project uses `SqlAzureV12`. Update after E0.2.
**Done when:** a new reader can follow the root README without hitting a missing folder.

### E0.5 · AI and preview prerequisites as a script · S · 🐳
**Tasks**
- [ ] `infra/scripts/05-fin-pulse-features.sql`: sets compatibility level 170, `PREVIEW_FEATURES = ON`, Query Store on (`OPERATION_MODE = READ_WRITE`, `QUERY_CAPTURE_MODE = AUTO`) for `fin_pulse`. Idempotent.
- [ ] Hook it into the README after `02-deploy-fin-pulse.sql`.
**Done when:** a fresh `docker compose up` plus two scripts gives a database ready for E2 to E6.
**Suggestions:** note in the script header which settings differ on Azure SQL Database (Query Store is on by default there; compat level follows the logical server).

### E0.6 · Study log · S
**Tasks**
- [ ] Add a "Lessons learned" section at the bottom of each `exercises/<module>/README.md`: what surprised you, the gotcha, the exam-relevant rule.
**Why:** the gotchas you hit yourself are the ones you remember in the exam. They also make good material for new quiz questions in `quiz/data`.

---

## E1 · Programmability objects
Notes: [Implement programmability objects with SQL](<../../quiz/kb/dp800/content/Design and develop database solutions/Implement programmability objects with SQL/>)

### E1.1 · Reporting views · M · both
**Why:** the `reporting` schema exists but holds nothing. Views are the first thing DAB, RAG and Power BI style consumers use.
**Tasks**
- [ ] `reporting.v_monthly_cashflow`: per user and month, earnings, expenses, net, savings rate.
- [ ] `reporting.v_budget_status`: each active budget with spent amount, percentage used and days remaining.
- [ ] `reporting.v_expense_category_monthly` `WITH SCHEMABINDING` + unique clustered index (an **indexed view**) using `SUM` and `COUNT_BIG(*)`.
- [ ] Extended properties in the same style as the tables.
**Done when:** views deploy through the dacpac and a test proves an app user sees only their own rows through the view (RLS applies to base tables under a view).
**Suggestions and gotchas**
- Indexed views require `SCHEMABINDING`, two-part names, `COUNT_BIG(*)` with `GROUP BY`, and specific `SET` options. Write down which ones failed for you.
- Check whether an indexed view can sit on a table with an RLS policy using `SCHEMABINDING = ON` **[verify]**. If it can't, that is a good exam-style trade-off to record.

### E1.2 · Functions: inline TVF vs multi-statement TVF vs scalar UDF · M · both
**Tasks**
- [ ] `finance.tvf_spend_by_category(@user_id, @from, @to)`: inline TVF.
- [ ] Same logic as a multi-statement TVF in `exercises/` (not deployed). Compare actual plans and row estimates.
- [ ] Scalar UDF `plan.fn_budget_pct_used(@budget_id)`. Check `sys.sql_modules.is_inlineable` and compare the plan with compat 140 vs 170.
**Done when:** `exercises/01-programmability/README.md` has a short table: function type, estimate quality, plan shape, when to use.
**Suggestions:** the "choose when to use each option" lesson is a frequent exam scenario; the table you write here is your cheat sheet.

### E1.3 · Stored procedures with proper error handling · M · both
**Tasks**
- [ ] `finance.usp_add_expense`: input validation, `SET XACT_ABORT ON`, `BEGIN TRY/CATCH`, `THROW` with custom error numbers (50000+), `XACT_STATE()` check before rollback, `OUTPUT` of the new id.
- [ ] `plan.usp_contribute_to_goal`: in one transaction, insert into `finance.expenses` (category `Investimento/Reserva`) and update `plan.goals.current_amount`. Roll back both on failure.
- [ ] Return codes vs `THROW`: document which one DAB surfaces as an HTTP error **[verify in E8.1]**.
**Done when:** tests cover success, validation failure, and a forced mid-transaction failure that leaves no partial data.
**Suggestions:** procedures are also the security boundary in E7.3 (grant `EXECUTE` only). Write them assuming the caller has no table permissions.

### E1.4 · A trigger that earns its place · S · both
**Why:** the exam asks when a trigger is right and when it isn't. Use one where a procedure can't guarantee the rule.
**Tasks**
- [ ] `finance.trg_bills_paid_next_occurrence` (AFTER UPDATE on `finance.bills`): when `paid_date` goes from NULL to a value on a recurring bill, insert the next occurrence.
- [ ] Set-based: handle multi-row updates through `inserted`/`deleted`. Write a test that pays 3 bills in one `UPDATE`.
- [ ] Guard recursion (`TRIGGER_NESTLEVEL()`).
**Done when:** single-row and multi-row tests pass.
**Gotchas:** the classic bug is `SELECT @id = id FROM inserted`, which silently handles only one row. Write that version first in `exercises/`, watch the test fail, then fix it.

### E1.5 · "When to use what" decision page · S
**Tasks**
- [ ] One table in `exercises/01-programmability/README.md`: view / inline TVF / MSTVF / scalar UDF / procedure / trigger × reusable in queries, can modify data, parameters, transaction control, DAB exposure, typical exam trap.

### E1.6 · Tests for programmability · M
**Tasks**
- [ ] `database.tests/ProgrammabilityTests.cs`: one test class per object type, using the existing `DatabaseTestBase` rollback pattern.
- [ ] Update `SchemaTests` so it also asserts the expected views, functions and procedures exist.
**Done when:** `dotnet test` passes locally and in `database-tests.yml`.

---

## E2 · Advanced T-SQL
Notes: [Write advanced T-SQL code](<../../quiz/kb/dp800/content/Design and develop database solutions/Write advanced T-SQL code/>) · All in `exercises/02-advanced-tsql/` unless stated.

### E2.1 · CTEs and window functions on real questions · M · 🐳
**Tasks**
- [ ] Running monthly spend per user (`SUM() OVER (PARTITION BY ... ORDER BY ... ROWS UNBOUNDED PRECEDING)`).
- [ ] Month-over-month change with `LAG`, top 3 categories per month with `DENSE_RANK`, spending quartiles with `NTILE(4)`.
- [ ] Recursive CTE date spine to fill days with no `water_intake` row (show the zero days).
- [ ] **Gaps and islands:** longest completed streak per habit from `body.habit_logs` (`ROW_NUMBER` difference trick).
**Done when:** each query has a one-line comment describing the business question it answers.
**Suggestions:** compare `ROWS` vs `RANGE` frames on a running total with duplicate dates; the difference is a classic trick question.

### E2.2 · JSON: native type and functions · M · both
**Tasks**
- [ ] Add `body.workouts.sets` as native `json` holding `[{"exercise":"Supino","reps":10,"kg":60}, ...]`. Generate it in datagen. If E0.2 says the dacpac can't build it, use `nvarchar(max)` + `CHECK (ISJSON(sets) = 1)` and note the difference.
- [ ] Queries: `OPENJSON ... WITH (...)` to shred sets, `JSON_VALUE` to filter, `JSON_OBJECT` / `JSON_ARRAYAGG` to build API-shaped output, `FOR JSON PATH` comparison.
- [ ] Total volume per exercise over time from JSON, using a computed column + index on `JSON_VALUE` for one hot path.
**Gotchas:** JSON indexes on the native type may be preview-only **[verify]**. Write down which approach you'd pick in Azure SQL today.

### E2.3 · Regular expressions · S · 🐳
**Tasks**
- [ ] `REGEXP_LIKE` CHECK on `dbo.users.email` (in `database/` if E0.2 allows, otherwise `exercises/`).
- [ ] `REGEXP_REPLACE` to normalize merchants (strip `*`, trailing codes and city names): `UBER *TRIP 4F2K` becomes `UBER TRIP`.
- [ ] `REGEXP_SUBSTR`, `REGEXP_COUNT`, `REGEXP_INSTR` on one example each.
**Gotchas:** regex functions require compat level 170 **[verify]**; a regex in a CHECK constraint runs on every insert, so compare insert cost with and without it on a 100k-row load.

### E2.4 · Fuzzy matching to build a merchant dimension · M · 🐳
**Tasks**
- [ ] New table `finance.merchants (id, canonical_name)` + `finance.merchant_aliases (alias, merchant_id, similarity)`.
- [ ] After `REGEXP_REPLACE` cleanup (E2.3), cluster aliases with `EDIT_DISTANCE`, `EDIT_DISTANCE_SIMILARITY` and `JARO_WINKLER_DISTANCE`. Pick a threshold and record false positives and negatives.
- [ ] Compare with the vector approach later (E5.2) on the same typo set.
**Gotchas:** fuzzy functions need `PREVIEW_FEATURES = ON`, and an all-pairs comparison is O(n²). Block by first letter or category first.

### E2.5 · Graph: what supports which goal · M · 🐳
**Tasks**
- [ ] New `graph` schema: `graph.Habit AS NODE`, `graph.Goal AS NODE`, `graph.Budget AS NODE`, `graph.Supports AS EDGE`, `graph.Limits AS EDGE`. Load from `body.habits`, `plan.goals`, `plan.budgets`.
- [ ] `MATCH` queries: habits that support a goal; budgets that limit a category tied to a goal.
- [ ] `SHORTEST_PATH` with `STRING_AGG(... WITHIN GROUP (GRAPH PATH))`.
- [ ] Edge constraint `CONNECTION (graph.Habit TO graph.Goal)`.
**Done when:** the README explains when graph beats a plain many-to-many junction table, and when it doesn't.
**Gotchas:** existing tables can't be converted to node tables; you create new ones and load them.

### E2.6 · Correlated subqueries vs window functions · S · 🐳
**Tasks**
- [ ] "Expenses above the user's average for that category": write it with a correlated subquery, with `AVG() OVER`, and with `CROSS APPLY`. Compare plans and logical reads (`SET STATISTICS IO ON`).
- [ ] `EXISTS` vs `IN` vs `JOIN` with NULLs: the `NOT IN` with a NULL trap.

---

## E3 · Specialized tables
Notes: [Design and implement database objects with SQL](<../../quiz/kb/dp800/content/Design and develop database solutions/Design and implement database objects with SQL/>) (05-use-specialized-table-types)

### E3.1 · Make `finance.investments` a real ledger table · M · both
**Why:** the table's description says "Ledger of amounts invested", but it's a normal table. Ledger = tamper evidence, a common compliance scenario.
**Tasks**
- [ ] Create `finance.investments` as `WITH (LEDGER = ON (APPEND_ONLY = ON))`. An existing table can't be converted, so: new table, copy rows, swap names (pre-deployment script or manual migration; document which).
- [ ] Generate a digest (`sys.sp_generate_database_ledger_digest`), tamper with a row via a page edit or a restored copy in a lab-only exercise, and run `sys.sp_verify_database_ledger`.
- [ ] Remove `update`/`delete` actions from the `Investment` DAB entity; corrections become compensating inserts (negative amount).
- [ ] Azure: enable automatic digest storage to immutable blob storage; document in `docs/azure/`.
**Gotchas**
- Append-only means no `UPDATE`/`DELETE`, so any test or datagen `--reset` path that deletes investments will break. Plan for truncate-by-drop in the lab.
- `investments` → `users` FK has no cascade, so user deletion is already blocked. Keep it that way.
- Check that the dacpac supports `LEDGER = ON` (E0.2) and that a schema compare doesn't try to rebuild it **[verify]**.

### E3.2 · Temporal tables for budgets and goals · M · both
**Tasks**
- [ ] `SYSTEM_VERSIONING = ON` on `plan.budgets` and `plan.goals` with explicit history tables and `HISTORY_RETENTION_PERIOD`.
- [ ] Queries: `FOR SYSTEM_TIME AS OF`, `BETWEEN`, `ALL`. Goal progress over time from history.
- [ ] Add the history tables to `sec.user_isolation_policy` **[verify: does the current-table predicate cover `FOR SYSTEM_TIME` queries against history?]** and extend `SecurityTests.RowLevelSecurityPolicyCoversEveryUserOwnedTable`.
**Gotchas:** `SchemaTests.TableCountMatchesProject` will change, and DDM/AE rules on history tables follow the current table only in some cases. Test, don't assume.

### E3.3 · Columnstore for reporting · S · both
**Tasks**
- [ ] Nonclustered columnstore index on `finance.expenses (user_id, category, amount, expense_date)`.
- [ ] Run E1.1's reporting queries before and after: batch mode, segment elimination, logical reads.
- [ ] Also show batch mode on rowstore (compat 150+) without the columnstore.
**Done when:** README has the before/after numbers.

### E3.4 · Memory-optimized table (optional) · S · 🐳
**Tasks**
- [ ] `SCHEMA_ONLY` memory-optimized staging table for the `datagen stream` path, or a memory-optimized table type as a TVP for bulk `usp_add_expense`.
**Gotchas:** in-memory OLTP in Azure SQL Database is only on Premium/Business Critical tiers, not General Purpose or serverless **[verify]**. That matters for your Azure free-tier setup, so keep this Docker-only.

### E3.5 · Data types and constraints review · S
**Tasks**
- [ ] Review all tables: `DATETIME` → `DATETIME2(3)`? `VARCHAR` vs `NVARCHAR` for Portuguese text with accents? Record decisions in an ADR-style note.
**Why:** data type choice ("which type for X") is a frequent exam question, and `fin_pulse` stores accented Portuguese text in `VARCHAR` columns.

---

## E4 · Models and embeddings
Notes: [Design and implement models and embeddings with SQL](<../../quiz/kb/dp800/content/Implement AI capabilities in database solutions/Design and implement models and embeddings with SQL/>)

### E4.1 · Choose and wire the model provider · M · both · decision
**Options**

| Option | Cost | Exam fidelity | Notes |
|---|---|---|---|
| Azure OpenAI (`text-embedding-3-small`, `gpt-4o-mini`) | Pay per token (small for this data) | Highest, matches the notes | API key or managed identity credential |
| Ollama in Docker (`nomic-embed-text`, `llama3.2`) | Free | Good for T-SQL, less for Azure security topics | `API_FORMAT = 'Ollama'` **[verify]**; SQL Server may require HTTPS for external models, so you may need a Caddy/nginx TLS sidecar **[verify]** |

**Recommended:** Ollama for the Docker lab (iterate freely), Azure OpenAI for the Azure SQL environment. Same T-SQL, different `CREATE EXTERNAL MODEL`.
**Tasks**
- [ ] If Ollama: add an `ollama` service under a new compose profile `ai`, plus the TLS proxy if required.
- [ ] Rewrite `10-ai-model.sql` with sqlcmd variables (`$(MODEL_ENDPOINT)`, `$(MODEL_NAME)`) instead of commented blocks, and target `fin_pulse` instead of `dbo.invoice`.
- [ ] Smoke test with `sp_invoke_external_rest_endpoint` first, then `AI_GENERATE_EMBEDDINGS`.
**Done when:** `SELECT AI_GENERATE_EMBEDDINGS(N'teste' USE MODEL fin_embed)` returns a vector on 🐳.

### E4.2 · Lock down model access · S · both
**Tasks**
- [ ] Replace `GRANT EXECUTE ANY EXTERNAL ENDPOINT TO [public]` with a role `ai_caller`, and grant `EXECUTE` on the specific external model to it **[verify exact GRANT syntax]**.
- [ ] Azure: database scoped credential with `IDENTITY = 'Managed Identity'` instead of an API key; grant the SQL server's identity the `Cognitive Services OpenAI User` role.
- [ ] Credential naming rule (bracketed base URL, no query string): add it to the script header, since it's the most common setup error.
**Links to:** E7.2.

### E4.3 · Embedding storage design · M · both
**Why:** where and how you store vectors is a design question the exam asks, and `fin_pulse` has three constraints that force a real decision:
1. `body.habit_logs` and potentially other tables are **partitioned**.
2. `mind.journal_entries.content` and `body.symptom_logs.notes` are **Always Encrypted (randomized)**, so the server can never read them to embed or full-text index.
3. Tables with a vector index may become **read-only** while the vector index feature is in preview **[verify current limitation]**, which would block `datagen stream`.

**Tasks**
- [ ] New schema `ai`. Table `ai.text_embeddings (id, source_table, source_id, content_hash, chunk_no, chunk_text, embedding vector(N), model_name, created_at)`. One table for all sources keeps vector indexes off the OLTP tables.
- [ ] Deduplicate by `content_hash`: the same merchant text embedded once, not once per expense.
- [ ] Choose `N`: 1536 vs reduced dimensions (`text-embedding-3-small` supports a `dimensions` parameter); record storage per row (about 4 bytes × N).
- [ ] Document the Always Encrypted trade-off: options are client-side embedding, Always Encrypted with secure enclaves, or accepting that journal entries aren't searchable.
- [ ] `ai.documents (id, title, body)`: a small corpus for chunking and RAG. **Idea:** load the DP-800 lesson markdown from `quiz/kb/dp800/content/`, which turns E6 into a study assistant over your own notes.
**Done when:** design note with the decisions above in `exercises/04-embeddings/README.md`, and the tables deployed.

### E4.4 · Chunk and backfill · M · both
**Tasks**
- [ ] `AI_GENERATE_CHUNKS(SOURCE = body, CHUNK_TYPE = FIXED, CHUNK_SIZE = 500)` over `ai.documents`; try two chunk sizes and overlap, and compare retrieval quality later in E5.5.
- [ ] Backfill procedure `ai.usp_embed_pending @batch_size`: embeds rows with `embedding IS NULL` in batches, catches throttling errors (HTTP 429), records failures.
- [ ] Estimate and log token counts and duration per batch.
**Gotchas:** a single `UPDATE ... SET embedding = AI_GENERATE_EMBEDDINGS(...)` on all rows is one long transaction with thousands of HTTP calls. Batch it.

### E4.5 · Keep embeddings fresh · M · 🐳 (+☁️ for CES)
**Tasks**
- [ ] Implement **Change Tracking** on the source tables + `ai.usp_embed_pending` polling `CHANGETABLE(CHANGES ...)`, scheduled with SQL Server Agent (`MSSQL_AGENT_ENABLED=true` in compose).
- [ ] Write a comparison (no build) of the alternatives: trigger + queue table, CDC, Change Event Streaming to Event Hubs with an external consumer, Azure Functions SQL trigger.
**Done when:** inserting an expense via `datagen stream` gets its embedding within one polling interval.
**Suggestions:** the notes call out that CES "decouples embedding generation from the database transaction". Write down why that matters (latency, failure isolation).

### E4.6 · Model versioning · S
**Tasks**
- [ ] `model_name` per row (already in E4.3). Procedure to re-embed everything for a new model side by side, then switch queries.
- [ ] Document: why vectors from different models must never be compared.

---

## E5 · Intelligent search
Notes: [Design and implement intelligent search with SQL](<../../quiz/kb/dp800/content/Implement AI capabilities in database solutions/Design and implement intelligent search with SQL/>)

### E5.1 · Full-text search · M · 🐳 (+☁️)
**Tasks**
- [ ] Docker: the `mssql/server` image may not include full-text. Build a small `infra/Dockerfile.fts` that installs `mssql-server-fts` **[verify package availability for 2025]**.
- [ ] Full-text catalog + index on `finance.expenses (description)` and `ai.documents (body)` with `LANGUAGE 1046` (Brazilian Portuguese word breaker and stemmer).
- [ ] `CONTAINS` (prefix, `NEAR`, `FORMSOF(INFLECTIONAL, ...)`), `FREETEXT`, `CONTAINSTABLE` with `RANK`.
- [ ] Azure SQL: same index works natively; verify.
**Gotchas:** full-text population is asynchronous. Tests that insert and search right away will be flaky; use `CHANGE_TRACKING AUTO` and wait on `FULLTEXTCATALOGPROPERTY(..., 'PopulateStatus')`.

### E5.2 · Exact vector search (k-NN baseline) · S · both
**Tasks**
- [ ] `ai.usp_search_exact @query, @top`: `ORDER BY VECTOR_DISTANCE('cosine', embedding, @q)`.
- [ ] Run the E2.4 typo set through it and compare with the fuzzy functions.
**Done when:** you can explain which of fuzzy matching vs vector search wins on typos vs synonyms ("mercado" vs "supermercado" vs "Pão de Açúcar").

### E5.3 · Approximate search with a vector index · M · both
**Tasks**
- [ ] `CREATE VECTOR INDEX ... WITH (METRIC = 'cosine', TYPE = 'diskann')` on `ai.text_embeddings`.
- [ ] `VECTOR_SEARCH(... TOP_N = ...)` and measure recall@10 against E5.2's exact results.
- [ ] Record index build time and size, and current limitations (DML on the table, required clustered index type) **[verify]**.
**Gotchas:** filtering by `user_id` after `VECTOR_SEARCH` can return fewer than `TOP_N` rows (post-filtering). Try a larger `TOP_N` and document the trade-off.

### E5.4 · Hybrid search with Reciprocal Rank Fusion · M · both
**Tasks**
- [ ] `ai.usp_hybrid_search @query, @user_id, @top = 10, @k = 60`: full-text `CONTAINSTABLE` ranks + vector ranks, merged with `SUM(1.0 / (@k + rank))`.
- [ ] Return which leg found each result (both / full-text only / vector only).
- [ ] Run as an app user with `SESSION_CONTEXT` set and confirm RLS limits results to that user.
**Done when:** a query like `"uber"` gets exact merchant matches from full-text and "transporte por aplicativo" style rows from vectors in one list.

### E5.5 · Search evaluation set · S
**Tasks**
- [ ] `exercises/05-search/eval.sql`: 20 queries with expected ids; compute recall@10 and MRR for full-text, vector, hybrid, and the two chunk sizes from E4.4.
**Why:** the notes cover MRR and the trade-offs explicitly; measuring it yourself makes the "which approach" questions easy.

---

## E6 · RAG
Notes: [Design and implement RAG with SQL](<../../quiz/kb/dp800/content/Implement AI capabilities in database solutions/Design and implement RAG with SQL/>)

### E6.1 · Retrieval step · S · both
- [ ] `ai.usp_rag_retrieve @question, @top` returns the top chunks as JSON (`id`, `source`, `text`, `score`), reusing E5.4.

### E6.2 · Prompt augmentation · M · both
- [ ] Build the chat-completions payload with `JSON_OBJECT`/`JSON_ARRAY`: system prompt (answer only from context, cite `[id]`, say "não sei" if absent), context block, user question.
- [ ] Token budget: cap context by characters and log when chunks are dropped.
- [ ] Treat retrieved text as data: delimit it and add a prompt-injection test row ("ignore previous instructions...") in `ai.documents`.

### E6.3 · Generation and logging · M · both
- [ ] `ai.usp_ask @question` calls `sp_invoke_external_rest_endpoint` to the chat model, parses `$.result.choices[0].message.content` with `JSON_VALUE`, returns answer + citations.
- [ ] `ai.rag_log (asked_at, user_id, question, retrieved_ids, answer, prompt_tokens, completion_tokens, latency_ms)`.
- [ ] Error paths: endpoint down, 429, empty retrieval.

### E6.4 · Structured + unstructured questions · M · both
- [ ] "Quanto gastei com alimentação em agosto e em quê?": combine `finance.tvf_spend_by_category` (E1.2) results as structured context with semantic retrieval.
- [ ] Document the routing rule: when to answer with SQL alone, retrieval alone, or both.

### E6.5 · Expose RAG through DAB and MCP · S · both
- [ ] Add `ai.usp_ask` as a DAB stored-procedure entity (POST only), so it also appears as an MCP tool (E11.2).
- [ ] Confirm RLS still scopes retrieval when called via DAB with session context (depends on E7.4).

### E6.6 · RAG vs fine-tuning note · S
- [ ] One page: when RAG, when fine-tuning, when plain SQL. Use your own `rag_log` numbers as examples.

---

## E7 · Security and compliance
Notes: [Implement data security and compliance with SQL](<../../quiz/kb/dp800/content/Secure, optimize, and deploy database solutions/Implement data security and compliance with SQL/>)

### E7.1 · Auditing · M · both
- [ ] 🐳: server audit to `/var/opt/mssql/audit` (new volume), database audit specification for `SELECT` on schema `mind`, `SCHEMA_OBJECT_CHANGE_GROUP`, `DATABASE_PERMISSION_CHANGE_GROUP`. Read with `sys.fn_get_audit_file`.
- [ ] ☁️: Azure SQL auditing to Log Analytics; KQL to find who read `mind` tables. Add to `docs/azure/SETUP.md`.
**Gotchas:** server audits are instance-level, so they can't go in the dacpac; add `infra/scripts/31-audit.sql` next to `30-tde.sql`.

### E7.2 · Secure model endpoints · S · both
- [ ] Covered by E4.2. Add: key in Key Vault (Azure), never in scripts or the repo; rotation procedure (`ALTER DATABASE SCOPED CREDENTIAL`).

### E7.3 · Object-level permissions · M · both
- [ ] App role gets `EXECUTE` on the procedures from E1.3 and `SELECT` on `reporting` views only; no direct `INSERT/UPDATE/DELETE` on tables. Show ownership chaining making it work.
- [ ] Column-level `GRANT SELECT (cols)` / `DENY` example on `dbo.users`.
- [ ] Tests in `SecurityTests.cs` for "can execute proc, cannot insert into table".

### E7.4 · DAB auth + RLS end to end · M · both
**Why:** today DAB uses `Unauthenticated` with `set-session-context: false`, and RLS is enforced only when `SESSION_CONTEXT(N'user_id')` is set, so DAB requests rely on DAB policies alone.
- [ ] Local: `authentication.provider = "Simulator"` **[verify name and behavior for DAB 2.x]**; Azure: Entra ID (`AzureAD`/`EntraID`) with an app registration.
- [ ] `set-session-context: true`. **Watch the key name:** DAB sends claims under their claim names, so the DAB policies use `@claims.userId` while the predicate reads `user_id`. Align them (custom claim `user_id`, or change the predicate) and test.
- [ ] Decide whether to keep DAB `database` policies as defense in depth or rely on RLS only; write the reasoning.
- [ ] Production flags: `mode: production`, `allow-introspection: false`, explicit CORS origins.

### E7.5 · Secure GraphQL, REST and MCP endpoints · S
- [ ] Per-entity role/action review, MCP exposure limited to read entities + `ai.usp_ask`, no `*` actions for `anonymous`.
- [ ] Optional: API Management in front for rate limiting (doc only).

### E7.6 · Data classification · S · both
- [ ] `ADD SENSITIVITY CLASSIFICATION` for PII and health columns (`users.email`, `mind.*`, `body.symptom_logs`), with labels and information types, in the dacpac.
- [ ] Query `sys.sensitivity_classifications`; on Azure, see it in the audit logs (`data_sensitivity_information`).

### E7.7 · Always Encrypted with secure enclaves (optional) · L · ☁️
- [ ] Spike only: VBS enclaves in Azure SQL allow equality/range/`LIKE` on encrypted columns. Compare with the current randomized setup and the E4.3 search trade-off. Write it up; no need to migrate.

---

## E8 · DAB and Azure integration
Notes: [Integrate SQL solutions with Azure services](<../../quiz/kb/dp800/content/Secure, optimize, and deploy database solutions/Integrate SQL solutions with Azure services/>)

### E8.1 · Expose views and procedures · S · both
- [ ] Add `reporting.v_monthly_cashflow`, `reporting.v_budget_status` (read-only entities, `key-fields` set) and `finance.usp_add_expense`, `plan.usp_contribute_to_goal`.
- [ ] Use `dab add` / `dab update` CLI rather than hand-editing JSON, to learn the CLI options the exam may ask about.
- [ ] Check how a `THROW` from E1.3 surfaces (HTTP status, message).

### E8.2 · Run DAB in the Docker lab · S · 🐳
- [ ] Compose service `dab` (profile `api`) using the official DAB image, mounting `api/dab-config.json`, pointing at `prod1` or `dev`.
- [ ] Smoke-test REST, GraphQL and MCP endpoints; add commands to `infra/README.md`.

### E8.3 · Deploy DAB to Azure · M · ☁️
- [ ] Azure Container Apps (or Static Web Apps database connections) with managed identity to Azure SQL, no connection-string password.
- [ ] Add to `db-pipeline.yml` or a separate `api-pipeline.yml`; document in `docs/azure/`.

### E8.4 · Azure Monitor configuration · M · ☁️
- [ ] Diagnostic settings for Azure SQL (`QueryStoreRuntimeStatistics`, `Errors`, `Deadlocks`, `Blocks`, `AutomaticTuning`) to Log Analytics.
- [ ] DAB OpenTelemetry (already wired via env vars) to Application Insights.
- [ ] Three alerts: CPU %, deadlocks > 0, failed connections. Save the KQL queries in `docs/azure/monitoring.md`.

### E8.5 · Change tracking technologies · M · both
- [ ] Docker: enable **CDC** on `finance.expenses` (needs SQL Server Agent), read `cdc.fn_cdc_get_all_changes_...`; compare with Change Tracking from E4.5.
- [ ] Azure: spike **Change Event Streaming** to Event Hubs for `finance.expenses`.
- [ ] Comparison table: CT / CDC / CES / Azure Functions SQL trigger: what it captures, latency, where it runs, cost.

---

## E9 · Performance
Notes: [Optimize database performance](<../../quiz/kb/dp800/content/Secure, optimize, and deploy database solutions/Optimize database performance/>)

### E9.1 · Query Store baseline · S · 🐳
- [ ] Run `datagen stream` for 30 min + E1.1 reporting queries; find top queries by CPU and duration in Query Store views and the SSMS reports.
- [ ] Save the DMV/Query Store queries you use in `exercises/09-performance/dmvs.sql` (`sys.dm_exec_query_stats`, `sys.dm_exec_requests`, `sys.dm_os_wait_stats`, `sys.query_store_*`).

### E9.2 · Parameter sniffing lab · M · 🐳
- [ ] Use the `--whale` user from E0.3. Procedure `finance.usp_user_expenses @user_id`.
- [ ] Compile for a small user, run for the whale (and vice versa); watch the regression in Query Store.
- [ ] Fixes, one at a time: force plan, Query Store hint (`OPTION(RECOMPILE)`), `OPTIMIZE FOR`, Parameter Sensitive Plan optimization (compat 160+ vs 150).
**Done when:** README table: fix, effect, downside, when you'd choose it.

### E9.3 · Automatic tuning · S · both
- [ ] `ALTER DATABASE CURRENT SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON)`; reproduce E9.2 and read `sys.dm_db_tuning_recommendations`.
- [ ] Azure: also check `CREATE_INDEX`/`DROP_INDEX` recommendations.

### E9.4 · Blocking · S · 🐳
- [ ] Two-session script: session A holds a transaction on `plan.goals`, session B waits. Find the head blocker via `sys.dm_exec_requests.blocking_session_id` + `sys.dm_tran_locks`.
- [ ] Same with RCSI on: readers no longer block.

### E9.5 · Deadlocks · M · 🐳
- [ ] Reproduce with opposite update order on `plan.goals` and `plan.budgets`.
- [ ] Read the deadlock graph from the `system_health` Extended Events session; save the XML.
- [ ] Fix: consistent access order; add retry on error 1205 in a procedure.

### E9.6 · Isolation levels · M · 🐳
- [ ] Matrix script: READ UNCOMMITTED, READ COMMITTED, RCSI, SNAPSHOT, REPEATABLE READ, SERIALIZABLE × dirty read, non-repeatable read, phantom, lost update, update conflict (3960).
- [ ] Optimized locking: check whether it's available on SQL Server 2025 (requires ADR) vs default-on in Azure SQL **[verify]**, and its effect on lock counts.

### E9.7 · Index tuning · S · 🐳
- [ ] Missing index DMVs for the E9.1 top queries; add one covering index; compare reads and the write overhead on `datagen stream`.
- [ ] Page compression on a large table; compare size and CPU.

### E9.8 · Configuration recommendations note · S
- [ ] One page: compat level, database-scoped `MAXDOP`, Azure SQL tier (serverless vs provisioned vs Hyperscale) for `fin_pulse`, with reasons. Matches the "recommend database configurations" lesson.

---

## E10 · CI/CD
Notes: [Implement CI/CD by using SQL database projects](<../../quiz/kb/dp800/content/Secure, optimize, and deploy database solutions/Implement CI CD by using SQL database projects/>)

### E10.1 · Schema drift detection · M · ☁️
- [ ] Before publish in `db-pipeline.yml`: SqlPackage `/Action:DriftReport` and `/Action:DeployReport`; upload both as artifacts.
- [ ] Fail the job on drift for `prod`; warn for `dev`.
- [ ] Exercise: add an index by hand in dev, watch the pipeline catch it, then resolve by either adding it to the project or letting the deploy remove it.

### E10.2 · Reference data · S · both
- [ ] Lookup tables `finance.expense_categories`, `finance.payment_methods` populated by idempotent `MERGE` in `PostDeployment/` via `:r` includes.
- [ ] Optional FK from `expenses.category` (needs a data-migration plan, which feeds E10.4).

### E10.3 · Static code analysis · S
- [ ] `<RunSqlCodeAnalysis>True</RunSqlCodeAnalysis>` + `SqlCodeAnalysisRules` in `database.sqlproj`; treat selected rules as errors (for example `SR0001` `SELECT *`).
- [ ] Fix or suppress current warnings with a reason.

### E10.4 · Refactor log and pre-deployment · M · both
- [ ] Rename a column through the project's refactor (generates `.refactorlog`) and confirm SqlPackage renames instead of drop and create.
- [ ] A pre-deployment script for a data motion case (E10.2's category FK); note how `BlockOnPossibleDataLoss` behaves.

### E10.5 · Testing strategy · S
- [ ] Extend `database.tests` for every new epic (E1.6, E3, E7.3).
- [ ] One-page testing pyramid for databases: unit (constraints, procedures), integration (RLS, AE, DAB), deployment (DeployReport), with tSQLt as the alternative you're not using and why.

### E10.6 · Deploy report on pull requests · S · ☁️
- [ ] On `pull_request`, generate a DeployReport against `dev` and post a summary comment with `gh`.
**Why:** pull-request review of schema changes is part of the branching lesson, and seeing the report on each PR builds the habit.

### E10.7 · Pipeline security review · S
- [ ] Least privilege for the deploy identity (is `db_owner` needed? which permissions does SqlPackage need?); pinned actions (done); environment protection; secret masking. Update `docs/azure/SETUP.md`.

---

## E11 · AI-assisted development
Notes: [Implement SQL solutions by using AI-assisted tools](<../../quiz/kb/dp800/content/Design and develop database solutions/Implement SQL solutions by using AI-assisted tools/>)

### E11.1 · Copilot instruction files · S
- [ ] `.github/copilot-instructions.md`: project overview, schemas, conventions (extended properties on every table/column, row-size comments, `CK_`/`FK_`/`UQ_` naming, idempotent post-deploy scripts).
- [ ] `.github/instructions/sql.instructions.md` with `applyTo: "database/**/*.sql"` for T-SQL rules.
- [ ] Test: ask Copilot for a new table and check it follows the conventions.

### E11.2 · MCP configuration · S · 🐳
- [ ] `.vscode/mcp.json` pointing at the DAB `/mcp` endpoint from E8.2 (and the MSSQL extension's MCP server, if you use it).
- [ ] Try: "what did user 3 spend on transport last month?" through the MCP tools, and check that RLS/DAB roles limit it.

### E11.3 · Security impact of AI tools · S
- [ ] Content exclusion for `infra/.env`, `infra/always-encrypted/*.pfx`, `infra/backups/` (already gitignored, but the editor can still read them).
- [ ] Short note: what data reaches the model via Copilot or MCP, read-only vs read-write MCP tools, and why the MCP endpoint must never run with `Unauthenticated` outside the lab.

---

## Open questions to settle early

1. **E0.2 result:** which 2025 features build in the dacpac with `Microsoft.Build.Sql` 2.3.0 and `SqlAzureV12`?
2. **E4.1:** Ollama locally, or Azure OpenAI everywhere? (Cost vs exam fidelity.)
3. **E4.3:** vector index preview limitations on DML, and whether they still apply to the build you run.
4. **E5.1:** full-text package availability for the SQL Server 2025 Linux image.
5. **E7.4:** DAB 2.x local auth provider name and how claims map to `SESSION_CONTEXT` keys.
