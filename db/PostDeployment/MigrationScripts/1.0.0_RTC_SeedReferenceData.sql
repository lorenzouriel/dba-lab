-- 1.0.0_RTC_SeedReferenceData.sql
-- Seeds initial reference data. Idempotent — checks before inserting.

SET QUOTED_IDENTIFIER ON;
GO

PRINT 'Running: 1.0.0_RTC_SeedReferenceData';

-- Seed root folder
IF NOT EXISTS (SELECT 1 FROM [dbo].[Folder] WHERE [Name] = N'Root')
BEGIN
    DECLARE @rootUserId UNIQUEIDENTIFIER;

    -- Seed system user
    IF NOT EXISTS (SELECT 1 FROM [dbo].[User] WHERE [ExternalId] = N'SYSTEM')
    BEGIN
        SET @rootUserId = NEWID();
        INSERT INTO [dbo].[User] ([Id], [ExternalId], [DisplayName], [Email], [Role])
        VALUES (@rootUserId, N'SYSTEM', N'System', N'system@localhost', 255);
    END
    ELSE
    BEGIN
        SELECT @rootUserId = [Id] FROM [dbo].[User] WHERE [ExternalId] = N'SYSTEM';
    END

    INSERT INTO [dbo].[Folder] ([Name], [ParentFolderId], [CreatedBy])
    VALUES (N'Root', NULL, @rootUserId);

    PRINT '  -> Root folder seeded';
END
ELSE
BEGIN
    PRINT '  -> Root folder already exists, skipping';
END
GO
