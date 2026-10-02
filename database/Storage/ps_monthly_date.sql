-- Monthly range partitioning on a DATE column, shared by the time-series log tables.
-- RANGE RIGHT: each boundary is the first day of its partition, so a month's rows sit in one partition and
-- values before 2024-01-01 / from 2028-01-01 fall into the first / last (open-ended) partitions.
-- Boundaries are static: schedule SPLIT RANGE ahead of time to add future months (splitting a non-empty
-- partition is expensive) and MERGE RANGE to retire old ones.
CREATE PARTITION FUNCTION [pf_monthly_date] (DATE)
AS RANGE RIGHT FOR VALUES
(
    '2024-01-01', '2024-02-01', '2024-03-01', '2024-04-01', '2024-05-01', '2024-06-01',
    '2024-07-01', '2024-08-01', '2024-09-01', '2024-10-01', '2024-11-01', '2024-12-01',
    '2025-01-01', '2025-02-01', '2025-03-01', '2025-04-01', '2025-05-01', '2025-06-01',
    '2025-07-01', '2025-08-01', '2025-09-01', '2025-10-01', '2025-11-01', '2025-12-01',
    '2026-01-01', '2026-02-01', '2026-03-01', '2026-04-01', '2026-05-01', '2026-06-01',
    '2026-07-01', '2026-08-01', '2026-09-01', '2026-10-01', '2026-11-01', '2026-12-01',
    '2027-01-01', '2027-02-01', '2027-03-01', '2027-04-01', '2027-05-01', '2027-06-01',
    '2027-07-01', '2027-08-01', '2027-09-01', '2027-10-01', '2027-11-01', '2027-12-01'
);
GO

-- Azure SQL Database has only the PRIMARY filegroup, so every partition maps to it. The benefits here are
-- partition elimination and per-partition maintenance (SWITCH, TRUNCATE ... WITH (PARTITIONS ...)), not
-- physical placement.
CREATE PARTITION SCHEME [ps_monthly_date]
AS PARTITION [pf_monthly_date] ALL TO ([PRIMARY]);
GO
