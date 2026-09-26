import argparse
import random

from . import db, generate


def main() -> None:
    parser = argparse.ArgumentParser(prog="datagen", description="fin_pulse test data generator")
    sub = parser.add_subparsers(dest="command", required=True)

    backfill = sub.add_parser("backfill", help="generate historical activity for N users")
    backfill.add_argument("--target", default="dev", help="docker-compose service to connect to")
    backfill.add_argument("--database", default="fin_pulse")
    backfill.add_argument("--users", type=int, default=50)
    backfill.add_argument("--days", type=int, default=365, help="size of the backfill window, ending today")
    backfill.add_argument("--seed", type=int, default=42)
    backfill.add_argument(
        "--reset", action="store_true",
        help="delete existing rows in every fin_pulse table first (fresh reseed)",
    )

    stream = sub.add_parser(
        "stream", help="continuously log small bursts of live activity for existing users (Ctrl+C to stop)",
    )
    stream.add_argument("--target", default="dev", help="docker-compose service to connect to")
    stream.add_argument("--database", default="fin_pulse")
    stream.add_argument("--interval", type=float, default=5.0, help="seconds between activity ticks")
    stream.add_argument(
        "--seed", type=int, default=None,
        help="defaults to a random seed each run so consecutive runs don't replay identical activity",
    )

    args = parser.parse_args()

    conn = db.connect(args.target, args.database)
    try:
        if args.command == "backfill":
            generate.backfill(conn, args.users, args.days, args.seed, args.reset)
        elif args.command == "stream":
            seed = args.seed if args.seed is not None else random.SystemRandom().randrange(1_000_000)
            generate.stream(conn, args.interval, seed)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
