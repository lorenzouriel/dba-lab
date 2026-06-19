# DBA Lab — SQL Server CI/CD with Always On AG

A portfolio project that simulates a production database CI/CD pipeline using Docker, SQL Server Always On Availability Groups, and SSDT schema-as-code.

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        Docker Network                            │
│                                                                  │
│  ┌─────────┐   ┌───────────┐   ┌───────────┐   ┌───────────┐   │
│  │ sql-dev  │   │sql-staging│   │sql-prod-1 │◄─►│sql-prod-2 │   │
│  │  :1401   │   │  :1402    │   │  :1403    │AG │  :1404    │   │
│  │          │   │           │   │  PRIMARY  │   │ SECONDARY │   │
│  └─────────┘   └───────────┘   └───────────┘   └───────────┘   │
└──────────────────────────────────────────────────────────────────┘

Pipeline: Dev → Staging → Prod (AG replicates to secondary)
```

## What This Demonstrates

| Concept | Implementation |
|---------|---------------|
| **SSDT / dacpac model** | SSDT project (`db.sqlproj`) — build produces `.dacpac` artifact |
| **Always On AG** | Certificate-based AG between prod-1 and prod-2, `CLUSTER_TYPE=NONE` |
| **CI/CD pipeline** | Dev → Staging → Prod lifecycle with manual promotion gates |
| **Schema deployment** | `msbuild` → `.dacpac` → `SqlPackage /Action:Publish` — automated diff and deploy |
| **Cross-env validation** | Drift detection script compares schema across all environments |
| **Failover** | Manual failover script with pre/post status checks |

## Quick Start

### 1. Start Infrastructure

```powershell
Copy-Item .env.example .env
# Edit .env with your passwords

.\dba-lab.ps1 up
```

### 2. Initialize Databases

```powershell
.\dba-lab.ps1 init
```

Builds `db.sqlproj` via MSBuild, then publishes the `.dacpac` to all four instances using `SqlPackage`. Creates the database if it doesn't exist.

### 3. Set Up Availability Group

```powershell
.\dba-lab.ps1 ag
```

Configures AG between sql-prod-1 (primary) and sql-prod-2 (secondary):
- Certificate-based authentication (no Active Directory)
- Synchronous commit with automatic seeding
- Secondary allows read-only connections

### 4. Deploy Pipeline

Each deploy runs: `msbuild` (build dacpac) → `SqlPackage /Action:Script` (preview diff) → `SqlPackage /Action:Publish` (apply) → verify.

```powershell
# Deploy to individual environments
.\dba-lab.ps1 deploy-dev
.\dba-lab.ps1 deploy-staging
.\dba-lab.ps1 deploy-prod

# Or run the full pipeline with promotion gates
.\dba-lab.ps1 deploy-all
```

Diff scripts are saved to `scripts/deploy/output/` for review.

### 5. Test Failover

```powershell
# Check current AG status
.\dba-lab.ps1 status

# Failover from prod-1 to prod-2
.\dba-lab.ps1 failover
```

## Project Structure

```
dba-lab/
├── docker-compose.yml              # 4 SQL Server instances
├── .env.example                    # Configuration template
├── dba-lab.ps1                     # CLI entry point (PowerShell)
│
├── db/                             # SSDT solution (Visual Studio)
│   ├── db.sln                      # Solution file
│   ├── db.sqlproj                  # AppDB project (SQL Server 2019 / Sql150)
│   ├── Tables/                     # Folder, User, Session, SessionAccess
│   ├── StoredProcedures/           # getSessionById, getSessionsByFolder
│   ├── Views/                      # vwActiveSessions
│   └── PostDeployment/             # Script.PostDeployment.sql + migrations
│
├── scripts/
│   ├── init/                       # Wait-for-SQL + dacpac init on all instances
│   ├── ag/                         # AG setup, failover, status
│   └── deploy/                     # msbuild + SqlPackage dacpac deployment
│       └── output/                 # Generated diff scripts (gitignored)
│
├── octopus-lab/                    # Octopus Deploy CI/CD lab
├── aws-lab/                        # AWS EC2 AG lab (planned)
├── azure-lab/                      # Azure DevOps + SQL MI (planned)
├── gcp-lab/                        # GCP Cloud SQL (planned)
│
└── docs/                           # Setup guides + architecture
```

## Port Map

| Service | Port | Purpose |
|---------|------|---------|
| sql-dev | 1401 | Dev environment |
| sql-staging | 1402 | Staging environment |
| sql-prod-1 | 1403 | Production primary |
| sql-prod-2 | 1404 | Production secondary (read-only) |

## Connecting via SSMS

```
Server: localhost,1401    (Dev)
Server: localhost,1402    (Staging)
Server: localhost,1403    (Prod Primary)
Server: localhost,1404    (Prod Secondary - read only)

Login: sa
Password: (from .env)
```

## How AG Works in This Lab

```
                Certificate Auth (port 5022)
sql-prod-1 ◄════════════════════════════════════► sql-prod-2
 (PRIMARY)         Synchronous Commit              (SECONDARY)
                   Automatic Seeding
                   Read-Only Secondary
```

- `CLUSTER_TYPE = NONE` — no Windows Failover Cluster needed
- Certificate-based endpoint authentication — no Active Directory
- `MSSQL_ENABLE_HADR=1` environment variable enables AG support
- Shared Docker volume (`ag-shared`) for certificate exchange between nodes
- Schema changes deploy to primary only — AG replicates automatically

## Design Decisions

### Why CLUSTER_TYPE = NONE?

Docker containers don't have Windows Server Failover Clustering. `CLUSTER_TYPE = NONE` creates a read-scale AG that works without WSFC or Pacemaker. Failover is manual (`FORCE_FAILOVER_ALLOW_DATA_LOSS`), which matches the controlled deployment model.

### Why Developer Edition?

SQL Server Developer Edition includes all Enterprise features (AG, columnstore, compression) but is free and licensed for non-production use. Perfect for a lab.

### Why dacpac Instead of Raw SQL Scripts?

A `.dacpac` is a compiled schema snapshot. `SqlPackage` compares it to the target database and generates only the delta — CREATE, ALTER, or DROP as needed. No hardcoded object lists, no "object already exists" errors, no manual ordering. Add a `.sql` file to the project and it deploys automatically.

### Why Deploy to Primary Only?

AG replicates data changes automatically. Schema changes (DDL) propagate through AG replication, so deploying to the primary is sufficient. The validation script confirms both nodes have identical schema.

## Roadmap

Each lab builds on the shared `db/` SSDT projects — one schema, multiple deployment targets:

```
dba-lab/
├── db/                  # Shared SSDT schema (source of truth for all labs)
│
├── octopus-lab/         # Octopus Deploy CI/CD with dacpac
│                          Build .sqlproj → .dacpac → package → Octopus feed
│                          SCRIPT (diff preview) → PUBLISH → verify
│                          Dev → Staging → Production lifecycle with gates
│
├── aws-lab/             # AWS EC2 with WSFC + AG
│                          VPC, private subnets, 2-AZ deployment
│                          Windows Server Failover Cluster (no AD)
│                          Multi-subnet AG listener, automatic failover
│
├── azure-lab/           # Azure DevOps + Azure SQL
│                          Azure DevOps pipelines with dacpac tasks
│                          Azure SQL Managed Instance or VM-based AG
│                          ARM/Bicep templates for infrastructure
│
└── gcp-lab/             # GCP Cloud SQL
│                          Cloud SQL for SQL Server
│                          Cloud Build pipelines
│                          Terraform for infrastructure
```

Each lab has its own `README.md`, setup guide (HTML), docker-compose (if applicable), and CLI entry point. The `db/` directory is never duplicated — all labs reference it directly.
