# CI/CD setup in the Azure portal and GitHub UI (OIDC deploy)

The click-through version of [SETUP.md](SETUP.md), which has the same steps as CLI commands. Read SETUP.md section 1 for how the pipeline works.

The workflow logs in with **OIDC**, so there is no client secret or password. It needs five values, which you collect in Azure and enter in GitHub as **Environment secrets**. They are identifiers rather than credentials, but this repo is public and its Actions logs are public, and GitHub prints variables in clear text there. Secrets are masked as `***`, so all five are stored as secrets. Repeat everything once per environment.

| | dev | qa | prod |
|---|---|---|---|
| Resource group | `rg-labdba-dev` | `rg-labdba-qa` | `rg-labdba-prod` |
| SQL server | `sql-labdba-dev-<random>` | `sql-labdba-qa-<random>` | `sql-labdba-prod-<random>` |
| Database | `fin_pulse` | `fin_pulse` | `fin_pulse` |
| App registration | `gh-labdba-dev` | `gh-labdba-qa` | `gh-labdba-prod` |
| Federated credential name | `github-dev` | `github-qa` | `github-prod` |
| GitHub Environment | `dev` | `qa` | `prod` |

The server name must be globally unique, so add a random number. Portal labels shift slightly between releases; the names below are the ones used at the time of writing.

**Prerequisites:** an Azure subscription where you can create resources and app registrations, and admin access to the GitHub repo `lorenzouriel/lab-dba`.

## Part 1: Azure portal

### 1. Resource group

1. Open [portal.azure.com](https://portal.azure.com), search **Resource groups**, then click **Create**.
2. Choose your subscription and set **Resource group** to `rg-labdba-dev`.
3. Set **Region** to `Brazil South` (or your region), then **Review + create**, then **Create**.

### 2. SQL server and database

1. Click **Create a resource**, search **SQL Database**, then **Create**.
2. **Basics** tab:
   - Subscription and Resource group: `rg-labdba-dev`.
   - Database name: `fin_pulse`.
   - Server: **Create new**. In the side panel set:
     - Server name: `sql-labdba-dev-<random>`.
     - Location: the same region.
     - Authentication method: **Use only Microsoft Entra authentication**.
     - **Set admin**: search for and select your own account, then **Select**.
     - Click **OK**.
   - Want to use SQL elastic pool: **No**.
   - Workload environment: **Development**.
3. **Compute + storage** → **Configure database**:
   - Service tier: **General Purpose**.
   - Compute tier: **Serverless**.
   - Max vCores: `1`. Min vCores: `0.5`.
   - **Enable auto-pause** with a delay of **1 hour**.
   - Click **Apply**.
   - If the portal offers the free database offer, you can apply it.
4. **Backup storage redundancy**: **Locally-redundant** (for prod, pick **Zone** or **Geo**).
5. **Networking** tab:
   - Connectivity method: **Public endpoint**.
   - **Allow Azure services and resources to access this server**: **Yes**. This is the firewall rule the GitHub runner needs.
   - **Add current client IP address**: **Yes**, so you can use the query editor.
   - Minimum TLS version: **1.2**.
6. **Security** tab: Microsoft Defender for SQL is optional; choose **Not now** for a lab. Leave the other tabs at their defaults.
7. Click **Review + create**, then **Create**. Wait for the deployment to finish.

You can change the firewall later under **SQL server → Security → Networking**.

### 3. App registration

1. Search **Microsoft Entra ID**, then in the left menu choose **Manage → App registrations → + New registration**.
2. Name: `gh-labdba-dev`.
3. Supported account types: **Accounts in this organizational directory only (Single tenant)**.
4. Leave Redirect URI empty, then click **Register**. Entra creates the service principal automatically.
5. On the **Overview** page, copy and keep:
   - **Application (client) ID**, which becomes `AZURE_CLIENT_ID`.
   - **Directory (tenant) ID**, which becomes `AZURE_TENANT_ID`.

### 4. Federated credential (the OIDC trust)

1. Go to Microsoft Entra ID → **App registrations**, open **Owned applications** (or **All applications**), and click `gh-labdba-dev`.
2. In the app's left menu choose **Manage → Certificates & secrets**.
3. Click the **Federated credentials** tab (next to Certificates and Client secrets), then **+ Add credential**.
4. Set **Federated credential scenario** to **GitHub Actions deploying Azure resources**, then fill in:
   - Organization: `lorenzouriel` (a personal account, but this field means "owner")
   - Organization ID: `92133074`
   - Repository: `lab-dba`
   - Repository ID: `1274611502`
   - Entity type: **Environment**
   - GitHub environment name: `dev`
   - Name: `github-dev`
   - Audience: leave `api://AzureADTokenExchange`
5. **Leave the generated subject identifier as it is.** The form builds an ID-based subject:

   ```text
   repo:lorenzouriel@92133074/lab-dba@1274611502:environment:dev
   ```

   This is what GitHub puts in the token for this repo (confirmed in the `azure/login` log, `subject claim - ...`). Do not rewrite it to the older name-based form `repo:lorenzouriel/lab-dba:environment:dev`: that one would not match. The subject is case-sensitive and must match the GitHub Environment name exactly. Repositories created before GitHub switched to ID-based subjects still send the name-based form; the `azure/login` log tells you which one you have.
6. Click **Add**.

Use one app per environment, and make sure each credential is added to **its own app** (`gh-labdba-prod` for prod). The `prod` credential then only works for jobs that run in the `prod` Environment, which is where your approval gate lives.

The environment name is the **GitHub Environment**, not a branch. `.github/workflows/db-pipeline.yml` deploys `main` to `qa` and `v*` tags to `prod`, so there is no `main` credential: use `qa` and `prod`.

### 5. Reader role

The login step needs the service principal to see a subscription. Reader on the resource group is enough, because data access goes through the database user.

1. Open the resource group `rg-labdba-dev` → **Access control (IAM)**.
2. Click **+ Add → Add role assignment**.
3. **Role** tab: search for and select **Reader**, then **Next**.
4. **Members** tab: Assign access to **User, group, or service principal**, click **+ Select members**, and search `gh-labdba-dev`. Select it, then **Select**.
5. Click **Review + assign** (twice).

### 6. Database user (the step people forget)

1. Open the SQL database `fin_pulse` (not the server) and choose **Query editor (preview)** in the left menu.
2. Sign in with **Microsoft Entra authentication**. It should offer **Continue as <your account>**, and that account must be the admin you set in step 2. If it says your IP is blocked, click the link to allow your IP and retry.
3. Run this, with the editor connected to `fin_pulse`:

   ```sql
   CREATE USER [gh-labdba-dev] FROM EXTERNAL PROVIDER;
   ALTER ROLE db_owner ADD MEMBER [gh-labdba-dev];
   ```

4. Check it. It should return one row of type `EXTERNAL_USER`:

   ```sql
   SELECT name, type_desc FROM sys.database_principals WHERE name = 'gh-labdba-dev';
   ```

`db_owner` is scoped to this one database only. Publishing needs it because the dacpac creates schemas, tables and constraints.

**Error 33159** (`Only connections established with Active Directory accounts can create other Active Directory users`) means the session isn't an Entra connection. The second error (`Cannot add the principal ... does not exist`) is just a consequence of the first.

1. Run `SELECT SUSER_SNAME();`. A SQL login name instead of your email means you're on SQL authentication.
2. Reconnect with Entra authentication:
   - Query editor: **Microsoft Entra authentication → Continue as ...**
   - SSMS or Azure Data Studio: **Microsoft Entra MFA** (or **Entra Default**), not SQL Server Authentication.
   - sqlcmd: `az login`, then `sqlcmd -S <server>.database.windows.net -d fin_pulse --authentication-method ActiveDirectoryDefault`.
3. Confirm under **SQL server → Settings → Microsoft Entra ID** that an admin is set and **Support only Microsoft Entra authentication** is ticked.
4. If you were already on Entra, the account must be the server's Entra admin. A personal Microsoft account added as a guest often fails; set a real Entra user, or a group that contains you, as the admin.
5. Last resort, unverified in this lab: create the user by client ID.

   ```sql
   -- <client-id> is the Application (client) ID of gh-labdba-dev
   DECLARE @sid VARBINARY(16) = CAST(CAST('<client-id>' AS UNIQUEIDENTIFIER) AS VARBINARY(16));
   DECLARE @sql NVARCHAR(MAX) = N'CREATE USER [gh-labdba-dev] WITH SID = ' + CONVERT(VARCHAR(34), @sid, 1) + N', TYPE = E;';
   EXEC (@sql);
   ALTER ROLE db_owner ADD MEMBER [gh-labdba-dev];
   ```

### 7. Collect the five values

| GitHub secret | Where to find it |
|---|---|
| `AZURE_CLIENT_ID` | Entra → App registration → Overview → Application (client) ID |
| `AZURE_TENANT_ID` | Entra → App registration → Overview → Directory (tenant) ID |
| `AZURE_SUBSCRIPTION_ID` | Subscriptions → your subscription → Overview → Subscription ID |
| `SQL_SERVER` | SQL server → Overview → **Server name** (ends in `.database.windows.net`) |
| `SQL_DATABASE` | `fin_pulse` |

Repeat steps 1–7 for `qa` and `prod`, changing the names.

## Part 2: GitHub UI

Open the repo `lorenzouriel/lab-dba` → **Settings**.

### 1. Environments

1. In the left menu choose **Environments → New environment**.
2. Name it `dev`, then **Configure environment**. Repeat for `qa` and `prod`.
3. The names must match the Entra credential and the workflow (`dev`, `qa`, `prod`), including case.

### 2. Protect prod

1. Open `prod`.
2. Tick **Required reviewers**, search for yourself, and add yourself. For a team, also tick **Prevent self-review**.
3. Under **Deployment branches and tags**, choose **Selected branches and tags** → **Add deployment branch or tag rule**. Set Ref type to **Tag** and the pattern to `v*`, then **Add rule**.
4. Click **Save protection rules**.

### 3. Environment secrets

For each Environment, under **Environment secrets**, click **Add environment secret** five times:

| Name | Type | Example value |
|---|---|---|
| `AZURE_CLIENT_ID` | **Secret** | `11111111-2222-3333-4444-555555555555` |
| `AZURE_TENANT_ID` | **Secret** | `aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee` |
| `AZURE_SUBSCRIPTION_ID` | **Secret** | `99999999-8888-7777-6666-555555555555` |
| `SQL_SERVER` | **Secret** | `sql-labdba-dev-12345.database.windows.net` |
| `SQL_DATABASE` | **Secret** | `fin_pulse` |

Each Environment gets its own client ID and server name. Because `SQL_DATABASE` is a secret, GitHub also masks the word `fin_pulse` wherever it appears in the deploy job's logs (for example in the publish output), which can make those logs harder to read. Secrets are masked by exact string, so a value that appears inside a different string (for example in an Azure error message) can still leak.

### 4. Branch protection

1. Go to **Settings → Branches → Add branch protection rule** (or **Add classic branch protection rule**).
2. Branch name pattern: `main`.
3. Tick **Require a pull request before merging**.
4. Tick **Require status checks to pass before merging**. Search for and add `tests / test` and `build`. They only appear in the search box after a workflow run has happened, so you may need to do step 5 first and come back.
5. Click **Create**. Repeat for `dev`.

### 5. First run

1. Push the workflow files to `dev`. This runs **Database CI/CD**.
2. Open the **Actions** tab. You should see `tests`, `build` and `deploy` (in the `dev` Environment) all succeed.
3. Verify in the Azure query editor on `fin_pulse`:

   ```sql
   SELECT s.name AS [schema], COUNT(*) AS tables
   FROM sys.tables t JOIN sys.schemas s ON s.schema_id = t.schema_id
   GROUP BY s.name;
   ```

   Expect 20 tables across `dbo`, `plan`, `finance`, `body` and `mind`.
4. Merge `dev` into `main` to deploy qa.
5. For prod, create a release tag from `main` (`git tag v0.1.0` and `git push origin v0.1.0`). The prod job waits for your approval.

## Per-environment checklist

- [ ] Server and database exist, and the server is Entra-only.
- [ ] **Allow Azure services** is on.
- [ ] Federated credential subject is `repo:lorenzouriel@92133074/lab-dba@1274611502:environment:<env>`, on that environment's own app.
- [ ] The app has Reader on the resource group.
- [ ] The database user exists in `fin_pulse` with `db_owner`.
- [ ] All five secrets are set on the GitHub Environment.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `AADSTS70021` or `AADSTS700213: No matching federated identity record found` | Subject mismatch | The login error prints the subject GitHub sent. Copy the `subject claim` from the `azure/login` log into the credential exactly. Check case, the ID-based vs name-based form (step 4.5), and that the job uses `environment:`. |
| `No subscriptions found` in the login step | No role on the service principal | Redo step 5 (Reader role). |
| `Login failed for user '<token-identified principal>'` | Database user missing | Redo step 6 inside `fin_pulse`, not `master`. |
| `Msg 33159` creating the user | Session isn't an Entra connection | See the error 33159 notes in step 6. |
| Cannot open server / firewall error | Azure services not allowed | Turn on **Allow Azure services** under SQL server → Networking. |
| First deploy after a pause is slow | Serverless database was auto-paused | Wait about a minute and re-run. |
| `startup_failure` mentioning `id-token` | Caller didn't grant `id-token: write` | Already fixed in `.github/workflows/db-pipeline.yml`. |

## Settle before the first qa or prod deploy

The dacpac creates an Always Encrypted master key (`database/Security/ae.cmk.sql`) that points at the **lab PFX provider**. Deploying it to Azure works, but real clients can't decrypt `journal_entries.content` or `symptom_logs.notes`. Before the first `qa` or `prod` deploy, move that key to Azure Key Vault (see [../../infra/always-encrypted/README.md](../../infra/always-encrypted/README.md)). TDE needs no work, because Azure SQL has it on by default.
