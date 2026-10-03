# Plan: deploy fin_pulse to AWS (and Azure) from GitHub Actions

**Status: plan only. Nothing in this document has been built or run.** Items marked **[verify]** are assumptions that the documentation did not confirm; each one has a check in the phase where it matters.

Related: [../azure/SETUP.md](../azure/SETUP.md) (CLI) and [../azure/SETUP-UI.md](../azure/SETUP-UI.md) (portal) describe the Azure side that already works.

## 1. Goal and scope

Deploy the same `database/` project to **Azure SQL Database** (done) and **Amazon RDS for SQL Server** (new) from one GitHub Actions pipeline, for `dev`, `qa` and `prod`, with:

- no long-lived cloud credentials in GitHub (OIDC to both clouds),
- the same approval rules per GitHub Environment,
- everything sensitive masked in the public Actions logs (the repo is public).

Out of scope for now: the `infra/` Docker lab, DAB deployment, infrastructure as code (Terraform or Bicep, listed as an optional last phase).

## 2. Decisions

Recommended defaults are marked. Please confirm or change them before phase 1.

| # | Decision | Options | Recommended |
|---|---|---|---|
| A | RDS edition | **Express** (free tier on a new account, no TDE, no Multi-AZ) · Standard (TDE, Multi-AZ, paid) · Developer via custom engine version (all Enterprise features including TDE, non-production only, needs your own installation media in S3) | **Express for dev** to prove the pipeline; decide on TDE when qa is added |
| B | How the runner reaches RDS | Open the security group to the runner's IP during deploy · bastion with SSM port forwarding · self-hosted runner in the VPC | **Security group opened per deploy** for dev and qa. Self-hosted runners are not recommended while the repo is public |
| C | First slice | dev only · all three environments | **dev only**, then qa, then prod |
| D | Dacpac strategy | Two dacpacs built from one source (Azure SQL provider and SQL Server provider) · one Azure dacpac with `AllowIncompatiblePlatform` | **Two dacpacs** |
| E | SQL Server version on RDS | 2022 · 2025 | **2022** (CI already runs 2022) |
| F | Region | `us-east-1` (cheapest, free tier) · `sa-east-1` (São Paulo; closer to you) | `us-east-1` unless latency matters |

## 3. What the documentation says (and what changed from earlier assumptions)

| Topic | Fact | Consequence |
|---|---|---|
| DB authentication | AWS documents IAM database authentication only for MariaDB, MySQL and PostgreSQL. SQL Server uses password authentication, or Windows/Kerberos through AWS Managed Microsoft AD. | The deploy login is a SQL login (`gh_deploy`) whose password lives in AWS Secrets Manager. AWS also says not to use the master user in applications. |
| Publish permission | SqlPackage needs `db_owner` to publish to an existing database. The RDS master user is `db_owner` on every user database. | `gh_deploy` gets `db_owner` on `fin_pulse` only. |
| TDE | Supported on Standard (2019, 2022, 2025) and Enterprise (2016, 2017) only, via a **TDE option group**; RDS manages the certificate. The option is persistent. AWS suggests keeping encrypted and unencrypted databases on separate instances. | Express cannot do TDE. [infra/scripts/30-tde.sql](../../infra/scripts/30-tde.sql) is lab-only and cannot be used on RDS. |
| OIDC | Provider URL `https://token.actions.githubusercontent.com`, audience `sts.amazonaws.com`, workflow needs `id-token: write`, and the trust policy must test `sub`. Repos created after July 15, 2026 put immutable owner and repository IDs in `sub`. | The trust policy uses the ID-based subject (see section 6). |
| TLS | RDS certificates are signed by an Amazon CA. `rds.force_ssl=1` forces SSL (static parameter, needs a reboot). | The Linux runner must trust the RDS CA bundle, or the connection falls back to `TrustServerCertificate=True` (weaker). |
| Always Encrypted | Listed as supported (SQL Server 2016 and later). | Key metadata still has to be handled per cloud (section 8). |
| Unsupported features | `xp_cmdshell`, CLR on 2017 and later, server-level triggers, `TRUSTWORTHY`, replication. | The schema uses none of them. |
| Express edition | Free tier: db.t3.micro or db.t4g.micro, 750 hours a month for 12 months for new accounts. No Multi-AZ, no Database Mail. | Fine for dev. |
| Network | GitHub-hosted runners cannot reach a private RDS instance. GitHub recommends self-hosted runners only for private repositories. | Section 2, decision B. |
| SqlPackage | `AllowIncompatiblePlatform` exists (default false) for dacpacs built for a different platform. | Used only as a fallback. |

## 4. Target architecture

```
GitHub Actions (db-pipeline.yml)
  tests  ─┐
  build  ─┴─► database-azure.dacpac      ─► deploy-azure ─ OIDC ─► Entra app ─► Azure SQL Database
             database-sqlserver.dacpac   ─► deploy-aws   ─ OIDC ─► IAM role  ─► RDS for SQL Server
                                                            │
                                                            ├─ Secrets Manager: gh_deploy password
                                                            └─ EC2: open/close one security-group rule
```

- One pipeline file. `deploy-azure` and `deploy-aws` run in parallel, both inside the same GitHub Environment (`dev`, `qa`, `prod`), so approval rules and secrets stay together.
- `fail-fast` is off in spirit: one cloud failing does not stop the other from deploying. Both are separate jobs, so this is the default.
- A shared composite action runs SqlPackage, so the publish logic exists once.

## 5. Files to create and change in the repo

### Create

| File | Purpose |
|---|---|
| `docs/aws/PLAN.md` | This document |
| `docs/aws/SETUP-UI.md` | Click-by-click AWS console + GitHub steps (written in phase 1, same style as [../azure/SETUP-UI.md](../azure/SETUP-UI.md)) |
| `docs/aws/SETUP.md` | The same steps as AWS CLI commands |
| `.github/actions/publish-dacpac/action.yml` | Composite action: install SqlPackage, publish a dacpac with a connection string, retry only on the "database not available" error |
| `infra/aws/bootstrap-gh-deploy.sql` | One-time SQL: create `gh_deploy` login, `fin_pulse` database, `db_owner` user |
| `infra/aws/iam/trust-policy.json` | IAM trust policy template (OIDC subject per environment) |
| `infra/aws/iam/permissions-policy.json` | IAM permissions policy template (Secrets Manager read, one security group) |
| `infra/aws/README.md` | What lives in `infra/aws/` and how it relates to `infra/` (the Docker lab) |
| `infra/aws/iac/` (optional, last phase) | Terraform for the AWS resources below |

### Change

| File | Change |
|---|---|
| `database/database.sqlproj` | Keep `DSP` as the Azure SQL provider by default; build the SQL Server dacpac by overriding `DSP` on the command line (`-p:DSP=Microsoft.Data.Tools.Schema.Sql.Sql160DatabaseSchemaProvider`). **[verify]** that a global property overrides the project property and that the SDK accepts that provider |
| `.github/workflows/db-pipeline.yml` | Build both dacpacs and upload two artifacts. Split `deploy` into `deploy-azure` (current steps, moved onto the composite action) and `deploy-aws` (new). Single concurrency group `db-deploy` |
| `database/README.md` | CI/CD section: mention AWS and the two dacpacs |
| `docs/azure/SETUP.md`, `docs/azure/SETUP-UI.md` | Cross-link to `docs/aws/`; update the workflow table after the split |
| `infra/.env.example` | None for the pipeline (AWS values live in GitHub). Add `AWS_*` only if you want to run the AWS CLI locally against the lab |
| `database/Security/ae.cmk.sql`, `ae.cek.sql` | Phase 4 only: handle per-environment key metadata (section 8) |
| `database.tests/` | Add nothing to the unit tests. CI already runs on SQL Server 2022; the SQL Server dacpac build is the new compile check |

### Leave alone

`infra/scripts/30-tde.sql` (lab-only TDE), the PFX key provider, the Docker lab files.

## 6. What to create on AWS (per environment)

Names use `dev`; repeat for `qa` and `prod`. Use one AWS account to start (or one account per environment if you prefer stronger isolation).

| # | Resource | Configuration |
|---|---|---|
| 1 | IAM OIDC identity provider (once per account) | URL `https://token.actions.githubusercontent.com`, audience `sts.amazonaws.com` |
| 2 | Security group `sg-labdba-rds-dev` | No inbound rules by default. The pipeline adds and removes a single `/32` rule on TCP 1433 |
| 3 | DB parameter group `labdba-sqlserver-ex-2022` | Family for SQL Server Express 2022. Set `rds.force_ssl` = `1` (static, requires a reboot) |
| 4 | DB option group | None for Express. For Standard, create `labdba-sqlserver-se-tde` with the `TDE` option (persistent; use a separate group per instance) |
| 5 | RDS instance `labdba-dev` | Engine `sqlserver-ex`, version 16.00 (2022), class `db.t3.micro`, 20 GiB gp3, default VPC, security group above, parameter group above, public access **on** for the lab (the security group is the gate), automated backups 1 day, no Multi-AZ, deletion protection off for dev. Master user `labdba_admin` |
| 6 | Secrets Manager secret `labdba/dev/gh_deploy` | JSON `{"username":"gh_deploy","password":"<generated>"}` |
| 7 | Master user credentials | Let RDS manage the master password in Secrets Manager, or set one and store it there. Never used by the pipeline |
| 8 | IAM role `gh-labdba-dev-deploy` | Trust policy and permissions policy below |
| 9 | Database `fin_pulse` and login `gh_deploy` | Created once with `infra/aws/bootstrap-gh-deploy.sql`, run as the master user from your own IP |

### Trust policy (role `gh-labdba-dev-deploy`)

The `sub` value is the ID-based form GitHub currently sends for this repository (the same string the Azure login logged). **[verify]** against the first AWS login attempt; if it fails, the log prints what was sent.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:lorenzouriel@92133074/lab-dba@1274611502:environment:dev"
        }
      }
    }
  ]
}
```

Use one role per environment (`...:environment:qa`, `...:environment:prod`) so the prod role can only be assumed by jobs running in the `prod` Environment.

### Permissions policy (least privilege)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadDeployLoginSecret",
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "arn:aws:secretsmanager:<REGION>:<ACCOUNT_ID>:secret:labdba/dev/gh_deploy-*"
    },
    {
      "Sid": "OpenAndCloseRunnerRule",
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "arn:aws:ec2:<REGION>:<ACCOUNT_ID>:security-group/<SG_ID>"
    },
    {
      "Sid": "DescribeGroups",
      "Effect": "Allow",
      "Action": "ec2:DescribeSecurityGroups",
      "Resource": "*"
    }
  ]
}
```

### One-time database bootstrap (`infra/aws/bootstrap-gh-deploy.sql`)

Run as the RDS master user, with your own IP temporarily allowed in the security group:

```sql
-- master
CREATE LOGIN gh_deploy WITH PASSWORD = N'<same value as the Secrets Manager secret>';
GO
CREATE DATABASE fin_pulse;
GO
USE fin_pulse;
GO
CREATE USER gh_deploy FOR LOGIN gh_deploy;
ALTER ROLE db_owner ADD MEMBER gh_deploy;
GO
```

RDS notes: database names cannot start with `rdsadmin`; the master user is `db_owner` but not `sysadmin`.

## 7. Pipeline design

### GitHub Environment secrets (per environment, all masked)

| Secret | Value |
|---|---|
| `AWS_ROLE_ARN` | ARN of `gh-labdba-<env>-deploy` |
| `AWS_REGION` | e.g. `us-east-1` (masking also blanks this string in logs; make it a variable if that bothers you) |
| `AWS_SQL_SERVER` | RDS endpoint, e.g. `labdba-dev.xxxx.us-east-1.rds.amazonaws.com,1433` |
| `AWS_SQL_DATABASE` | `fin_pulse` |
| `AWS_SECURITY_GROUP_ID` | `sg-...` |
| `AWS_DB_SECRET_ID` | `labdba/<env>/gh_deploy` |

The Azure secrets (`AZURE_*`, `SQL_SERVER`, `SQL_DATABASE`) stay as they are.

### Jobs

1. `tests` (unchanged), `build` (now builds two dacpacs).
2. `build`: `dotnet build database/database.sqlproj -c Release` for Azure, copy the dacpac aside, then build again with `-p:DSP=...Sql160DatabaseSchemaProvider` and copy that one. Upload `database-azure` and `database-sqlserver`. **[verify]** that the second build does not reuse stale intermediate output; use `--no-incremental` if needed.
3. `deploy-azure`: current steps, with the SqlPackage step replaced by the composite action.
4. `deploy-aws` (draft; same `if` and Environment expression as today):
   1. Download `database-sqlserver`.
   2. Check required secrets.
   3. `aws-actions/configure-aws-credentials` with `role-to-assume` and region (use the current major version **[verify]**). Job permissions `id-token: write`, `contents: read`.
   4. Fetch the password with `aws secretsmanager get-secret-value`, print `::add-mask::<password>` before using it.
   5. Find the runner's public IP (`curl https://checkip.amazonaws.com`).
   6. `aws ec2 authorize-security-group-ingress` for `<ip>/32` on 1433, with a description containing the run id.
   7. Trust the RDS CA bundle (download `global-bundle.pem` from the RDS truststore and point `SSL_CERT_FILE` at a combined bundle). **[verify]** that SqlPackage on Linux honors it; fallback is `TargetTrustServerCertificate=True`.
   8. Publish through the composite action with `Server=<endpoint>;Initial Catalog=fin_pulse;User ID=gh_deploy;Password=<secret>;Encrypt=True;TrustServerCertificate=False`.
   9. `if: always()`: revoke the security group rule.
5. Concurrency: one group, `db-deploy`, `cancel-in-progress: false`.

### Composite action: `.github/actions/publish-dacpac`

- Inputs: `dacpac`, `connection-string`, `block-data-loss`, `extra-arguments`.
- Installs SqlPackage with `dotnet tool install --global microsoft.sqlpackage` and adds the tools folder to the PATH (the runner no longer ships it; this is the failure we already hit on Azure).
- Runs the publish in a retry loop that retries only when the output contains the "not currently available" message (Azure serverless auto-pause), and fails immediately on any other error.
- Always passes `/p:DropObjectsNotInSource=false`.
- Replaces the current wake-up, wait and `azure/sql-action` steps.

## 8. Security parity

| Feature | Azure | AWS (RDS) | Work needed |
|---|---|---|---|
| Row-level security, masking, roles | In the dacpac | Same dacpac content | Verify in phase 2 |
| TDE | On by default | Option group, Standard or Developer only | Phase 4, not on Express |
| Transport encryption | Enforced by Azure | `rds.force_ssl=1` + CA trust | Phase 1 and 3 |
| Always Encrypted | Planned Key Vault CMK | No AWS KMS provider for SqlClient; needs a small custom provider, or keep the PFX provider for non-prod | Phase 4 |
| Deploy login | Entra (no password) | SQL login, password in Secrets Manager | Phase 1 |

**Always Encrypted key metadata.** `ae.cmk.sql` names the lab PFX provider. For `qa` and `prod` on either cloud: create the real CMK and CEK before the publish with a small prep script, then publish with `/p:ExcludeObjectTypes=ColumnMasterKeys;ColumnEncryptionKeys` so the dacpac does not overwrite them. The tables still reference `CEK_fin_pulse`, so the prep step must run first. See [../../infra/always-encrypted/README.md](../../infra/always-encrypted/README.md).

## 9. Phases and acceptance criteria

| Phase | Work | Done when |
|---|---|---|
| 1. AWS foundation | Items 1 to 9 in section 6, for `dev`. Write `docs/aws/SETUP-UI.md` and `SETUP.md` as you go. | You can connect to RDS from your IP as `gh_deploy` and run `SELECT 1`; the role can be assumed from a test workflow run |
| 2. SQL Server dacpac | Override `DSP`, build both dacpacs in CI, publish the SQL Server dacpac by hand to RDS | A manual `sqlpackage` publish to RDS succeeds; the check query shows 20 tables, the RLS policy, masked columns and the two encrypted columns |
| 3. Pipeline | Composite action, split deploy, `deploy-aws`, secrets on the `dev` Environment | A push to `dev` deploys to both clouds, and the security group has no leftover rule |
| 4. Security parity | TDE (Standard or Developer), Always Encrypted key handling, per-environment key prep | Encrypted columns readable by a test client on both clouds; TDE reported as encrypted on RDS |
| 5. qa and prod | Repeat phase 1 and 3 for `qa` and `prod`, including prod approval and tag rules | A `v*` tag deploys to prod on both clouds after one approval flow |
| 6. Optional | Terraform for the AWS side | A clean account can be rebuilt from code |

Verification query for phase 2 and 3 (adapt from [../azure/SETUP-UI.md](../azure/SETUP-UI.md)):

```sql
SELECT s.name AS [schema], COUNT(*) AS tables
FROM sys.tables t JOIN sys.schemas s ON s.schema_id = t.schema_id
GROUP BY s.name;
SELECT COUNT(*) AS rls_policies FROM sys.security_policies;
SELECT COUNT(*) AS masked_columns FROM sys.masked_columns;
SELECT COUNT(*) AS encrypted_columns FROM sys.columns WHERE column_encryption_key_id IS NOT NULL;
```

## 10. Risks and open questions

| Risk | Mitigation |
|---|---|
| The SQL Server provider rejects something in the schema (partitioning in `Storage/ps_monthly_date.sql`, security policy, Always Encrypted metadata) | Phase 2 is a manual publish before any pipeline work |
| Overriding `DSP` on the command line does not behave as expected | Fall back to a second project file or `AllowIncompatiblePlatform` |
| The runner's IP rule is left behind if a job is cancelled | Revoke in an `if: always()` step; consider a scheduled cleanup job that removes rules with the run-id description |
| SqlPackage on Linux does not trust the RDS CA | Use `TrustServerCertificate=True` as a temporary fallback |
| Two jobs in the same Environment may ask for approval twice on `prod` | Check the first prod deploy; if annoying, put both clouds in one job |
| ID-based OIDC subject mismatch in the IAM trust policy | Copy the exact `sub` from the error or the Azure log |
| Express free tier ends after 12 months or is unavailable on your account | Check current pricing before phase 1; stop the instance when idle (RDS auto-restarts a stopped instance after 7 days) |
| Public repo: Actions logs are public | Keep all AWS identifiers as masked secrets (section 7); never print the DB password |

## 11. Sources

- [Amazon RDS TDE for SQL Server](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.SQLServer.Options.TDE.html)
- [Amazon RDS for Microsoft SQL Server](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html)
- [Database authentication with Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/database-authentication.html)
- [SQL Server Developer Edition on RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/sqlserver-dev-edition.html)
- [SSL with RDS SQL Server](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/SQLServer.Concepts.General.SSL.Using.html)
- [Features not supported on RDS SQL Server](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/SQLServer.Concepts.General.FeatureNonSupport.html)
- [SQL Server features on RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/SQLServer.Concepts.General.FeatureSupport.html)
- [GitHub Docs: OIDC in AWS](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws)
- [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
- [SqlPackage Publish (Microsoft Learn)](https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage-publish?view=sql-server-ver17)
- [Amazon RDS Free Tier](https://aws.amazon.com/rds/free/)
