CREATE PROCEDURE [dbo].[getExpensesByUser]
    @UserId INT,
    @PageSize INT = 25,
    @PageNumber INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        x.[id],
        x.[amount],
        x.[category],
        x.[description],
        x.[expense_date],
        x.[payment_method],
        x.[currency_code],
        x.[status]
    FROM [dbo].[expenses] x
    WHERE x.[user_id] = @UserId
      AND x.[status] = 1
    ORDER BY x.[expense_date] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO
