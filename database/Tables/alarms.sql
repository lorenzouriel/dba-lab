-- A triggered alarm event (speeding, sos, geofence, ...), optionally tied to a geofence.
CREATE TABLE [dbo].[alarms]
(
    [id]            BIGINT       IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 8 bytes
    [tenant_id]     INT          NOT NULL,                             -- 4 bytes
    [vehicle_id]    INT          NOT NULL,                             -- 4 bytes
    [device_id]     INT          NOT NULL,                             -- 4 bytes
    [alarm_type_id] TINYINT      NOT NULL,                             -- 1 byte
    [geofence_id]   INT          NULL,                                 -- 4 bytes
    [triggered_at]  DATETIME2    NOT NULL,                             -- 8 bytes (default precision)
    [latitude]      DECIMAL(9,6) NOT NULL,                             -- 5 bytes (precision <= 9)
    [longitude]     DECIMAL(9,6) NOT NULL,                             -- 5 bytes (precision <= 9)
    [is_resolved]   BIT          NOT NULL DEFAULT 0,                   -- 1 byte
    [resolved_at]   DATETIME2    NULL,                                 -- 8 bytes (default precision)
    [resolved_by]   INT          NULL,                                 -- 4 bytes
    [created_at]    DATETIME     NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_alarms_tenants] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[tenants] ([id]),
    CONSTRAINT [FK_alarms_vehicles] FOREIGN KEY ([vehicle_id]) REFERENCES [dbo].[vehicles] ([id]),
    CONSTRAINT [FK_alarms_devices] FOREIGN KEY ([device_id]) REFERENCES [dbo].[devices] ([id]),
    CONSTRAINT [FK_alarms_alarm_types] FOREIGN KEY ([alarm_type_id]) REFERENCES [dbo].[alarm_types] ([id]),
    CONSTRAINT [FK_alarms_geofences] FOREIGN KEY ([geofence_id]) REFERENCES [dbo].[geofences] ([id]),
    CONSTRAINT [FK_alarms_users] FOREIGN KEY ([resolved_by]) REFERENCES [dbo].[users] ([id])
);
-- Estimated row size: 8 + 4 + 4 + 4 + 1 + 4 + 8 + 5 + 5 + 1 + 8 + 4 + 8 = ~64 bytes
-- Plus row overhead (~7 bytes) = ~71 bytes per row
-- 1 million rows ≈ 68 MB -- 10 million rows ≈ 677 MB
GO

CREATE INDEX [IX_alarms_vehicle_id_triggered_at] ON [dbo].[alarms]([vehicle_id], [triggered_at]);
GO

CREATE INDEX [IX_alarms_tenant_id_is_resolved] ON [dbo].[alarms]([tenant_id], [is_resolved]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A triggered alarm event (speeding, sos, geofence, ...), optionally tied to a geofence.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each alarm (primary key). BIGINT: high-volume, time-series table.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tenant this alarm belongs to. References tenants.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'tenant_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Vehicle the alarm was triggered for. References vehicles.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'vehicle_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Device that reported the alarm. References devices.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'device_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Kind of alarm. References alarm_types.id. TINYINT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'alarm_type_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Geofence involved, for GEOFENCE_ENTER/GEOFENCE_EXIT alarms. References geofences.id. INT, nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'geofence_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When the alarm condition occurred. DATETIME2.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'triggered_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Latitude where the alarm was triggered. DECIMAL(9,6).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'latitude';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Longitude where the alarm was triggered. DECIMAL(9,6).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'longitude';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether the alarm has been acknowledged/resolved. BIT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'is_resolved';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When the alarm was resolved. DATETIME2, nullable until resolved.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'resolved_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'User who resolved the alarm. References users.id. INT, nullable until resolved.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'resolved_by';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the alarm record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarms',
    @level2type = N'Column', @level2name = N'created_at';
GO
