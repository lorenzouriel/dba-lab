CREATE TABLE [dbo].[Session] (
    [Id]              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    [Name]            NVARCHAR(500)    NOT NULL,
    [FolderId]        UNIQUEIDENTIFIER NOT NULL,
    [CreatedBy]       UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate]     DATETIME2(7)     NOT NULL DEFAULT SYSUTCDATETIME(),
    [Duration]        FLOAT            NULL,
    [State]           TINYINT          NOT NULL DEFAULT 0,
    [IsDeleted]       BIT              NOT NULL DEFAULT 0,
    [ViewCount]       INT              NOT NULL DEFAULT 0,
    CONSTRAINT [PK_Session] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_Session_Folder] FOREIGN KEY ([FolderId])
        REFERENCES [dbo].[Folder] ([Id]),
    CONSTRAINT [FK_Session_User] FOREIGN KEY ([CreatedBy])
        REFERENCES [dbo].[User] ([Id])
);
GO

CREATE NONCLUSTERED INDEX [IX_Session_FolderId]
    ON [dbo].[Session] ([FolderId])
    INCLUDE ([Name], [State], [CreatedDate])
    WHERE [IsDeleted] = 0;
GO

CREATE NONCLUSTERED INDEX [IX_Session_CreatedBy]
    ON [dbo].[Session] ([CreatedBy], [CreatedDate] DESC)
    WHERE [IsDeleted] = 0;
GO
