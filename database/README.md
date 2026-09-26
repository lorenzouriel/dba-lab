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
| `finance` | `investments` | A user's individual investment positions (broker, invested amount, current value, yield). |
| `finance` | `bills` | Recurring/one-off payment obligations with due-date tracking. |
| `investment` | `stocks` | Market OHLCV price history for stocks (reference data, not user-scoped). |
| `investment` | `cryptos` | Market OHLCV price history for cryptocurrencies (reference data). |
| `investment` | `currencies` | Historical FX rates between a currency and a base currency (reference data). |
| `body` | `weekly_routines` | Template: the usual planned routine per day of week. |
| `body` | `workouts` | A logged training session. |
| `body` | `personal_records` | Append-only PR history per exercise/metric. |
| `body` | `meals` | Per-meal nutrition log (calories, macros). |
| `body` | `water_intake` | Daily running total of water consumed. |
| `body` | `body_metrics` | Weight/height/body-fat measurements over time. |
| `body` | `sleep_logs` | Bed/wake time per night; `total_hours` is a computed column. |
| `mind` | `meditation_sessions` | Per-session meditation log with before/after mood. |
| `mind` | `journal_entries` | Free-form journal entries with optional mood/category. |

`reporting` is also created (via `Security\reporting.sql`) but currently holds
no objects — reserved for future aggregation views.

All FKs are real constraints (not just indexed columns) for referential
integrity, and `user_id` FKs on the `body`/`mind` tables cascade on delete.

## Build

```powershell
msbuild database.sqlproj /p:Configuration=Release
```

This produces `bin/Release/database.dacpac`.

## Deploy

```powershell
SqlPackage /Action:Publish `
  /SourceFile:bin\Release\database.dacpac `
  /TargetConnectionString:"Server=localhost;Database=fin_pulse;User Id=sa;Password=<password>;TrustServerCertificate=True"
```

See [`lab-ag-&-cicd/`](../labs/lab-ag-&-cicd/) for a full worked example of this
pattern (schema, PostDeployment seed data, Docker-based dev/staging/prod pipeline).
