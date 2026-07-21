CREATE PROCEDURE [dbo].[getGoalsByUser]
    @UserId INT,
    @PageSize INT = 25,
    @PageNumber INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        g.[id],
        g.[name],
        g.[description],
        g.[target_amount],
        g.[current_amount],
        g.[currency_code],
        g.[due_date],
        g.[status]
    FROM [dbo].[goals] g
    WHERE g.[user_id] = @UserId
      AND g.[status] = 1
    ORDER BY g.[due_date]
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO
