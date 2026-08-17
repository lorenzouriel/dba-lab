# sqlserver-lab

SQL Server 2025 (Developer) lab in Docker for DP-800 — *Developing AI-Enabled
Database Solutions*. No SQL Server installed on the host.

## Layout

```
sqlserver-lab/
├── docker-compose.yml       sql1 + bootstrap; sql2/ollama/caddy behind profiles
├── .env.example             copy to .env — SA password, ports, memory
├── .gitignore                keeps .env, .bak, and .crt out of git
├── docker/
│   ├── mssql/Dockerfile     thin layer: trusts CA certs from ./certs
│   └── caddy/Caddyfile      TLS terminator in front of Ollama
├── scripts/
│   ├── 00-bootstrap.sql     instance config, runs on every `up`
│   ├── 01-restore.sql       restore a .bak, auto-derives MOVE targets
│   ├── 10-ai-model.sql      external model + vector column patterns
│   └── 20-ag-setup.sql      cert-based HADR endpoints + availability group
├── restore/                 ← drop .bak files here (mounted read-only)
├── backups/                 ← BACKUP DATABASE writes here
└── certs/                   ← CA certs to trust (caddy-root.crt lands here)
```

## One-time setup

```powershell
Copy-Item .env.example .env
New-Item -ItemType Directory -Force -Path restore, backups, certs | Out-Null

# image runs non-root as uid 10001; fix ownership on the bind mounts via a
# throwaway container (no native chown on Windows)
docker run --rm -v "${PWD}:/data" busybox sh -c "chown -R 10001:0 /data/backups /data/restore /data/certs && chmod 775 /data/backups"

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

## Use case 1 — sql1: start, restore, back up

```powershell
docker compose up -d --build sql1   # build + start
docker compose up bootstrap         # one-shot instance config (safe to re-run)
```

Connect from SSMS / Azure Data Studio / DBeaver: `localhost,1401`, user `sa`,
**Trust server certificate = on** (the instance uses a self-signed cert). Or
from the shell:

```powershell
docker compose exec sql1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$env:MSSQL_SA_PASSWORD" -C
```

**Restore a database.** Drop `billing.bak` into `./restore/`, then:

```powershell
$env:SEED_DB = "billing"; $env:SEED_BAK = "billing.bak"
docker compose --profile seed run --rm seed
```

`01-restore.sql` reads the backup header and generates the `MOVE` clauses, so
Windows-authored backups with `C:\` paths restore cleanly. It also forces
compat level 170 and turns on Query Store and preview features.

**Back up a database.** `BACKUP DATABASE` can't target the bind-mounted
`./backups/` folder directly on Docker Desktop for Windows (see *Why*
below), so back up into the `sql1-data` named volume and copy the file out:

```powershell
$env:DB = "billing"
docker compose exec sql1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$env:MSSQL_SA_PASSWORD" -C -b -Q `
  "BACKUP DATABASE [$env:DB] TO DISK='/var/opt/mssql/data/$env:DB.bak' WITH INIT, COMPRESSION, STATS=10"
docker compose cp sql1:/var/opt/mssql/data/$env:DB.bak ./backups/$env:DB.bak
docker compose exec sql1 rm -f /var/opt/mssql/data/$env:DB.bak
```

---

## Use case 2 — sql2 + Availability Group

Two independent containers, no domain and no WSFC/Pacemaker, so this brings
up a `CLUSTER_TYPE = NONE` AG (manual failover only) using certificate-based
endpoint auth. `20-ag-setup.sql` hops between both instances with sqlcmd's
`:CONNECT`, exchanges HADR certs, opens the mirroring endpoints, and creates
`ag1` with automatic seeding — no manual backup/restore step needed for the
AG database itself.

```powershell
docker compose --profile ha up -d sql2          # bring up the secondary, localhost,1402
docker compose --profile ha run --rm ag-setup   # certs, endpoints, create + join ag1
```

`ag-setup` creates a small `agdb` database if one doesn't already exist
(override with `$env:AGDB = "yourdb"` before running, as long as that
database exists and is reachable on sql1). Seeding runs asynchronously —
check sync state:

```powershell
docker compose exec sql1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$env:MSSQL_SA_PASSWORD" -C -Q `
  "SELECT ag.name, r.replica_server_name, rs.role_desc, drs.synchronization_state_desc, drs.is_local FROM sys.availability_groups ag JOIN sys.availability_replicas r ON ag.group_id = r.group_id JOIN sys.dm_hadr_availability_replica_states rs ON r.replica_id = rs.replica_id LEFT JOIN sys.dm_hadr_database_replica_states drs ON drs.replica_id = rs.replica_id;"
```

`role_desc` shows `PRIMARY`/`SECONDARY`; watch `synchronization_state_desc`
go from `SYNCHRONIZING` to `SYNCHRONIZED` on both rows once seeding catches
up (`database_state_desc` is normal to see as `NULL` for the non-local row —
only `synchronization_state_desc` is reliable cross-replica). There is no
listener (no virtual IP without a cluster manager) — connect to `sql1,1401`
or `sql2,1402` directly, or query `role_desc` to find the current primary.

---

## Use case 3 — AI: Ollama + Caddy (TLS) for embeddings

`sp_invoke_external_rest_endpoint` rejects plain `http://`, so this profile
puts Caddy in front of Ollama for a local HTTPS endpoint and rebuilds sql1 to
trust Caddy's CA.

```powershell
docker compose --profile ai up -d                                 # Ollama + Caddy
docker compose exec ollama ollama pull nomic-embed-text           # embedding model
docker compose cp caddy:/data/caddy/pki/authorities/local/root.crt ./certs/caddy-root.crt
docker compose up -d --build sql1                                 # rebuild sql1 to trust it
```

See `scripts/10-ai-model.sql` for `CREATE EXTERNAL MODEL` and vector column
patterns once this is up.

---

## Everyday commands

```powershell
docker compose ps                    # container status
docker compose logs -f sql1          # tail sql1 errorlog
docker compose restart sql1          # restart sql1
docker compose --profile ha --profile ai down       # stop everything (volumes survive)
docker compose --profile ha --profile ai down -v    # full reset — destroys volumes too
```

## Why the pieces are the way they are

**Developer, not Express.** Express caps the buffer pool at 1410 MB, databases
at 10 GB, and has no SQL Agent. Developer is free and gives you the full
Enterprise surface.

**Pinned to `2025-latest`.** The DP-800 blueprint is built on SQL Server 2025
features — `vector`, `CREATE EXTERNAL MODEL`, `AI_GENERATE_EMBEDDINGS`,
DiskANN, `sp_invoke_external_rest_endpoint`. None of it exists in 2022.

**`$$MSSQL_SA_PASSWORD` in the healthcheck.** A single `$` gets interpolated by
Compose at parse time, baking the plaintext password into the container config
where `docker inspect` shows it. `CMD-SHELL` + `$$` defers expansion to the
container's shell. `-C` is required or sqlcmd 18 fails the TLS handshake.

**`chown 10001:0` on the bind mounts.** The image runs non-root as uid 10001;
without it `BACKUP DATABASE` returns OS error 5 and restores can't read the file.

**Two backup folders.** `restore/` is read-only (source `.bak` files you bring
in), `backups/` is writable (what the engine produces). One folder means either
backups fail or the container can write to your source files.

**`BACKUP DATABASE` can't target `./backups/` directly on Docker Desktop for
Windows.** The engine pre-allocates the `.bak` file, then shrinks it to the
real size once the write completes — that final `DiskChangeFileSize` call
isn't supported through the Windows bind-mount passthrough and fails with OS
error 31 right at the finish line, after all the pages are already written.
Backing up into the `sql1-data` *named* volume (a real Linux filesystem
inside the Docker VM) and then `docker compose cp`-ing the file out works
fine — that's what Use case 1 and 2 above do.

**`CLUSTER_TYPE = NONE` for the AG.** Real Always On needs a cluster manager
(WSFC or Pacemaker) for automatic failover; neither is worth standing up for
two containers on one Docker host. `NONE` gives a real AG — replication,
automatic seeding, `sys.dm_hadr_*` — with manual failover, which is enough
for the DP-800 HA/DR objectives. Endpoint auth uses certificates instead of
Windows auth for the same reason: sql1 and sql2 share no domain.

**HTTPS is mandatory for AI endpoints.** `sp_invoke_external_rest_endpoint`
rejects plain `http://`, which is why the `ai` profile puts Caddy in front of
Ollama and why sql1 is built from a Dockerfile that ingests `./certs`.

## Known gap

Always Encrypted **with secure enclaves** needs VBS, which is Windows-only.
Basic Always Encrypted, RLS, DDM, and TDE all work here; the enclave scenarios
in domain 2 stay theoretical unless you spin up a Windows VM.
