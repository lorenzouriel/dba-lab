CREATE PROCEDURE [dbo].[getUserById]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.[id],
        u.[username],
        u.[phone_number],
        u.[email],
        u.[created_at],
        u.[plan],
        u.[status]
    FROM [dbo].[users] u
    WHERE u.[id] = @UserId;
END;
GO
