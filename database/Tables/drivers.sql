-- A person assigned to drive vehicles; doesn't necessarily have a login (see users).
CREATE TABLE [dbo].[drivers]
(
    [id]             INT IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [tenant_id]      INT           NOT NULL,                   -- 4 bytes
    [full_name]      NVARCHAR(200) NOT NULL,                   -- ~40 bytes avg (20 chars typical, 400 bytes max)
    [license_number] VARCHAR(50)   NULL,                       -- ~15 bytes avg (50 bytes max)
    [phone]          VARCHAR(20)   NULL,                       -- ~15 bytes avg (20 bytes max)
    [is_active]      BIT           NOT NULL DEFAULT 1,         -- 1 byte
    [created_at]     DATETIME      NOT NULL DEFAULT GETDATE(), -- 8 bytes
    CONSTRAINT [FK_drivers_tenants] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[tenants] ([id])
);
-- Estimated row size: 4 + 4 + 40 + 15 + 15 + 1 + 8 = ~87 bytes
-- Plus row overhead (~7 bytes) = ~94 bytes per row
-- 1 million rows ≈ 90 MB
GO

CREATE INDEX [IX_drivers_tenant_id] ON [dbo].[drivers]([tenant_id]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A person assigned to drive vehicles; doesn''t necessarily have a login (see users).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'drivers';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each driver (primary key). INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'drivers',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tenant this driver belongs to. References tenants.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'drivers',
    @level2type = N'Column', @level2name = N'tenant_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Driver''s full name. NVARCHAR(200).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'drivers',
    @level2type = N'Column', @level2name = N'full_name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional driver''s license number. VARCHAR(50).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'drivers',
    @level2type = N'Column', @level2name = N'license_number';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional contact phone number. VARCHAR(20).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'drivers',
    @level2type = N'Column', @level2name = N'phone';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether the driver is currently active/employed (1) or not (0). BIT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'drivers',
    @level2type = N'Column', @level2name = N'is_active';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the driver record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'drivers',
    @level2type = N'Column', @level2name = N'created_at';
GO
