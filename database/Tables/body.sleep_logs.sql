-- Nightly sleep log: bed time, wake time, and total hours slept (computed automatically, cannot be set directly).
-- QUOTED_IDENTIFIER must be ON to create a table with a PERSISTED computed column.
SET QUOTED_IDENTIFIER ON;
GO

CREATE TABLE [body].[sleep_logs]
(
    [id]          INT          IDENTITY (1, 1) PRIMARY KEY NOT NULL,             -- 4 bytes
    [user_id]     INT          NOT NULL,                                         -- 4 bytes
    [bed_time]    DATETIME2    NOT NULL,                                         -- 8 bytes (default precision)
    [wake_time]   DATETIME2    NOT NULL,                                         -- 8 bytes (default precision)
    [total_hours] AS (ROUND(DATEDIFF(SECOND, [bed_time], [wake_time]) / 3600.0, 2)) PERSISTED, -- computed, 9 bytes
    [notes]       VARCHAR(500) NULL,                                             -- ~60 bytes avg (500 bytes max)
    [status]      TINYINT      NOT NULL DEFAULT 1,                               -- 1 byte
    [created_at]  DATETIME     NOT NULL DEFAULT GETDATE(),                       -- 8 bytes
    CONSTRAINT [FK_sleep_logs_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [CK_sleep_logs_times] CHECK ([wake_time] > [bed_time])
);
-- Estimated row size: 4 + 4 + 8 + 8 + 9 + 60 + 1 + 8 = ~102 bytes
-- Plus row overhead (~7 bytes) = ~109 bytes per row
-- 1 million rows ≈ 104 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Nightly sleep log: bed time, wake time, and total hours slept (computed automatically, cannot be set directly).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'sleep_logs';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each sleep log entry (primary key). INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'sleep_logs',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who owns this sleep log. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'sleep_logs',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time the user went to bed. DATETIME2.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'sleep_logs',
    @level2type = N'Column', @level2name = N'bed_time';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time the user woke up. Must be after bed_time (enforced by check constraint); correctly handles sessions that cross midnight since both are full datetime2 values. DATETIME2.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'sleep_logs',
    @level2type = N'Column', @level2name = N'wake_time';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total hours slept, automatically computed from wake_time minus bed_time. Cannot be written directly (computed column).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'sleep_logs',
    @level2type = N'Column', @level2name = N'total_hours';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional notes about sleep quality or disturbances. VARCHAR(500).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'sleep_logs',
    @level2type = N'Column', @level2name = N'notes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted). TINYINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'sleep_logs',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this sleep log entry was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'sleep_logs',
    @level2type = N'Column', @level2name = N'created_at';
GO
