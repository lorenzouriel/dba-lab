-- Session-level logged training sessions (train of the day) -- one row per workout performed.
CREATE TABLE [body].[workouts]
(
    [id]               INT          IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]          INT          NOT NULL,                             -- 4 bytes
    [workout_date]     DATE         NOT NULL,                             -- 3 bytes
    [routine_name]     VARCHAR(100) NOT NULL,                             -- ~25 bytes avg (100 bytes max)
    [duration_minutes] INT          NULL,                                 -- 4 bytes
    [calories_burned]  DECIMAL(8,2) NULL,                                 -- 5 bytes (precision 8)
    [notes]            VARCHAR(500) NULL,                                 -- ~60 bytes avg (500 bytes max)
    [status]           TINYINT      NOT NULL DEFAULT 1,                  -- 1 byte
    [created_at]       DATETIME     NOT NULL DEFAULT GETDATE(),          -- 8 bytes
    CONSTRAINT [FK_workouts_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
);
-- Estimated row size: 4 + 4 + 3 + 25 + 4 + 5 + 60 + 1 + 8 = ~114 bytes
-- Plus row overhead (~7 bytes) = ~121 bytes per row
-- 1 million rows ≈ 115 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Session-level logged training sessions (train of the day) -- one row per workout performed.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'workouts';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each workout record (primary key). INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'workouts',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who performed this workout. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'workouts',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the workout was performed. DATE.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'workouts',
    @level2type = N'Column', @level2name = N'workout_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name of the routine performed during this session (e.g., Push Day, Leg Day). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'workouts',
    @level2type = N'Column', @level2name = N'routine_name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total duration of the workout session, in minutes. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'workouts',
    @level2type = N'Column', @level2name = N'duration_minutes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Estimated calories burned during the workout session. DECIMAL(8,2).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'workouts',
    @level2type = N'Column', @level2name = N'calories_burned';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional notes about the workout session. VARCHAR(500).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'workouts',
    @level2type = N'Column', @level2name = N'notes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted). TINYINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'workouts',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this workout record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'workouts',
    @level2type = N'Column', @level2name = N'created_at';
GO
