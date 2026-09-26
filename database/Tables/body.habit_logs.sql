-- Daily adherence log for a habit -- one row per user per habit per date, marking whether it was
-- completed or skipped that day.
CREATE TABLE [body].[habit_logs]
(
    [id]            INT          IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]       INT          NOT NULL,                             -- 4 bytes
    [habit_id]      INT          NOT NULL,                             -- 4 bytes
    [log_date]      DATE         NOT NULL,                             -- 3 bytes
    [is_completed]  BIT          NOT NULL DEFAULT 0,                   -- 1 byte
    [notes]         VARCHAR(500) NULL,                                 -- ~60 bytes avg (500 bytes max)
    [status]        TINYINT      NOT NULL DEFAULT 1,                   -- 1 byte
    [created_at]    DATETIME     NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_habit_logs_users]  FOREIGN KEY ([user_id])  REFERENCES [dbo].[users]  ([id]) ON DELETE CASCADE,
    -- No ON DELETE CASCADE here: habits already cascades from users, so cascading here too would give
    -- SQL Server two cascade paths from users to habit_logs, which it rejects at deploy time.
    CONSTRAINT [FK_habit_logs_habits] FOREIGN KEY ([habit_id]) REFERENCES [body].[habits] ([id]),
    CONSTRAINT [UQ_habit_logs_user_habit_date] UNIQUE ([user_id], [habit_id], [log_date])
);
-- Estimated row size: 4 + 4 + 4 + 3 + 1 + 60 + 1 + 8 = ~85 bytes
-- Plus row overhead (~7 bytes) = ~92 bytes per row
-- 1 million rows ≈ 88 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Daily adherence log for a habit -- one row per user per habit per date, marking whether it was completed or skipped that day.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habit_logs';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each habit log entry (primary key). INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habit_logs',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who logged this entry. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habit_logs',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the habit this log entry tracks. References body.habits.id. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habit_logs',
    @level2type = N'Column', @level2name = N'habit_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date this adherence entry applies to. DATE.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habit_logs',
    @level2type = N'Column', @level2name = N'log_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Whether the habit was completed on this date (1) or skipped (0). BIT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habit_logs',
    @level2type = N'Column', @level2name = N'is_completed';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional notes about this entry (e.g., reason for skipping). VARCHAR(500).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habit_logs',
    @level2type = N'Column', @level2name = N'notes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted). TINYINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habit_logs',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this habit log entry was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habit_logs',
    @level2type = N'Column', @level2name = N'created_at';
GO
