-- Registered application users and their authentication data (root of the multi-schema fin_pulse app).
CREATE TABLE [dbo].[users]
(
    [id]           INT            IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [username]     VARCHAR(100)   NOT NULL,                             -- ~25 bytes avg (100 bytes max)
    [phone_number] VARCHAR(15)    MASKED WITH (FUNCTION = 'partial(0, "XXXXXX", 4)') NULL, -- ~10 bytes avg (15 bytes max); shows last 4 digits
    [email]        VARCHAR(100)   MASKED WITH (FUNCTION = 'email()') NOT NULL,              -- ~25 bytes avg (100 bytes max); aXXX@XXXX.com
    [password]     NVARCHAR(1024) MASKED WITH (FUNCTION = 'default()') NULL,                -- ~120 bytes avg (60-char hash, 2048 bytes max); xxxx
    [created_at]   DATETIME       NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    [status]       TINYINT        NOT NULL DEFAULT 1                    -- 1 byte
);
-- Estimated row size: 4 + 25 + 10 + 25 + 120 + 8 + 1 = ~193 bytes
-- Plus row overhead (~7 bytes) = ~200 bytes per row
-- 1 million rows ≈ 191 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stores registered application users and their authentication data.',
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
    @value = N'Public username chosen by the user. VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'users',
    @level2type = N'Column', @level2name = N'username';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional phone number used for contact or verification. VARCHAR(15).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'users',
    @level2type = N'Column', @level2name = N'phone_number';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary email address of the user (used for login and notifications). VARCHAR(100).',
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
    @value = N'Date and time when the user record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'users',
    @level2type = N'Column', @level2name = N'created_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'User status flag (1 = active, 0 = inactive, others for future states). TINYINT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'users',
    @level2type = N'Column', @level2name = N'status';
GO
