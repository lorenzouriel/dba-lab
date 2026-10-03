# DP-300 lab backlog

Hands-on work for each part of the DP-300 exam that the lab doesn't cover yet. Every story adds a script, an exercise or an Azure resource to this repo, and each one is tied to the study notes in [quiz/kb/dp300/content/](../../quiz/kb/dp300/content/).

**Status: backlog only. Nothing here has been built yet.** Items marked **[verify]** are assumptions to check against current Microsoft docs before building.

- [How to read this backlog](#how-to-read-this-backlog)
- [Roadmap](#roadmap)
- [E0. Lab foundation](#e0-lab-foundation)
- [E1. Monitoring and baselines](#e1-monitoring-and-baselines)
- [E2. Query performance tuning](#e2-query-performance-tuning)
- [E3. Database and instance configuration](#e3-database-and-instance-configuration)
- [E4. Task automation (local)](#e4-task-automation-local)
- [E5. Task automation (Azure and pipeline)](#e5-task-automation-azure-and-pipeline)
- [E6. Backup and restore](#e6-backup-and-restore)
- [E7. HA/DR on SQL Server](#e7-hadr-on-sql-server)
- [E8. HA/DR on Azure SQL](#e8-hadr-on-azure-sql)
- [E9. Security hardening](#e9-security-hardening)
- [E10. Plan, provision and migrate](#e10-plan-provision-and-migrate)

---

## How to read this backlog

### What's already in the lab

None of the stories below should rebuild these:

| Area | Already built |
|---|---|
| Instances | prod1, prod2 and prod3 (SQL Server 2025) in the AG, plus standalone dev and staging. SQL Agent is enabled everywhere. |
| HA | `ag1` with `CLUSTER_TYPE = NONE`, certificate endpoints, automatic seeding, sync prod2, async read-scale prod3, read-only routing |
| Security | TDE ([30-tde.sql](../../infra/scripts/30-tde.sql)), Always Encrypted, Dynamic Data Masking, RLS (`sec.user_isolation_policy`), a ledger table, contained Entra users in Azure |
| Performance | Monthly partitioning (`ps_monthly_date`), MAXDOP and cost threshold set in [00-bootstrap.sql](../../infra/scripts/00-bootstrap.sql), Query Store (only on databases restored with `01-restore.sql`), [99-stress-test.sql](../../infra/scripts/99-stress-test.sql) |
| Load | `datagen backfill` (about 270k rows) and `datagen-stream` (continuous writes) |
| Azure | Azure SQL Database (serverless) for dev, qa and prod, deployed from GitHub Actions with OIDC |

### Story format

Each story has:

- **Objective**: the DP-300 skill it practices.
- **Tasks**: what to build.
- **Done when**: checks you can run to show it works.
- **Tips**: gotchas and ideas for going further.
- **Tags**: where it runs and how big it is.

| Tag | Meaning |
|---|---|
| `local` | Docker lab only, free |
| `azure-free` | Fits the free offers (Azure SQL Database free offer, Automation free minutes, Log Analytics free tier). Delete it when you're done anyway. |
| `azure-$` | Costs money while it exists. Create, practice, then tear down the same day. |
| `S` / `M` / `L` | About 1–2 h / half a day / a full day or more |
| `stretch` | Goes beyond what DP-300 tests. Do it last. |

### Definition of done (every story)

1. Scripts live in `infra/scripts/` (or `infra/azure/` for Azure) and follow the existing header style: what the script does, how to run it, whether it's idempotent.
2. A "Use case" section in [infra/README.md](../../infra/README.md), or a page under `docs/`, shows the exact commands.
3. Re-running the script doesn't break anything. Destructive drills say so in the header and only touch throwaway databases.
4. The matching `daily-review` file gets a "Lab:" line linking to the script.
5. Add 3–5 questions about what you saw to [quiz/data/dp300.js](../../quiz/data/dp300.js). Write about things you observed (error messages, DMV columns), not just definitions.

### Script number ranges

These continue the ranges already in use (`0x` setup, `2x` AG, `30` TDE, `99` stress):

| Range | Epic |
|---|---|
| `03`–`09` | E0 foundation |
| `22`–`29` | E7 HA/DR |
| `31`–`39` | E9 security |
| `40`–`49` | E1, E2, E3 performance |
| `50`–`59` | E4 automation |
| `60`–`69` | E6 backup and restore |
| `infra/azure/` | E5, E8, E10 Azure (Bicep and CLI) |

---

## Roadmap

| Order | Epic | DP-300 domain | Stories | Where |
|---|---|---|---|---|
| 1 | E0 Lab foundation | — | 4 | local |
| 2 | E1 Monitoring and baselines | Monitor, configure, and optimize | 5 | local + 1 Azure |
| 3 | E2 Query performance tuning | Monitor, configure, and optimize | 6 | local |
| 4 | E4 Task automation (local) | Automation of tasks | 5 | local |
| 5 | E6 Backup and restore | HA/DR | 6 | local |
| 6 | E7 HA/DR on SQL Server | HA/DR | 5 | local |
| 7 | E9 Security hardening | Secure environment | 7 | local + Azure |
| 8 | E3 Database and instance configuration | Monitor, configure, and optimize | 5 | local |
| 9 | E10 Plan, provision and migrate | Plan and implement | 5 | Azure |
| 10 | E5 Task automation (Azure and pipeline) | Automation of tasks | 5 | Azure + GitHub |
| 11 | E8 HA/DR on Azure SQL | HA/DR | 4 | Azure |

All the local epics (E0–E4, E6, E7, plus the local half of E9) come first. They're free, and they cover most of the "how does this behave" questions on the exam. The Azure epics are grouped at the end so you can provision once and run several stories in one session (see [E10-S1](#e10-s1-bicep-modules-for-server-database-and-elastic-pool)).

---

## E0. Lab foundation

Small changes that make the other epics easier to build and repeat.

### E0-S1: Fix the root README
- **Objective:** none (housekeeping).
- **Tasks:** Rewrite [README.md](../../README.md) to describe the current layout (`infra/`, `database/`, `database.tests/`, `api/`, `quiz/`, `docs/`). It still describes `lab-ag-&-cicd/`, `lab-octopus/` and `dp800/` at the root. Link to this backlog.
- **Done when:** every link in the README resolves.
- **Tags:** `local` `S`

### E0-S2: A `dba` utility database
- **Objective:** a common DBA practice. Stories in E1, E4 and E6 store their output here.
- **Tasks:** Add `03-dba-database.sql`. It creates a `dba` database (SIMPLE recovery) on every instance, with schemas `baseline`, `maint` and `log`.
- **Done when:** it runs idempotently on prod1, dev and staging.
- **Tips:** Keep `dba` out of `ag1` on purpose. Each replica should keep its own history, which also shows why instance-level objects don't fail over with an AG (see [E7-S4](#e7-s4-contained-ag-and-instance-level-objects)).
- **Tags:** `local` `S`

### E0-S3: Turn on Query Store for fin_pulse
- **Objective:** *Configure Query Store*.
- **Tasks:** Query Store is only turned on by `01-restore.sql` today. Enable it for `fin_pulse` too, either through database options in `database.sqlproj` (the dacpac then carries the setting to Azure) or in a post-deployment script. Set `QUERY_CAPTURE_MODE = AUTO`, `MAX_STORAGE_SIZE_MB` and `WAIT_STATS_CAPTURE_MODE = ON`.
- **Done when:** `SELECT actual_state_desc FROM sys.database_query_store_options` returns `READ_WRITE` on prod1 and on Azure dev.
- **Tips:** Compare `ALL` and `AUTO` capture modes. The exam likes asking which one to use in production (`AUTO`). Query Store is on by default in Azure SQL, so check what the dacpac changes there.
- **Tags:** `local` `S`

### E0-S4: Cost guardrails for Azure work
- **Objective:** *Plan and implement data platform resources* (cost).
- **Tasks:** Create a budget with an alert on the lab subscription. Put a `lab=dp300` and `expires=<date>` tag on everything the E5, E8 and E10 stories create. Add `infra/azure/teardown.ps1`, which deletes every resource group tagged `lab=dp300`.
- **Done when:** a test resource group is created, tagged, and removed by the teardown script.
- **Tags:** `azure-free` `S`

---

## E1. Monitoring and baselines

Notes: [Describe performance monitoring](../../quiz/kb/dp300/content/Monitor,%20configure,%20and%20optimize%20database%20resources/Describe%20performance%20monitoring/)

### E1-S1: Baseline collection job
- **Objective:** *Establish baseline metrics*, *Interpret performance metrics*.
- **Tasks:** Write `40-baseline.sql`. It creates tables in `dba.baseline` and an Agent job that snapshots these DMVs every 5 minutes:
  - `sys.dm_os_wait_stats`
  - `sys.dm_io_virtual_file_stats`
  - `sys.dm_os_performance_counters` (Batch Requests/sec, Page life expectancy, SQL Compilations/sec)
  - `sys.dm_exec_query_stats` (top 20 by CPU)

  Add a view that turns the cumulative counters into deltas between snapshots.
- **Done when:** after an hour of `datagen-stream` plus one run of `99-stress-test.sql`, the delta view shows the stress window clearly (the `SOS_SCHEDULER_YIELD` and `CXPACKET` jump).
- **Tips:**
  - Wait stats are cumulative since restart, so always store deltas.
  - Filter out benign waits such as `SLEEP_TASK` and `BROKER_*`. Copy a known exclusion list rather than inventing one.
  - Collecting baselines with an Agent job is also an E4 skill.
- **Tags:** `local` `M`

### E1-S2: Extended Events for blocking and deadlocks
- **Objective:** *Explore Extended Events*, *Identify blocking*.
- **Tasks:** Write `41-xevents.sql`, which creates:
  1. A `blocked_process_report` session. Set `sp_configure 'blocked process threshold (s)', 10` first.
  2. A long-query session on `sql_statement_completed` with `duration > 2s`, written to an `event_file` under `/var/opt/mssql/log`.

  Add `41a-make-deadlock.sql`: two scripts that update `finance.expenses` and `finance.bills` in opposite order.
- **Done when:**
  - The deadlock graph shows up in `system_health` (read it with `sys.fn_xe_file_target_read_file`) without any custom session.
  - The blocked process report names both sessions.
- **Tips:**
  - `system_health` already captures deadlocks, so knowing that is a cheap exam point.
  - On Azure SQL Database, XE sessions are database-scoped (`ON DATABASE`) and write to a blob container. Repeat this on Azure dev if you want to see the difference.
- **Tags:** `local` `M`

### E1-S3: Blocking triage with DMVs
- **Objective:** *Identify and resolve blocking*.
- **Tasks:** Write `42-whoisblocking.sql`. It joins `sys.dm_exec_requests`, `sys.dm_exec_sessions`, `sys.dm_os_waiting_tasks` and `sys.dm_tran_locks` into a head-of-blocking-chain report that shows the SQL text. Then cause blocking with an open transaction in SSMS and run it.
- **Done when:** the report names the head blocker and the lock resource. You killed the blocker and watched the chain clear.
- **Tips:** Run the same scenario again after [E3-S4](#e3-s4-optimized-locking-and-adr) to see how optimized locking changes it.
- **Tags:** `local` `S`

### E1-S4: Query Store reports as a monitoring tool
- **Objective:** *Explore Query Performance Insight* (the Azure view of Query Store).
- **Tasks:** Run `datagen-stream` for an hour. Use the Query Store reports in SSMS (Top Resource Consuming Queries, Query Wait Statistics), then write the same results in T-SQL against `sys.query_store_runtime_stats` and `sys.query_store_wait_stats`.
- **Done when:** your T-SQL returns the same top 5 queries as the SSMS report.
- **Tips:** In Azure, open Query Performance Insight on the dev database after a pipeline run. It's the same data in a portal view.
- **Tags:** `local` `S`

### E1-S5: Database watcher on Azure SQL
- **Objective:** *Describe database watcher*.
- **Tasks:** Create a database watcher for the Azure dev database. Use a free Azure Data Explorer cluster as the data store **[verify]**, look at the built-in dashboards, and run one KQL query against the collected data.
- **Done when:** the dashboard shows CPU and the top queries for dev.
- **Tips:** Serverless auto-pause and the watcher affect each other. Check whether the watcher's connections keep the database awake **[verify]**, and delete the watcher afterwards if they do.
- **Tags:** `azure-free` `M` `stretch`

---

## E2. Query performance tuning

Notes:
- [Explore query performance optimization](../../quiz/kb/dp300/content/Monitor,%20configure,%20and%20optimize%20database%20resources/Explore%20query%20performance%20optimization/)
- [Evaluate performance improvements](../../quiz/kb/dp300/content/Monitor,%20configure,%20and%20optimize%20database%20resources/Evaluate%20performance%20improvements/)
- [Configure databases for optimal performance](../../quiz/kb/dp300/content/Monitor,%20configure,%20and%20optimize%20database%20resources/Configure%20databases%20for%20optimal%20performance/)

### E2-S1: Plan regression and forced plan
- **Objective:** *Identify and fix plan regressions with Query Store*.
- **Tasks:** Write `43-query-store-regression.sql`:
  1. Make the data skewed. Give one "whale" user 100x the expenses of everyone else (a `datagen` flag or an `INSERT ... SELECT`).
  2. Create a procedure `finance.usp_expenses_by_user @user_id`.
  3. Run it for a small user, then a whale user, then clear the plan cache and run it in the reverse order.
  4. Find the regressed query in Query Store and force the good plan with `sp_query_store_force_plan`.
- **Done when:** the Regressed Queries report shows two plans for one query, and after forcing, `is_forced_plan = 1` and the duration is back to normal.
- **Tips:**
  - Also try a **Query Store hint** (`sys.sp_query_store_set_hints`, for example `OPTION(RECOMPILE)` or `OPTIMIZE FOR`). It's the way to change a plan without changing app code.
  - Compat 160+ has **parameter-sensitive plan optimization**, which may keep separate plans for small and whale users on its own. Run the drill at compat 150 and at 170 and compare `sys.query_store_query_variant`.
- **Tags:** `local` `M`

### E2-S2: Automatic tuning
- **Objective:** *Describe automatic tuning*.
- **Tasks:** Repeat the E2-S1 regression with `ALTER DATABASE fin_pulse SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON)`. Read `sys.dm_db_tuning_recommendations` before and after.
- **Done when:** the recommendation's `state` shows that the engine forced the plan, not you.
- **Tips:** Index auto-tuning (`CREATE_INDEX` and `DROP_INDEX`) only exists in Azure SQL Database. Turn it on for the Azure dev database and check its recommendations after a few days of pipeline traffic.
- **Tags:** `local` `S`

### E2-S3: Intelligent query processing, compat 140 vs 170
- **Objective:** *Describe intelligent query processing*.
- **Tasks:** Write `44-iqp-compare.sql`. It runs the same workload at compat levels 140, 150, 160 and 170 and saves the actual plans. Look for:
  - Memory grant feedback (`IsMemoryGrantFeedbackAdjusted` in the plan XML)
  - Adaptive joins
  - Table variable deferred compilation (150+)
  - Batch mode on rowstore (150+)
  - DOP feedback and CE feedback (160+, need Query Store)
- **Done when:** you have a small table with one row per feature: the compat level it appears at and the plan property that proves it.
- **Tips:** Run each query 3–5 times before reading the plan, because the feedback features only adjust after repeated runs.
- **Tags:** `local` `M`

### E2-S4: Index analysis and maintenance
- **Objective:** *Detect and correct fragmentation*, *missing indexes*.
- **Tasks:** Write `45-index-health.sql`:
  - A fragmentation report from `sys.dm_db_index_physical_stats` (LIMITED, then SAMPLED).
  - A missing-index report from `sys.dm_db_missing_index_*`.
  - An unused-index report from `sys.dm_db_index_usage_stats`.

  Fragment a table on purpose with random-GUID inserts or deletes, then compare `REORGANIZE`, `REBUILD WITH (ONLINE = ON)` and `REBUILD WITH (RESUMABLE = ON)`. Pause and resume the resumable one.
- **Done when:** fragmentation drops after each operation, and you saw a resumable rebuild in `sys.index_resumable_operations` with state `PAUSED`.
- **Tips:**
  - Missing-index DMVs reset on restart and ignore column order. Treat them as hints, not instructions.
  - Rebuilding a partitioned index can target one partition: `REBUILD PARTITION = n` on the `ps_monthly_date` tables.
- **Tags:** `local` `M`

### E2-S5: Statistics
- **Objective:** *Maintain statistics*, *database-scoped configuration*.
- **Tasks:** Find stale statistics with `sys.dm_db_stats_properties` (`modification_counter`). Show a bad estimate on an ascending date key in a monthly partition. Then fix it with `UPDATE STATISTICS ... WITH FULLSCAN` and compare with `AUTO_UPDATE_STATISTICS_ASYNC`.
- **Done when:** the actual vs estimated rows in the plan move from far apart to close.
- **Tips:** Incremental statistics (`STATISTICS_INCREMENTAL = ON`) fit the partitioned tables, since only changed partitions are rescanned.
- **Tags:** `local` `S`

### E2-S6: Performance-based design
- **Objective:** *Explore performance-based database design* (normalization, data types, index design).
- **Tasks:** Review the `fin_pulse` tables for implicit conversions (look for `CONVERT_IMPLICIT` in the plan cache), oversized `NVARCHAR(MAX)` columns and missing FK indexes. Write the findings to `docs/dp300/design-review.md` and fix one through the normal pipeline (PR → dev → qa).
- **Done when:** one fix is deployed through the pipeline, with a before/after plan.
- **Tips:** Making the fix in SSDT and shipping it through CI/CD also practices the E5 deployment skills.
- **Tags:** `local` `M`

---

## E3. Database and instance configuration

Notes: [Configure SQL Server resources for optimal performance](../../quiz/kb/dp300/content/Monitor,%20configure,%20and%20optimize%20database%20resources/Configure%20SQL%20Server%20resources%20for%20optimal%20performance/)

### E3-S1: Resource Governor
- **Objective:** *Control resources with Resource Governor*.
- **Tasks:** Write `46-resource-governor.sql`. It creates a `reporting_pool` (`MAX_CPU_PERCENT = 20`, `CAP_CPU_PERCENT = 30`), a workload group, and a classifier function in `master` that routes a `reporting_login` to the pool. Run `99-stress-test.sql` as that login while `datagen-stream` runs as `sa`.
- **Done when:** `sys.dm_resource_governor_resource_pools` shows the pool capped, and the `datagen-stream` latency stays steady.
- **Tips:**
  - The classifier function must be schema-bound and fast. A broken classifier can lock everyone out, so learn the DAC (`ADMIN:`) connection as the escape hatch.
  - Resource Governor isn't available to you in Azure SQL Database.
- **Tags:** `local` `M`

### E3-S2: Columnstore and compression
- **Objective:** *Optimize database storage*, *index types*.
- **Tasks:** Write `47-columnstore-compression.sql`:
  - Run `sp_estimate_data_compression_savings` for ROW and PAGE on the 3 largest tables, then apply the better option.
  - Add a nonclustered columnstore index on `finance.expenses` for a monthly-spend report, and compare logical reads and duration with and without it.
- **Done when:** a results table shows size before and after, and reads and duration for the report.
- **Tips:**
  - Use `sys.dm_db_column_store_row_group_physical_stats` to watch delta stores turn into compressed row groups. `datagen-stream` keeps feeding the delta store, which demonstrates the tuple mover.
  - Ship the final version through SSDT so it works in Azure too.
- **Tags:** `local` `M`

### E3-S3: tempdb and memory configuration
- **Objective:** *Configure tempdb*, *max server memory*.
- **Tasks:**
  - Check the tempdb file count against the vCPU count and look for contention (`PAGELATCH_*` on 2:1:x pages) under a temp-table-heavy loop.
  - Turn on memory-optimized tempdb metadata.
  - Compare `MSSQL_MEMORY_LIMIT_MB` with `max server memory` in the container.
- **Done when:** a note explains what changed and why, in [infra/README.md](../../infra/README.md).
- **Tips:** On Linux, tempdb and memory are also set through `mssql-conf`. Know both ways for the exam.
- **Tags:** `local` `S`

### E3-S4: Optimized locking and ADR
- **Objective:** *Database-scoped configuration*, *accelerated database recovery*.
- **Tasks:**
  - Turn on accelerated database recovery (ADR) and optimized locking on a copy of `fin_pulse` (SQL Server 2025 **[verify]**).
  - Repeat the E1-S3 blocking scenario and compare `sys.dm_tran_locks` counts.
  - Time a long transaction's rollback with ADR on vs off.
- **Done when:** a table compares lock counts and rollback time, ADR on vs off.
- **Tips:** ADR and optimized locking are on by default in Azure SQL Database. That's why lock behavior can differ between the local tests and Azure.
- **Tags:** `local` `M`

### E3-S5: Database-scoped configuration tour
- **Objective:** *Describe database-scoped configuration options*.
- **Tasks:** Script `48-dsc.sql`. It sets and resets `MAXDOP`, `LEGACY_CARDINALITY_ESTIMATION`, `PARAMETER_SNIFFING`, `OPTIMIZE_FOR_AD_HOC_WORKLOADS` and `CLEAR PROCEDURE_CACHE` at the database level, then shows how each one differs from the instance-level `sp_configure` setting.
- **Done when:** a table lists each option, its scope, and whether it works in Azure SQL Database.
- **Tips:** In Azure SQL Database, database-scoped configuration is the only MAXDOP knob you have. That's a common exam scenario.
- **Tags:** `local` `S`

---

## E4. Task automation (local)

Notes: [Create and manage SQL Agent jobs](../../quiz/kb/dp300/content/Configure%20and%20manage%20automation%20of%20tasks/Create%20and%20manage%20SQL%20Agent%20jobs/)

### E4-S1: Backup jobs
- **Objective:** *Create and manage SQL Agent jobs*, *schedules*.
- **Tasks:** Write `50-agent-backup-jobs.sql`. It creates jobs for a weekly full, a daily differential, and a log backup every 15 minutes for `fin_pulse`, writing to `/var/opt/mssql/data/backups`. Use a named volume, because bind mounts fail on Docker Desktop for Windows (see the infra README). Log each run to `dba.log`.
- **Done when:** `msdb.dbo.backupset` shows an unbroken full → diff → log chain after a day of running.
- **Tips:**
  - Ola Hallengren's `MaintenanceSolution.sql` is the industry standard, and it runs on Linux. Write one job by hand to learn `sp_add_job`, `sp_add_jobstep` and `sp_add_schedule`, then switch to Ola.
  - On an AG database, use `sys.fn_hadr_backup_is_preferred_replica` so the job only runs on the preferred replica. This ties in with E7.
- **Tags:** `local` `M`

### E4-S2: Maintenance jobs
- **Objective:** *Automate database maintenance*.
- **Tasks:** Add Agent jobs for index maintenance (using the E2-S4 logic, or Ola's `IndexOptimize`), statistics updates, `DBCC CHECKDB` (`PHYSICAL_ONLY` on weeknights, full on weekends), and msdb history cleanup (`sp_delete_backuphistory`, `sp_purge_jobhistory`).
- **Done when:** all jobs succeed for 3 days in a row, and the job history shows each step's duration.
- **Tips:** SSIS-based maintenance plans don't exist on Linux. Know that they're the GUI equivalent on Windows, because the exam still asks about them.
- **Tags:** `local` `M`

### E4-S3: Database Mail and operators
- **Objective:** *Configure notifications for task status*.
- **Tasks:**
  1. Add a `mailpit` service (`axllent/mailpit`) to `docker-compose.yml` as an SMTP catcher with a web UI.
  2. Write `51-dbmail.sql`. It turns on `Database Mail XPs` and creates an account, a profile, and a `DBA` operator.
  3. Set the Agent mail profile (on Linux: `mssql-conf set sqlagent.databasemailprofile`).
  4. Make every job notify on failure.
- **Done when:** a job that fails on purpose sends an email you can see in the Mailpit UI.
- **Tips:** Use `msdb.dbo.sysmail_event_log` and `sysmail_allitems` to debug when no email arrives.
- **Tags:** `local` `M`

### E4-S4: Alerts
- **Objective:** *Create alerts* (your notes' CPU-alert exercise).
- **Tasks:** Write `52-alerts.sql`. It creates:
  - Alerts for severity 17–25
  - Alerts for errors 823, 824 and 825 (I/O and corruption)
  - Alerts for 1480 (AG role change) and 35264/35265 (AG data movement suspended/resumed)
  - A performance-condition alert on CPU, as in your module exercise

  Send all of them to the `DBA` operator.
- **Done when:** a manual failover (E7-S1) sends a 1480 email, and `RAISERROR ... WITH LOG` at severity 17 sends another.
- **Tips:** Errors need `WITH LOG` (or the `is_event_logged` flag) before Agent alerts can see them.
- **Tags:** `local` `S`

### E4-S5: Multi-server administration
- **Objective:** *Manage jobs across servers*.
- **Tasks:** Make prod1 a master server (MSX) and dev and staging target servers (TSX). Push one job to all of them.
- **Done when:** the job runs on dev and staging, and the result is reported back to prod1.
- **Tips:** MSX/TSX needs encrypted connections that trust each other's certificates, the same self-signed-cert problem the README describes for read-only routing. Set `MsxEncryptChannelOptions` if it fails. This is the on-premises answer to Azure elastic jobs ([E5-S2](#e5-s2-elastic-jobs)).
- **Tags:** `local` `M` `stretch`

---

## E5. Task automation (Azure and pipeline)

Notes:
- [Manage Azure PaaS tasks using automation](../../quiz/kb/dp300/content/Configure%20and%20manage%20automation%20of%20tasks/Manage%20Azure%20PaaS%20tasks%20using%20automation/)
- [Automate database deployment](../../quiz/kb/dp300/content/Configure%20and%20manage%20automation%20of%20tasks/Automate%20database%20deployment/)

### E5-S1: Schema diff on pull requests
- **Objective:** *Automate database deployment*.
- **Tasks:** Add a job to [db-pipeline.yml](../../.github/workflows/db-pipeline.yml) that runs `SqlPackage /Action:DeployReport` and `/Action:Script` against dev on PRs, and posts the generated DDL as a PR comment.
- **Done when:** a PR that adds a column gets a comment with the `ALTER TABLE`.
- **Tips:** This closes one of the "Known limitations" in [SETUP.md](../azure/SETUP.md). PR runs need OIDC, so either add a federated credential for `pull_request` or limit the job to PRs from branches in this repo. Never run it for forks, because the repo is public.
- **Tags:** `azure-free` `M`

### E5-S2: Elastic jobs
- **Objective:** *Explore elastic jobs*.
- **Tasks:** Create an elastic job agent and its job database. Create a target group with the dev, qa and prod databases, and a job that runs index maintenance and collects `sys.dm_db_resource_stats` from each one into the job database.
- **Done when:** `jobs.job_executions` shows success on all three targets.
- **Tips:**
  - The agent signs in to the targets with a user-assigned managed identity (the current recommendation) or database-scoped credentials.
  - The job agent and its database cost money **[verify]**. Create them, run the job, and tear them down.
  - Cross-check the job against MSX/TSX (E4-S5).
- **Tags:** `azure-$` `M`

### E5-S3: Azure Automation runbook
- **Objective:** *Build an automation runbook* (your notes' index-rebuild exercise).
- **Tasks:** Create an Automation account with a managed identity and a PowerShell runbook that connects to dev with an Entra token and rebuilds fragmented indexes. Schedule it weekly.
- **Done when:** the runbook job output lists the indexes it rebuilt.
- **Tips:**
  - The free tier includes 500 job minutes a month.
  - A scheduled run wakes the serverless database, so schedule it during hours when you're already using it.
- **Tags:** `azure-free` `S`

### E5-S4: Logic App workflow
- **Objective:** *Automate database workflows with Logic Apps*.
- **Tasks:** Create a Consumption Logic App that runs daily, queries `fin_pulse` for users over budget (`plan.budgets` vs `finance.expenses`), and sends an email.
- **Done when:** the run history shows a successful run with the query output.
- **Tips:** Use the SQL connector with a managed identity, not SQL authentication. The server is Entra-only, so SQL authentication wouldn't work anyway.
- **Tags:** `azure-free` `S`

### E5-S5: Drift detection and smoke test
- **Objective:** *Monitor automated tasks*, *deployment*.
- **Tasks:**
  - Add a scheduled workflow that runs `SqlPackage /Action:DriftReport` against qa and prod and opens an issue when it finds drift.
  - Add a post-deploy smoke test: a `SELECT` against each schema run by a test identity (the pipeline currently trusts a green publish).
- **Done when:** a manual `ALTER` in qa opens an issue on the next scheduled run.
- **Tips:** DriftReport needs the database to be registered as a data-tier application (`/p:RegisterDataTierApplication=true` on publish).
- **Tags:** `azure-free` `M`

---

## E6. Backup and restore

Notes: [Back up and restore databases](../../quiz/kb/dp300/content/Plan%20and%20configure%20a%20high%20availability%20and%20disaster%20recovery%20%28HA%20DR%29%20environment/Back%20up%20and%20restore%20databases/)

### E6-S1: Recovery models in practice
- **Objective:** *Recovery models*, *log management*.
- **Tasks:** On a copy of `fin_pulse` (`fin_pulse_lab`), compare SIMPLE, FULL and BULK_LOGGED under a bulk insert. Watch `sys.databases.log_reuse_wait_desc` and log size with `sys.dm_db_log_space_usage`. Fill the log in FULL mode without log backups until `LOG_BACKUP` blocks reuse.
- **Done when:** a note explains each `log_reuse_wait_desc` value you saw, including `AVAILABILITY_REPLICA` on an AG database.
- **Tags:** `local` `S`

### E6-S2: Point-in-time restore drill
- **Objective:** *Restore to a point in time*, *RPO*.
- **Tasks:** Write `60-pitr-drill.sql`:
  1. Use the E4-S1 backup chain.
  2. Note the time, then run `DELETE FROM finance.expenses WHERE ...` as the "accident".
  3. Restore full → diff → logs `WITH NORECOVERY`, then the last log `WITH STOPAT = '<time>'`, into a new database `fin_pulse_pitr`.
  4. Copy the deleted rows back.
- **Done when:** the deleted rows are back in `fin_pulse` with no other data loss, and you recorded how long the restore took (your RTO).
- **Tips:**
  - Also use `STOPATMARK` with a marked transaction (`BEGIN TRAN ... WITH MARK`). It's a common exam answer for restoring several databases to the same point.
  - Restoring to a new name rather than over the original is the safe, realistic choice.
- **Tags:** `local` `M`

### E6-S3: Tail-log backup
- **Objective:** *Tail-log backups*, *disaster recovery*.
- **Tasks:** On `fin_pulse_lab`, delete the data file while the container is stopped, or set the database `OFFLINE` and remove the `.mdf`. Take `BACKUP LOG ... WITH NO_TRUNCATE`, then restore with zero data loss.
- **Done when:** the last transaction committed before the "failure" is present after the restore.
- **Tags:** `local` `S`

### E6-S4: Backup verification and corruption drill
- **Objective:** *Integrity checks*, *page restore*.
- **Tasks:**
  1. Back up `WITH CHECKSUM`, then run `RESTORE VERIFYONLY` and `RESTORE HEADERONLY`/`FILELISTONLY`.
  2. On a **throwaway** database, corrupt one page with `DBCC WRITEPAGE` (undocumented; never on real data).
  3. Find it with `DBCC CHECKDB` and `msdb.dbo.suspect_pages`, then fix it with a page restore (`RESTORE DATABASE ... PAGE = '1:xxx'`).
- **Done when:** `CHECKDB` is clean after the page restore, and the E4-S4 alert for error 824 fired.
- **Tips:** Stretch goal: corrupt a page in an AG database on prod1 and watch automatic page repair fetch it from prod2 (`sys.dm_hadr_auto_page_repair`). That's a real HA benefit of AGs.
- **Tags:** `local` `M`

### E6-S5: Backup encryption and certificates
- **Objective:** *Encrypt backups*, *TDE and restore across servers*.
- **Tasks:**
  1. Take a backup `WITH ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = ...)`.
  2. Try to restore the TDE-protected `fin_pulse` backup on staging without the certificate and capture the error.
  3. Restore the certificate from [infra/backups](../../infra/backups/) and try again.
- **Done when:** the restore fails without the certificate and succeeds with it, and the error message is in your notes.
- **Tips:** This is the reason [30-tde.sql](../../infra/scripts/30-tde.sql) backs up the certificate. The exam loves "the restore fails on the new server, why?".
- **Tags:** `local` `S`

### E6-S6: Backup to URL with S3-compatible storage
- **Objective:** *Back up to URL* (the local stand-in for backing up to Azure Blob).
- **Tasks:** Add a MinIO service with TLS. Create `CREATE CREDENTIAL [s3://minio:9000/sqlbackups] WITH IDENTITY = 'S3 Access Key', SECRET = '<key>:<secret>'` and run `BACKUP DATABASE ... TO URL = 's3://...'`, then restore from it.
- **Done when:** the backup lands in the MinIO bucket and the restore succeeds.
- **Tips:**
  - S3 backup needs HTTPS that SQL Server trusts. Add the MinIO CA to the container's trusted certificate store **[verify]** the path for SQL Server on Linux. This is the same certificate trust problem as read-only routing, but here it can be solved.
  - In Azure, backups are automatic. For the IaaS (VM) case, the exam answer is backup to URL with a SAS credential.
- **Tags:** `local` `L` `stretch`

---

## E7. HA/DR on SQL Server

Notes:
- [Describe high availability and disaster recovery strategies](../../quiz/kb/dp300/content/Plan%20and%20configure%20a%20high%20availability%20and%20disaster%20recovery%20%28HA%20DR%29%20environment/Describe%20high%20availability%20and%20disaster%20recovery%20strategies/)
- [Explore IaaS and PaaS solutions for HA/DR](../../quiz/kb/dp300/content/Plan%20and%20configure%20a%20high%20availability%20and%20disaster%20recovery%20%28HA%20DR%29%20environment/Explore%20IaaS%20and%20PaaS%20solutions%20for%20high%20availability%20and%20disaster%20recovery/)

### E7-S1: Planned failover runbook
- **Objective:** *Perform a manual failover*.
- **Tasks:** Write `22-ag-failover.sql`, a scripted planned failover from prod1 to prod2 and back, for `CLUSTER_TYPE = NONE`:
  1. Set prod1 to `REQUIRED_SYNCHRONIZED_SECONDARIES_TO_COMMIT = 1`.
  2. Check that prod2 is `SYNCHRONIZED`.
  3. Demote prod1 with `SET (ROLE = SECONDARY)`.
  4. Run `FORCE_FAILOVER_ALLOW_DATA_LOSS` on prod2. With a synchronized secondary it loses no data.
  5. Point `datagen-stream` at the new primary.
- **Done when:** prod2 is primary, prod1 and prod3 resynchronize, no rows are lost (compare row counts), and the 1480 alert from E4-S4 fired.
- **Tips:** With no listener, every client has to be pointed at the new primary by hand. That's the reason the exam always pairs AGs with a listener (or a failover group in Azure).
- **Tags:** `local` `M`

### E7-S2: Forced failover with data loss
- **Objective:** *RPO for async replicas*, *forced failover*.
- **Tasks:** With `datagen-stream` writing to prod1:
  1. Read `last_hardened_lsn` and `log_send_queue_size` for prod3.
  2. `docker compose stop prod1` (or kill it).
  3. Force failover to prod3, the async replica, with `FORCE_FAILOVER_ALLOW_DATA_LOSS`.
  4. Compare the newest row on prod3 with the last row `datagen-stream` logged as committed.
  5. Bring prod1 back, see that it's suspended, and resume it as a secondary. Rows that never reached prod3 are gone.
- **Done when:** a note gives the number of rows lost and how it relates to the send queue just before the failure.
- **Tips:** This shows why async replicas are read-scale or DR and never the automatic HA partner, and what `REQUIRED_SYNCHRONIZED_SECONDARIES_TO_COMMIT` protects you from.
- **Tags:** `local` `M`

### E7-S3: AG health monitoring
- **Objective:** *Monitor HA/DR*, *estimate RPO and RTO*.
- **Tasks:** Write `23-ag-health.sql`. It reports `log_send_queue_size`, `log_send_rate`, `redo_queue_size`, `redo_rate`, `last_commit_time` lag and `secondary_lag_seconds` for each replica, and estimates RPO (send queue ÷ send rate) and RTO (redo queue ÷ redo rate). Store snapshots in `dba.baseline`.
- **Done when:** under `datagen-stream`, prod3's lag shows clearly. Throttle prod3 (lower `mem_limit` or `docker pause` for 30 s) and watch the queue grow and drain.
- **Tags:** `local` `S`

### E7-S4: Contained AG and instance-level objects
- **Objective:** *What does and doesn't fail over with an AG*.
- **Tasks:**
  - After E7-S1, list what didn't move: logins, Agent jobs, Database Mail, linked servers, and the TDE certificate. Fix the logins with matching SIDs, or `sp_help_revlogin`.
  - Then build a second AG as a **contained AG** (SQL Server 2022+), which has its own `master` and `msdb`, and repeat.
- **Done when:** with the contained AG, a login and an Agent job created through the AG are there after failover without any manual copy.
- **Tips:** Check whether contained AGs support `CLUSTER_TYPE = NONE` **[verify]**. If they don't, the finding is still useful: write it down and keep only the first half of this story.
- **Tags:** `local` `L` `stretch`

### E7-S5: Log shipping from dev to staging
- **Objective:** *Log shipping* (compared with AGs).
- **Tasks:** Add a shared named volume, `logship`, mounted on dev and staging. Configure log shipping with the `sp_add_log_shipping_*` procedures (the SSMS wizard doesn't work against Linux), with staging in `STANDBY` mode so it's readable between restores. Add the monitor job.
- **Done when:** a row inserted on dev appears on staging after the next backup/copy/restore cycle, and `msdb.dbo.log_shipping_monitor_secondary` shows the restore delay.
- **Tips:** Note the trade-offs against an AG: log shipping has a schedule-based RPO, manual failover, a readable secondary only in STANDBY (and users get disconnected on each restore), and works across editions and versions.
- **Tags:** `local` `M`

---

## E8. HA/DR on Azure SQL

Notes: [Explore IaaS and PaaS solutions for HA/DR](../../quiz/kb/dp300/content/Plan%20and%20configure%20a%20high%20availability%20and%20disaster%20recovery%20%28HA%20DR%29%20environment/Explore%20IaaS%20and%20PaaS%20solutions%20for%20high%20availability%20and%20disaster%20recovery/)

### E8-S1: Point-in-time restore and backup retention
- **Objective:** *Automated backups in Azure SQL*, *PITR*.
- **Tasks:**
  - Delete rows in dev, then restore dev to a point before the delete as `fin_pulse_pitr` (`az sql db restore --time`).
  - Change PITR retention (1–35 days) and backup storage redundancy (LRS/ZRS/GRS) and note what each costs.
  - Delete a database and restore it from "Deleted databases".
- **Done when:** the restored database has the deleted rows, and the restore time is recorded.
- **Tips:** A PITR restore always creates a **new** database, and you can't overwrite the original. That's a common exam trap.
- **Tags:** `azure-free` `S`

### E8-S2: Long-term retention
- **Objective:** *Long-term retention (LTR)*.
- **Tasks:** Set an LTR policy on qa (for example weekly 4 weeks, monthly 12 months), list LTR backups with `az sql db ltr-backup list`, and restore one.
- **Done when:** an LTR backup is listed (the first one can take up to 7 days to appear **[verify]**) and restored.
- **Tags:** `azure-free` `S`

### E8-S3: Geo-replication and failover group
- **Objective:** *Active geo-replication*, *failover groups*.
- **Tasks:**
  1. Create a secondary server in another region and a failover group for qa.
  2. Connect through the listener (`<fog>.database.windows.net`) and the read-only listener (`<fog>.secondary.database.windows.net`).
  3. Run a planned failover, then a forced failover (`--allow-data-loss`).
  4. Update the pipeline's qa connection string to the listener and check it still deploys after a failover.
- **Done when:** the pipeline deploys to qa through the listener before and after a failover.
- **Tips:**
  - The secondary is a second billed database. Check whether free-offer databases can be geo-replicated **[verify]**, and expect to pay a little for this one.
  - The Entra admin and contained users replicate with the database, but **server-level** firewall rules don't.
  - Compare with the local AG: the listener is what was missing in E7-S1.
- **Tags:** `azure-$` `M`

### E8-S4: Zone redundancy and geo-restore
- **Objective:** *Zone redundancy*, *geo-restore*.
- **Tasks:** Read the zone-redundancy options for General Purpose serverless and turn it on if your region supports it **[verify]** the cost. Run a geo-restore of dev into another region from its geo-redundant backups.
- **Done when:** the geo-restored database comes up in the second region, and you recorded the RPO the docs give for geo-restore.
- **Tags:** `azure-$` `S`

---

## E9. Security hardening

Notes:
- [Configure database authentication and authorization](../../quiz/kb/dp300/content/Implement%20a%20secure%20environment/Configure%20database%20authentication%20and%20authorization/)
- [Protect data in-transit and at rest](../../quiz/kb/dp300/content/Implement%20a%20secure%20environment/Protect%20data%20in-transit%20and%20at%20rest/)
- [Implement compliance controls for sensitive data](../../quiz/kb/dp300/content/Implement%20a%20secure%20environment/Implement%20compliance%20controls%20for%20sensitive%20data/)

### E9-S1: SQL Server Audit
- **Objective:** *Explore server and database audit*.
- **Tasks:** Write `31-audit.sql`:
  - A server audit to `/var/opt/mssql/audit/`.
  - A server audit specification for failed logins and role membership changes.
  - A database audit specification on `fin_pulse` for `SELECT` on `dbo.users` and DML on `finance.*`.

  Read the results with `sys.fn_get_audit_file`.
- **Done when:** a failed login and a `SELECT` on `dbo.users` both appear in the audit file.
- **Tips:** On Azure dev, turn on server-level auditing to Log Analytics and query it with KQL (`SQLSecurityAuditEvents`). Azure auditing has no audit-specification objects, so compare the two models.
- **Tags:** `local` + `azure-free` `M`

### E9-S2: Data classification
- **Objective:** *Explore data classification*.
- **Tasks:** Write `32-classification.sql`. Use `ADD SENSITIVITY CLASSIFICATION` on the masked and encrypted columns (`dbo.users`, `mind.journal_entries`, `body.symptom_logs`, `finance.*`), with labels and information types. Ship the statements in SSDT so Azure gets them too.
- **Done when:** `sys.sensitivity_classifications` lists them, and an audited `SELECT` shows `data_sensitivity_information` in the E9-S1 audit output.
- **Tips:** In Azure, the portal's Data Discovery & Classification shows the same metadata and recommends more columns. Compare its suggestions with yours.
- **Tags:** `local` `S`

### E9-S3: Check the RLS bypass in the deploy pipeline
- **Objective:** *Row-level security*, *least privilege*.
- **Tasks:** The pipeline now publishes with `/p:AllowUnsafeRowLevelSecurityDataMovement=true`. Check what the deploy identity can see:
  1. Run `SELECT COUNT(*)` as the deploy user and compare it with the real count.
  2. Read `sec.fn_user_access_predicate` and find out whether it has a bypass for `db_owner` or for that identity.
  3. Add a test in [database.tests](../../database.tests/) that rebuilds a table protected by RLS and checks that no rows are lost.
- **Done when:** the test passes, and SETUP.md documents how the bypass works.
- **Tips:** If the predicate has no bypass, a table rebuild during deploy silently drops every row the deploy identity can't see. That's real data loss, so this one is worth doing early.
- **Tags:** `local` `S`

### E9-S4: Key and certificate rotation
- **Objective:** *Manage encryption keys*.
- **Tasks:**
  - Rotate the Always Encrypted column master key (create a new CMK, rotate the CEK to it, then drop the old CMK).
  - Rotate the TDE certificate on prod1 (`ALTER DATABASE ENCRYPTION KEY ENCRYPTION BY SERVER CERTIFICATE`).
  - Put `fin_pulse` with TDE into `ag1`, which means restoring the certificate on prod2 and prod3 first.
- **Done when:** the encrypted columns are still readable after rotation, and TDE-protected `fin_pulse` is synchronized on all 3 replicas.
- **Tips:** The AG part is a classic exam scenario: "the database can't be added to the AG, why?". It's because the certificate is missing on the secondary.
- **Tags:** `local` `M`

### E9-S5: Ledger verification
- **Objective:** *Explore Azure SQL Database ledger*.
- **Tasks:**
  - Generate a digest for `finance.investments` with `sys.sp_generate_database_ledger_digest`.
  - Tamper with the data. As `sa`, edit the data file offline, or try an `UPDATE` on an append-only table and capture the error.
  - Run `sys.sp_verify_database_ledger` with the saved digest.
- **Done when:** verification passes on clean data and fails (or is blocked) after tampering, and both outputs are in your notes.
- **Tips:** In Azure, turn on automatic digest storage to immutable blob storage. That's the production pattern, and the local setup can't do it.
- **Tags:** `local` `S`

### E9-S6: Encrypted connections and SQL injection
- **Objective:** *Enable encrypted connections*, *Describe SQL injection*.
- **Tasks:**
  - Force encryption on prod1 (`mssql-conf set network.forceencryption 1`) and check `sys.dm_exec_connections.encrypt_option`.
  - Write a small Python script with `datagen`'s driver that is injectable through string concatenation, exploit it, then fix it with parameters.
- **Done when:** every connection shows `encrypt_option = TRUE`, and the parameterized version resists the same payload.
- **Tips:** Replacing the self-signed certificate with one from a local CA (for example `mkcert`) would also fix the read-only routing TLS problem in the infra README.
- **Tags:** `local` `M`

### E9-S7: Azure network and threat protection
- **Objective:** *Firewall rules*, *Microsoft Defender for SQL*, *customer-managed TDE*.
- **Tasks:**
  1. Replace "Allow Azure services" with a pipeline step that adds and removes the runner's IP (the SETUP.md limitation).
  2. Turn on Defender for SQL on dev (30-day trial) and run a vulnerability assessment.
  3. Switch dev's TDE to a customer-managed key in Key Vault (needs purge protection and the server's managed identity).
  4. Read about private endpoints and why they would block GitHub-hosted runners.
- **Done when:** the pipeline deploys with "Allow Azure services" off, the VA baseline is saved, and TDE shows the Key Vault key.
- **Tips:** Turn Defender off before the trial ends.
- **Tags:** `azure-free` → `azure-$` after the trial `M`

---

## E10. Plan, provision and migrate

Notes:
- [Deploy PaaS solutions with Azure SQL](../../quiz/kb/dp300/content/Plan%20and%20implement%20data%20platform%20resources/Deploy%20PaaS%20solutions%20with%20Azure%20SQL/)
- [Deploy IaaS solutions with Azure SQL](../../quiz/kb/dp300/content/Plan%20and%20implement%20data%20platform%20resources/Deploy%20IaaS%20solutions%20with%20Azure%20SQL/)
- [Migrate SQL Server workloads to Azure SQL Database](../../quiz/kb/dp300/content/Plan%20and%20implement%20data%20platform%20resources/Migrate%20SQL%20Server%20workloads%20to%20Azure%20SQL%20Database/)
- [Migrate SQL Server workloads to Azure SQL Managed Instance](../../quiz/kb/dp300/content/Plan%20and%20implement%20data%20platform%20resources/Migrate%20SQL%20Server%20workloads%20to%20Azure%20SQL%20Managed%20Instance/)

### E10-S1: Bicep modules for server, database and elastic pool
- **Objective:** *Automate deployment with Bicep*, *elastic pools*.
- **Tasks:** Add `infra/azure/bicep/` with modules for the logical server (Entra-only), a database (serverless or provisioned), an elastic pool, and firewall rules. Use one parameter file per environment. Deploy a throwaway `lab` environment with `az deployment group what-if`, then `create`.
- **Done when:** `what-if` against the existing dev environment shows no unexpected changes, and the `lab` environment deploys and tears down cleanly.
- **Tips:** The AWS PLAN.md lists IaC as out of scope, so this also unblocks that plan. Recreating dev from Bicep is a good test of how complete the template is.
- **Tags:** `azure-free` (pool is `azure-$`) `L`

### E10-S2: Pick a tier from measurements
- **Objective:** *Choose a deployment option and service tier*.
- **Tasks:** Take the E1-S1 baseline from prod1 (CPU, IOPS, log rate, memory) and pick a tier for it: DTU vs vCore, General Purpose vs Business Critical vs Hyperscale, serverless vs provisioned, single database vs pool. Write the decision as an ADR.
- **Done when:** the ADR cites the baseline numbers and the tier limits from Microsoft docs.
- **Tips:** Draft it with the `github-cr-adr` skill.
- **Tags:** `local` `S`

### E10-S3: BACPAC migration
- **Objective:** *Migrate to Azure SQL Database* (offline).
- **Tasks:** Run `SqlPackage /Action:Export` of `fin_pulse` from prod1, fix every blocker it reports, and `/Action:Import` into a new Azure database.
- **Done when:** the import succeeds and the row counts match.
- **Tips:**
  - Expect blockers from Always Encrypted metadata, TDE (the BACPAC holds data decrypted, so treat it as sensitive), and instance-level objects.
  - The fixes you make are exactly what the "migration assessment" exam questions ask about.
- **Tags:** `azure-free` `M`

### E10-S4: Migration assessment
- **Objective:** *Assess and plan migrations*.
- **Tasks:** Run the current Microsoft assessment tool against prod1 (Azure Migrate or the SSMS migration component **[verify]** which one is current; Data Migration Assistant and Azure Data Studio are retired). Get SKU recommendations for SQL Database, SQL Managed Instance and SQL Server on a VM.
- **Done when:** the assessment report is saved and compared with your E10-S2 ADR.
- **Tags:** `local` `S`

### E10-S5: Managed Instance and SQL Server on a VM
- **Objective:** *Deploy SQL Managed Instance*, *SQL Server on Azure VMs*.
- **Tasks:** If you're eligible, use the Managed Instance free offer **[verify]** to restore a `fin_pulse` backup from blob storage (or try the Log Replay Service). Create a SQL Server VM from the marketplace image just long enough to look at the SQL IaaS Agent extension, storage configuration (data, log and tempdb on separate disks, caching) and automated backup, then delete it.
- **Done when:** a note compares MI, the VM and SQL Database for this workload, covering features, management and cost.
- **Tips:** Even if you only read the docs, the "which deployment option?" questions are a large part of this domain.
- **Tags:** `azure-$` `L` `stretch`
