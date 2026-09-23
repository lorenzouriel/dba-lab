-- The customer/company that owns vehicles, devices and users in this system.
CREATE TABLE [dbo].[tenants]
(
    [id]         INT IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [name]       NVARCHAR(200) NOT NULL,                   -- ~50 bytes avg (25 chars typical, 400 bytes max)
    [email]      VARCHAR(100)  NOT NULL,                    -- ~25 bytes avg (100 bytes max)
    [phone]      VARCHAR(20)   NULL,                        -- ~15 bytes avg (20 bytes max)
    [is_active]  BIT           NOT NULL DEFAULT 1,           -- 1 byte
    [created_at] DATETIME      NOT NULL DEFAULT GETDATE()   -- 8 bytes
);
-- Estimated row size: 4 + 50 + 25 + 15 + 1 + 8 = ~103 bytes
-- Plus row overhead (~7 bytes) = ~110 bytes per row
-- 1 million rows ≈ 105 MB
GO

CREATE UNIQUE INDEX [UX_tenants_email] ON [dbo].[tenants]([email]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The customer/company that owns vehicles, devices and users in this system (tenant root).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tenants';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each tenant (primary key). INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tenants',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Company/customer name. NVARCHAR(200).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tenants',
    @level2type = N'Column', @level2name = N'name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary contact/billing email for the tenant (unique). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tenants',
    @level2type = N'Column', @level2name = N'email';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional contact phone number. VARCHAR(20).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tenants',
    @level2type = N'Column', @level2name = N'phone';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether the tenant account is active (1) or suspended/disabled (0). BIT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tenants',
    @level2type = N'Column', @level2name = N'is_active';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the tenant record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tenants',
    @level2type = N'Column', @level2name = N'created_at';
GO
