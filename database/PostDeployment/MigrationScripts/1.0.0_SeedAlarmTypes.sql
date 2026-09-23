-- 1.0.0_SeedAlarmTypes.sql
-- Seeds the fixed alarm_types catalog. Idempotent -- checks before inserting.

SET QUOTED_IDENTIFIER ON;
GO

PRINT 'Running: 1.0.0_SeedAlarmTypes';

IF NOT EXISTS (SELECT 1 FROM [dbo].[alarm_types])
BEGIN
    INSERT INTO [dbo].[alarm_types] ([code], [description], [severity])
    VALUES
        (N'SPEEDING',       N'Vehicle exceeded the configured speed limit', 2),
        (N'SOS',             N'Driver triggered a panic/SOS button',         3),
        (N'GEOFENCE_ENTER',  N'Vehicle entered a monitored geofence',        1),
        (N'GEOFENCE_EXIT',   N'Vehicle left a monitored geofence',           1),
        (N'IDLE',            N'Vehicle idled beyond the configured threshold', 1),
        (N'LOW_BATTERY',     N'Device battery is low',                      1),
        (N'POWER_CUT',       N'Device lost main power / was disconnected',  2),
        (N'HARSH_BRAKING',   N'Harsh braking event detected',               2);

    PRINT '  -> Alarm types seeded';
END
ELSE
BEGIN
    PRINT '  -> Alarm types already seeded, skipping';
END
GO
