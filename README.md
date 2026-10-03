# DBA Lab

A hands-on SQL Server and Azure SQL lab built around one schema, **fin_pulse** (a personal finance and health tracker), plus study notes and practice quizzes for the Microsoft **DP-300**, **DP-800** and **DP-900** exams.

The same SSDT project runs everywhere: in a local Docker lab (SQL Server 2025 with an Always On availability group), in a test suite, and in Azure SQL Database through a GitHub Actions pipeline.

## Repository layout

```
lab-dba/
├── database/          # SSDT project for fin_pulse (tables, security, partitioning)
├── database.tests/    # xUnit tests run against a disposable SQL Server
├── infra/             # Docker lab: prod1/prod2/prod3 AG, dev, staging, data generator
├── api/               # Data API builder config (REST, GraphQL, MCP over fin_pulse)
├── quiz/              # Practice quiz web app + study notes (kb/dp300, dp800, dp900)
├── docs/              # Azure CI/CD setup, AWS plan, DP-300 backlog
└── .github/workflows/ # Database CI/CD, tests, quiz deployment
```

### [`database/`](database/)

SSDT project (`database.sqlproj`) that builds `fin_pulse` into a `.dacpac`. It targets Azure SQL (`SqlAzureV12DatabaseSchemaProvider`), so the build rejects syntax Azure SQL doesn't support. Schemas: `body`, `finance`, `mind`, `plan`, `reporting` and `sec`.

Security and storage features used in the schema:

- Row-level security (`sec.user_isolation_policy`)
- Always Encrypted columns
- Dynamic data masking
- A ledger table (`finance.investments`)
- Monthly range partitioning (`ps_monthly_date`)

See its [README](database/README.md).

### [`database.tests/`](database.tests/)

xUnit tests (constraints, schema, security, Always Encrypted, integration). They deploy every file listed in `database.sqlproj` into a throwaway `fin_pulse_test` database, which is dropped at the end of each run. In CI they run against a disposable SQL Server 2022 container. See its [README](database.tests/README.md).

### [`infra/`](infra/)

Docker Compose lab with SQL Server 2025 Developer and no local install needed:

| Instance | Port | Role |
|---|---|---|
| prod1 | 1401 | AG primary |
| prod2 | 1402 | Sync secondary, read-only |
| prod3 | 1405 | Async secondary, read-scale only |
| dev | 1403 | Standalone |
| staging | 1404 | Standalone |

Numbered scripts in [`infra/scripts/`](infra/scripts/) cover:

- Instance bootstrap
- Restoring a `.bak`
- Deploying fin_pulse with sqlcmd
- The availability group (`CLUSTER_TYPE = NONE`, certificate endpoints, automatic seeding)
- TDE
- An Azure OpenAI model
- A CPU stress test

[`data_gen/`](infra/data_gen/) fills the schema with a year of activity, or streams writes continuously. See the [infra README](infra/README.md) for every use case, and [`always-encrypted/`](infra/always-encrypted/) for the column master key setup.

### [`api/`](api/)

[Data API builder](https://learn.microsoft.com/azure/data-api-builder/) configuration ([`dab-config.json`](api/dab-config.json)) that exposes fin_pulse over REST (`/api`), GraphQL (`/graphql`) and MCP (`/mcp`). The connection string comes from the `DATABASE_CONNECTION_STRING` environment variable.

### [`quiz/`](quiz/)

A static practice quiz (plain HTML, CSS and JS, no build step) with question banks for DP-300, DP-800 and DP-900 in [`quiz/data/`](quiz/data/). Every explanation links back to the lesson it came from. Open [`quiz/index.html`](quiz/index.html) locally, or use the deployed version at **https://lorenzouriel.github.io/lab-dba/**.

The study notes live in [`quiz/kb/`](quiz/kb/), one folder per exam, organized by exam domain and Microsoft Learn module:

- [`dp300/content/`](quiz/kb/dp300/content/): all five DP-300 domains, plus a condensed [`daily-review/`](quiz/kb/dp300/content/daily-review/00-index.md)
- [`dp800/content/`](quiz/kb/dp800/content/)
- [`dp900/content/`](quiz/kb/dp900/content/)

### [`docs/`](docs/)

| Document | What it covers |
|---|---|
| [azure/SETUP.md](docs/azure/SETUP.md) | How the database pipeline works and how to set up Azure and GitHub for it (CLI) |
| [azure/SETUP-UI.md](docs/azure/SETUP-UI.md) | The same setup through the Azure portal and GitHub UI |
| [aws/PLAN.md](docs/aws/PLAN.md) | Plan (not built yet) to also deploy fin_pulse to Amazon RDS for SQL Server |
| [dp300/BACKLOG.md](docs/dp300/BACKLOG.md) | Epics and stories for extending this lab to cover every DP-300 objective |

### [`.github/workflows/`](.github/workflows/)

| Workflow | What it does |
|---|---|
| [db-pipeline.yml](.github/workflows/db-pipeline.yml) | Runs tests, builds the dacpac, and publishes to Azure SQL with OIDC: `dev` on push to `dev`, `qa` on push to `main`, `prod` on a `v*` tag (needs approval) |
| [database-tests.yml](.github/workflows/database-tests.yml) | Reusable workflow that runs `database.tests` against a SQL Server container |
| [deploy-quiz.yml](.github/workflows/deploy-quiz.yml) | Publishes `quiz/` to GitHub Pages on push to `main` |

## Quick start

```powershell
# 1. Local lab: start prod1 and configure the instance
cd infra
Copy-Item .env.example .env   # then set MSSQL_SA_PASSWORD
docker compose up -d prod1
docker compose up bootstrap-prod1

# 2. Deploy fin_pulse and fill it with data
docker compose exec prod1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$env:MSSQL_SA_PASSWORD" -C -b -I -i /scripts/02-deploy-fin-pulse.sql
docker compose --profile datagen run --rm datagen backfill --target prod1

# 3. Run the tests. They use the dev instance (port 1403) unless TEST_SQL_CONNECTION is set
docker compose --profile dev up -d dev
cd ../database.tests
dotnet test
```

Load `.env` into your PowerShell session before using `$env:MSSQL_SA_PASSWORD`. The [infra README](infra/README.md#one-time-setup) shows how, along with the one-time folder permissions setup.

## Study tooling

The repo has local Claude Code skills (`/dp300-quiz`, `/dp800-quiz` and `/dp900-quiz`). Each one generates practice questions from the notes in `quiz/kb/` and runs an interactive quiz. They live in `.claude/skills/`, which is gitignored, so they only exist in local clones that have them.
