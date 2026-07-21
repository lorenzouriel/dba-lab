CREATE PROCEDURE [dbo].[getBudgetsByUser]
    @UserId INT,
    @PageSize INT = 25,
    @PageNumber INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        b.[id],
        b.[name],
        b.[description],
        b.[amount_limit],
        b.[currency_code],
        b.[start_date],
        b.[end_date],
        b.[status]
    FROM [dbo].[budgets] b
    WHERE b.[user_id] = @UserId
      AND b.[status] = 1
    ORDER BY b.[start_date] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO
