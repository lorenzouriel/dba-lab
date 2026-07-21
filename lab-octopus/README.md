# Octopus Lab — dacpac CI/CD with Octopus Deploy

Deploys this lab's SSDT project (`db/`) through Octopus Deploy using the dacpac workflow: build → package → push → deploy through environments.

## Prerequisites

- **dba-lab running** — SQL Server instances must be up (`..\ag-&-cicd-lab\dba-lab.ps1 up` + `init`)
- **Visual Studio with SSDT** — builds `.sqlproj` into `.dacpac`
- **sqlpackage** — installed globally (`dotnet tool install -g microsoft.sqlpackage`)
- **OctopusTools** — for `octo pack/push` (`dotnet tool install -g OctopusTools`)
- **Octopus license** — free Community Edition at octopus.com

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Docker Network (dba-lab)                      │
│                                                                      │
│  ┌─────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐          │
│  │ sql-dev  │  │sql-staging│  │sql-prod-1 │◄►│sql-prod-2 │          │
│  │  :1401   │  │  :1402    │  │  :1403    │AG│  :1404    │          │
│  └─────────┘  └───────────┘  └───────────┘  └───────────┘          │
│       ▲             ▲             ▲                                   │
│       │             │             │                                   │
│       └─────────────┴─────────────┘                                  │
│                     │                                                │
│             ┌───────────────┐                                        │
│             │ Octopus Deploy│    ← octopus-lab containers            │
│             │    :8080      │                                        │
│             └───────┬───────┘                                        │
│             ┌───────┴───────┐                                        │
│             │  octopus-db   │                                        │
│             │    :1400      │                                        │
│             └───────────────┘                                        │
└─────────────────────────────────────────────────────────────────────┘

Pipeline:
  .sqlproj → dacpac → nupkg → Octopus feed → Deploy: Dev → Staging → Prod
```

## Quick Start

```powershell
# 1. Start dba-lab first
cd ..\ag-&-cicd-lab
.\dba-lab.ps1 up
.\dba-lab.ps1 init
.\dba-lab.ps1 ag
cd ..\octopus-lab

# 2. Configure
Copy-Item .env.example .env    # edit passwords + license key

# 3. Start Octopus (~2 min to initialize)
.\octopus-lab.ps1 up

# 4. First-time setup in browser
#    Open http://localhost:8080
#    Login with ADMIN_USERNAME / ADMIN_PASSWORD
#    Profile → API Keys → New API Key → copy to .env as OCTOPUS_API_KEY

# 5. Configure environments + project
.\octopus-lab.ps1 setup

# 6. Build, package, push
.\octopus-lab.ps1 build
.\octopus-lab.ps1 pack
.\octopus-lab.ps1 push

# 7. Create release + deploy in Octopus UI (http://localhost:8080)
```

## Deployment Process

Octopus runs these steps per environment:

| # | Step | What It Does |
|---|------|-------------|
| 1 | **Script** | `sqlpackage /Action:Script` — generates diff SQL, attaches as artifact for DBA review |
| 2 | **Publish AppDB** | `sqlpackage /Action:Publish` — applies dacpac delta to AppDB |
| 3 | **Post-Deploy** | Runs idempotent migration scripts (seed data) |
| 4 | **Verify** | Queries sys.tables/procedures/views, logs object counts |

## Lifecycle

```
Dev (auto) → Staging (manual gate) → Production (DBA sign-off)
                                          └→ AG replicates to secondary
```

## Port Map

| Service | Port | Purpose |
|---------|------|---------|
| octopus-server | 8080 | Octopus Deploy UI |
| octopus-db | 1400 | Octopus internal DB |

## CLI Commands

| Command | What It Does |
|---------|-------------|
| `.\octopus-lab.ps1 up` | Start Octopus (DB + Server) |
| `.\octopus-lab.ps1 down` | Stop Octopus containers |
| `.\octopus-lab.ps1 clean` | Stop + remove Octopus volumes |
| `.\octopus-lab.ps1 setup` | Configure environments, lifecycle, project |
| `.\octopus-lab.ps1 build` | Build dacpac from `db/` SSDT projects |
| `.\octopus-lab.ps1 pack` | Package dacpac into .nupkg |
| `.\octopus-lab.ps1 push` | Push .nupkg to Octopus built-in feed |
