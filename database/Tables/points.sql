-- Raw GPS telemetry pings from a device. High-volume; grouped into tracks/stops downstream.
CREATE TABLE [dbo].[points]
(
    [id]          BIGINT       IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 8 bytes
    [device_id]   INT          NOT NULL,                             -- 4 bytes
    [vehicle_id]  INT          NOT NULL,                             -- 4 bytes
    [track_id]    BIGINT       NULL,                                 -- 8 bytes
    [stop_id]     BIGINT       NULL,                                 -- 8 bytes
    [recorded_at] DATETIME2    NOT NULL,                             -- 8 bytes (default precision)
    [latitude]    DECIMAL(9,6) NOT NULL,                             -- 5 bytes (precision <= 9)
    [longitude]   DECIMAL(9,6) NOT NULL,                             -- 5 bytes (precision <= 9)
    [speed_kmh]   DECIMAL(6,2) NULL,                                 -- 5 bytes (precision <= 9)
    [heading]     SMALLINT     NULL,                                 -- 2 bytes
    [ignition_on] BIT          NULL,                                 -- 1 byte
    [created_at]  DATETIME     NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_points_devices] FOREIGN KEY ([device_id]) REFERENCES [dbo].[devices] ([id]),
    CONSTRAINT [FK_points_vehicles] FOREIGN KEY ([vehicle_id]) REFERENCES [dbo].[vehicles] ([id]),
    CONSTRAINT [FK_points_tracks] FOREIGN KEY ([track_id]) REFERENCES [dbo].[tracks] ([id]),
    CONSTRAINT [FK_points_stops] FOREIGN KEY ([stop_id]) REFERENCES [dbo].[stops] ([id])
);
-- Estimated row size: 8 + 4 + 4 + 8 + 8 + 8 + 5 + 5 + 5 + 2 + 1 + 8 = ~66 bytes
-- Plus row overhead (~7 bytes) = ~73 bytes per row
-- 1 million rows ≈ 70 MB
-- Realistic scenario: 1,000 devices pinging every 30s ≈ 2.9M points/day ≈ ~200 MB/day ≈ ~73 GB/year
GO

CREATE INDEX [IX_points_device_id_recorded_at] ON [dbo].[points]([device_id], [recorded_at]);
GO

CREATE INDEX [IX_points_track_id] ON [dbo].[points]([track_id]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Raw GPS telemetry pings from a device. High-volume; grouped into tracks/stops downstream.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each point (primary key). BIGINT: highest-volume table, one row per GPS ping.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Device that reported this point. References devices.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points',
    @level2type = N'Column', @level2name = N'device_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Vehicle the reporting device was installed in. References vehicles.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points',
    @level2type = N'Column', @level2name = N'vehicle_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Track this point was grouped into (moving), if processed. References tracks.id. BIGINT, nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points',
    @level2type = N'Column', @level2name = N'track_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stop this point was grouped into (stationary), if processed. References stops.id. BIGINT, nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points',
    @level2type = N'Column', @level2name = N'stop_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp the device recorded this GPS fix (device clock, not ingestion time). DATETIME2.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points',
    @level2type = N'Column', @level2name = N'recorded_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Latitude of the GPS fix. DECIMAL(9,6).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points',
    @level2type = N'Column', @level2name = N'latitude';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Longitude of the GPS fix. DECIMAL(9,6).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points',
    @level2type = N'Column', @level2name = N'longitude';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Instantaneous speed at this fix, in km/h. DECIMAL(6,2), nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points',
    @level2type = N'Column', @level2name = N'speed_kmh';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Compass heading at this fix, in degrees (0-359). SMALLINT, nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points',
    @level2type = N'Column', @level2name = N'heading';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether the ignition was on at this fix. BIT, nullable if unsupported by the device.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points',
    @level2type = N'Column', @level2name = N'ignition_on';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the point row was inserted (ingestion time). DATETIME.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'points',
    @level2type = N'Column', @level2name = N'created_at';
GO
