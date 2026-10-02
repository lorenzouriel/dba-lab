# data_gen/

A small Python generator that fills the [`database/`](../../database/)
`fin_pulse` schema (personal finance + health tracker) with believable,
**heavily-used** daily activity: 50 users by default, each logging several
expenses a day, three-plus meals a day, a water-intake row, and a sleep log
-- across a full year ending today. A full default
run generates around 270k rows in total (measured), in well under 15 seconds.

It has two modes: `backfill` (a historical batch, described below) and
`stream` (continuous "right now" activity every few seconds -- see
[Usage](#usage)). `stream` also runs as a standalone `datagen-stream` compose
service with a restart policy, for sustained/continuous load rather than a
one-shot foreground run -- the one worth leaving running against `prod1`
while `prod2` is joined to the AG, so you can watch rows show up on the
read-only secondary as they replicate.

No Faker, no ORM: a small hardcoded Brazilian-Portuguese name/category pool
plus `pyodbc` + `executemany`. Reproducible via `--seed` (`backfill` only --
`stream` seeds randomly per run by design, see below).

## What `backfill` generates (per run, defaults: 50 users, 365 days)

| Table(s) | Cadence |
|----------|---------|
| `dbo.users` | 50 rows, one-time |
| `plan.budgets`, `plan.goals` | 2-3 budgets and 1-3 goals per user |
| `finance.earnings` | monthly salary + occasional freelance/bonus |
| `finance.expenses` | **1-5 rows per user per day** (the bulk of the data) |
| `finance.investments`, `finance.bills` | 4-8 / 4-6 static rows per user |
| `body.weekly_routines` | 7 rows per user (one per day of week) |
| `body.workouts` | most days, skipping each user's weekly rest day |
| `body.personal_records` | 3-6 sparse rows per user |
| `body.meals` | 3-4 rows per user per day |
| `body.water_intake`, `body.sleep_logs` | ~1 row per user per day |
| `body.body_metrics` | weekly per user |
| `body.habits`, `body.habit_logs` | 3-5 habits per user, logged ~90% of days (~75% completed) |
| `body.substance_logs` | caffeine most days; alcohol occasional, more likely on weekends |
| `body.symptom_logs` | 2-5 sparse off-days per user over the window (`notes` left NULL, see below) |
| `mind.meditation_sessions` | ~45% of days per user |
| `mind.journal_entries` | **not generated** -- see below |

`mind.journal_entries.content` and `body.symptom_logs.notes` are Always Encrypted
(see [`../always-encrypted/`](../always-encrypted/)). pyodbc in this container has no
key-store provider, so it can't write ciphertext: journal entries are skipped
(`content` is NOT NULL) and `notes` is omitted. Write those columns from a
client that registers the CMK provider (the .NET tests do).

## Usage

Via `docker-compose.yml` (see [`../README.md`](../README.md) Use case 4):

```powershell
docker compose --profile datagen run --rm datagen backfill --target dev
docker compose --profile datagen run --rm datagen backfill --target dev --users 100 --days 365 --reset
```

`--target` is a docker-compose service name (`prod1`, `prod2`, `prod3`,
`dev`, `staging`) reached over the internal Docker network -- always port
1433, not the host-mapped port from `.env`. `prod2`/`prod3` are AG
secondaries and read-only, so `backfill`/`stream` only ever make sense
against `prod1`, `dev`, or `staging` -- they're listed as valid targets
mainly so ad-hoc read queries against them don't need a workaround.
`--reset` deletes existing rows from every
`fin_pulse` table (and reseeds identities) before generating, so repeat runs
don't just keep appending. A 50-user/365-day run is ~270k rows and finishes
in well under 15 seconds with `fast_executemany` -- scale `--users`/`--days`
up further if you want a heavier dataset (e.g. for testing index/query
performance), or down for a quick smoke test.

**`stream`** logs a handful of "right now" rows (an expense, a water top-up,
a meal, a habit check-off, or a caffeine log -- weighted
towards expenses, same as real usage) for 1-3 random *existing* users every
`--interval` seconds, committing after each tick. It needs `dbo.users`
already populated, so run `backfill` at least once first. Two ways to run it:

```powershell
# foreground, one-off: Ctrl+C (or `docker stop`) to end it
docker compose --profile datagen run --rm datagen stream --target prod1
docker compose --profile datagen run --rm datagen stream --target prod1 --interval 2

# background, continuous: keeps running (and restarts on crash) until stopped
docker compose --profile datagen up -d datagen-stream
docker compose --profile datagen logs -f datagen-stream
docker compose --profile datagen stop datagen-stream
```

The foreground form is for watching ticks land in real time or for a custom
`--interval`/`--target`; `datagen-stream` (`restart: unless-stopped`, fixed
at `--target prod1 --interval 3`) is for leaving continuous load running in
the background indefinitely -- edit its `command:` in `docker-compose.yml`
to change the interval or point it elsewhere. Both are handled gracefully on
Ctrl+C/SIGINT or `docker stop`/SIGTERM, committing the in-flight tick before
exiting -- `stream` seeds from a random source each run (not `--seed`) so
consecutive runs/restarts don't replay identical activity.

## Layout

```
data_gen/
├── Dockerfile          python:3.12-slim + msodbcsql18 + pyodbc
├── requirements.txt
└── datagen/
    ├── db.py            connection helper (reads MSSQL_SA_PASSWORD)
    ├── generate.py       table generators (backfill) + stream_tick/stream (live loop)
    └── main.py           CLI: `backfill --target --database --users --days --seed --reset`
                                `stream --target --database --interval --seed`
```

`docker-compose.yml` bind-mounts `./data_gen/datagen` read-only into the
image, so editing generator code and re-running `docker compose run` doesn't
need an image rebuild.
