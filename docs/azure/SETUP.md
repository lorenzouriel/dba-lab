# CI/CD setup: Azure SQL Database (dev, qa, prod)

How the database pipeline works, and everything that has to exist in Azure and GitHub before it can deploy.

This page uses the Azure CLI and `gh`. For the same steps as portal and GitHub UI clicks, see [SETUP-UI.md](SETUP-UI.md).

- [1. How the pipeline works](#1-how-the-pipeline-works)
- [2. What you need to create](#2-what-you-need-to-create)
- [3. Azure setup](#3-azure-setup)
- [4. GitHub setup](#4-github-setup)
- [5. First run and verification](#5-first-run-and-verification)
- [6. Day-to-day usage](#6-day-to-day-usage)
- [7. Troubleshooting](#7-troubleshooting)
- [8. Known limitations](#8-known-limitations)

---

## 1. How the pipeline works

Three workflows in [.github/workflows/](.github/workflows/):

| File | Role |
|---|---|
| [db-pipeline.yml](.github/workflows/db-pipeline.yml) | Entry point. Decides what runs for each trigger. |
| [database-tests.yml](.github/workflows/database-tests.yml) | Reusable. Runs [database.tests](database.tests) against a throwaway SQL Server 2022 container. |
| [db-deploy.yml](.github/workflows/db-deploy.yml) | Reusable. Logs in to Azure with OIDC and publishes the dacpac to one environment. |

```
 PR to dev/main ──► tests ─┐
                           ├─► (stop: nothing is deployed from a PR)
                    build ─┘

 push to dev   ──► tests ─┐
                          ├─► deploy-dev   (Environment: dev)
                   build ─┘

 push to main  ──► tests ─┐
                          ├─► deploy-qa    (Environment: qa)
                   build ─┘

 tag v*        ──► tests ─┐
                          ├─► deploy-prod  (Environment: prod, needs approval)
                   build ─┘
```

Details that matter:

- **Tests gate every deploy.** `deploy-*` jobs `need` both `tests` and `build`. A red test blocks dev as well as prod.
- **Tests do not touch Azure.** `DatabaseFixture` drops and recreates `fin_pulse_test` on whatever server `TEST_SQL_CONNECTION` points to. In CI that is a disposable container with a throwaway password, never a real database. It is SQL Server 2022, not Azure SQL, so Azure-specific behavior is not covered by the tests.
- **Build.** `dotnet build database/database.sqlproj -c Release` produces `database.dacpac`. The project targets Azure SQL (`SqlAzureV12DatabaseSchemaProvider`), so the build rejects syntax Azure SQL does not support.
- **Deploy.** `azure/sql-action` runs `SqlPackage /Action:Publish`, which diffs the dacpac against the live database and applies only the difference. Arguments:

  | Environment | `BlockOnPossibleDataLoss` | `DropObjectsNotInSource` |
  |---|---|---|
  | dev | `false` | `false` |
  | qa | `true` | `false` |
  | prod | `true` | `false` |

  With `DropObjectsNotInSource=false`, an object removed from source is left in the database instead of dropped. Turn it on later once you trust the pipeline.
- **Authentication.** There is no client secret or password. GitHub issues a short-lived OIDC token per job, Entra exchanges it for an access token (because of a federated credential you create), and that token logs in to SQL (because of a database user you create).
- **Path filters.** PRs and branch pushes only run when `database/**`, `database.tests/**` or the `db-*.yml` workflows change. Tag pushes ignore path filters, so a `v*` tag always runs.
- **Concurrency.** Deploys to the same environment queue instead of overlapping, and are never cancelled mid-publish.

---

## 2. What you need to create

### Azure (per environment: dev, qa, prod)

| # | Resource | Notes |
|---|---|---|
| 1 | Resource group | One per environment, e.g. `rg-labdba-dev`. |
| 2 | Azure SQL logical server | Entra-only authentication, with you as Entra admin. |
| 3 | Azure SQL database `fin_pulse` | Serverless General Purpose is cheapest. |
| 4 | Firewall rule | So GitHub runners can reach the server. |
| 5 | Entra app registration + service principal | One per environment (recommended). |
| 6 | Federated credential on the app | Trusts one GitHub Environment. |
| 7 | Reader role for the service principal | On the resource group, so `azure/login` has a subscription. |
| 8 | Contained database user for the app | `db_owner` inside `fin_pulse` only. |

### GitHub

| # | Item |
|---|---|
| 1 | Three Environments: `dev`, `qa`, `prod` |
| 2 | Five secrets on each Environment (see [4.2](#42-environment-secrets)) |
| 3 | Required reviewers on `prod` |
| 4 | Branch protection on `main` and `dev` requiring the test and build checks |

The IDs below are identifiers, not credentials. This repo is public and GitHub prints variables in clear text in public Actions logs, so all five are stored as Environment **secrets** (masked as `***`).

---

## 3. Azure setup

Run these with the Azure CLI (`az login` first). Everything below is shown for `dev`; repeat it for `qa` and `prod` by changing `ENV`.

### 3.1 Variables

```bash
ENV=dev                                  # dev | qa | prod
LOCATION=brazilsouth                     # pick your region
SUFFIX=$RANDOM                           # SQL server names are globally unique
RG=rg-labdba-$ENV
SERVER=sql-labdba-$ENV-$SUFFIX           # becomes $SERVER.database.windows.net
DB=fin_pulse
APP=gh-labdba-$ENV                       # app registration display name
REPO=lorenzouriel/lab-dba

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
ADMIN_UPN=$(az account show --query user.name -o tsv)
ADMIN_OID=$(az ad signed-in-user show --query id -o tsv)
```

Keep `$SERVER`, `$APP` and the IDs: you need them again in section 4.

### 3.2 Resource group

```bash
az group create -n $RG -l $LOCATION
```

### 3.3 SQL server (Entra-only auth)

```bash
az sql server create -g $RG -n $SERVER -l $LOCATION \
  --enable-ad-only-auth \
  --external-admin-principal-type User \
  --external-admin-name $ADMIN_UPN \
  --external-admin-sid $ADMIN_OID
```

Entra-only means there is no `sa`-style SQL login and no password to leak. You (the Entra admin) are the only one who can create database users in 3.8.

### 3.4 Database

```bash
az sql db create -g $RG -s $SERVER -n $DB \
  --edition GeneralPurpose --compute-model Serverless \
  --family Gen5 --capacity 1 --min-capacity 0.5 \
  --auto-pause-delay 60 \
  --backup-storage-redundancy Local
```

- Serverless with `--auto-pause-delay 60` pauses after an hour idle, so dev and qa cost almost nothing while idle. The first connection after a pause takes about a minute to resume; the deploy step waits for it, but a short timeout on your side would not.
- For prod, consider `--backup-storage-redundancy Zone` or `Geo`, and a longer point-in-time-restore window (`az sql db str-policy set --retention-days 14`).
- On a new subscription you can add `--use-free-limit --free-limit-exhaustion-behavior AutoPause` to use the free offer on one database.

### 3.5 Firewall

GitHub-hosted runners have changing IPs, so the simplest option is the "Allow Azure services" rule:

```bash
az sql server firewall-rule create -g $RG -s $SERVER \
  -n AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
```

This lets any Azure-hosted service reach the server, which is acceptable for a lab but too open for a real prod. Safer alternatives, both requiring a workflow change (see [section 8](#8-known-limitations)):

- Add the runner's public IP with `az sql server firewall-rule create` before the publish, and delete it afterwards.
- Use a self-hosted runner inside a VNet with a private endpoint.

### 3.6 App registration and federated credential

The federated credential tells Entra: "trust tokens GitHub issues for this repo and this Environment." The `subject` must match exactly, including case.

```bash
APP_ID=$(az ad app create --display-name $APP --query appId -o tsv)
az ad sp create --id $APP_ID

az ad app federated-credential create --id $APP_ID --parameters '{
  "name": "github-'$ENV'",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:'$REPO':environment:'$ENV'",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

One app per environment means a leaked or misconfigured `dev` credential can never deploy to `prod`. Because the subject names the Environment, the `prod` credential only works for jobs that run in the `prod` Environment, which is where your approval gate lives.

### 3.7 Reader role

`azure/login` needs the service principal to see at least one subscription. Without a role it fails with "No subscriptions found". Reader on the resource group is enough, since all data access goes through the database user, not Azure RBAC:

```bash
az role assignment create \
  --assignee $APP_ID --role Reader \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG
```

### 3.8 Database user

This is the step people forget, and it is what produces `Login failed for user '<token-identified principal>'`.

Connect to the **`fin_pulse` database** (not `master`) as the Entra admin you set in 3.3, then run:

```sql
CREATE USER [gh-labdba-dev] FROM EXTERNAL PROVIDER;   -- the $APP display name
ALTER ROLE db_owner ADD MEMBER [gh-labdba-dev];
```

Ways to connect:

```bash
# go-sqlcmd (https://learn.microsoft.com/sql/tools/sqlcmd/go-sqlcmd-utility)
sqlcmd -S $SERVER.database.windows.net -d $DB --authentication-method ActiveDirectoryDefault
```

or the Azure Portal query editor, signed in as the admin. Your own IP must be allowed on the firewall to connect from your machine (`az sql server firewall-rule create` with your IP).

Why `db_owner`: `SqlPackage` creates, alters and drops tables, schemas and constraints. If you want less, the minimum is `db_ddladmin` plus `db_datareader`/`db_datawriter`, but publish also reads and sometimes writes extended properties and metadata, so start with `db_owner` scoped to this one database and tighten later if you need to.

### 3.9 Collect the values for GitHub

```bash
echo "AZURE_CLIENT_ID=$APP_ID"
echo "AZURE_TENANT_ID=$TENANT_ID"
echo "AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
echo "SQL_SERVER=$SERVER.database.windows.net"
echo "SQL_DATABASE=$DB"
```

Repeat 3.1 to 3.9 for `qa` and `prod`.

---

## 4. GitHub setup

### 4.1 Environments

Repo: **Settings → Environments → New environment**, or with the CLI:

```bash
gh api -X PUT repos/lorenzouriel/lab-dba/environments/dev
gh api -X PUT repos/lorenzouriel/lab-dba/environments/qa

# prod: require approval from you before any deploy job starts
MY_ID=$(gh api user --jq .id)
gh api -X PUT repos/lorenzouriel/lab-dba/environments/prod \
  --input - <<EOF
{ "reviewers": [{ "type": "User", "id": $MY_ID }] }
EOF
```

For `prod`, also consider limiting deployments to tags matching `v*` (Environment settings → Deployment branches and tags), so nothing but a release tag can ever reach it.

A repo owner approving their own deployment is allowed by default. For a team, set "Prevent self-review".

### 4.2 Environment secrets

Set these on each Environment (Settings → Environments → *env* → Environment secrets), using the values from 3.9 for that environment:

| Name | Type | Example |
|---|---|
| `AZURE_CLIENT_ID` | `11111111-2222-3333-4444-555555555555` |
| `AZURE_TENANT_ID` | `aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee` |
| `AZURE_SUBSCRIPTION_ID` | `99999999-8888-7777-6666-555555555555` |
| `SQL_SERVER` | `sql-labdba-dev-12345.database.windows.net` |
| `SQL_DATABASE` | `fin_pulse` |

```bash
gh secret set   AZURE_CLIENT_ID       --env dev --body "$APP_ID"
gh secret set   AZURE_TENANT_ID       --env dev --body "$TENANT_ID"
gh secret set   AZURE_SUBSCRIPTION_ID --env dev --body "$SUBSCRIPTION_ID"
gh secret set   SQL_SERVER            --env dev --body "$SERVER.database.windows.net"
gh secret set   SQL_DATABASE          --env dev --body "$DB"
```

None of them lets anyone log in on its own; the trust lives in the federated credential (3.6). They are secrets only so the public logs don't expose your tenant, subscription, server and database name. Masking `fin_pulse` also blanks that word wherever it appears in the deploy job's logs.

### 4.3 Branch protection

Settings → Branches → add rules for `main` and `dev`:

- Require a pull request before merging.
- Require status checks: `tests / test` and `build` from **Database CI/CD**.

Without this, a broken change can reach `dev`/`qa` by direct push, and the pipeline would only find out after the push.

---

## 5. First run and verification

1. Commit and push the workflows to `dev`. The first push to `dev` runs the whole chain and deploys to the dev database.
2. In the Actions tab, open **Database CI/CD**. You should see `tests`, `build` and `deploy-dev`.
3. Confirm in the database:

   ```sql
   SELECT s.name AS [schema], COUNT(*) AS tables
   FROM sys.tables t JOIN sys.schemas s ON s.schema_id = t.schema_id
   GROUP BY s.name;
   ```

   You should see 20 tables across `dbo`, `plan`, `finance`, `body` and `mind`.
4. Merge `dev` into `main`. That deploys to qa.
5. Cut the first release from `main`:

   ```bash
   git checkout main && git pull
   git tag v0.1.0
   git push origin v0.1.0
   ```

   The prod job waits for your approval, then deploys.

A checklist for each environment before its first deploy:

- [ ] Server and database exist; server is Entra-only.
- [ ] Firewall allows the runner.
- [ ] Federated credential subject is `repo:lorenzouriel/lab-dba:environment:<env>`.
- [ ] Service principal has Reader on the resource group.
- [ ] Contained user exists in `fin_pulse` with `db_owner`.
- [ ] All five secrets are set on the Environment.

---

## 6. Day-to-day usage

| I want to... | Do this |
|---|---|
| Change the schema | Edit or add `.sql` under `database/`. **Add new files to `database/database.sqlproj`** as `<Build Include="...">`; the build and the test fixture only see listed files. |
| Test a change | Open a PR. Tests and build run; nothing deploys. |
| Run the tests locally | `$env:MSSQL_SA_PASSWORD="<from infra/.env>"; dotnet test database.tests` (see [database.tests/README.md](database.tests/README.md)). |
| Ship to dev | Merge the PR into `dev`. |
| Ship to qa | Merge `dev` into `main`. |
| Ship to prod | Tag `main` (`git tag vX.Y.Z && git push origin vX.Y.Z`) and approve the job. |
| Update the table count test | Change the number in `SchemaTests.TableCountMatchesProject` when you add a table. It is the likeliest first failure. |
| Add data migrations | Put idempotent scripts under `database/PostDeployment/MigrationScripts/` and `:r` them from `Script.PostDeployment.sql`. |

Rollback: Publish is forward-only. To undo a change, merge a revert and let the pipeline deploy it, or restore the database to a point in time (`az sql db restore`) for a destructive mistake. The data-loss guard on qa and prod exists to stop the second case before it happens.

---

## 7. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `AADSTS70021: No matching federated identity record found` | Subject mismatch | The credential subject must be exactly `repo:lorenzouriel/lab-dba:environment:<env>`. Check the Environment name's case and that the job uses `environment:`. |
| `No subscriptions found` in `azure/login` | Service principal has no role | Do 3.7. |
| `Login failed for user '<token-identified principal>'` | Database user missing | Do 3.8 in the `fin_pulse` database, not `master`. |
| `Cannot open server ... Client with IP address ... is not allowed` | Firewall | Do 3.5. |
| Connection times out on the first deploy of the day | Serverless database is resuming | Re-run the job; it succeeds once the database is awake. |
| `Rows were detected. The schema update is terminating because data loss might occur` | `BlockOnPossibleDataLoss` caught a destructive change | Intended. Split the change (add new column, copy, drop later) or handle it in a post-deployment script. |
| `Build error SQL70001: This statement is not recognized in this context` | A `.sql` file has a statement SSDT does not accept (e.g. `SET QUOTED_IDENTIFIER`, `USE`) | Remove it from the file; project settings cover it. |
| Table in the repo but not in the dacpac | File not listed in `database.sqlproj` | Add the `<Build Include>`. |
| `Duplicate 'Build' items were included` | `EnableDefaultSqlItems` removed | Keep it `false`; items are listed by hand on purpose. |
| Tests pass locally, fail in CI on one test | Container is `2022-latest`, local may differ | Compare versions; CI is the reference. |

---

## 8. Known limitations

- **Firewall:** the setup above relies on "Allow Azure services". A tighter version needs workflow steps to add and remove the runner's IP.
- **Prod rebuilds from the tag.** Prod deploys a dacpac built from the tagged commit, not the exact artifact that was deployed to qa. For the same commit the output is equivalent, but it is not the same file.
- **No PR schema diff.** PRs do not run `SqlPackage DeployReport` against dev, so reviewers do not see the generated DDL. Adding it needs OIDC access from PR runs.
- **No smoke test after deploy.** A green publish is the only signal.
- **No drift detection.** Nothing alerts if someone changes prod by hand.
- **Tests run on SQL Server, not Azure SQL.** Features that only exist or behave differently in Azure SQL are not exercised.
- **Not covered:** DAB deployment, the `infra/` lab (Docker/AG), and provisioning Azure resources as code. Section 3 is manual; the next step would be Bicep so the three environments are reproducible.
