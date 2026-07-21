CREATE PROCEDURE [dbo].[getInvestmentsByUser]
    @UserId INT,
    @PageSize INT = 25,
    @PageNumber INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        i.[id],
        i.[asset_name],
        i.[investment_type],
        i.[category],
        i.[invested_amount],
        i.[current_value],
        i.[profit_loss],
        i.[annual_yield_percent],
        i.[broker],
        i.[purchase_date],
        i.[maturity_date],
        i.[currency_code],
        i.[status]
    FROM [dbo].[investments] i
    WHERE i.[user_id] = @UserId
      AND i.[status] = 1
    ORDER BY i.[purchase_date] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO
