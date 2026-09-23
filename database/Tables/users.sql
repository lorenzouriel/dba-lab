-- Login accounts (email + password) that manage a tenant's fleet.
CREATE TABLE [dbo].[users]
(
    [id]         INT IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [tenant_id]  INT            NOT NULL,                   -- 4 bytes
    [email]      VARCHAR(100)   NOT NULL,                   -- ~25 bytes avg (100 bytes max)
    [password]   NVARCHAR(1024) NOT NULL,                   -- ~120 bytes avg (60-char hash, 2048 bytes max)
    [full_name]  NVARCHAR(200)  NOT NULL,                   -- ~40 bytes avg (20 chars typical, 400 bytes max)
    [is_active]  BIT            NOT NULL DEFAULT 1,          -- 1 byte
    [created_at] DATETIME       NOT NULL DEFAULT GETDATE(), -- 8 bytes
    CONSTRAINT [FK_users_tenants] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[tenants] ([id])
);
-- Estimated row size: 4 + 4 + 25 + 120 + 40 + 1 + 8 = ~202 bytes
-- Plus row overhead (~7 bytes) = ~209 bytes per row
-- 1 million rows ≈ 199 MB
GO

CREATE UNIQUE INDEX [UX_users_email] ON [dbo].[users]([email]);
GO

CREATE INDEX [IX_users_tenant_id] ON [dbo].[users]([tenant_id]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Login accounts (email + password) that manage a tenant''s fleet.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'users';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each user (primary key). INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'users',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tenant this user account belongs to. References tenants.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'users',
    @level2type = N'Column', @level2name = N'tenant_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Login email address, unique across all tenants. VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'users',
    @level2type = N'Column', @level2name = N'email';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Hashed password for authentication (never stored in plain text). NVARCHAR(1024).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'users',
    @level2type = N'Column', @level2name = N'password';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Display name of the user. NVARCHAR(200).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'users',
    @level2type = N'Column', @level2name = N'full_name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether the account can log in (1) or is disabled (0). BIT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'users',
    @level2type = N'Column', @level2name = N'is_active';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the user record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'users',
    @level2type = N'Column', @level2name = N'created_at';
GO
