import argparse

from . import db, generate


def main() -> None:
    parser = argparse.ArgumentParser(prog="datagen", description="fin_pulse test data generator")
    sub = parser.add_subparsers(dest="command", required=True)

    backfill = sub.add_parser("backfill", help="generate historical activity for N users")
    backfill.add_argument("--target", default="dev", help="docker-compose service to connect to")
    backfill.add_argument("--database", default="fin_pulse")
    backfill.add_argument("--users", type=int, default=10)
    backfill.add_argument("--days", type=int, default=90, help="size of the backfill window, ending today")
    backfill.add_argument("--seed", type=int, default=42)
    backfill.add_argument(
        "--reset", action="store_true",
        help="delete existing rows in every fin_pulse table first (fresh reseed)",
    )

    args = parser.parse_args()

    conn = db.connect(args.target, args.database)
    try:
        if args.command == "backfill":
            generate.backfill(conn, args.users, args.days, args.seed, args.reset)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
