-- Habit definitions: the recurring non-workout habits a user wants to track (vitamins, stretching,
-- reading, no-sugar, screen-time limit, etc.). Actual daily adherence is recorded in body.habit_logs.
CREATE TABLE [body].[habits]
(
    [id]                INT          IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]           INT          NOT NULL,                             -- 4 bytes
    [habit_name]        VARCHAR(100) NOT NULL,                             -- ~25 bytes avg (100 bytes max)
    [category]          VARCHAR(50)  NULL,                                 -- ~15 bytes avg (50 bytes max)
    [target_frequency]  VARCHAR(20)  NOT NULL DEFAULT 'Daily',             -- ~8 bytes avg (20 bytes max)
    [description]       VARCHAR(500) NULL,                                 -- ~60 bytes avg (500 bytes max)
    [status]            TINYINT      NOT NULL DEFAULT 1,                   -- 1 byte
    [created_at]        DATETIME     NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_habits_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [UQ_habits_user_name] UNIQUE ([user_id], [habit_name])
);
-- Estimated row size: 4 + 4 + 25 + 15 + 8 + 60 + 1 + 8 = ~125 bytes
-- Plus row overhead (~7 bytes) = ~132 bytes per row
-- 1 million rows ≈ 126 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Habit definitions: the recurring non-workout habits a user wants to track. Actual daily adherence is recorded in body.habit_logs.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habits';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each habit definition (primary key). INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habits',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who owns this habit. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habits',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name of the habit being tracked (e.g., Take Vitamins, Stretch, Read 10 Pages, No Sugar). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habits',
    @level2type = N'Column', @level2name = N'habit_name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional free-text category label (e.g., Health, Mindfulness, Productivity). VARCHAR(50).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habits',
    @level2type = N'Column', @level2name = N'category';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'How often the habit is meant to be performed (e.g., Daily, Weekly, Custom). VARCHAR(20).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habits',
    @level2type = N'Column', @level2name = N'target_frequency';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional details about the habit. VARCHAR(500).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habits',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted/Archived). TINYINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habits',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this habit definition was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'habits',
    @level2type = N'Column', @level2name = N'created_at';
GO
