/*  02-deploy-fin-pulse.sql
    Deploys the fin_pulse schema (see ../../database/) via plain sqlcmd :r
    includes, in FK-dependency order -- a stand-in for SqlPackage/dotnet
    build, neither of which is installed on the host. Mirrors
    database.sqlproj's <Build Include> order exactly; keep both in sync
    when a table is added or removed.

    Requires /database mounted read-only (currently only prod1, see
    docker-compose.yml). Run once prod1 reports healthy:

        docker compose exec prod1 /opt/mssql-tools18/bin/sqlcmd `
          -S localhost -U sa -P "$env:MSSQL_SA_PASSWORD" -C -b -i /scripts/02-deploy-fin-pulse.sql

    Idempotent-ish: CREATE DATABASE is skipped if fin_pulse already exists,
    but re-running against an already-deployed database will fail on the
    CREATE TABLE/CREATE SCHEMA statements (this lab doesn't need DROP-and-
    recreate semantics -- use `datagen backfill --reset` to reset rows, or
    drop the database manually to start over).
*/
:on error exit
SET NOCOUNT ON;
GO

IF DB_ID('fin_pulse') IS NULL
    CREATE DATABASE fin_pulse;
GO

USE fin_pulse;
GO

:r /database/Security/finance.sql
:r /database/Security/plan.sql
:r /database/Security/reporting.sql
:r /database/Security/body.sql
:r /database/Security/mind.sql
:r /database/Security/sec.sql
:r /database/Security/roles.sql
:r /database/Security/ae.cmk.sql
:r /database/Security/ae.cek.sql

:r /database/Storage/ps_monthly_date.sql
:r /database/Tables/users.sql
:r /database/Tables/plan.budgets.sql
:r /database/Tables/plan.goals.sql
:r /database/Tables/finance.earnings.sql
:r /database/Tables/finance.expenses.sql
:r /database/Tables/finance.investments.sql
:r /database/Tables/finance.bills.sql
:r /database/Tables/body.weekly_routines.sql
:r /database/Tables/body.workouts.sql
:r /database/Tables/body.personal_records.sql
:r /database/Tables/body.meals.sql
:r /database/Tables/body.water_intake.sql
:r /database/Tables/body.body_metrics.sql
:r /database/Tables/body.sleep_logs.sql
:r /database/Tables/body.habits.sql
:r /database/Tables/body.habit_logs.sql
:r /database/Tables/body.substance_logs.sql
:r /database/Tables/body.symptom_logs.sql
:r /database/Tables/mind.meditation_sessions.sql
:r /database/Tables/mind.journal_entries.sql

:r /database/Functions/sec.fn_user_access_predicate.sql
:r /database/Security/sec.user_isolation_policy.sql

PRINT 'fin_pulse schema deployed.';
GO
