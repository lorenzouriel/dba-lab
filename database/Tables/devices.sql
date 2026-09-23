-- The GPS/telemetry hardware unit installed in a vehicle.
CREATE TABLE [dbo].[devices]
(
    [id]            INT IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [tenant_id]     INT           NOT NULL,                   -- 4 bytes
    [vehicle_id]    INT           NULL,                       -- 4 bytes
    [serial_number] VARCHAR(50)   NOT NULL,                   -- ~20 bytes avg (50 bytes max)
    [imei]          VARCHAR(20)   NULL,                       -- ~15 bytes avg (IMEI is 15 digits, 20 bytes max)
    [model]         NVARCHAR(100) NULL,                       -- ~20 bytes avg (10 chars typical, 200 bytes max)
    [installed_at]  DATETIME      NULL,                       -- 8 bytes
    [is_active]     BIT           NOT NULL DEFAULT 1,         -- 1 byte
    [created_at]    DATETIME      NOT NULL DEFAULT GETDATE(), -- 8 bytes
    CONSTRAINT [FK_devices_tenants] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[tenants] ([id]),
    CONSTRAINT [FK_devices_vehicles] FOREIGN KEY ([vehicle_id]) REFERENCES [dbo].[vehicles] ([id])
);
-- Estimated row size: 4 + 4 + 4 + 20 + 15 + 20 + 8 + 1 + 8 = ~84 bytes
-- Plus row overhead (~7 bytes) = ~91 bytes per row
-- 1 million rows ≈ 87 MB
GO

CREATE UNIQUE INDEX [UX_devices_serial_number] ON [dbo].[devices]([serial_number]);
GO

CREATE INDEX [IX_devices_vehicle_id] ON [dbo].[devices]([vehicle_id]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The GPS/telemetry hardware unit installed in a vehicle.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'devices';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each device (primary key). INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'devices',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tenant this device belongs to. References tenants.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'devices',
    @level2type = N'Column', @level2name = N'tenant_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Vehicle this device is currently installed in, if any. References vehicles.id. INT, nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'devices',
    @level2type = N'Column', @level2name = N'vehicle_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Manufacturer serial number, unique across all tenants. VARCHAR(50).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'devices',
    @level2type = N'Column', @level2name = N'serial_number';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional IMEI of the device''s cellular modem. VARCHAR(20).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'devices',
    @level2type = N'Column', @level2name = N'imei';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional device model/hardware version. NVARCHAR(100).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'devices',
    @level2type = N'Column', @level2name = N'model';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When the device was physically installed in its vehicle. DATETIME, nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'devices',
    @level2type = N'Column', @level2name = N'installed_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether the device is currently active/reporting (1) or decommissioned (0). BIT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'devices',
    @level2type = N'Column', @level2name = N'is_active';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the device record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'devices',
    @level2type = N'Column', @level2name = N'created_at';
GO
