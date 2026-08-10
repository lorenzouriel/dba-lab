## Introduction
- Module theme = **database DevOps**: SQL Database Projects (declarative schema-as-code) → source control → branching/PR workflow → schema drift detection → CI/CD pipelines → automated testing
- Core shift: from sequential migration scripts (ALTER chains) to a **declarative desired-state model** that tooling diffs against the target
- **Exam angle**: expect "what does tool/action X produce" and "which SqlPackage action for which scenario" questions — this module is very tool/command-specific, less conceptual than the security module

## Create, build, and validate SQL database projects
- **SQL database project** = database schema as files — one `.sql` file per object (table, proc, view, function); declarative (desired end-state), not sequential migration scripts
- Build output = **`.dacpac`** — a compiled model of the entire schema; this is the deployable artifact that flows through the pipeline
- Build gives two things: **validation** (object refs + T-SQL syntax checked against a target SQL version) and a **deployable artifact**
- **Two project formats — know the distinction cold:**
    - **Original**: MSBuild/.NET Framework-based, ships with SSDT in Visual Studio
    - **SDK-style** (`Microsoft.Build.Sql`): **recommended for new projects** — .NET 8+ cross-platform (Windows/Linux/macOS, matters for non-Windows CI runners), NuGet package references for DB references, **default globbing** (drop a `.sql` file in the folder, it's auto-included, no manual entries)
    - **Version note**: SDK-style is GA in VS Code, **preview** in Visual Studio 2022; **Visual Studio 2026 supports only the original format**
    - Converting original→SDK-style: back up project file + archive a `.dacpac` from the current project first, compare before/after `.dacpac` to confirm nothing was lost
- Create via CLI: `dotnet new sqlproj -n MyDatabaseProject`; build via `dotnet build MyDatabaseProject.sqlproj` → produces `.dacpac` in `bin/Debug`
- Build catches: broken object references (view references nonexistent column), and **target-platform T-SQL feature mismatches** (e.g., a SQL Server 2025 vector function used in a project targeting `Sql140`/SQL Server 2017 fails the build)
- Build output = **errors** (block build) vs **warnings** (don't block, e.g. inconsistent casing); optional **SQL code analysis rules** flag best-practice violations (deprecated joins, `SELECT *` in views, unindexed columns in `IN` predicates)
- **Target platform** is set in the `.sqlproj` file — controls which T-SQL features pass validation; must match deployment target
- **SqlPackage** = the deployment tool: `dotnet tool install --global microsoft.sqlpackage`

```bash
sqlpackage /Action:Publish /SourceFile:bin/Debug/MyDatabaseProject.dacpac /TargetConnectionString:"Server=...;Authentication=Active Directory Default"
```

- New DB → creates every object in dependency order (referenced tables before FKs)
- Existing DB → diffs `.dacpac` vs live schema, generates **only the needed ALTER statements**
- **Idempotent**: deploying the same `.dacpac` 5x — the 5th run changes nothing
- Can fan out one `.dacpac` across a fleet of databases (multi-tenant upgrades)
- **Preview before deploying** — two actions to remember:
    - `/Action:Script` → produces the **exact T-SQL** that would run
    - `/Action:DeployReport` → produces an **XML summary** of every CREATE/ALTER/DROP
- **Exam angle**: SDK-style vs original format capabilities (esp. cross-platform + default globbing), what a `.dacpac` actually is (compiled schema model, not data), and Script vs DeployReport actions are the top testable specifics

## Configure source control and manage reference data
- Because each object = one file, Git diffs are **object-level and precise** (a commit touching Customers table + one proc shows exactly those two files)
- Standard folder structure: `Tables/`, `Views/`, `StoredProcedures/`, `Scripts/PostDeployment/`, `Scripts/PreDeployment/` — SDK-style default globbing auto-picks up files placed here
- **`.gitignore`** should exclude: `bin/`, `obj/`, `*.dacpac`, `*.user` — the `.dacpac` is a rebuilt artifact, never tracked in source
- **Predeployment vs post-deployment scripts** — run outside the compiled model, exactly **one of each per project**:
    - **Pre-deployment**: runs **before** the deployment plan — data migration prep, dropping constraints
    - **Post-deployment**: runs **after** the deployment plan — seed/reference data, lookup tables, app defaults
    - Declared in `.sqlproj`:
```xml
<ItemGroup><PreDeploy Include="prep-db.sql" /></ItemGroup>
<ItemGroup><PostDeploy Include="PostDeploy.sql" /></ItemGroup>
```

- **SQLCMD `:r` includes** — split one logical script across multiple files, referenced from a single entry point:
```sql
:r .\Scripts\PostDeployment\seed-statuses.sql
:r .\Scripts\PostDeployment\seed-regions.sql
```

- Each referenced file must be **excluded from the build** (`Build Remove`) and kept visible in the project (`None Include`) — otherwise the build tries to compile it as a schema object and fails:
```xml
<ItemGroup>
    <Build Remove="Scripts\PostDeployment\seed-statuses.sql" />
    <None Include="Scripts\PostDeployment\seed-statuses.sql" />
</ItemGroup>
```

- **Idempotency for reference data — critical exam point**: post-deployment scripts run on **every** deployment, not just the first. Plain `INSERT` → duplicate key violation on the 2nd run. Use **`MERGE`** instead:

```sql
MERGE INTO [dbo].[OrderStatuses] AS target
USING (VALUES (1, N'Pending'), (2, N'Processing')) AS source ([StatusID],[StatusName])
ON target.[StatusID] = source.[StatusID]
WHEN MATCHED THEN UPDATE SET [StatusName] = source.[StatusName]
WHEN NOT MATCHED THEN INSERT ([StatusID],[StatusName]) VALUES (source.[StatusID], source.[StatusName]);
```

- Tip worth remembering: validate combined predeploy/post-deploy scripts by renaming `.dacpac`→`.zip` and extracting — reveals the single combined `.sql` file per script type
- **Exam angle**: exactly-one predeploy + one post-deploy script per project, `Build Remove`/`None Include` requirement for `:r`-included files, and **MERGE-not-INSERT for idempotent reference data** are the most testable specifics

## Manage branching, pull requests, and conflict resolution
- Strategy: **feature branch per change** → PR into `main` → **keep `main` always deployable**

```bash
git checkout -b feature/add-customer-email
git add . && git commit -m "Add Email column to Customers table"
git push origin feature/add-customer-email
```

- Object-per-file structure makes **diffs precise** — a PR reviewing a schema change shows exactly the changed T-SQL, not a buried line in a giant migration script
- PR review questions to check (could appear as scenario distractors): does it break existing queries/procs? naming convention consistent? needs a post-deployment script update? causes data loss/needs migration?
- **CI build as a PR gate**: Azure DevOps → **Build Validation branch policy**; GitHub → workflow triggered on `pull_request` events targeting `main` — a failed `dotnet build` (broken reference/syntax error) blocks merge
- **Merge conflict resolution flow**: `git pull origin main` into feature branch → Git marks conflicting sections → manually reconcile both changes → `git add` + commit resolution
- **Critical gotcha to remember**: a clean **text** merge does NOT guarantee a valid **schema** — e.g., one branch renames a column, another branch adds a proc referencing the old name; Git merges without complaint but the project is broken → **always rebuild (`dotnet build`) after resolving conflicts** to catch this
- Best practice: keep feature branches short-lived to minimize conflict frequency/severity
- **Exam angle**: "why rebuild after a conflict resolves cleanly" (schema-validity ≠ text-merge-cleanliness) is the standout testable concept here

## Detect and resolve schema drift
- **Schema drift** = gap between what the project defines and what actually exists live — caused by manual `ALTER` via SSMS, emergency 2 AM hotfixes never backported, or third-party tools/ORMs modifying objects behind the scenes
- **The danger**: an unreviewed deployment diffs the `.dacpac` against the drifted live DB and **silently drops** anything the project doesn't know about (e.g., a hotfix column) — drift detection must happen **before** that deployment runs
- **Schema comparison tool** — compares any two of {live database, SQL project, `.dacpac`}:
    - Compare **database→project** to _find_ drift
    - Compare **project→database** to _preview_ what a deployment would change (same tool, reversed direction)
    - Tunable options: ignore whitespace, ignore column order, **block on possible data loss** (flags destructive drops)
    - Save settings as **`.scmp`** file, commit to repo → repeatable, consistent comparisons across the team
- **Resolving drift** — decide whether prod or the project has the "right" version:
    - Graphical schema compare lets you **cherry-pick** which differences to import (accept the hotfix, ignore a monitoring agent's temp table)
    - **Automate with `SqlPackage /Action:Extract`** — pulls live schema into files; running `git status` after extraction shows exactly which files changed = automated drift report

```bash
sqlpackage /Action:Extract /SourceConnectionString:"..." /TargetFile:MyDatabaseProject /p:ExtractTarget=SchemaObjectType
git status --porcelain | wc -l   # gives an automated drift COUNT
```

- **Review before applying** (same two actions from the build/deploy unit, now in a drift context):
    - `/Action:Script` → exact T-SQL that would run, store as pipeline artifact for approval
    - `/Action:DeployReport` → XML operations summary — parse it in-pipeline to **alert on high-impact events** (data motion, clustered index rebuilds, column drops)
- **`DacpacVerify`** — separate tool, compares **two `.dacpac` files** (predeploy/post-deploy scripts, SQLCMD vars, DB references, properties, objects) — useful for validating an original→SDK-style conversion or confirming a pipeline produces the expected artifact: `dacpacverify before.dacpac after.dacpac`
- **Exam angle**: database→project vs project→database compare direction, the `Extract` + `git status` automated drift-count pattern, and DeployReport's role in **alerting on destructive operations before production** are the key testable points

## Implement CI/CD pipelines
- **Two-stage pattern**: **Build** (compile project → `.dacpac` artifact) → **Deploy** (publish that _same_ artifact across dev→staging→production) — building once eliminates "works in dev, breaks in prod"
- **GitHub Actions**: workflows in `.github/workflows/*.yml`; **`azure/sql-action`** handles `.dacpac` deployment to Azure SQL — supports `.dacpac`, `.sqlproj`, and raw `.sql` scripts; supports SQL auth, Entra ID, and service principal auth
    - If Azure SQL firewall is enabled, pairing `azure/login` + `azure/sql-action` **automatically adds a temporary firewall rule for the runner's IP** during deployment and **removes it afterward** — a specific testable behavior
- **Azure DevOps**: **`SqlAzureDacpacDeployment`** task for `.dacpac` deployment; for Linux agents or more control, install SqlPackage directly and script the publish call
- **Secrets management — never hardcode connection strings in YAML:**
    - **GitHub**: repository secrets or **environment secrets** (Settings → Secrets and variables → Actions) — environment secrets scope production credentials to only jobs targeting that environment; reference via `${{ secrets.NAME }}`
    - **OIDC (OpenID Connect)** with `azure/login` — **federated credentials, no client secret stored anywhere** — needs `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` — this is the **preferred passwordless pattern**
    - **Azure Key Vault** integration for centralized secret storage — Azure DevOps has a native Key Vault task; GitHub Actions reads via `azure/login` + Azure CLI calls — can integrate with Azure Functions for automated **credential rotation**
- **Deployment gating/controls — memorize these distinctly:**
    - **Environment protection rules** (GitHub/Azure DevOps): required reviewers (manual approval gate), wait timers (cooldown before execution), deployment branch restrictions (e.g., only `main`→production)
    - **Branch policies** (protect `main`): minimum PR reviewers, **Build Validation** (CI build as a merge gate), comment resolution required, automatically-included reviewers
    - **CODEOWNERS** file (GitHub) / automatically-included-reviewers policy (Azure DevOps) — forces specific team review on SQL file changes:

```
# .github/CODEOWNERS
/Database/ @db-team
*.sql @db-team @dba-lead
```

- **Branch control check** (Azure DevOps-specific) — locks down which pipelines can access a service connection's production credentials, scoped to a specific branch (e.g., only pipelines running as `main`) — even a modified feature-branch pipeline targeting prod gets **refused** by the service connection itself
- **Exam angle**: OIDC/federated-credential pattern as the passwordless best practice, the automatic firewall-rule add/remove behavior of `azure/sql-action`, and distinguishing environment protection rules (deploy-time gates) from branch policies (merge-time gates) from branch control checks (service-connection-level, Azure DevOps only) are the top testable items

## Design and implement a testing strategy
- **Three testing layers, increasing cost/coverage** — know the exact scope of each:
    - **Build validation** (`dotnet build`) — fastest; catches syntax errors + broken object references only; proves structural validity, **not correctness**
    - **Unit tests** — verify individual procs/functions return correct results for given inputs; catch **logic errors**
    - **Integration tests** — end-to-end scenarios against a deployed database; prove objects work together; require a running instance, **slowest/most expensive**
- **SSDT SQL unit tests** — three-phase structure, **exact pattern to remember**:
    - **Pre-test**: set up needed data, clear leftovers from prior runs
    - **Test**: execute the operation under test (call the proc/query the view)
    - **Post-test**: clean up so the run doesn't contaminate the next
- **Test conditions** (validate what came back) — memorize the named ones: **Row Count**, **Scalar Value**, **Expected Schema** (most common); also Data Checksum, Empty ResultSet, Not Empty ResultSet, Execution Time

```sql
-- Pre-test: setup
INSERT INTO [Sales].[Customer] (CustomerName) VALUES (N'Test Customer');
SET @CustomerID = SCOPE_IDENTITY();
-- Test: exercise the proc
EXECUTE @RC = [Sales].[uspPlaceNewOrder] @CustomerID, 100, GETDATE(), 'O';
SELECT [YTDOrders] FROM [Sales].[Customer] WHERE [CustomerID] = @CustomerID;
-- paired with a Scalar Value condition expecting YTDOrders = 100
```

- Setup flow in Visual Studio: right-click a proc in SQL Server Object Explorer → **Create Unit Tests** → choose/create C# test project → set test connection → enable **"Automatically deploy the database project before unit tests are run"** (keeps test DB in sync with latest project)
- **Negative tests** — verify a proc **fails correctly** on invalid input (e.g., canceling an already-shipped order should error, not silently succeed). Add the **`ExpectedSqlException`** attribute to the generated C# test method:

```csharp
[TestMethod()]
[ExpectedSqlException(Severity = 16, MatchFirstError = false, State = 1)]
public void Sales_uspCancelOrder_FilledOrder_Test()
```

- Test **passes only if** the proc raises a matching error; if it succeeds silently, the test **fails** — this is the intended behavior
- Integration tests need a **dedicated test database**, redeployed automatically before each run (same "auto-deploy" setting) to stay current with the project
- **Test environment best practices**: isolate from production (never test against prod), reset to known state before each run (post-deployment/cleanup scripts), externalize connection strings via config so local dev and CI point correctly without code changes
- **CI/CD wiring**: Azure DevOps → `VSTest@2` task; GitHub Actions → `dotnet test ./DatabaseTests/DatabaseTests.csproj` — a failing test **blocks the pipeline**, preventing the change from reaching staging/production
- **Exam angle**: the three-tier testing pyramid (build validation → unit → integration) and what each catches, the pre-test/test/post-test structure, `ExpectedSqlException` for negative-path testing, and "auto-deploy project before tests run" as the mechanism keeping test DBs current are the top testable specifics