CREATE PROCEDURE [dbo].[getEarningsByUser]
    @UserId INT,
    @PageSize INT = 25,
    @PageNumber INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.[id],
        e.[amount],
        e.[category],
        e.[description],
        e.[earning_date],
        e.[payment_method],
        e.[currency_code],
        e.[status]
    FROM [dbo].[earnings] e
    WHERE e.[user_id] = @UserId
      AND e.[status] = 1
    ORDER BY e.[earning_date] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO
