CREATE TABLE [dbo].[SessionAccess] (
    [Id]              INT              NOT NULL IDENTITY(1,1),
    [SessionId]       UNIQUEIDENTIFIER NOT NULL,
    [UserId]          UNIQUEIDENTIFIER NOT NULL,
    [AccessType]      TINYINT          NOT NULL DEFAULT 0,
    [GrantedDate]     DATETIME2(7)     NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_SessionAccess] PRIMARY KEY CLUSTERED ([Id]),
    CONSTRAINT [FK_SessionAccess_Session] FOREIGN KEY ([SessionId])
        REFERENCES [dbo].[Session] ([Id]),
    CONSTRAINT [FK_SessionAccess_User] FOREIGN KEY ([UserId])
        REFERENCES [dbo].[User] ([Id]),
    CONSTRAINT [UQ_SessionAccess_SessionUser] UNIQUE ([SessionId], [UserId])
);
GO

CREATE NONCLUSTERED INDEX [IX_SessionAccess_UserId]
    ON [dbo].[SessionAccess] ([UserId])
    INCLUDE ([SessionId], [AccessType]);
GO
