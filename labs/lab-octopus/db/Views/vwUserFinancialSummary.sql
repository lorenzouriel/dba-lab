CREATE VIEW [dbo].[vwUserFinancialSummary]
AS
    SELECT
        u.[id]                                    AS UserId,
        u.[username],
        ISNULL(e.TotalEarnings, 0)                AS TotalEarnings,
        ISNULL(x.TotalExpenses, 0)                AS TotalExpenses,
        ISNULL(e.TotalEarnings, 0) - ISNULL(x.TotalExpenses, 0) AS NetBalance,
        ISNULL(i.TotalInvested, 0)                AS TotalInvested
    FROM [dbo].[users] u
    LEFT JOIN (
        SELECT [user_id], SUM([amount]) AS TotalEarnings
        FROM [dbo].[earnings]
        WHERE [status] = 1
        GROUP BY [user_id]
    ) e ON e.[user_id] = u.[id]
    LEFT JOIN (
        SELECT [user_id], SUM([amount]) AS TotalExpenses
        FROM [dbo].[expenses]
        WHERE [status] = 1
        GROUP BY [user_id]
    ) x ON x.[user_id] = u.[id]
    LEFT JOIN (
        SELECT [user_id], SUM([invested_amount]) AS TotalInvested
        FROM [dbo].[investments]
        WHERE [status] = 1
        GROUP BY [user_id]
    ) i ON i.[user_id] = u.[id]
    WHERE u.[status] = 1;
GO
