# DP-300 — Configure and Manage Automation of Tasks

## 1. Automate database deployment

### Remember

- Infrastructure as Code (IaC) = resources defined in scripts/templates stored in source control.
- Bicep compiles into ARM JSON at deployment time — same capabilities, cleaner syntax.
- ARM templates/Bicep = **declarative** (what to deploy). PowerShell/Azure CLI = **imperative** (steps to run).
- ARM/Bicep deployments are idempotent — safe to redeploy repeatedly.
- PowerShell and Azure CLI can both run imperative commands **and** deploy ARM/Bicep templates.
- Azure CLI can't deploy a remote Bicep file directly by URI — compile it to JSON first.

### Deployment models

| Model | Tools | Style |
|---|---|---|
| Declarative | ARM templates, Bicep | Specify desired end state |
| Imperative | PowerShell, Azure CLI | Specify a sequence of steps |

Azure portal is a GUI over ARM templates — every portal deployment can be exported (**Export template**) and decompiled into Bicep.

### Bicep

- Microsoft's recommended IaC authoring language for Azure — not a general-purpose programming language.
- Benefits: continuous support for all resource types/API versions, concise syntax, idempotent, modular (reusable modules), rich IntelliSense via the VS Code Bicep extension.
- Supports orchestration (resource dependencies) and extensibility (run PowerShell/Bash post-deployment).

```bicep
resource sqlServer 'Microsoft.Sql/servers@2022-02-01' = {
  name: serverName
  location: location
}
```

**Easy rule:** Bicep file → compiles to ARM JSON at deploy time → same result, less typing.

Deployment scopes (PowerShell and CLI): resource group, subscription, management group, tenant.

### ARM templates

- JSON documents describing resources in a resource group.
- `dependsOn` builds dependencies between resources.
- Exportable from any existing resource group in the Azure portal — useful for learning syntax or reproducing environments.

### PowerShell (Az module)

- `Az.Sql` module manages Azure SQL resources; commands use verb-noun syntax.
- `Get-AzSqlServer`, `New-AzSqlDatabase`, `New-AzSqlInstance` are the core cmdlets to know.
- Deploy a template: `New-AzResourceGroupDeployment -TemplateFile ... -TemplateParameterFile ...`

```powershell
New-AzSqlDatabase -ResourceGroupName "RG01" -ServerName "Server01" -DatabaseName "DB01"
```

### Azure CLI

- Cross-platform (Linux/Mac/Windows); also runs in Cloud Shell or a Docker container.
- Syntax pattern: `reference name` → `command` → `parameter` → `value`.
- Deploy a local Bicep file directly: `az deployment group create --template-file main.bicep`.

**Exam idea:** `az deployment group create --template-file` works for **local** Bicep files, but a **remote** Bicep file by URI must be compiled to JSON first — `--template-uri` only takes ARM JSON.

### CLI vs PowerShell quick reference

| Task | Azure CLI | Azure PowerShell |
|---|---|---|
| Sign in | `az login` | `Connect-AzAccount` |
| List subscriptions | `az account list` | `Get-AzSubscription` |
| Set subscription | `az account set --subscription` | `Set-AzContext -Subscription` |
| List VMs | `az vm list` | `Get-AzVM` |
| Create SQL server | `az sql server create` | `New-AzSqlServer` |

Some Azure PostgreSQL/MySQL commands exist only in Azure CLI, not PowerShell.

### CI/CD for deployments

- Azure Pipelines automates build/test/deploy — either by calling a PowerShell script or using dedicated deployment tasks that stage and deploy templates.
- **CI**: frequent small changes checked into source control, with automated build/package/test.
- **CD**: automates delivery of changes to infrastructure — consistent and fast.
- Best practice: keep Bicep/ARM templates under source control, same as application code.

---

## 2. Create and manage SQL Agent jobs

### Remember

- SQL Server Agent schedules jobs on SQL Server and Azure SQL Managed Instance — **not available on Azure SQL Database**.
- Jobs, schedules, and history all live in `msdb`.
- Maintenance Plans are built with a wizard and run as SQL Server Agent jobs (created as Integration Services packages).
- `DBCC CHECKDB` is the only way to check a whole database for corruption — schedule it regularly.
- Notify operators on **failure only** to avoid alert fatigue; notifications require an existing operator.
- Alerts enable proactive monitoring: error log, performance conditions, or WMI events.

### Maintenance plan tasks

| Task | Purpose | Watch out for |
|---|---|---|
| Check database integrity | Runs `DBCC CHECKDB` | Align schedule with backup retention window |
| Shrink database | Reclaims free space | Causes heavy fragmentation — avoid as routine task |
| Reorganize/Rebuild index | Fixes fragmentation | Rebuild also refreshes statistics |
| Update statistics | Improves query plans | Default sampling is usually enough |
| Cleanup history | Trims job/backup history in `msdb` | Controls `msdb` growth |
| Execute SQL Server Agent job | Runs another user-defined job | — |
| Backup Database (Full/Diff/Log) | Backs up databases | Log backups need non-SIMPLE recovery model |
| Maintenance Cleanup Tasks | Deletes old report/backup files | Subfolders must be listed explicitly or they're skipped |

**Easy rule:** backup retention must cover at least the consistency-check interval — a backup can still contain corruption, since the backup operation itself doesn't detect it.

### Proxy accounts

- A proxy account is a stored credential the SQL Server Agent uses to run a specific job **step** as another identity.
- Use it when a step needs access the Agent service account doesn't have (e.g., backing up to a network share).

### Job schedules

- Jobs and schedules have a many-to-many relationship — one job can have several schedules, one schedule can serve several jobs.
- The Maintenance Plan Wizard only creates a dedicated schedule per plan; it can't reuse an independent schedule.

### Multiserver environment (MSX/TSX)

- **MSX** (master server) stores job definitions centrally.
- **TSX** (target servers) periodically pull job schedules from the MSX.
- Define a job once on MSX and deploy it consistently across the enterprise.

### Operators, notifications, alerts

| Object | Role |
|---|---|
| Operator | Alias for a person/group (usually an email group) that receives notifications |
| Notification | Job-level: fires on success, failure, or completion |
| Alert | Fires on an error-log entry, performance condition, or WMI event |

- The SQL Server Agent mail profile (Database Mail) must be enabled before operators can receive email.
- An alert can either notify an operator **or** execute another Agent job automatically — e.g., alert on storage errors 823/824/825 → run a `DBCC CHECKDB` job.

---

## 3. Manage Azure PaaS tasks using automation

### Remember

- Azure SQL Database has no SQL Server Agent/`msdb` — use **Elastic Jobs**, **Azure Automation**, or **Logic Apps** instead.
- Elastic Jobs run **T-SQL only**, across many databases/servers; need a Job Agent + a dedicated job database (S1 or higher).
- Azure Automation runbooks (PowerShell/Python/graphical) handle general Azure **and on-premises** automation via hybrid workers.
- A runbook restarts from the beginning if interrupted — write it to be idempotent/restartable.
- Logic Apps give low-code workflow automation with prebuilt connectors, including a SQL Server connector.
- Azure Policy governs resource compliance (region, naming, tags) — it's not a job scheduler.

### Elastic Jobs

| Component | Purpose |
|---|---|
| Elastic job agent | Azure resource that runs/manages jobs |
| Job database | Dedicated DB (S1+) storing job metadata |
| Target group | Servers, elastic pools, or databases the job runs against |
| Job | One or more T-SQL job steps |

- Server/pool targets need a credential in `master`; a single-database target needs only a database credential — use least privilege.
- Job scripts must be idempotent: rerunning after a failure shouldn't error or duplicate work.

```powershell
$job | Add-AzSqlElasticJobStep -Name "Step1" -TargetGroupName $g.TargetGroupName `
  -CredentialName $c.CredentialName -CommandText $sql
```

Use cases: scheduled management tasks, schema deployment, cross-database data movement, telemetry aggregation into one destination table.

**Exam idea:** SQL Agent jobs → SQL Server & Azure SQL Managed Instance. Elastic Jobs → Azure SQL Database & elastic pools.

### Azure Automation

| Component | Purpose |
|---|---|
| Runbook | Unit of execution (PowerShell, Python, or graphical) |
| Module | Imports the cmdlets a runbook needs (e.g., `Az.Accounts`, `Az.Sql`) |
| Credential | Stores secrets for runbooks to use at runtime |
| Schedule | Triggers a runbook at a set time |

- Log in with the account's system-assigned managed identity — needs RBAC permissions granted to that identity or the runbook fails.
- Hybrid workers let Automation manage on-premises/VM resources too (e.g., start VM → run backup → shut down VM).
- Use the **Test pane** to validate runbook code inside the Automation context before scheduling it.

```powershell
try {
    Connect-AzAccount -Identity
} catch {
    throw $_.Exception
}
```

### Azure Policy & tags

- Policy enforces governance rules (region limits, naming standards, resource sizes); scopes = management group, subscription, or resource group. Group related policies into initiatives.
- Tags are `key:value` metadata, up to 50 per resource — usable for filtering (`Where-Object` on `.tags`) and cost breakdown in billing.

**Easy rule:** never put secrets in tags — tags are plain text and surface in exports, deployment history, and monitoring logs.

### Logic Apps

- Serverless, low-code workflow designer with prebuilt, Microsoft-managed connectors — Microsoft handles hosting, scaling, and maintenance.
- SQL Server connector actions: get/insert/delete rows, run a query or stored procedure; triggers on row insert/update/delete.
- Consumption (multi-tenant) workflows get only the **managed** SQL connector; Standard (single-tenant) workflows also get a **built-in** SQL connector running in-process.

### Monitor automated tasks

| Automation type | How to monitor |
|---|---|
| Runbook | Jobs blade, metric alerts, Activity Log, Log Analytics |
| Elastic Job | Portal overview, PowerShell (`Get-AzSqlElasticJobExecution`), T-SQL (`jobs.job_executions`) |

- Elastic Jobs auto-retry failed executions — built-in resilience to transient failures.
- Diagnostic settings must be configured on the Automation account before Log Analytics can query job data.

```sql
SELECT * FROM jobs.job_executions
WHERE job_name = 'MyJob'
ORDER BY start_time DESC;
```

**Exam idea:** an alert's action group can send email, call a webhook, or **run a runbook** — so an alert condition can trigger further automation automatically.
