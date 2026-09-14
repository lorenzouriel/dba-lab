/*  99-stress-test.sql
    Generates CPU-bound wait (SOS_SCHEDULER_YIELD, CXPACKET/CXCONSUMER once
    it goes parallel) and a few genuinely long-running statements, for
    exercising Data Eyes' Waits and SQL statements tabs. Needs no seeded
    database — runs entirely against system catalog views. Read-only.

    Run inside the sql1 container so it always has sqlcmd + the right host:
      docker compose exec sql1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$env:MSSQL_SA_PASSWORD" -C -b -i /scripts/99-stress-test.sql
*/
SET NOCOUNT ON;
GO

-- Pure CPU burn: hashes every (a,b) pair from spt_values (2,508 rows, so
-- ~6.3M pairs). No index to seek, forces a hash join + parallel plan under
-- the lab's cost-threshold-for-parallelism=50 -> CXPACKET/CXCONSUMER, plus
-- SOS_SCHEDULER_YIELD as threads contend for the container's 2 vCPUs.
SELECT COUNT(*) AS burned
FROM master..spt_values AS a
CROSS JOIN master..spt_values AS b
WHERE HASHBYTES('SHA2_256', CAST(a.number AS varchar(10)) + CAST(b.number AS varchar(10))) IS NOT NULL
OPTION (MAXDOP 2);
GO 15

-- A genuinely long, expensive-sort statement — no supporting index for the
-- ORDER BY, so it's a real sort operator; shows up clearly in the SQL
-- statements tab's plan view with cost concentrated in the Sort node.
-- Bounded to ~2508 x 2508 x 25 =~ 157M rows before the sort — big and slow,
-- not the ~15.8 BILLION an unbounded third cross join would produce.
-- ROW_NUMBER() OVER (ORDER BY ...) forces a real sort the optimizer can't
-- discard (a plain terminal ORDER BY would get dropped once wrapped in an
-- aggregate) while the outer COUNT(*) keeps the client-bound result to one
-- row instead of streaming ~157M rows back over the wire.
SELECT COUNT(*) AS rows_sorted
FROM (
    SELECT ROW_NUMBER() OVER (
        ORDER BY HASHBYTES('SHA2_256', CAST(a.number AS varchar(10)) + CAST(b.number AS varchar(10))) DESC
    ) AS rn
    FROM master..spt_values AS a
    CROSS JOIN master..spt_values AS b
    CROSS JOIN (SELECT TOP (25) number FROM master..spt_values) AS c
) AS sorted
OPTION (MAXDOP 2);
GO 3
