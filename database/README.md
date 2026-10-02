# database/

A SQL Server Database Project (SSDT) modeling **fin_pulse**, a personal
finance + health tracker (based on [bthr](https://github.com/lorenzouriel/bthr)),
buildable from Visual Studio or the `msbuild`/`dotnet build` CLI into a
`.dacpac`, then deployed with `SqlPackage`.

## Structure

```
database/
├── database.sln
├── database.sqlproj
├── Storage/           # partition function + scheme
├── Tables/
├── Views/
├── StoredProcedures/
├── Functions/
├── Security/          # CREATE SCHEMA scripts
├── Properties/
└── PostDeployment/
    └── MigrationScripts/
```

The project targets SQL Server 2019 (`Sql150DatabaseSchemaProvider`) — change the
`DSP` property in `database.sqlproj` to target a different version.

## Schema

Every table except `dbo.users` carries a `user_id` FK back to it. Tables are
split across schemas by domain:

| Schema | Table | Purpose |
|--------|-------|---------|
| `dbo` | `users` | Login accounts (username/email + password) — root of the app. |
| `plan` | `budgets` | Spending limits with a date range. |
| `plan` | `goals` | Savings goals with a target/current amount and due date. |
| `finance` | `earnings` | Income records (salary, bonus, freelance, ...). |
| `finance` | `expenses` | Spending records with category and payment method. |
| `finance` | `investments` | Ledger of amounts a user invested per asset/broker (no current value/returns -- computed by the app from a market-data API). |
| `finance` | `bills` | Recurring/one-off payment obligations with due-date tracking. |
| `body` | `weekly_routines` | Template: the usual planned routine per day of week. |
| `body` | `workouts` | A logged training session. |
| `body` | `personal_records` | Append-only PR history per exercise/metric. |
| `body` | `meals` | Per-meal nutrition log (calories, macros). |
| `body` | `water_intake` | Daily running total of water consumed. |
| `body` | `body_metrics` | Weight/height/body-fat measurements over time. |
| `body` | `sleep_logs` | Bed/wake time per night; `total_hours` is a computed column. |
| `body` | `habits` | Definitions of recurring non-workout habits to track (vitamins, stretching, reading, ...). |
| `body` | `habit_logs` | Daily completed/skipped adherence log per habit. |
| `body` | `substance_logs` | Caffeine/alcohol/nicotine intake log, timestamped for correlation with `sleep_logs`. |
| `body` | `symptom_logs` | Symptom/illness log explaining days off the normal routine. |
| `mind` | `meditation_sessions` | Per-session meditation log with before/after mood. |
| `mind` | `journal_entries` | Free-form journal entries with optional mood/category. |

`reporting` is also created (via `Security\reporting.sql`) but currently holds
no objects — reserved for future aggregation views.

`body.habit_logs` is partitioned monthly on `log_date` (`Storage\ps_monthly_date.sql`) as a
pilot. Its PK is `(id, log_date)` because the partition column must be in every aligned unique
key; `id` stays unique in practice through `IDENTITY`. Partition boundaries are static (2024-01 to
2027-12): `SPLIT RANGE` ahead of time to add months.

All FKs are real constraints (not just indexed columns) for referential
integrity, and `user_id` FKs on the `body`/`mind` tables cascade on delete.

## Build

The project is SDK-style (`Microsoft.Build.Sql`) and targets Azure SQL Database
(`SqlAzureV12DatabaseSchemaProvider`). It builds on any OS:

```powershell
dotnet build database.sqlproj -c Release
```

This produces `bin/Release/database.dacpac`. `Build` items are listed explicitly
(`EnableDefaultSqlItems=false`) because `database.tests` reads that order to deploy
the schema; add each new `.sql` file to `database.sqlproj`.

## Deploy

```powershell
SqlPackage /Action:Publish `
  /SourceFile:bin\Release\database.dacpac `
  /TargetConnectionString:"Server=localhost;Database=fin_pulse;User Id=sa;Password=<password>;TrustServerCertificate=True"
```

## CI/CD

[`db-pipeline.yml`](../.github/workflows/db-pipeline.yml) builds the dacpac and runs
[`database.tests`](../database.tests) on every PR and push; its `deploy` job publishes to
Azure SQL Database:

| Trigger | Deploys to | Data-loss guard |
|---|---|---|
| push to `dev` | `dev` | off |
| push to `main` | `qa` | on |
| tag `v*` | `prod` | on (add required reviewers on the `prod` Environment) |

Auth is GitHub OIDC to an Entra app registration (no client secret). Each GitHub
Environment (`dev`, `qa`, `prod`) needs these **secrets** (masked in the public logs):
`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `SQL_SERVER` (e.g.
`sql-labdba-dev.database.windows.net`) and `SQL_DATABASE`. The app registration needs a
federated credential for that Environment and a contained user in the target database
(`CREATE USER [<app name>] FROM EXTERNAL PROVIDER; ALTER ROLE db_owner ADD MEMBER [<app name>];`),
and the server firewall must allow GitHub runners.

See [`lab-ag-&-cicd/`](../labs/lab-ag-&-cicd/) for a full worked example of this
pattern (schema, PostDeployment seed data, Docker-based dev/staging/prod pipeline).
