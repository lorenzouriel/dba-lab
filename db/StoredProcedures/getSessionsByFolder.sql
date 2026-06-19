CREATE PROCEDURE [dbo].[getSessionsByFolder]
    @FolderId UNIQUEIDENTIFIER,
    @PageSize INT = 25,
    @PageNumber INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.[Id],
        s.[Name],
        s.[CreatedBy],
        u.[DisplayName] AS CreatorName,
        s.[CreatedDate],
        s.[Duration],
        s.[State],
        s.[ViewCount]
    FROM [dbo].[Session] s
    INNER JOIN [dbo].[User] u ON u.[Id] = s.[CreatedBy]
    WHERE s.[FolderId] = @FolderId
      AND s.[IsDeleted] = 0
    ORDER BY s.[CreatedDate] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO
