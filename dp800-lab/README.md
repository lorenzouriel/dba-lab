# sqlserver-lab

SQL Server 2025 (Developer) lab in Docker for DP-800 — *Developing AI-Enabled
Database Solutions*. No SQL Server installed on the host.

## Layout

```
sqlserver-lab/
├── docker-compose.yml       sql1 + bootstrap; sql2/ollama/caddy behind profiles
├── Makefile                 make init / up / sql / seed / ai / trust-ca
├── .env.example             copy to .env — SA password, ports, memory
├── .gitignore               keeps .env, .bak, and .crt out of git
├── docker/
│   ├── mssql/Dockerfile     thin layer: trusts CA certs from ./certs
│   └── caddy/Caddyfile      TLS terminator in front of Ollama
├── scripts/
│   ├── 00-bootstrap.sql     instance config, runs on every `up`
│   ├── 01-restore.sql       restore a .bak, auto-derives MOVE targets
│   └── 10-ai-model.sql      external model + vector column patterns
├── restore/                 ← drop .bak files here (mounted read-only)
├── backups/                 ← BACKUP DATABASE writes here
└── certs/                   ← CA certs to trust (caddy-root.crt lands here)
```

## Start

```bash
make init      # .env + chown -R 10001:0 on the bind mounts
$EDITOR .env   # set MSSQL_SA_PASSWORD
make up        # build, start, bootstrap
make sql       # interactive sqlcmd
```

Connect from SSMS / Azure Data Studio / DBeaver: `localhost,1401`, user `sa`,
**Trust server certificate = on** (the instance uses a self-signed cert).

## Restoring a database

Drop `billing.bak` into `./restore/`, then:

```bash
SEED_DB=billing SEED_BAK=billing.bak make seed
```

`01-restore.sql` reads the backup header and generates the `MOVE` clauses, so
Windows-authored backups with `C:\` paths restore cleanly. It also forces
compat level 170 and turns on Query Store and preview features.

## Optional profiles

| Command | What you get |
|---|---|
| `make ha` | second instance on `localhost,1402` for AG, replication, cross-instance CI/CD |
| `make ai` + `make pull-model` + `make trust-ca` | Ollama behind Caddy, and sql1 rebuilt to trust Caddy's CA |

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

**HTTPS is mandatory for AI endpoints.** `sp_invoke_external_rest_endpoint`
rejects plain `http://`, which is why the `ai` profile puts Caddy in front of
Ollama and why sql1 is built from a Dockerfile that ingests `./certs`.

## Known gap

Always Encrypted **with secure enclaves** needs VBS, which is Windows-only.
Basic Always Encrypted, RLS, DDM, and TDE all work here; the enclave scenarios
in domain 2 stay theoretical unless you spin up a Windows VM.
