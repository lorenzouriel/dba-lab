CREATE TABLE [dbo].[Folder] (
    [Id]              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    [Name]            NVARCHAR(255)    NOT NULL,
    [ParentFolderId]  UNIQUEIDENTIFIER NULL,
    [CreatedBy]       UNIQUEIDENTIFIER NOT NULL,
    [CreatedDate]     DATETIME2(7)     NOT NULL DEFAULT SYSUTCDATETIME(),
    [ModifiedDate]    DATETIME2(7)     NOT NULL DEFAULT SYSUTCDATETIME(),
    [IsDeleted]       BIT              NOT NULL DEFAULT 0,
    CONSTRAINT [PK_Folder] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_Folder_ParentFolder] FOREIGN KEY ([ParentFolderId])
        REFERENCES [dbo].[Folder] ([Id])
);
GO

CREATE NONCLUSTERED INDEX [IX_Folder_ParentFolderId]
    ON [dbo].[Folder] ([ParentFolderId])
    WHERE [IsDeleted] = 0;
GO
