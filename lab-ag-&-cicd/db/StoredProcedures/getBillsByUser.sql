CREATE PROCEDURE [dbo].[getBillsByUser]
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
        b.[category],
        b.[amount],
        b.[due_day],
        b.[payment_method],
        b.[currency_code],
        b.[is_recurrent],
        b.[end_date],
        b.[recurrence_type],
        b.[status]
    FROM [dbo].[bills] b
    WHERE b.[user_id] = @UserId
      AND b.[status] = 1
    ORDER BY b.[due_day]
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO
