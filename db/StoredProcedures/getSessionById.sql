CREATE PROCEDURE [dbo].[getSessionById]
    @SessionId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.[Id],
        s.[Name],
        s.[FolderId],
        f.[Name]        AS FolderName,
        s.[CreatedBy],
        u.[DisplayName] AS CreatorName,
        s.[CreatedDate],
        s.[Duration],
        s.[State],
        s.[ViewCount]
    FROM [dbo].[Session] s
    INNER JOIN [dbo].[Folder] f ON f.[Id] = s.[FolderId]
    INNER JOIN [dbo].[User]  u ON u.[Id] = s.[CreatedBy]
    WHERE s.[Id] = @SessionId
      AND s.[IsDeleted] = 0;
END;
GO
