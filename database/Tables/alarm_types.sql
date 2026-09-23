-- Fixed catalog of alarm kinds (speeding, sos, geofence, ...). Shared across all tenants.
CREATE TABLE [dbo].[alarm_types]
(
    [id]          TINYINT       IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 1 byte
    [code]        VARCHAR(30)   NOT NULL,                             -- ~12 bytes avg (30 bytes max)
    [description] NVARCHAR(200) NOT NULL,                             -- ~50 bytes avg (25 chars typical, 400 bytes max)
    [severity]    TINYINT       NOT NULL DEFAULT 1                    -- 1 byte
);
-- Estimated row size: 1 + 12 + 50 + 1 = ~64 bytes
-- Plus row overhead (~7 bytes) = ~71 bytes per row
-- Fixed lookup table (~10 seeded rows) -- total size negligible, well under 1 KB
GO

CREATE UNIQUE INDEX [UX_alarm_types_code] ON [dbo].[alarm_types]([code]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Fixed catalog of alarm kinds (speeding, sos, geofence, ...), shared across all tenants.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarm_types';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each alarm type (primary key). TINYINT: at most 255 alarm kinds.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarm_types',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Short unique code identifying the alarm type (e.g. SPEEDING, SOS, GEOFENCE_ENTER). VARCHAR(30).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarm_types',
    @level2type = N'Column', @level2name = N'code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Human-readable description of what triggers this alarm. NVARCHAR(200).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarm_types',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Severity level of the alarm (1=low, 2=medium, 3=high). TINYINT.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'alarm_types',
    @level2type = N'Column', @level2name = N'severity';
GO
