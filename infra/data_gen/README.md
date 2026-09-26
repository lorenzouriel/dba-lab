# data_gen/

A small Python generator that fills the [`database/`](../../database/)
`fin_pulse` schema (personal finance + health tracker) with believable,
**heavily-used** daily activity: 10 users by default, each logging several
expenses a day, three-plus meals a day, a water-intake row, a sleep log, and
most days a journal entry -- across a rolling window ending today.

No Faker, no ORM: a small hardcoded Brazilian-Portuguese name/category pool
plus `pyodbc` + `executemany`. Reproducible via `--seed`.

## What it generates (per run, defaults: 10 users, 90 days)

| Table(s) | Cadence |
|----------|---------|
| `dbo.users` | 10 rows, one-time |
| `plan.budgets`, `plan.goals` | 2-3 budgets and 1-3 goals per user |
| `finance.earnings` | monthly salary + occasional freelance/bonus |
| `finance.expenses` | **1-5 rows per user per day** (the bulk of the data) |
| `finance.investments`, `finance.bills` | 4-8 / 4-6 static rows per user |
| `investment.stocks/cryptos/currencies` | daily OHLCV random-walk, not user-scoped |
| `body.weekly_routines` | 7 rows per user (one per day of week) |
| `body.workouts` | most days, skipping each user's weekly rest day |
| `body.personal_records` | 3-6 sparse rows per user |
| `body.meals` | 3-4 rows per user per day |
| `body.water_intake`, `body.sleep_logs` | ~1 row per user per day |
| `body.body_metrics` | weekly per user |
| `mind.meditation_sessions` | ~45% of days per user |
| `mind.journal_entries` | ~70% of days per user |

## Usage

Via `docker-compose.yml` (see [`../README.md`](../README.md) Use case 4):

```powershell
docker compose --profile datagen run --rm datagen backfill --target dev
docker compose --profile datagen run --rm datagen backfill --target dev --users 25 --days 180 --reset
```

`--target` is a docker-compose service name (`prod1`, `prod2`, `dev`,
`staging`) reached over the internal Docker network -- always port 1433, not
the host-mapped port from `.env`. `--reset` deletes existing rows from every
`fin_pulse` table (and reseeds identities) before generating, so repeat runs
don't just keep appending.

## Layout

```
data_gen/
├── Dockerfile          python:3.12-slim + msodbcsql18 + pyodbc
├── requirements.txt
└── datagen/
    ├── db.py            connection helper (reads MSSQL_SA_PASSWORD)
    ├── generate.py       table generators, one function per table (group)
    └── main.py           CLI: `backfill --target --database --users --days --seed --reset`
```

`docker-compose.yml` bind-mounts `./data_gen/datagen` read-only into the
image, so editing generator code and re-running `docker compose run` doesn't
need an image rebuild.
