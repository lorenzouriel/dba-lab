-- A trip: the continuous, in-motion segment of a vehicle's journey between two stops.
CREATE TABLE [dbo].[tracks]
(
    [id]            BIGINT       IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 8 bytes
    [tenant_id]     INT          NOT NULL,                             -- 4 bytes
    [vehicle_id]    INT          NOT NULL,                             -- 4 bytes
    [device_id]     INT          NOT NULL,                             -- 4 bytes
    [driver_id]     INT          NULL,                                 -- 4 bytes
    [started_at]    DATETIME2    NOT NULL,                             -- 8 bytes (default precision)
    [ended_at]      DATETIME2    NULL,                                 -- 8 bytes (default precision)
    [distance_km]   DECIMAL(9,2) NULL,                                 -- 5 bytes (precision <= 9)
    [max_speed_kmh] DECIMAL(6,2) NULL,                                 -- 5 bytes (precision <= 9)
    [created_at]    DATETIME     NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_tracks_tenants] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[tenants] ([id]),
    CONSTRAINT [FK_tracks_vehicles] FOREIGN KEY ([vehicle_id]) REFERENCES [dbo].[vehicles] ([id]),
    CONSTRAINT [FK_tracks_devices] FOREIGN KEY ([device_id]) REFERENCES [dbo].[devices] ([id]),
    CONSTRAINT [FK_tracks_drivers] FOREIGN KEY ([driver_id]) REFERENCES [dbo].[drivers] ([id])
);
-- Estimated row size: 8 + 4 + 4 + 4 + 4 + 8 + 8 + 5 + 5 + 8 = ~58 bytes
-- Plus row overhead (~7 bytes) = ~65 bytes per row
-- 1 million rows ≈ 62 MB -- 10 million rows (busy fleet, ~1 year) ≈ 620 MB
GO

CREATE INDEX [IX_tracks_vehicle_id_started_at] ON [dbo].[tracks]([vehicle_id], [started_at]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A trip: the continuous, in-motion segment of a vehicle''s journey between two stops.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tracks';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each track (primary key). BIGINT: high-volume, time-series table.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tracks',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tenant this track belongs to. References tenants.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tracks',
    @level2type = N'Column', @level2name = N'tenant_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Vehicle that made this trip. References vehicles.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tracks',
    @level2type = N'Column', @level2name = N'vehicle_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Device that reported this trip''s points. References devices.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tracks',
    @level2type = N'Column', @level2name = N'device_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Driver assigned during this trip, if known. References drivers.id. INT, nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tracks',
    @level2type = N'Column', @level2name = N'driver_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When the trip started. DATETIME2.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tracks',
    @level2type = N'Column', @level2name = N'started_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When the trip ended; NULL while the vehicle is still moving. DATETIME2, nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tracks',
    @level2type = N'Column', @level2name = N'ended_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total distance covered during the trip, in kilometers. DECIMAL(9,2), nullable until computed.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tracks',
    @level2type = N'Column', @level2name = N'distance_km';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Maximum speed reached during the trip, in km/h. DECIMAL(6,2), nullable until computed.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tracks',
    @level2type = N'Column', @level2name = N'max_speed_kmh';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the track record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'tracks',
    @level2type = N'Column', @level2name = N'created_at';
GO
