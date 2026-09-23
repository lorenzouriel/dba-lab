-- A tenant's fleet vehicle, optionally assigned to a current driver.
CREATE TABLE [dbo].[vehicles]
(
    [id]           INT IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [tenant_id]    INT           NOT NULL,                   -- 4 bytes
    [driver_id]    INT           NULL,                       -- 4 bytes
    [plate_number] VARCHAR(20)   NOT NULL,                   -- ~8 bytes avg (20 bytes max)
    [brand]        NVARCHAR(100) NULL,                       -- ~16 bytes avg (8 chars typical, 200 bytes max)
    [model]        NVARCHAR(100) NULL,                       -- ~20 bytes avg (10 chars typical, 200 bytes max)
    [year]         SMALLINT      NULL,                       -- 2 bytes
    [is_active]    BIT           NOT NULL DEFAULT 1,         -- 1 byte
    [created_at]   DATETIME      NOT NULL DEFAULT GETDATE(), -- 8 bytes
    CONSTRAINT [FK_vehicles_tenants] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[tenants] ([id]),
    CONSTRAINT [FK_vehicles_drivers] FOREIGN KEY ([driver_id]) REFERENCES [dbo].[drivers] ([id])
);
-- Estimated row size: 4 + 4 + 4 + 8 + 16 + 20 + 2 + 1 + 8 = ~67 bytes
-- Plus row overhead (~7 bytes) = ~74 bytes per row
-- 1 million rows ≈ 71 MB
GO

CREATE UNIQUE INDEX [UX_vehicles_tenant_id_plate_number] ON [dbo].[vehicles]([tenant_id], [plate_number]);
GO

CREATE INDEX [IX_vehicles_driver_id] ON [dbo].[vehicles]([driver_id]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A tenant''s fleet vehicle, optionally assigned to a current driver.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'vehicles';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each vehicle (primary key). INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'vehicles',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tenant this vehicle belongs to. References tenants.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'vehicles',
    @level2type = N'Column', @level2name = N'tenant_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Currently assigned driver, if any. References drivers.id. INT, nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'vehicles',
    @level2type = N'Column', @level2name = N'driver_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'License plate number, unique per tenant. VARCHAR(20).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'vehicles',
    @level2type = N'Column', @level2name = N'plate_number';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional vehicle manufacturer/brand. NVARCHAR(100).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'vehicles',
    @level2type = N'Column', @level2name = N'brand';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional vehicle model. NVARCHAR(100).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'vehicles',
    @level2type = N'Column', @level2name = N'model';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional model year. SMALLINT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'vehicles',
    @level2type = N'Column', @level2name = N'year';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether the vehicle is currently in service (1) or decommissioned (0). BIT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'vehicles',
    @level2type = N'Column', @level2name = N'is_active';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the vehicle record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'vehicles',
    @level2type = N'Column', @level2name = N'created_at';
GO
