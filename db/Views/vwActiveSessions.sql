CREATE VIEW [dbo].[vwActiveSessions]
AS
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
    WHERE s.[IsDeleted] = 0
      AND s.[State] IN (1, 2);  -- 1=Processing, 2=Complete
GO
