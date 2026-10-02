"""Connection helper. Targets a docker-compose service name over the internal
Docker network (always port 1433 -- not the host-mapped ports from .env)."""

import os

import pyodbc

TARGETS = ("prod1", "prod2", "prod3", "dev", "staging")


def connect(target: str, database: str) -> pyodbc.Connection:
    if target not in TARGETS:
        raise SystemExit(f"--target must be one of {TARGETS}, got {target!r}")

    password = os.environ.get("MSSQL_SA_PASSWORD")
    if not password:
        raise SystemExit("MSSQL_SA_PASSWORD is not set (pass it through the datagen service env)")

    conn_str = (
        "DRIVER={ODBC Driver 18 for SQL Server};"
        f"SERVER={target},1433;"
        f"DATABASE={database};"
        "UID=sa;"
        f"PWD={password};"
        "TrustServerCertificate=yes;"
        "Encrypt=yes;"
    )
    return pyodbc.connect(conn_str, autocommit=False)
