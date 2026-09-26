# sqlserver-lab
SQL Server 2025 (Developer) lab in Docker for DP-800 — *Developing AI-Enabled
Database Solutions*. No SQL Server installed on the host.

## Architecture
| Instance | Port | Profile   | Notes                    |
|----------|------|-----------|---------------------------|
| prod1    | 1401 | (default) | AG primary, always up     |
| prod2    | 1402 | `ha`      | AG secondary, read-only   |
| dev      | 1403 | `dev`     | standalone, no AG         |
| staging  | 1404 | `staging` | standalone, no AG         |

prod1/prod2 form the `ag1` availability group (see Use case 2). dev and
staging are independent standalone instances — bring them up only when
you need them.

## Layout
```
sqlserver-lab/
├── docker-compose.yml       prod1 + bootstrap-prod1; prod2 behind the ha
│                             profile; dev behind the dev profile; staging
│                             behind the staging profile
├── .env.example             copy to .env — SA password, ports, memory
├── .gitignore                keeps .env and .bak out of git
├── scripts/
│   ├── 00-bootstrap.sql     instance config, runs on every `up` (per instance)
│   ├── 01-restore.sql       restore a .bak, auto-derives MOVE targets
│   ├── 10-ai-model.sql      external model + vector column patterns (Azure OpenAI)
│   └── 20-ag-setup.sql      cert-based HADR endpoints + read-only availability group
├── restore/                 ← drop .bak files here (mounted read-only)
├── backups/                 ← BACKUP DATABASE writes here
└── data_gen/                Python fin_pulse test data generator (see data_gen/README.md)
```

## One-time setup
```powershell
Copy-Item .env.example .env
New-Item -ItemType Directory -Force -Path restore, backups | Out-Null

# image runs non-root as uid 10001; fix ownership on the bind mounts via a
# throwaway container (no native chown on Windows)
docker run --rm -v "${PWD}:/data" busybox sh -c "chown -R 10001:0 /data/backups /data/restore && chmod 775 /data/backups"

notepad .env   # set MSSQL_SA_PASSWORD
```

Every session, load `.env` into the current PowerShell tab before running any
`sqlcmd`/`$env:` command below — `docker compose` reads `.env` on its own for
compose-file substitution, but the raw `sqlcmd` calls need it as a real
environment variable too:

```powershell
Get-Content .env | Where-Object { $_ -match '^\s*[^#].+?=' } | ForEach-Object {
    $name, $value = $_ -split '=', 2
    [Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim())
}
```

---

## Use case 1 — prod1: start, restore, back up
```powershell
docker compose up -d prod1               # start
docker compose up bootstrap-prod1        # one-shot instance config (safe to re-run)
```

Connect from SSMS / Azure Data Studio / DBeaver: `localhost,1401`, user `sa`,
**Trust server certificate = on** (the instance uses a self-signed cert). Or
from the shell:

```powershell
docker compose exec prod1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$env:MSSQL_SA_PASSWORD" -C
```

**Restore a database.** Drop `billing.bak` into `./restore/`, then:

```powershell
$env:SEED_DB = "billing"; $env:SEED_BAK = "billing.bak"
docker compose --profile seed run --rm seed
```

`01-restore.sql` reads the backup header and generates the `MOVE` clauses, so
Windows-authored backups with `C:\` paths restore cleanly. It also forces
compat level 170 and turns on Query Store and preview features. `seed`
targets prod1 by default — set `$env:SEED_TARGET` to `dev` or `staging` to
restore into those instead.

**Back up a database.** `BACKUP DATABASE` can't target the bind-mounted
`./backups/` folder directly on Docker Desktop for Windows (see *Why*
below), so back up into the `prod1-data` named volume and copy the file out:

```powershell
$env:DB = "billing"
docker compose exec prod1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$env:MSSQL_SA_PASSWORD" -C -b -Q `
  "BACKUP DATABASE [$env:DB] TO DISK='/var/opt/mssql/data/$env:DB.bak' WITH INIT, COMPRESSION, STATS=10"
docker compose cp prod1:/var/opt/mssql/data/$env:DB.bak ./backups/$env:DB.bak
docker compose exec prod1 rm -f /var/opt/mssql/data/$env:DB.bak
```

---

## Use case 2 — prod2 + Availability Group, read-only
Two independent containers, no domain and no WSFC/Pacemaker, so this brings
up a `CLUSTER_TYPE = NONE` AG (manual failover only) using certificate-based
endpoint auth. `20-ag-setup.sql` hops between both instances with sqlcmd's
`:CONNECT`, exchanges HADR certs, opens the mirroring endpoints, creates
`ag1` with automatic seeding, and configures prod2 as a
`SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY)` replica with a read-only
routing list — no manual backup/restore step needed for the AG database
itself.

```powershell
docker compose --profile ha up -d prod2         # bring up the secondary, localhost,1402
docker compose --profile ha run --rm ag-setup   # certs, endpoints, create + join ag1, read-only routing
```

`ag-setup` creates a small `agdb` database if one doesn't already exist
(override with `$env:AGDB = "yourdb"` before running, as long as that
database exists and is reachable on prod1). Seeding runs asynchronously —
check sync state:

```powershell
docker compose exec prod1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$env:MSSQL_SA_PASSWORD" -C -Q `
  "SELECT ag.name, r.replica_server_name, rs.role_desc, drs.synchronization_state_desc, drs.is_local FROM sys.availability_groups ag JOIN sys.availability_replicas r ON ag.group_id = r.group_id JOIN sys.dm_hadr_availability_replica_states rs ON r.replica_id = rs.replica_id LEFT JOIN sys.dm_hadr_database_replica_states drs ON drs.replica_id = rs.replica_id;"
```

`role_desc` shows `PRIMARY`/`SECONDARY`; watch `synchronization_state_desc`
go from `SYNCHRONIZING` to `SYNCHRONIZED` on both rows once seeding catches
up (`database_state_desc` is normal to see as `NULL` for the non-local row —
only `synchronization_state_desc` is reliable cross-replica). There is no
listener (no virtual IP without a cluster manager) — connect to `prod1,1401`
for read-write, or `prod2,1402` (or `prod1,1401` with
`ApplicationIntent=ReadOnly`, which routes to prod2) for read-only.

---

## Use case 3 — dev and staging: standalone instances
Independent instances, no AG, brought up only when needed:
```powershell
docker compose --profile dev up -d dev              # localhost,1403
docker compose up bootstrap-dev                       # one-shot instance config

docker compose --profile staging up -d staging       # localhost,1404
docker compose up bootstrap-staging                    # one-shot instance config
```

Same connection pattern as prod1 (SSMS/ADS/DBeaver, **Trust server
certificate = on**), and the same `seed`/backup workflow from Use case 1 —
just point `$env:SEED_TARGET` (or `docker compose exec`) at `dev`/`staging`
instead of `prod1`.

---

## Use case 4 — heavy daily usage data (data_gen)
`data_gen/` is a Python generator that fills the [`database/`](../database/)
`fin_pulse` schema (personal finance + health tracker) with 10 believable,
**heavily-active** users by default: several expenses and meals logged per
day, plus daily water/sleep/journal entries across a rolling window — see
[`data_gen/README.md`](data_gen/README.md) for exactly what gets generated
per table.

```powershell
docker compose --profile datagen run --rm datagen backfill --target dev
docker compose --profile datagen run --rm datagen backfill --target dev --users 25 --days 180 --reset
```

---

## Everyday commands
```powershell
docker compose ps                                                     # container status
docker compose logs -f prod1                                          # tail prod1 errorlog
docker compose restart prod1                                          # restart prod1
docker compose --profile ha --profile dev --profile staging down      # stop everything (volumes survive)
docker compose --profile ha --profile dev --profile staging down -v   # full reset — destroys volumes too
```
