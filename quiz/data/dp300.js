// DP-300 practice quiz questions.
// Auto-assembled from domain drafts; each item's `source` cites the exact
// dp300/content/ lesson file the answer/explanation comes from.
const DP300_QUESTIONS = [
{
  "id": "easy-01",
  "tier": "easy",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and deploy Azure SQL solutions",
  "question": "Which Azure SQL deployment option is the simplest choice for a single application database, being a fully managed PaaS service?",
  "options": [
    "Azure SQL Database",
    "SQL Server on Azure Virtual Machines",
    "Azure SQL Managed Instance",
    "Azure Arc-enabled SQL Server"
  ],
  "correctIndex": 0,
  "explanation": "Azure SQL Database is fully managed PaaS, so there's no OS or instance to maintain, which is why it's usually the simplest fit for a single application database.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and deploy Azure SQL solutions/README.md",
    "heading": "Choose the right SQL platform",
    "quote": "Azure SQL Database is a fully managed PaaS service and is usually the simplest choice for a single application database."
  }
},
{
  "id": "easy-02",
  "tier": "easy",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and deploy Azure SQL solutions",
  "question": "Which option gives a team the greatest control over the SQL Server environment, at the cost of owning OS patching and high availability?",
  "options": [
    "SQL Server on Azure Virtual Machines",
    "Azure SQL Database",
    "SQL Database in Microsoft Fabric",
    "Azure SQL Managed Instance"
  ],
  "correctIndex": 0,
  "explanation": "Running SQL Server on IaaS VMs hands the team full control of the OS and instance, but that also means the team is responsible for patching and HA configuration.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and deploy Azure SQL solutions/README.md",
    "heading": "Choose the right SQL platform",
    "quote": "SQL Server on Azure Virtual Machines provides the greatest control, but the team owns the operating system, patching, and high-availability configuration."
  }
},
{
  "id": "easy-03",
  "tier": "easy",
  "domain": "Plan and implement data platform resources",
  "module": "Configure resources for scale and performance",
  "question": "For intermittent workloads with unpredictable usage, which Azure SQL Database compute option is appropriate?",
  "options": [
    "Serverless",
    "Provisioned compute",
    "Business Critical provisioned tier",
    "Fixed vCore General Purpose"
  ],
  "correctIndex": 0,
  "explanation": "Serverless auto-scales and auto-pauses compute, which fits workloads that run intermittently rather than steadily.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Configure resources for scale and performance/README.md",
    "heading": "Scale deliberately",
    "quote": "Serverless is useful for intermittent workloads; provisioned compute suits steady demand."
  }
},
{
  "id": "easy-04",
  "tier": "easy",
  "domain": "Plan and implement data platform resources",
  "module": "Configure resources for scale and performance",
  "question": "Before changing a database's capacity or service tier, what should you establish first?",
  "options": [
    "A performance baseline covering CPU, I/O latency, workers, memory pressure, query duration, and concurrency",
    "A new partitioning scheme",
    "A failover group",
    "A backup retention policy"
  ],
  "correctIndex": 0,
  "explanation": "Without a baseline you can't tell whether a capacity change actually helped, so measuring current resource and query behavior comes first.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Configure resources for scale and performance/README.md",
    "heading": "Scale deliberately",
    "quote": "Establish a baseline before changing capacity. Measure CPU, data and log I/O latency, workers, memory pressure, query duration, and concurrency."
  }
},
{
  "id": "easy-05",
  "tier": "easy",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and implement a migration strategy",
  "question": "Which migration approach stops writes, copies the data, and then cuts over — trading simplicity for required downtime?",
  "options": [
    "Offline migration",
    "Online migration",
    "Log shipping migration",
    "Elastic Jobs migration"
  ],
  "correctIndex": 0,
  "explanation": "An offline migration is easier to reason about precisely because writes stop during the copy, but that pause is exactly what causes the downtime.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and implement a migration strategy/README.md",
    "heading": "Assess before moving",
    "quote": "An offline migration stops writes, copies data, and then cuts over. It is easier to reason about but requires downtime."
  }
},
{
  "id": "easy-06",
  "tier": "easy",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and implement a migration strategy",
  "question": "Besides the databases themselves, what should be inventoried before a migration?",
  "options": [
    "Compatibility level, SQL Agent jobs, linked servers, authentication dependencies, encryption, and unsupported features",
    "Only the target storage account tier",
    "Only the number of CPU cores on the target",
    "Only the backup retention policy"
  ],
  "correctIndex": 0,
  "explanation": "Missing a dependency like a linked server or an unsupported feature is a common source of migration surprises, so the inventory has to go beyond just the data.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and implement a migration strategy/README.md",
    "heading": "Assess before moving",
    "quote": "Inventory databases, compatibility level, SQL Agent jobs, linked servers, authentication dependencies, encryption, and unsupported features."
  }
},
{
  "id": "easy-07",
  "tier": "easy",
  "domain": "Implement a secure environment",
  "module": "Configure database authentication and authorization",
  "question": "Why is Microsoft Entra ID preferred over SQL authentication for people and supported workloads?",
  "options": [
    "It centralizes identity lifecycle, MFA, and conditional access",
    "It removes the need for any permissions model",
    "It automatically encrypts all data at rest",
    "It is required before read scale-out can be enabled"
  ],
  "correctIndex": 0,
  "explanation": "Entra ID's value is identity governance — lifecycle, MFA, and conditional access — not that it replaces authorization or encryption.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Configure database authentication and authorization/README.md",
    "heading": "Authenticate identities",
    "quote": "Prefer Microsoft Entra ID for people and supported workloads because it centralizes identity lifecycle, MFA, and conditional access."
  }
},
{
  "id": "easy-08",
  "tier": "easy",
  "domain": "Implement a secure environment",
  "module": "Configure database authentication and authorization",
  "question": "What is the difference between authentication and authorization?",
  "options": [
    "Authentication proves identity; authorization determines what that identity can do",
    "Authentication grants permissions; authorization proves identity",
    "They are two names for the same process",
    "Authorization only applies to Microsoft Entra accounts"
  ],
  "correctIndex": 0,
  "explanation": "Keeping these separate matters operationally too: login creation (authentication) and database user mapping (authorization) are handled as distinct steps.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Configure database authentication and authorization/README.md",
    "heading": "Authenticate identities",
    "quote": "Authentication proves identity. Authorization determines what that identity can do."
  }
},
{
  "id": "easy-09",
  "tier": "easy",
  "domain": "Implement a secure environment",
  "module": "Implement security for data at rest and data in transit",
  "question": "What does Transparent Data Encryption (TDE) protect?",
  "options": [
    "Database files, backups, and transaction logs at rest",
    "Only data in transit between client and server",
    "Only specific sensitive columns chosen by the DBA",
    "Only the customer-managed key in Key Vault"
  ],
  "correctIndex": 0,
  "explanation": "TDE works at the storage layer, encrypting the files, backups, and logs, rather than protecting specific columns or the network path.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement security for data at rest and data in transit/README.md",
    "heading": "Protect data at rest",
    "quote": "Transparent Data Encryption encrypts database files, backups, and transaction logs at rest."
  }
},
{
  "id": "easy-10",
  "tier": "easy",
  "domain": "Implement a secure environment",
  "module": "Implement security for data at rest and data in transit",
  "question": "TDE is transparent to applications, but it does not protect data from:",
  "options": [
    "Highly privileged in-database users",
    "Theft of the physical backup file",
    "Unencrypted transaction logs",
    "Loss of the storage account"
  ],
  "correctIndex": 0,
  "explanation": "Because TDE decrypts data for any authorized connection, a highly privileged in-database user can still see plaintext — that gap is what features like Always Encrypted address.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement security for data at rest and data in transit/README.md",
    "heading": "Protect data at rest",
    "quote": "It is transparent to applications but does not protect data from highly privileged in-database users."
  }
},
{
  "id": "easy-11",
  "tier": "easy",
  "domain": "Implement a secure environment",
  "module": "Implement compliance controls for sensitive data",
  "question": "Data classification is best described as:",
  "options": [
    "Metadata that must be combined with permissions, encryption, and auditing",
    "A form of encryption on its own",
    "A replacement for auditing",
    "A backup retention policy"
  ],
  "correctIndex": 0,
  "explanation": "Classification just labels sensitivity so consistent controls can be applied — it doesn't itself lock down or encrypt anything.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement compliance controls for sensitive data/README.md",
    "heading": "Discover and govern sensitive data",
    "quote": "Classification is metadata, not encryption; combine it with permissions, encryption, and auditing."
  }
},
{
  "id": "easy-12",
  "tier": "easy",
  "domain": "Implement a secure environment",
  "module": "Implement compliance controls for sensitive data",
  "question": "What does Dynamic Data Masking actually do?",
  "options": [
    "Obscures values for nonprivileged users, without securing the underlying data from users with direct elevated access",
    "Encrypts the underlying column data at rest",
    "Physically removes sensitive columns from the table",
    "Prevents any user from ever reading the column"
  ],
  "correctIndex": 0,
  "explanation": "DDM is a display-layer control for ordinary queries; someone with elevated direct access can still bypass the mask and see real values.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement compliance controls for sensitive data/README.md",
    "heading": "Limit disclosure",
    "quote": "Dynamic Data Masking obscures values for nonprivileged users but does not secure the underlying data from users with direct elevated access."
  }
},
{
  "id": "easy-13",
  "tier": "easy",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor resource activity and performance",
  "question": "What is the purpose of establishing an operational baseline?",
  "options": [
    "It turns a vague report of \"slow\" into a measurable deviation",
    "It permanently fixes query performance",
    "It replaces the need for Query Store",
    "It automatically scales the database"
  ],
  "correctIndex": 0,
  "explanation": "Without a recorded normal, \"it's slow\" has nothing to compare against — the baseline gives you a number to measure the deviation from.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor resource activity and performance/README.md",
    "heading": "Establish an operational baseline",
    "quote": "A baseline turns a vague report of “slow” into a measurable deviation."
  }
},
{
  "id": "easy-14",
  "tier": "easy",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor resource activity and performance",
  "question": "Which tool centralizes monitoring for SQL workloads across an estate?",
  "options": [
    "Database Watcher",
    "Elastic Jobs",
    "Resource Governor",
    "Query Store"
  ],
  "correctIndex": 0,
  "explanation": "Database Watcher is built to collect metrics across many SQL workloads in one place, unlike the other options which serve automation, throttling, or single-database query analysis.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor resource activity and performance/README.md",
    "heading": "Establish an operational baseline",
    "quote": "Database Watcher centralizes monitoring for SQL workloads and can collect metrics across an estate."
  }
},
{
  "id": "easy-15",
  "tier": "easy",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor and optimize query performance",
  "question": "What does Query Store retain that helps diagnose regressions?",
  "options": [
    "Query text, plans, runtime statistics, and regressions",
    "Only backup history",
    "Only firewall rules",
    "Only login audit records"
  ],
  "correctIndex": 0,
  "explanation": "Query Store's whole value for tuning is that it keeps historical plans and runtime stats, letting you compare a slow period to a known-good one.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor and optimize query performance/README.md",
    "heading": "Diagnose before tuning",
    "quote": "Query Store retains query text, plans, runtime statistics, and regressions."
  }
},
{
  "id": "easy-16",
  "tier": "easy",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor and optimize query performance",
  "question": "Forcing a stable query plan in Query Store should be treated as:",
  "options": [
    "A safety mechanism, not permanent design",
    "A permanent fix that ends the investigation",
    "A replacement for indexing",
    "A required step before every deployment"
  ],
  "correctIndex": 0,
  "explanation": "Plan forcing buys time and stability, but the underlying cause of the regression still needs to be found and fixed.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor and optimize query performance/README.md",
    "heading": "Diagnose before tuning",
    "quote": "Use it to compare a slow interval to a known-good period and, when justified, force a stable plan while the root cause is addressed. Review forced plans regularly; they are a safety mechanism, not permanent design."
  }
},
{
  "id": "easy-17",
  "tier": "easy",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Configure database solutions for optimal performance",
  "question": "What is the difference between reorganizing and rebuilding an index?",
  "options": [
    "Reorganize is online and incremental; rebuild is more intensive and refreshes statistics",
    "Reorganize refreshes statistics; rebuild is online and incremental",
    "They are identical operations with different names",
    "Reorganize requires taking the database offline"
  ],
  "correctIndex": 0,
  "explanation": "Reorganize is the lighter-weight, online option, while rebuild does more work but also brings the side benefit of fresh statistics.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Configure database solutions for optimal performance/README.md",
    "heading": "Maintain trustworthy metadata",
    "quote": "Reorganize is online and incremental; rebuild is more intensive and refreshes statistics."
  }
},
{
  "id": "easy-18",
  "tier": "easy",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage SQL Server Agent jobs",
  "question": "What is a SQL Server Agent job?",
  "options": [
    "A sequence of steps executed by a schedule, alert, or manual start",
    "A single T-SQL statement run once",
    "A network firewall rule",
    "A backup retention policy"
  ],
  "correctIndex": 0,
  "explanation": "A job is a container of ordered steps, and it can be triggered by a schedule, an alert, or a manual start rather than only one of those.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage SQL Server Agent jobs/README.md",
    "heading": "Build reliable jobs",
    "quote": "A SQL Server Agent job is a sequence of steps executed by a schedule, alert, or manual start."
  }
},
{
  "id": "easy-19",
  "tier": "easy",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage SQL Server Agent jobs",
  "question": "Why should job steps run through least-privileged proxies or credentials?",
  "options": [
    "To limit the damage if a step is compromised or misconfigured, following least privilege",
    "To make jobs run faster",
    "To avoid needing SQL Server Agent entirely",
    "To bypass authentication checks"
  ],
  "correctIndex": 0,
  "explanation": "Scoping each step's identity down to what it actually needs limits the blast radius if that step ever misbehaves or is compromised.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage SQL Server Agent jobs/README.md",
    "heading": "Build reliable jobs",
    "quote": "run them through least-privileged proxies or credentials, and make each step safe to retry."
  }
},
{
  "id": "easy-20",
  "tier": "easy",
  "domain": "Configure and manage automation of tasks",
  "module": "Automate deployment of database resources",
  "question": "Which tools define Azure resources declaratively?",
  "options": [
    "ARM and Bicep",
    "Azure PowerShell and Azure CLI",
    "SQL Server Agent and Elastic Jobs",
    "Query Store and Extended Events"
  ],
  "correctIndex": 0,
  "explanation": "ARM/Bicep describe the desired end state declaratively, whereas PowerShell/CLI are better suited to imperative, scripted operations.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Automate deployment of database resources/README.md",
    "heading": "Use repeatable deployments",
    "quote": "ARM and Bicep define Azure resources declaratively."
  }
},
{
  "id": "easy-21",
  "tier": "easy",
  "domain": "Configure and manage automation of tasks",
  "module": "Automate deployment of database resources",
  "question": "Where should deployment secrets be kept?",
  "options": [
    "Key Vault or an approved secret store",
    "Hardcoded directly in the Bicep template",
    "In the deployment's activity log",
    "In a SQL Server Agent job step's comments"
  ],
  "correctIndex": 0,
  "explanation": "Parameterizing environment values while routing secrets to Key Vault keeps credentials out of source-controlled templates.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Automate deployment of database resources/README.md",
    "heading": "Use repeatable deployments",
    "quote": "Parameterize environment-specific values, keep secrets in Key Vault or an approved secret store, and use a what-if review before production."
  }
},
{
  "id": "easy-22",
  "tier": "easy",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage database tasks in Azure",
  "question": "What do Elastic Jobs run across a group of Azure SQL databases?",
  "options": [
    "T-SQL",
    "PowerShell scripts only",
    "ARM templates",
    "Bicep files"
  ],
  "correctIndex": 0,
  "explanation": "Elastic Jobs are built specifically to run T-SQL against a target group of databases for fleet-wide maintenance or admin work.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage database tasks in Azure/README.md",
    "heading": "Automate fleet operations",
    "quote": "Elastic Jobs run T-SQL across a group of Azure SQL databases."
  }
},
{
  "id": "easy-23",
  "tier": "easy",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage database tasks in Azure",
  "question": "What characteristics should database tasks have?",
  "options": [
    "Small, observable, and independently recoverable",
    "Large, opaque, and tightly coupled",
    "Manual-only with no logging",
    "Run exclusively from a developer's workstation"
  ],
  "correctIndex": 0,
  "explanation": "Small, observable, independently recoverable tasks are easier to retry and diagnose than one large monolithic operation.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage database tasks in Azure/README.md",
    "heading": "Automate fleet operations",
    "quote": "Database tasks should be small, observable, and independently recoverable."
  }
},
{
  "id": "easy-24",
  "tier": "easy",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan an HA DR strategy for database solutions",
  "question": "What does Recovery Point Objective (RPO) define?",
  "options": [
    "Acceptable data loss",
    "Acceptable service interruption",
    "The number of replicas required",
    "The backup compression ratio"
  ],
  "correctIndex": 0,
  "explanation": "RPO is about how much data you can afford to lose, which is a distinct concern from RTO's focus on downtime duration.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan an HA DR strategy for database solutions/README.md",
    "heading": "Begin with business objectives",
    "quote": "Recovery Point Objective defines acceptable data loss; Recovery Time Objective defines acceptable service interruption."
  }
},
{
  "id": "easy-25",
  "tier": "easy",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan an HA DR strategy for database solutions",
  "question": "Does implementing high availability automatically provide disaster recovery?",
  "options": [
    "No — one does not automatically provide the other",
    "Yes, HA and DR are the same mechanism",
    "Yes, but only for Managed Instance",
    "No, DR must always be configured before HA"
  ],
  "correctIndex": 0,
  "explanation": "HA is about surviving a local failure quickly; DR is about recovering from a much broader failure, and a design needs to address both deliberately.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan an HA DR strategy for database solutions/README.md",
    "heading": "Begin with business objectives",
    "quote": "High availability reduces local failure downtime; disaster recovery restores service after a broader failure. One does not automatically provide the other."
  }
},
{
  "id": "easy-26",
  "tier": "easy",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan and perform backup and restore of a database",
  "question": "What actually proves that a database is recoverable?",
  "options": [
    "Testing restores, not just confirming backup completion",
    "Confirming the backup job shows \"Succeeded\"",
    "Checking that TDE is enabled",
    "Verifying the storage account has enough free space"
  ],
  "correctIndex": 0,
  "explanation": "A backup can report success and still be unusable — only an actual test restore confirms the recovery chain works.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan and perform backup and restore of a database/README.md",
    "heading": "Design recoverability",
    "quote": "Test restores—not backup completion—prove recoverability."
  }
},
{
  "id": "easy-27",
  "tier": "easy",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan and perform backup and restore of a database",
  "question": "Which backup types preserve the recovery chain for SQL Server?",
  "options": [
    "Full, differential, and transaction-log backups",
    "Only full backups",
    "Only transaction-log backups",
    "Snapshot backups only"
  ],
  "correctIndex": 0,
  "explanation": "Full, differential, and log backups work together to form an unbroken recovery chain, which is what point-in-time restore relies on.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan and perform backup and restore of a database/README.md",
    "heading": "Design recoverability",
    "quote": "For SQL Server, choose full, differential, and transaction-log backups that preserve the recovery chain."
  }
},
{
  "id": "easy-28",
  "tier": "easy",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Configure HA DR for database solutions",
  "question": "What do failover groups provide for a group of Azure SQL databases?",
  "options": [
    "A listener-style endpoint and coordinated failover",
    "Row-level encryption",
    "Automatic index rebuilding",
    "Elastic Job scheduling"
  ],
  "correctIndex": 0,
  "explanation": "Failover groups add a stable, listener-style endpoint on top of geo-replication so a whole group of databases can fail over together.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Configure HA DR for database solutions/README.md",
    "heading": "Select and configure the mechanism",
    "quote": "Failover groups provide a listener-style endpoint and coordinated failover for a group of databases."
  }
},
{
  "id": "medium-01",
  "tier": "medium",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and deploy Azure SQL solutions",
  "question": "A team needs instance-level compatibility, SQL Server Agent, and cross-database queries. Which platform fits best?",
  "options": [
    "Azure SQL Managed Instance",
    "Azure SQL Database",
    "SQL Database in Microsoft Fabric",
    "Azure Arc-enabled SQL Server"
  ],
  "correctIndex": 0,
  "explanation": "Managed Instance exists specifically to keep instance-scoped features like SQL Agent and cross-database queries while staying PaaS.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and deploy Azure SQL solutions/README.md",
    "heading": "Choose the right SQL platform",
    "quote": "Azure SQL Managed Instance is appropriate when instance-level compatibility, SQL Server Agent, cross-database queries, or native backup/restore behavior are required."
  }
},
{
  "id": "medium-02",
  "tier": "medium",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and deploy Azure SQL solutions",
  "question": "Which approach is used to deploy database schema changes declaratively, as distinct from Bicep/ARM for infrastructure?",
  "options": [
    "SQL projects and DACPACs",
    "Azure CLI scripts",
    "SQL Server Agent jobs",
    "Elastic Jobs"
  ],
  "correctIndex": 0,
  "explanation": "Bicep/ARM own the resource layer while SQL projects/DACPACs own the schema layer — keeping those two concerns separate is the point.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and deploy Azure SQL solutions/README.md",
    "heading": "Deploy and maintain",
    "quote": "Bicep or ARM deploy Azure resources, while SQL projects and DACPACs deploy database schemas."
  }
},
{
  "id": "medium-03",
  "tier": "medium",
  "domain": "Plan and implement data platform resources",
  "module": "Configure resources for scale and performance",
  "question": "Read scale-out should only be used for workloads that:",
  "options": [
    "Tolerate replica lag",
    "Require synchronous writes",
    "Need cross-database transactions",
    "Require SQL Server Agent"
  ],
  "correctIndex": 0,
  "explanation": "Read replicas can lag behind the primary, so offloading reads to them only makes sense if the workload can tolerate slightly stale data.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Configure resources for scale and performance/README.md",
    "heading": "Scale deliberately",
    "quote": "Use read scale-out only for workloads that tolerate replica lag."
  }
},
{
  "id": "medium-04",
  "tier": "medium",
  "domain": "Plan and implement data platform resources",
  "module": "Configure resources for scale and performance",
  "question": "Which statement about row vs. page compression is accurate?",
  "options": [
    "Row compression is a conservative first choice, while page compression can save more space on read-heavy, compressible data",
    "Page compression is always safe for write-intensive tables",
    "Row compression only works with clustered columnstore indexes",
    "Page compression eliminates the need for partitioning"
  ],
  "correctIndex": 0,
  "explanation": "Row compression is the safer default; page compression can save more but costs more CPU, which is why it's positioned for read-heavy, compressible data.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Configure resources for scale and performance/README.md",
    "heading": "Data layout",
    "quote": "Row compression is a conservative first choice; page compression can save more space on read-heavy, compressible data."
  }
},
{
  "id": "medium-05",
  "tier": "medium",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and implement a migration strategy",
  "question": "An online migration minimizes downtime by:",
  "options": [
    "Seeding the target and continuously replicating changes until cutover",
    "Taking the source offline immediately",
    "Skipping validation of the target schema",
    "Relying solely on native backup/restore"
  ],
  "correctIndex": 0,
  "explanation": "Continuous replication after the initial seed is what lets the source keep serving traffic right up until cutover.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and implement a migration strategy/README.md",
    "heading": "Assess before moving",
    "quote": "An online migration seeds the target and continuously replicates changes until cutover."
  }
},
{
  "id": "medium-06",
  "tier": "medium",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and implement a migration strategy",
  "question": "After cutover, what validation steps should be performed?",
  "options": [
    "Compare row counts and critical aggregates, run application smoke tests, check jobs and permissions, and monitor errors and performance",
    "Immediately decommission the source system",
    "Skip smoke tests to save time",
    "Only check CPU utilization on the target"
  ],
  "correctIndex": 0,
  "explanation": "A migration isn't done at cutover — verifying data integrity, app behavior, and dependent objects is what confirms it actually worked.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and implement a migration strategy/README.md",
    "heading": "Execute and validate",
    "quote": "After cutover, compare row counts and critical aggregates, run application smoke tests, check jobs and permissions, and monitor errors and performance."
  }
},
{
  "id": "medium-07",
  "tier": "medium",
  "domain": "Implement a secure environment",
  "module": "Configure database authentication and authorization",
  "question": "Which practice is recommended for authorization design?",
  "options": [
    "Grant permissions to database roles or Entra groups rather than individual users",
    "Grant db_owner broadly to simplify management",
    "Rely on SQL logins only, never contained users",
    "Avoid using schemas as a permission boundary"
  ],
  "correctIndex": 0,
  "explanation": "Assigning permissions to roles/groups instead of individuals keeps access manageable as people join, move, and leave.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Configure database authentication and authorization/README.md",
    "heading": "Authorize with least privilege",
    "quote": "Grant permissions to database roles or Entra groups rather than individual users."
  }
},
{
  "id": "medium-08",
  "tier": "medium",
  "domain": "Implement a secure environment",
  "module": "Configure database authentication and authorization",
  "question": "Why should explicit DENY be used only when necessary?",
  "options": [
    "Because denies complicate troubleshooting",
    "Because denies are deprecated in Azure SQL",
    "Because denies automatically override Entra MFA",
    "Because denies cannot be applied at the schema level"
  ],
  "correctIndex": 0,
  "explanation": "A DENY overrides other grants in ways that are easy to forget about, which makes later access troubleshooting harder.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Configure database authentication and authorization/README.md",
    "heading": "Authorize with least privilege",
    "quote": "Explicitly deny only when necessary, because denies complicate troubleshooting."
  }
},
{
  "id": "medium-09",
  "tier": "medium",
  "domain": "Implement a secure environment",
  "module": "Implement security for data at rest and data in transit",
  "question": "Which Always Encrypted mode should be used only when equality lookups are required, given its information-disclosure trade-off?",
  "options": [
    "Deterministic encryption",
    "Randomized encryption",
    "Row-Level Security",
    "Dynamic Data Masking"
  ],
  "correctIndex": 0,
  "explanation": "Deterministic encryption produces the same ciphertext for the same value, which is what enables equality lookups but also what leaks pattern information.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement security for data at rest and data in transit/README.md",
    "heading": "Protect data at rest",
    "quote": "Use deterministic encryption only when equality lookups are required, recognizing its information-disclosure trade-off."
  }
},
{
  "id": "medium-10",
  "tier": "medium",
  "domain": "Implement a secure environment",
  "module": "Implement security for data at rest and data in transit",
  "question": "What is required to use secure enclaves for in-place operations on Always Encrypted columns?",
  "options": [
    "Compatible client drivers and attestation design",
    "A geo-replicated secondary database",
    "A Resource Governor workload group",
    "Dynamic Data Masking enabled on the same column"
  ],
  "correctIndex": 0,
  "explanation": "Enclave computation depends on the client and server agreeing on attestation and using compatible drivers to route operations to the enclave.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement security for data at rest and data in transit/README.md",
    "heading": "Protect data at rest",
    "quote": "Secure enclaves enable some in-place operations on protected values and require compatible client drivers and attestation design."
  }
},
{
  "id": "medium-11",
  "tier": "medium",
  "domain": "Implement a secure environment",
  "module": "Implement compliance controls for sensitive data",
  "question": "Why is change tracking not a substitute for auditing?",
  "options": [
    "It records that rows changed but does not preserve a complete before-and-after audit history",
    "It requires Always Encrypted to function",
    "It only works on Managed Instance",
    "It automatically masks changed values"
  ],
  "correctIndex": 0,
  "explanation": "Change tracking is built for sync scenarios — knowing what changed — not for reconstructing a full audit trail of who changed what and when.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement compliance controls for sensitive data/README.md",
    "heading": "Discover and govern sensitive data",
    "quote": "Change tracking records that rows changed and is useful for synchronization; it does not preserve a complete before-and-after audit history."
  }
},
{
  "id": "medium-12",
  "tier": "medium",
  "domain": "Implement a secure environment",
  "module": "Implement compliance controls for sensitive data",
  "question": "How should Row-Level Security be validated before relying on it?",
  "options": [
    "Test it with representative users and ensure application queries cannot bypass the predicate",
    "Enable it only in production, never in test environments",
    "Confirm it works by checking the execution plan alone",
    "Disable auditing while testing RLS"
  ],
  "correctIndex": 0,
  "explanation": "RLS is only as strong as its predicate function — testing with real user contexts is how you catch a query path that slips past the filter.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement compliance controls for sensitive data/README.md",
    "heading": "Limit disclosure",
    "quote": "Row-Level Security filters rows through a predicate function based on the caller context. Test it with representative users and ensure application queries cannot bypass the predicate."
  }
},
{
  "id": "medium-13",
  "tier": "medium",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor resource activity and performance",
  "question": "How should Extended Events sessions be used to limit overhead?",
  "options": [
    "Capture only the events and fields needed, use filters, and stop the session after diagnosis",
    "Capture every event type by default for completeness",
    "Leave sessions running indefinitely once created",
    "Avoid using filters so nothing is missed"
  ],
  "correctIndex": 0,
  "explanation": "Extended Events are meant to be targeted diagnostic sessions — broad, unfiltered, long-running sessions add exactly the overhead they're meant to avoid.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor resource activity and performance/README.md",
    "heading": "Establish an operational baseline",
    "quote": "Extended Events are targeted diagnostic sessions: capture only the events and fields needed, use filters, and stop the session after diagnosis to limit overhead."
  }
},
{
  "id": "medium-14",
  "tier": "medium",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor resource activity and performance",
  "question": "What should alerting focus on to avoid noise?",
  "options": [
    "Sustained symptoms and meaningful thresholds, not every transient spike",
    "Every metric deviation regardless of duration",
    "Only CPU usage",
    "Only backup failures"
  ],
  "correctIndex": 0,
  "explanation": "Alerting on every brief spike trains people to ignore alerts; sustained, meaningful thresholds keep alerts actionable.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor resource activity and performance/README.md",
    "heading": "Establish an operational baseline",
    "quote": "Alert on sustained symptoms and meaningful thresholds, not every transient spike."
  }
},
{
  "id": "medium-15",
  "tier": "medium",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor and optimize query performance",
  "question": "When diagnosing a blocking issue, what should be identified?",
  "options": [
    "The lead blocker, the held resource, the transaction scope, and why it remains open",
    "Only the SPID of the blocked session",
    "Only the query text of the blocked session",
    "Only the wait type name"
  ],
  "correctIndex": 0,
  "explanation": "Fixing blocking requires understanding the whole chain — who's holding what, in what transaction scope, and why it hasn't released yet.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor and optimize query performance/README.md",
    "heading": "Diagnose before tuning",
    "quote": "For blocking, identify the lead blocker, the held resource, the transaction scope, and why it remains open."
  }
},
{
  "id": "medium-16",
  "tier": "medium",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor and optimize query performance",
  "question": "What is the recommended alternative to routinely killing blocking sessions?",
  "options": [
    "Correct transaction design, indexing, or concurrency settings",
    "Increase the database's compute tier",
    "Disable Query Store",
    "Force every query plan"
  ],
  "correctIndex": 0,
  "explanation": "Killing a session only clears the symptom for a moment; fixing the transaction design or indexing addresses why the blocking happened at all.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor and optimize query performance/README.md",
    "heading": "Diagnose before tuning",
    "quote": "Avoid solving every incident by killing sessions—correct transaction design, indexing, or concurrency settings instead."
  }
},
{
  "id": "medium-17",
  "tier": "medium",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Configure database solutions for optimal performance",
  "question": "What should determine when an index needs maintenance?",
  "options": [
    "Fragmentation, page count, workload window, and log-space capacity",
    "Only the number of rows in the table",
    "Only the database's compatibility level",
    "Only how long ago the index was created"
  ],
  "correctIndex": 0,
  "explanation": "Maintenance decisions should be evidence-based — fragmentation and size versus how much workload window and log space you actually have.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Configure database solutions for optimal performance/README.md",
    "heading": "Maintain trustworthy metadata",
    "quote": "Index maintenance should be driven by fragmentation, page count, workload window, and log-space capacity."
  }
},
{
  "id": "medium-18",
  "tier": "medium",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage SQL Server Agent jobs",
  "question": "What should be accounted for when scheduling maintenance jobs?",
  "options": [
    "Job duration, overlap, time zones, and daylight-saving changes",
    "Only the SQL Server version",
    "Only the number of CPU cores",
    "Only the storage account tier"
  ],
  "correctIndex": 0,
  "explanation": "A job that looks fine on paper can still collide with critical workload windows once duration, overlap, and time-zone shifts are considered.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage SQL Server Agent jobs/README.md",
    "heading": "Build reliable jobs",
    "quote": "Schedule maintenance outside critical workload windows and account for job duration, overlap, time zones, and daylight-saving changes."
  }
},
{
  "id": "medium-19",
  "tier": "medium",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage SQL Server Agent jobs",
  "question": "Why configure notifications for jobs that exceed an expected duration, not just for failures?",
  "options": [
    "Because a successful but stalled job can be operationally harmful",
    "Because Agent jobs cannot fail by design",
    "Because duration alerts replace the need for job history",
    "Because notifications are required for compliance certification"
  ],
  "correctIndex": 0,
  "explanation": "A job that's still \"running\" long past its normal window can be just as harmful as an outright failure, so duration deserves its own alert.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage SQL Server Agent jobs/README.md",
    "heading": "Build reliable jobs",
    "quote": "Configure notifications for failure and for jobs that exceed an expected duration; a successful but stalled job can be operationally harmful."
  }
},
{
  "id": "medium-20",
  "tier": "medium",
  "domain": "Configure and manage automation of tasks",
  "module": "Automate deployment of database resources",
  "question": "What review should be performed before deploying a template to production?",
  "options": [
    "A what-if review",
    "A DBCC CHECKDB run",
    "A partition switch dry run",
    "A failover group test"
  ],
  "correctIndex": 0,
  "explanation": "A what-if review previews the exact changes a deployment would make, catching surprises before they hit production.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Automate deployment of database resources/README.md",
    "heading": "Use repeatable deployments",
    "quote": "use a what-if review before production."
  }
},
{
  "id": "medium-21",
  "tier": "medium",
  "domain": "Configure and manage automation of tasks",
  "module": "Automate deployment of database resources",
  "question": "Why should imperative scripts (PowerShell/CLI) used in pipelines be made idempotent?",
  "options": [
    "So rerunning them is safe",
    "So they run faster than declarative templates",
    "So they no longer require authentication",
    "So they bypass the what-if review"
  ],
  "correctIndex": 0,
  "explanation": "Pipelines retry; if a script isn't safe to run twice, a retry can create duplicate resources or leave things in a broken state.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Automate deployment of database resources/README.md",
    "heading": "Use repeatable deployments",
    "quote": "make scripts idempotent so rerunning them is safe."
  }
},
{
  "id": "medium-22",
  "tier": "medium",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage database tasks in Azure",
  "question": "What should each Elastic Job step be designed to tolerate?",
  "options": [
    "Partial success and reruns",
    "Only a single guaranteed successful run",
    "Concurrent schema changes without locking",
    "Removal of the target group mid-run"
  ],
  "correctIndex": 0,
  "explanation": "Across a large target group, some databases will fail or lag on any given run, so steps need to tolerate partial success and safe reruns.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage database tasks in Azure/README.md",
    "heading": "Automate fleet operations",
    "quote": "Use them for consistent maintenance or administrative work across tenant databases, but design each step to tolerate partial success and reruns."
  }
},
{
  "id": "medium-23",
  "tier": "medium",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage database tasks in Azure",
  "question": "Why should correlation IDs be added to database tasks?",
  "options": [
    "When a task triggers downstream automation, to trace related work across systems",
    "To satisfy Always Encrypted requirements",
    "To replace the need for a central log",
    "To automatically disable retries"
  ],
  "correctIndex": 0,
  "explanation": "A correlation ID lets you follow one logical operation across multiple triggered systems instead of piecing it together from separate logs.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage database tasks in Azure/README.md",
    "heading": "Automate fleet operations",
    "quote": "Add correlation IDs when a task triggers downstream automation."
  }
},
{
  "id": "medium-24",
  "tier": "medium",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan an HA DR strategy for database solutions",
  "question": "Besides the database itself, what dependencies should RPO/RTO requirements account for?",
  "options": [
    "DNS, identity, networking, and reporting",
    "Only the database engine version",
    "Only the compute tier",
    "Only the storage redundancy setting"
  ],
  "correctIndex": 0,
  "explanation": "A database can fail over successfully and the application can still be down if DNS, identity, or networking dependencies weren't part of the plan.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan an HA DR strategy for database solutions/README.md",
    "heading": "Begin with business objectives",
    "quote": "Translate both into an application-specific requirement, including dependencies such as DNS, identity, networking, and reporting."
  }
},
{
  "id": "medium-25",
  "tier": "medium",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan an HA DR strategy for database solutions",
  "question": "When evaluating replication for an HA/DR design, what factors should be compared?",
  "options": [
    "Synchronous versus asynchronous replication, regional separation, operational complexity, cost, failover ownership, and client reconnection behavior",
    "Only the number of secondary replicas",
    "Only the backup file format",
    "Only whether TDE is enabled"
  ],
  "correctIndex": 0,
  "explanation": "The right replication choice depends on trade-offs across consistency, geography, cost, and how clients reconnect — not any single factor alone.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan an HA DR strategy for database solutions/README.md",
    "heading": "Begin with business objectives",
    "quote": "Evaluate synchronous versus asynchronous replication, regional separation, operational complexity, cost, failover ownership, and client reconnection behavior."
  }
},
{
  "id": "medium-26",
  "tier": "medium",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan and perform backup and restore of a database",
  "question": "What does point-in-time restore depend on?",
  "options": [
    "Retention and log-chain health",
    "Only the database's compute tier",
    "Only whether TDE is enabled",
    "Only the number of read replicas"
  ],
  "correctIndex": 0,
  "explanation": "Point-in-time restore replays the backup/log chain up to a moment in time, so it's only as good as how far back retention goes and whether that log chain is intact.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan and perform backup and restore of a database/README.md",
    "heading": "Design recoverability",
    "quote": "It is useful for accidental changes but depends on retention and log-chain health."
  }
},
{
  "id": "medium-27",
  "tier": "medium",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan and perform backup and restore of a database",
  "question": "What must be documented as part of a backup strategy, beyond where backups are stored?",
  "options": [
    "Who can restore them and how encryption keys are recovered",
    "Only the backup file naming convention",
    "Only the SQL Server edition in use",
    "Only the available network bandwidth"
  ],
  "correctIndex": 0,
  "explanation": "A backup you can't restore because no one knows who's authorized, or the encryption key is missing, isn't really a usable backup.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan and perform backup and restore of a database/README.md",
    "heading": "Design recoverability",
    "quote": "Document where backups live, who can restore them, and how encryption keys are recovered."
  }
},
{
  "id": "medium-28",
  "tier": "medium",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Configure HA DR for database solutions",
  "question": "What is log shipping, relative to Always On availability groups?",
  "options": [
    "A simpler asynchronous option that restores log backups to a secondary on a schedule",
    "A synchronous, zero-data-loss replication mechanism",
    "A method that requires shared storage and cluster coordination",
    "A feature exclusive to Azure SQL Database"
  ],
  "correctIndex": 0,
  "explanation": "Log shipping trades the sophistication of Always On for simplicity — it just restores log backups to a secondary on a schedule.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Configure HA DR for database solutions/README.md",
    "heading": "Select and configure the mechanism",
    "quote": "Log shipping is a simpler asynchronous option that restores log backups to a secondary on a schedule."
  }
},
{
  "id": "hard-01",
  "tier": "hard",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and deploy Azure SQL solutions",
  "question": "What is true about partitioning a large table?",
  "options": [
    "It supports maintenance and lifecycle operations but doesn't automatically make queries faster",
    "It always improves query performance regardless of filters",
    "It replaces the need for indexing entirely",
    "It requires sharding to be configured first"
  ],
  "correctIndex": 0,
  "explanation": "Partitioning is primarily an operational tool for maintenance and data lifecycle, not a guaranteed performance win unless queries actually filter on the partition key.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and deploy Azure SQL solutions/README.md",
    "heading": "Deploy and maintain",
    "quote": "Partitioning supports maintenance and data lifecycle operations; it does not automatically make every query faster."
  }
},
{
  "id": "hard-02",
  "tier": "hard",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and deploy Azure SQL solutions",
  "question": "When should sharding be used instead of partitioning?",
  "options": [
    "When a single database cannot meet scale, isolation, or geographic requirements",
    "When query plans show missing indexes",
    "When the compression ratio is too low",
    "When SQL Agent jobs are failing"
  ],
  "correctIndex": 0,
  "explanation": "Sharding solves a different problem than partitioning — it's for when one database's capacity, isolation, or geography can't meet requirements at all, not for query tuning.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and deploy Azure SQL solutions/README.md",
    "heading": "Deploy and maintain",
    "quote": "Sharding splits data across independent databases when a single database cannot meet scale, isolation, or geographic requirements."
  }
},
{
  "id": "hard-03",
  "tier": "hard",
  "domain": "Plan and implement data platform resources",
  "module": "Configure resources for scale and performance",
  "question": "Scaling a database's service tier is NOT a substitute for which of the following?",
  "options": [
    "A poor execution plan, missing indexes, or blocking",
    "A missing partition function",
    "An unconfigured firewall rule",
    "A stale backup"
  ],
  "correctIndex": 0,
  "explanation": "Throwing more compute at a workload doesn't fix a bad plan or missing index — those need actual query and indexing work.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Configure resources for scale and performance/README.md",
    "heading": "Scale deliberately",
    "quote": "Scaling is not a substitute for a poor execution plan, missing indexes, or blocking."
  }
},
{
  "id": "hard-04",
  "tier": "hard",
  "domain": "Plan and implement data platform resources",
  "module": "Configure resources for scale and performance",
  "question": "Why should compression be tested with representative data before adopting it broadly?",
  "options": [
    "Because it may increase CPU time for write-intensive tables even though it saves storage and I/O",
    "Because compression disables automatic tuning",
    "Because compression is incompatible with Query Store",
    "Because compression only applies to Managed Instance"
  ],
  "correctIndex": 0,
  "explanation": "Compression trades CPU for storage/I/O savings, and that trade only pays off on the actual workload shape you tested — not universally.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Configure resources for scale and performance/README.md",
    "heading": "Data layout",
    "quote": "Compression reduces storage and I/O at the cost of CPU... Test both with representative data, because compression may increase CPU time for write-intensive tables."
  }
},
{
  "id": "hard-05",
  "tier": "hard",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and implement a migration strategy",
  "question": "For a Managed Instance copy or move scenario, which items specifically must be validated?",
  "options": [
    "Network access, service tier, encryption keys, and login synchronization",
    "Only the storage account SKU",
    "Only the resource group name",
    "Only the SQL Agent job schedules"
  ],
  "correctIndex": 0,
  "explanation": "A Managed Instance copy/move can fail quietly on network reachability, tier mismatches, key access, or unsynced logins if these aren't checked explicitly.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and implement a migration strategy/README.md",
    "heading": "Execute and validate",
    "quote": "For Managed Instance copy or move, validate network access, service tier, encryption keys, and login synchronization."
  }
},
{
  "id": "hard-06",
  "tier": "hard",
  "domain": "Implement a secure environment",
  "module": "Configure database authentication and authorization",
  "question": "What is the recommended order of operations for enabling Entra-based access to a database?",
  "options": [
    "Configure an Entra administrator first, then create contained database users for Entra identities",
    "Create contained database users first, then configure an Entra administrator",
    "Enable SQL authentication first, then disable it once Entra is confirmed working",
    "Grant db_owner to the Entra admin group before creating any users"
  ],
  "correctIndex": 0,
  "explanation": "The Entra administrator is what lets the database recognize Entra identities at all, so it has to exist before contained users can be mapped to them.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Configure database authentication and authorization/README.md",
    "heading": "Authenticate identities",
    "quote": "Configure an Entra administrator first, then create contained database users for Entra users, groups, or service principals."
  }
},
{
  "id": "hard-07",
  "tier": "hard",
  "domain": "Implement a secure environment",
  "module": "Configure database authentication and authorization",
  "question": "When troubleshooting a failed access attempt, which set of factors should be checked?",
  "options": [
    "Connection identity, target database, user mapping, role membership, effective permissions, firewall/network path, and token freshness",
    "Only the firewall rules",
    "Only the SQL Server version",
    "Only the backup retention setting"
  ],
  "correctIndex": 0,
  "explanation": "An access failure can originate at any layer from identity to network to token expiry, so troubleshooting has to walk the whole chain rather than guessing one cause.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Configure database authentication and authorization/README.md",
    "heading": "Authorize with least privilege",
    "quote": "When access fails, verify the connection identity, target database, user mapping, role membership, effective permissions, firewall and network path, and token freshness."
  }
},
{
  "id": "hard-08",
  "tier": "hard",
  "domain": "Implement a secure environment",
  "module": "Implement security for data at rest and data in transit",
  "question": "What is the difference between Private Endpoints and service endpoints for network protection?",
  "options": [
    "Private Endpoints provide a private IP address in a virtual network, while service endpoints extend a VNet identity to a public service",
    "Private Endpoints only work with SQL Managed Instance; service endpoints only with Azure SQL Database",
    "Service endpoints encrypt data in transit; Private Endpoints encrypt data at rest",
    "They are identical features with different names"
  ],
  "correctIndex": 0,
  "explanation": "The two solve network access differently: a Private Endpoint brings the service into your VNet with a private IP, while a service endpoint extends your VNet's identity out to the public service.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement security for data at rest and data in transit/README.md",
    "heading": "Protect data in transit",
    "quote": "Private Endpoints provide a private IP address in a virtual network; service endpoints extend a VNet identity to a public service."
  }
},
{
  "id": "hard-09",
  "tier": "hard",
  "domain": "Implement a secure environment",
  "module": "Implement security for data at rest and data in transit",
  "question": "Why should network restrictions be paired with identity controls rather than relied on alone?",
  "options": [
    "Because neither network restrictions nor identity controls replaces the other",
    "Because network restrictions are deprecated in Azure SQL",
    "Because identity controls only work over unencrypted connections",
    "Because firewall rules automatically grant database permissions"
  ],
  "correctIndex": 0,
  "explanation": "Restricting the network doesn't control who can act once connected, and identity controls don't stop unwanted network reachability — you need both layers.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement security for data at rest and data in transit/README.md",
    "heading": "Protect data in transit",
    "quote": "Pair network restrictions with identity controls—neither replaces the other."
  }
},
{
  "id": "hard-10",
  "tier": "hard",
  "domain": "Implement a secure environment",
  "module": "Implement compliance controls for sensitive data",
  "question": "What is a key limitation of Ledger for compliance purposes?",
  "options": [
    "It does not replace backups, authorization, or a broader compliance program",
    "It cannot be used with Azure SQL Database",
    "It automatically satisfies all regulatory requirements",
    "It replaces the need for Row-Level Security"
  ],
  "correctIndex": 0,
  "explanation": "Ledger proves data integrity through tamper-evident history, but it's one control among many — it doesn't substitute for backups, access control, or the rest of a compliance program.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement compliance controls for sensitive data/README.md",
    "heading": "Limit disclosure",
    "quote": "Ledger provides tamper-evident history for supported Azure SQL scenarios. It can help demonstrate data integrity, but it does not replace backups, authorization, or a broader compliance program."
  }
},
{
  "id": "hard-11",
  "tier": "hard",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor resource activity and performance",
  "question": "Which category of tools is used for engine-level investigation, as opposed to capacity signals?",
  "options": [
    "DMVs, Query Store, and Extended Events",
    "Platform metrics alone",
    "Azure Monitor autoscale rules",
    "Backup retention reports"
  ],
  "correctIndex": 0,
  "explanation": "Platform metrics tell you capacity is stressed; DMVs, Query Store, and Extended Events are what let you dig into the engine to find why.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor resource activity and performance/README.md",
    "heading": "Establish an operational baseline",
    "quote": "Use platform metrics for capacity signals and DMVs, Query Store, and Extended Events for engine-level investigation."
  }
},
{
  "id": "hard-12",
  "tier": "hard",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor resource activity and performance",
  "question": "Besides metrics themselves, what should be tracked alongside them so later changes can be explained?",
  "options": [
    "The workload and configuration",
    "Only the SQL Server build number",
    "Only the storage account tier",
    "Only the number of open connections"
  ],
  "correctIndex": 0,
  "explanation": "A metric spike is hard to explain months later without knowing what workload or configuration was in play at the time it happened.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor resource activity and performance/README.md",
    "heading": "Establish an operational baseline",
    "quote": "Track the workload and configuration alongside metrics so later changes can be explained."
  }
},
{
  "id": "hard-13",
  "tier": "hard",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor and optimize query performance",
  "question": "When reading an execution plan, which direction should you read it and what should you look for?",
  "options": [
    "From the expensive operators outward, looking for estimate-vs-actual differences, spills, scans, key lookups, implicit conversions, and bad joins",
    "From the least expensive operator inward, ignoring estimates",
    "Only at the top-level SELECT operator",
    "Only at index seek operators, ignoring everything else"
  ],
  "correctIndex": 0,
  "explanation": "Starting from the costliest operators and comparing estimated to actual rows is what surfaces the real bottleneck instead of guessing.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor and optimize query performance/README.md",
    "heading": "Diagnose before tuning",
    "quote": "Read execution plans from the expensive operators outward. Look for large estimate-versus-actual differences, spills, scans, key lookups, implicit conversions, and bad join choices."
  }
},
{
  "id": "hard-14",
  "tier": "hard",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor and optimize query performance",
  "question": "Before adding or adjusting an index to fix a slow query, what must be proven?",
  "options": [
    "Its benefit and write cost",
    "That Query Store is disabled",
    "That the table uses page compression",
    "That the database is on a Business Critical tier"
  ],
  "correctIndex": 0,
  "explanation": "Every index adds write cost, so a new index should only be added once its read benefit is shown to outweigh that write overhead.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor and optimize query performance/README.md",
    "heading": "Diagnose before tuning",
    "quote": "Add or adjust indexes only after proving their benefit and write cost."
  }
},
{
  "id": "hard-15",
  "tier": "hard",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Configure database solutions for optimal performance",
  "question": "What is the correct use of Resource Governor?",
  "options": [
    "Limiting resource consumption by workload class for isolation, not for hiding inefficient queries",
    "Automatically rewriting inefficient queries",
    "Replacing the need for index maintenance",
    "Forcing query plans across all databases"
  ],
  "correctIndex": 0,
  "explanation": "Resource Governor caps how much of the server a workload class can consume — it isolates workloads from each other, it doesn't make any single query more efficient.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Configure database solutions for optimal performance/README.md",
    "heading": "Maintain trustworthy metadata",
    "quote": "Resource Governor, where available, limits resource consumption by workload class; it is useful for isolation, not for hiding inefficient queries."
  }
},
{
  "id": "hard-16",
  "tier": "hard",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Configure database solutions for optimal performance",
  "question": "Before raising a database's compatibility level, what should be done?",
  "options": [
    "Regression testing, then measuring the impact on the real workload",
    "Nothing — newer compatibility levels are always safe to apply immediately",
    "Disable Intelligent Query Processing first",
    "Rebuild every index in the database"
  ],
  "correctIndex": 0,
  "explanation": "A higher compatibility level can change plan choices in ways that help some queries and hurt others, so it needs regression testing against the actual workload first.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Configure database solutions for optimal performance/README.md",
    "heading": "Maintain trustworthy metadata",
    "quote": "Keep compatibility levels current only after regression testing, and measure the impact on the real workload."
  }
},
{
  "id": "hard-17",
  "tier": "hard",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage SQL Server Agent jobs",
  "question": "When a job fails, what is the recommended first response?",
  "options": [
    "Inspect job history, step output, SQL error logs, permissions, dependency availability, and schedule state",
    "Immediately rerun the whole job",
    "Disable the job permanently",
    "Escalate to increase the server's compute tier"
  ],
  "correctIndex": 0,
  "explanation": "Diagnosing before reacting avoids masking a real cause (like a permission or dependency issue) behind a job that just gets rerun blindly.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage SQL Server Agent jobs/README.md",
    "heading": "Build reliable jobs",
    "quote": "When a job fails, inspect job history, step output, SQL error logs, permissions, dependency availability, and schedule state."
  }
},
{
  "id": "hard-18",
  "tier": "hard",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage SQL Server Agent jobs",
  "question": "What should you do instead of immediately rerunning a failed job from the start?",
  "options": [
    "Reproduce the failing step with the same execution identity",
    "Grant the job's proxy account sysadmin rights",
    "Change the job's schedule to run more frequently",
    "Delete and recreate the job definition"
  ],
  "correctIndex": 0,
  "explanation": "Rerunning the whole job can hide which specific step and identity actually failed — reproducing just that step isolates the real cause.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage SQL Server Agent jobs/README.md",
    "heading": "Build reliable jobs",
    "quote": "Reproduce the failing step with the same execution identity rather than immediately rerunning the whole job."
  }
},
{
  "id": "hard-19",
  "tier": "hard",
  "domain": "Configure and manage automation of tasks",
  "module": "Automate deployment of database resources",
  "question": "How should infrastructure and database schema deployment be organized?",
  "options": [
    "Separated from each other, but with their dependencies coordinated",
    "Always combined into a single deployment step",
    "Schema deployment first, with infrastructure deployment disabled",
    "Infrastructure deployment only, with schema managed manually"
  ],
  "correctIndex": 0,
  "explanation": "Keeping infra and schema deployments separate makes each easier to reason about, but they still need coordinated ordering since schema depends on the infra existing.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Automate deployment of database resources/README.md",
    "heading": "Use repeatable deployments",
    "quote": "Separate infrastructure deployment from database schema deployment, but coordinate their dependencies."
  }
},
{
  "id": "hard-20",
  "tier": "hard",
  "domain": "Configure and manage automation of tasks",
  "module": "Automate deployment of database resources",
  "question": "When a deployment fails, what should be inspected to diagnose the cause?",
  "options": [
    "The deployment operation list, activity log, resource-provider error, template parameters, policy assignments, quotas, and network dependencies",
    "Only the resource group name",
    "Only the Bicep file's line count",
    "Only the subscription ID"
  ],
  "correctIndex": 0,
  "explanation": "A deployment failure can stem from a quota limit, a policy block, a bad parameter, or a network dependency — the diagnosis has to check all of them, not just re-run and hope.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Automate deployment of database resources/README.md",
    "heading": "Use repeatable deployments",
    "quote": "For failed deployments, inspect the deployment operation list, activity log, resource-provider error, template parameters, policy assignments, quotas, and network dependencies."
  }
},
{
  "id": "hard-21",
  "tier": "hard",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage database tasks in Azure",
  "question": "Before retrying a failed database task, what should be investigated?",
  "options": [
    "Authentication, target-group membership, network rules, concurrency, command timeout, and job history",
    "Only the SQL Server version",
    "Only the Elastic Job agent's region",
    "Only whether the task used a managed identity"
  ],
  "correctIndex": 0,
  "explanation": "A blind retry wastes time if the root cause is a persistent network rule or membership issue rather than a transient blip.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage database tasks in Azure/README.md",
    "heading": "Automate fleet operations",
    "quote": "Investigate authentication, target-group membership, network rules, concurrency, command timeout, and job history before retrying."
  }
},
{
  "id": "hard-22",
  "tier": "hard",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan an HA DR strategy for database solutions",
  "question": "What limitation applies to hybrid HA/DR strategies that combine on-premises SQL Server, Azure VMs, Managed Instance, or Azure SQL Database?",
  "options": [
    "Only supported topology combinations should be selected",
    "Any combination works equally well",
    "Hybrid strategies cannot include Azure SQL Database",
    "Hybrid strategies require Ledger to be enabled"
  ],
  "correctIndex": 0,
  "explanation": "Not every mix of on-prem and Azure components is actually a supported replication topology, so the design has to be checked against what's supported, not assumed.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan an HA DR strategy for database solutions/README.md",
    "heading": "Begin with business objectives",
    "quote": "Hybrid strategies may combine on-premises SQL Server, Azure VMs, Managed Instance, or Azure SQL Database, but only supported topology combinations should be selected."
  }
},
{
  "id": "hard-23",
  "tier": "hard",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan an HA DR strategy for database solutions",
  "question": "What should be recorded after testing an HA/DR runbook, and what should happen if the objective is missed?",
  "options": [
    "Record actual recovery time and data-loss exposure, then revise the design if it misses the objective",
    "Record only whether the failover technically completed",
    "Nothing further is needed once a failover test succeeds once",
    "Immediately switch to a different Azure region without further testing"
  ],
  "correctIndex": 0,
  "explanation": "A failover that \"worked\" but took longer than the RTO or lost more data than the RPO allows is a design gap that needs to be fed back into revising the strategy.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan an HA DR strategy for database solutions/README.md",
    "heading": "Begin with business objectives",
    "quote": "Record actual recovery time and data-loss exposure, then revise the design if it misses the objective."
  }
},
{
  "id": "hard-24",
  "tier": "hard",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan and perform backup and restore of a database",
  "question": "When using cloud storage for native backups, what should be validated and protected?",
  "options": [
    "Secure the identity and storage access, validate throughput, and protect backup files with encryption and immutable or retained storage where appropriate",
    "Only the storage account's redundancy tier",
    "Only the container's public access setting",
    "Only the backup compression ratio"
  ],
  "correctIndex": 0,
  "explanation": "Backups stored in the cloud carry their own risk surface — identity, throughput, encryption, and immutability all need to be deliberately configured, not assumed.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan and perform backup and restore of a database/README.md",
    "heading": "Design recoverability",
    "quote": "When using cloud storage, secure the identity and storage access, validate throughput, and protect backup files with encryption and immutable or retained storage where appropriate."
  }
},
{
  "id": "hard-25",
  "tier": "hard",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan and perform backup and restore of a database",
  "question": "What should teams do when a compliance policy requires backups to be retained beyond the platform's default window?",
  "options": [
    "Configure long-term retention, understanding the service-specific restore options",
    "Rely on point-in-time restore alone, since it covers any retention period",
    "Disable platform-managed backups and rely only on manual T-SQL backups",
    "Reduce backup frequency to save on storage cost"
  ],
  "correctIndex": 0,
  "explanation": "Point-in-time restore is bounded by normal retention, so meeting a longer compliance window means explicitly configuring long-term retention and understanding how restoring from it differs.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan and perform backup and restore of a database/README.md",
    "heading": "Design recoverability",
    "quote": "Azure SQL services provide platform-managed backups; configure long-term retention when policy requires it and understand the service-specific restore options."
  }
},
{
  "id": "hard-26",
  "tier": "hard",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Configure HA DR for database solutions",
  "question": "What must be planned before testing failover for active geo-replication or failover groups?",
  "options": [
    "DNS and connection-string behavior",
    "Only the backup retention policy",
    "Only the storage redundancy tier",
    "Only the SQL Server Agent job schedule"
  ],
  "correctIndex": 0,
  "explanation": "A failover can succeed at the database layer and still break the application if clients don't reconnect correctly through DNS or the connection string.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Configure HA DR for database solutions/README.md",
    "heading": "Select and configure the mechanism",
    "quote": "Plan DNS and connection-string behavior before testing failover."
  }
},
{
  "id": "hard-27",
  "tier": "hard",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Configure HA DR for database solutions",
  "question": "On Azure VMs, what must be carefully designed for both Always On availability groups and Failover Cluster Instances?",
  "options": [
    "Quorum, networking, load balancing, storage, and domain dependencies",
    "Only the VM's disk throughput",
    "Only the SQL Server edition",
    "Only the backup compression setting"
  ],
  "correctIndex": 0,
  "explanation": "Both mechanisms depend on cluster infrastructure — quorum, networking, storage, and domain — which on IaaS VMs is the team's own responsibility to design correctly.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Configure HA DR for database solutions/README.md",
    "heading": "Select and configure the mechanism",
    "quote": "On Azure VMs, both require careful design of quorum, networking, load balancing, storage, and domain dependencies."
  }
},
{
  "id": "usecase-01",
  "tier": "usecase",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and deploy Azure SQL solutions",
  "question": "A company runs an operational database that needs to automatically mirror data into OneLake for immediate analytics in Fabric. Which service fits this scenario?",
  "options": [
    "SQL Database in Microsoft Fabric",
    "Azure SQL Managed Instance",
    "SQL Server on Azure Virtual Machines",
    "Azure Arc-enabled SQL Server"
  ],
  "correctIndex": 0,
  "explanation": "SQL Database in Fabric is purpose-built to keep transactional data operational while continuously mirroring it into OneLake for analytics.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and deploy Azure SQL solutions/README.md",
    "heading": "Choose the right SQL platform",
    "quote": "SQL Database in Microsoft Fabric is an operational database that automatically mirrors data into OneLake; it suits applications that need transactional data and immediate Fabric analytics."
  }
},
{
  "id": "usecase-02",
  "tier": "usecase",
  "domain": "Plan and implement data platform resources",
  "module": "Configure resources for scale and performance",
  "question": "A large sales table is partitioned by month to support fast archiving of old data. What must be true for this design to work well?",
  "options": [
    "Clustered indexes and the partition function are aligned, and important queries filter on the partition key",
    "The table must use page compression exclusively",
    "The database must run on SQL Server on Azure VMs",
    "Read scale-out replicas must be enabled"
  ],
  "correctIndex": 0,
  "explanation": "Partition switching for archiving only works cleanly when the clustered index and partition function agree, and queries actually benefit only if they filter on that same key.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Configure resources for scale and performance/README.md",
    "heading": "Data layout",
    "quote": "Align clustered indexes and partition functions, and use partition switching for fast archive or load operations. Confirm that important queries filter on the partition key."
  }
},
{
  "id": "usecase-03",
  "tier": "usecase",
  "domain": "Plan and implement data platform resources",
  "module": "Plan and implement a migration strategy",
  "question": "A company is migrating a production database and wants to minimize downtime while still monitoring for issues before the final cutover. Which migration strategy and practice should they follow?",
  "options": [
    "Use an online migration, closely monitoring replication latency and schema changes until final synchronization",
    "Use an offline migration and skip rehearsal to save time",
    "Delete the source database immediately after copying data",
    "Use an online migration but skip row-count validation after cutover"
  ],
  "correctIndex": 0,
  "explanation": "An online migration is what minimizes downtime, but that benefit only holds up if latency and schema drift are actively monitored right up to the final sync.",
  "source": {
    "path": "dp300/content/Plan and implement data platform resources/Plan and implement a migration strategy/README.md",
    "heading": "Assess before moving",
    "quote": "It minimizes downtime but needs careful monitoring of latency, schema changes, and final synchronization."
  }
},
{
  "id": "usecase-04",
  "tier": "usecase",
  "domain": "Implement a secure environment",
  "module": "Configure database authentication and authorization",
  "question": "An application team wants a cohesive permission boundary for a set of related tables and stored procedures without granting broad server-wide roles. What approach fits best?",
  "options": [
    "Prefer schema-level permissions for the application's objects",
    "Grant db_owner to the application's service principal",
    "Use only server-level logins with sysadmin",
    "Disable authorization checks for the application's connection"
  ],
  "correctIndex": 0,
  "explanation": "Schema-level permissions give the application a coherent boundary around its own objects without the blast radius of a fixed role like db_owner.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Configure database authentication and authorization/README.md",
    "heading": "Authorize with least privilege",
    "quote": "Prefer schema-level permissions for a cohesive application boundary; avoid broad fixed roles such as `db_owner`."
  }
},
{
  "id": "usecase-05",
  "tier": "usecase",
  "domain": "Implement a secure environment",
  "module": "Implement security for data at rest and data in transit",
  "question": "A team needs to encrypt specific highly sensitive columns so that even the database engine cannot view the plaintext, while still allowing equality comparisons in WHERE clauses. Which feature and configuration fits?",
  "options": [
    "Always Encrypted with deterministic encryption",
    "Transparent Data Encryption with a customer-managed key",
    "Dynamic Data Masking",
    "Row-Level Security with a predicate function"
  ],
  "correctIndex": 0,
  "explanation": "Always Encrypted keeps plaintext away from the engine entirely, and deterministic encryption is specifically what preserves the ability to do equality lookups on those columns.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement security for data at rest and data in transit/README.md",
    "heading": "Protect data at rest",
    "quote": "Always Encrypted protects selected columns so the database engine cannot view plaintext. Use deterministic encryption only when equality lookups are required..."
  }
},
{
  "id": "usecase-06",
  "tier": "usecase",
  "domain": "Implement a secure environment",
  "module": "Implement compliance controls for sensitive data",
  "question": "A compliance team wants sensitive columns identified consistently across teams so that permissions, encryption, and auditing decisions can be applied consistently. What should they implement first?",
  "options": [
    "Classify columns by sensitivity and business purpose",
    "Enable Dynamic Data Masking on every column",
    "Deploy Ledger on all tables",
    "Disable change tracking"
  ],
  "correctIndex": 0,
  "explanation": "Classification is the foundation everything else builds on — without a consistent label for sensitivity, permissions and auditing decisions end up applied inconsistently.",
  "source": {
    "path": "dp300/content/Implement a secure environment/Implement compliance controls for sensitive data/README.md",
    "heading": "Discover and govern sensitive data",
    "quote": "Classify columns by sensitivity and business purpose so teams can apply consistent handling, retention, and access controls."
  }
},
{
  "id": "usecase-07",
  "tier": "usecase",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor resource activity and performance",
  "question": "An operations team receives a vague report that \"the database is slow\" but has no prior performance data to compare against. What should they have done in advance to make this actionable?",
  "options": [
    "Captured a baseline of normal CPU, I/O, memory, waits, connections, query duration, and error rates during representative periods",
    "Disabled Extended Events to reduce overhead",
    "Relied solely on transient alert spikes",
    "Waited until the next scheduled maintenance window"
  ],
  "correctIndex": 0,
  "explanation": "Without a captured baseline, there's no \"normal\" to compare the current state against, which is exactly why a vague \"slow\" report is hard to act on.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor resource activity and performance/README.md",
    "heading": "Establish an operational baseline",
    "quote": "Capture normal CPU, data and log I/O, memory, waits, connections, query duration, and error rates during representative periods."
  }
},
{
  "id": "usecase-08",
  "tier": "usecase",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Monitor and optimize query performance",
  "question": "A DBA notices Intelligent Insights flagged a query regression. What should they do before acting on the recommendation?",
  "options": [
    "Validate its recommendations with workload evidence",
    "Immediately force the plan Intelligent Insights suggests without review",
    "Disable Query Store to confirm the issue disappears",
    "Kill all sessions currently running that query"
  ],
  "correctIndex": 0,
  "explanation": "Intelligent Insights is a symptom detector, not a verified fix — its suggestions still need to be checked against actual workload evidence before acting.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Monitor and optimize query performance/README.md",
    "heading": "Diagnose before tuning",
    "quote": "Intelligent Insights can highlight symptoms, but validate its recommendations with workload evidence."
  }
},
{
  "id": "usecase-09",
  "tier": "usecase",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Configure database solutions for optimal performance",
  "question": "A platform team wants to apply verified performance corrections like plan forcing or index recommendations automatically, but with oversight. What should they configure and what governance should follow?",
  "options": [
    "Enable automatic tuning on supported services and review its actions under an explicit operational policy",
    "Enable Resource Governor to auto-tune queries",
    "Force every execution plan captured in Query Store",
    "Rebuild every index nightly regardless of fragmentation"
  ],
  "correctIndex": 0,
  "explanation": "Automatic tuning is designed to apply verified corrections on its own, but that autonomy is exactly why its actions still need review under an explicit policy.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Configure database solutions for optimal performance/README.md",
    "heading": "Maintain trustworthy metadata",
    "quote": "Automatic tuning can apply verified corrections, such as plan forcing or index recommendations, on supported services. Review its actions and set an explicit operational policy."
  }
},
{
  "id": "usecase-10",
  "tier": "usecase",
  "domain": "Monitor, configure, and optimize database resources",
  "module": "Configure database solutions for optimal performance",
  "question": "A team manages multiple databases on the same server and wants to tune behavior for just one database without affecting the others. What should they use?",
  "options": [
    "Database-scoped configuration",
    "A Resource Governor workload classifier",
    "A server-level compatibility level change",
    "Elastic Jobs"
  ],
  "correctIndex": 0,
  "explanation": "Database-scoped configuration exists precisely to let one database's behavior be tuned in isolation, instead of a server-wide setting that would affect every database.",
  "source": {
    "path": "dp300/content/Monitor, configure, and optimize database resources/Configure database solutions for optimal performance/README.md",
    "heading": "Maintain trustworthy metadata",
    "quote": "Database-scoped configuration lets you tune behavior per database without changing the whole server."
  }
},
{
  "id": "usecase-11",
  "tier": "usecase",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage SQL Server Agent jobs",
  "question": "A team wants job definitions to survive server rebuilds and be reviewable through change history. What practice should they adopt?",
  "options": [
    "Store job definitions in source control or a repeatable deployment process",
    "Keep job definitions only inside the msdb database with no external record",
    "Recreate jobs manually after every server rebuild",
    "Disable job history to reduce storage usage"
  ],
  "correctIndex": 0,
  "explanation": "A job that only lives in msdb disappears with the server; treating job definitions as versioned code is what makes them survivable and reviewable.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage SQL Server Agent jobs/README.md",
    "heading": "Build reliable jobs",
    "quote": "Store job definitions in source control or a repeatable deployment process."
  }
},
{
  "id": "usecase-12",
  "tier": "usecase",
  "domain": "Configure and manage automation of tasks",
  "module": "Automate deployment of database resources",
  "question": "An organization wants automation identities used in CI/CD pipelines to follow least privilege. What should they do when granting these identities access?",
  "options": [
    "Grant automation identities only the permissions required for their resource scope",
    "Grant the Owner role at the subscription level for simplicity",
    "Use a shared sysadmin SQL login for all pipelines",
    "Disable Azure Policy checks for the automation identity"
  ],
  "correctIndex": 0,
  "explanation": "A pipeline identity with subscription-wide Owner access is a bigger risk than the convenience is worth — scoping it to just what the deployment needs limits the exposure.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Automate deployment of database resources/README.md",
    "heading": "Use repeatable deployments",
    "quote": "Grant automation identities only the permissions required for their resource scope."
  }
},
{
  "id": "usecase-13",
  "tier": "usecase",
  "domain": "Configure and manage automation of tasks",
  "module": "Create and manage database tasks in Azure",
  "question": "A team's retry logic keeps retrying a script that always fails due to a syntax error, wasting time on every scheduled run. What should their retry policy do differently?",
  "options": [
    "Distinguish transient platform failures from deterministic script errors",
    "Always retry every failure the same fixed number of times",
    "Disable retries entirely for all tasks",
    "Increase the command timeout until the script succeeds"
  ],
  "correctIndex": 0,
  "explanation": "Retrying a deterministic script bug will never succeed no matter how many times it runs — the retry policy needs to tell that case apart from a genuinely transient failure.",
  "source": {
    "path": "dp300/content/Configure and manage automation of tasks/Create and manage database tasks in Azure/README.md",
    "heading": "Automate fleet operations",
    "quote": "A retry policy should distinguish transient platform failures from deterministic script errors."
  }
},
{
  "id": "usecase-14",
  "tier": "usecase",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan an HA DR strategy for database solutions",
  "question": "A business defines a maximum acceptable downtime and a maximum acceptable data loss for a critical database, but hasn't yet tested how failover actually behaves for the application. What should they do next?",
  "options": [
    "Test the runbook regularly, including planned and unplanned failover, restore validation, application connection behavior, data consistency checks, and failback",
    "Assume the design meets objectives since RPO/RTO were defined on paper",
    "Skip testing and proceed directly to a production cutover",
    "Rely only on vendor documentation instead of testing their own environment"
  ],
  "correctIndex": 0,
  "explanation": "RPO/RTO targets on paper mean nothing until the runbook is actually tested end-to-end, including how the application behaves through a real failover.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan an HA DR strategy for database solutions/README.md",
    "heading": "Begin with business objectives",
    "quote": "Test the runbook regularly. Include planned and unplanned failover, restore validation, application connection behavior, data consistency checks, and failback."
  }
},
{
  "id": "usecase-15",
  "tier": "usecase",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Plan and perform backup and restore of a database",
  "question": "A team accidentally deleted a large number of rows a few hours ago and needs to recover the database to just before that change, without losing more recent unrelated data. Which capability addresses this, and what does it depend on?",
  "options": [
    "Point-in-time restore, which depends on retention and log-chain health",
    "A geo-replication failover, which depends on DNS propagation",
    "Dynamic Data Masking, which depends on user permissions",
    "Elastic Jobs, which depends on target-group membership"
  ],
  "correctIndex": 0,
  "explanation": "Point-in-time restore is built for exactly this — rolling back to a moment before an accidental change — but it only works as far back as retention and an unbroken log chain allow.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Plan and perform backup and restore of a database/README.md",
    "heading": "Design recoverability",
    "quote": "Point-in-time restore uses the available backup history to return a database to a chosen time before a failure. It is useful for accidental changes but depends on retention and log-chain health."
  }
},
{
  "id": "usecase-16",
  "tier": "usecase",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Configure HA DR for database solutions",
  "question": "After a failover event completes successfully, what should the team do before considering the incident resolved?",
  "options": [
    "Validate data and application health after failover, and plan a safe failback rather than treating the role change as completion",
    "Immediately decommission the original primary",
    "Disable monitoring since the failover succeeded",
    "Skip validation since failover groups are fully automated"
  ],
  "correctIndex": 0,
  "explanation": "A completed role change isn't the same as a healthy application — validating data and connectivity, and planning a safe failback, is what actually closes out the incident.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Configure HA DR for database solutions/README.md",
    "heading": "Select and configure the mechanism",
    "quote": "During an incident, follow the tested runbook, validate data and application health after failover, and plan safe failback rather than treating the first successful role change as completion."
  }
},
{
  "id": "usecase-17",
  "tier": "usecase",
  "domain": "Plan and configure a high availability and disaster recovery (HA DR) environment",
  "module": "Configure HA DR for database solutions",
  "question": "A team needs readable secondary databases for reporting offload on Azure SQL Database, with coordinated failover for a group of related databases and predictable DNS behavior for client apps. Which combination of features fits best?",
  "options": [
    "Active geo-replication combined with failover groups",
    "Failover Cluster Instances on Azure VMs",
    "Log shipping to an on-premises secondary",
    "Elastic Jobs distributing read queries across databases"
  ],
  "correctIndex": 0,
  "explanation": "Active geo-replication supplies the readable secondaries, and failover groups add the coordinated, DNS-stable endpoint on top — together they cover both requirements.",
  "source": {
    "path": "dp300/content/Plan and configure a high availability and disaster recovery (HA DR) environment/Configure HA DR for database solutions/README.md",
    "heading": "Select and configure the mechanism",
    "quote": "Active geo-replication creates readable secondary databases for supported Azure SQL Database scenarios. Failover groups provide a listener-style endpoint and coordinated failover for a group of databases."
  }
}
];
