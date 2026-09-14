CREATE VIEW [dbo].[vwUpcomingBills]
AS
    SELECT
        b.[id],
        b.[user_id],
        b.[name],
        b.[category],
        b.[amount],
        b.[due_day],
        b.[payment_method],
        b.[currency_code],
        b.[is_recurrent],
        CASE
            WHEN b.[due_day] > DAY(EOMONTH(GETDATE())) THEN EOMONTH(GETDATE())
            ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), b.[due_day])
        END AS DueDateThisMonth
    FROM [dbo].[bills] b
    WHERE b.[status] = 1
      AND (b.[is_recurrent] = 1 OR b.[end_date] >= GETDATE());
GO
