-- A stationary period of a vehicle, optionally at the end of a track.
CREATE TABLE [dbo].[stops]
(
    [id]         BIGINT        IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 8 bytes
    [tenant_id]  INT           NOT NULL,                             -- 4 bytes
    [vehicle_id] INT           NOT NULL,                             -- 4 bytes
    [track_id]   BIGINT        NULL,                                 -- 8 bytes
    [started_at] DATETIME2     NOT NULL,                             -- 8 bytes (default precision)
    [ended_at]   DATETIME2     NULL,                                 -- 8 bytes (default precision)
    [latitude]   DECIMAL(9,6)  NOT NULL,                             -- 5 bytes (precision <= 9)
    [longitude]  DECIMAL(9,6)  NOT NULL,                             -- 5 bytes (precision <= 9)
    [address]    NVARCHAR(300) NULL,                                 -- ~60 bytes avg (30 chars typical, 600 bytes max)
    [created_at] DATETIME      NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_stops_tenants] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[tenants] ([id]),
    CONSTRAINT [FK_stops_vehicles] FOREIGN KEY ([vehicle_id]) REFERENCES [dbo].[vehicles] ([id]),
    CONSTRAINT [FK_stops_tracks] FOREIGN KEY ([track_id]) REFERENCES [dbo].[tracks] ([id])
);
-- Estimated row size: 8 + 4 + 4 + 8 + 8 + 8 + 5 + 5 + 60 + 8 = ~118 bytes
-- Plus row overhead (~7 bytes) = ~125 bytes per row
-- 1 million rows ≈ 119 MB -- 10 million rows (busy fleet, ~1 year) ≈ 1.16 GB
GO

CREATE INDEX [IX_stops_vehicle_id_started_at] ON [dbo].[stops]([vehicle_id], [started_at]);
GO

CREATE INDEX [IX_stops_track_id] ON [dbo].[stops]([track_id]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A stationary period of a vehicle, optionally at the end of a track.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'stops';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each stop (primary key). BIGINT: high-volume, time-series table.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'stops',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tenant this stop belongs to. References tenants.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'stops',
    @level2type = N'Column', @level2name = N'tenant_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Vehicle that made this stop. References vehicles.id. INT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'stops',
    @level2type = N'Column', @level2name = N'vehicle_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Track this stop follows, if any. References tracks.id. BIGINT, nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'stops',
    @level2type = N'Column', @level2name = N'track_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When the vehicle became stationary. DATETIME2.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'stops',
    @level2type = N'Column', @level2name = N'started_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'When the vehicle resumed moving; NULL while still stopped. DATETIME2, nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'stops',
    @level2type = N'Column', @level2name = N'ended_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Latitude where the vehicle stopped. DECIMAL(9,6).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'stops',
    @level2type = N'Column', @level2name = N'latitude';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Longitude where the vehicle stopped. DECIMAL(9,6).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'stops',
    @level2type = N'Column', @level2name = N'longitude';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional reverse-geocoded street address of the stop location. NVARCHAR(300).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'stops',
    @level2type = N'Column', @level2name = N'address';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the stop record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'stops',
    @level2type = N'Column', @level2name = N'created_at';
GO
