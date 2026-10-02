# database.tests

Unit and integration tests for the `fin_pulse` SQL project in [../database](../database).

| Layer | Where |
|---|---|
| Build validation | SSDT build of `database.sqlproj` |
| Unit tests | `ConstraintTests.cs`, `SchemaTests.cs`: defaults, CHECK/UNIQUE/NOT NULL/FK, computed column, cascades |
| Integration tests | `IntegrationTests.cs`: scenarios spanning several tables |

## How it works

- `DatabaseFixture` drops and recreates `fin_pulse_test`, then deploys every `<Build Include>` from `database.sqlproj`, in order. Nothing to keep in sync by hand.
- Each test runs in a transaction that is rolled back, so tests are isolated and order-independent.
- Negative tests use `AssertSqlError(number, sql)`, the equivalent of SSDT's `[ExpectedSqlException]`. The test fails if the statement succeeds.
- The test database is dropped at the end. Set `KEEP_TEST_DB=1` to inspect it.

## Run locally (lab dev instance, port 1403)

```powershell
$env:MSSQL_SA_PASSWORD = "<value from infra/.env>"
dotnet test
```

Or point at any other server with `TEST_SQL_CONNECTION`. Never point it at a database you care about: `fin_pulse_test` is dropped on every run.

## Adding tests

When stored procedures, views or functions are added to the project, add a test class per object: seed rows in the test body, call the object, assert on the result, and add negative cases for each validation. Update `TableCountMatchesProject` when tables are added.

CI: [.github/workflows/database-tests.yml](../.github/workflows/database-tests.yml) runs `dotnet test` against a SQL Server container.
