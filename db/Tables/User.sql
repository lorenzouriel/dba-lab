CREATE TABLE [dbo].[User] (
    [Id]              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    [ExternalId]      NVARCHAR(255)    NOT NULL,
    [DisplayName]     NVARCHAR(255)    NOT NULL,
    [Email]           NVARCHAR(320)    NULL,
    [Role]            TINYINT          NOT NULL DEFAULT 0,
    [CreatedDate]     DATETIME2(7)     NOT NULL DEFAULT SYSUTCDATETIME(),
    [LastLoginDate]   DATETIME2(7)     NULL,
    [IsEnabled]       BIT              NOT NULL DEFAULT 1,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([Id])
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_User_ExternalId]
    ON [dbo].[User] ([ExternalId]);
GO
