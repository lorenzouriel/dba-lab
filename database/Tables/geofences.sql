-- A named circular zone (center + radius) used to trigger enter/exit alarms.
CREATE TABLE [dbo].[geofences]
(
    [id]            INT           IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [tenant_id]     INT           NOT NULL,                             -- 4 bytes
    [name]          NVARCHAR(200) NOT NULL,                             -- ~40 bytes avg (20 chars typical, 400 bytes max)
    [center_lat]    DECIMAL(9,6)  NOT NULL,                             -- 5 bytes (precision <= 9)
    [center_lng]    DECIMAL(9,6)  NOT NULL,                             -- 5 bytes (precision <= 9)
    [radius_meters] INT           NOT NULL,                             -- 4 bytes
    [is_active]     BIT           NOT NULL DEFAULT 1,                   -- 1 byte
    [created_at]    DATETIME      NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_geofences_tenants] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[tenants] ([id])
);
-- Estimated row size: 4 + 4 + 40 + 5 + 5 + 4 + 1 + 8 = ~71 bytes
-- Plus row overhead (~7 bytes) = ~78 bytes per row
-- 1 million rows ≈ 74 MB
GO

CREATE INDEX [IX_geofences_tenant_id] ON [dbo].[geofences]([tenant_id]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A named circular zone (center + radius) used to trigger enter/exit alarms.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'geofences';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each geofence (primary key). INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'geofences',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tenant this geofence belongs to. References tenants.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'geofences',
    @level2type = N'Column', @level2name = N'tenant_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Descriptive name of the zone (e.g. "Main Warehouse"). NVARCHAR(200).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'geofences',
    @level2type = N'Column', @level2name = N'name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Latitude of the zone''s center point. DECIMAL(9,6).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'geofences',
    @level2type = N'Column', @level2name = N'center_lat';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Longitude of the zone''s center point. DECIMAL(9,6).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'geofences',
    @level2type = N'Column', @level2name = N'center_lng';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Zone radius in meters, measured from the center point. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'geofences',
    @level2type = N'Column', @level2name = N'radius_meters';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether the geofence is currently monitored (1) or disabled (0). BIT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'geofences',
    @level2type = N'Column', @level2name = N'is_active';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the geofence record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'geofences',
    @level2type = N'Column', @level2name = N'created_at';
GO
