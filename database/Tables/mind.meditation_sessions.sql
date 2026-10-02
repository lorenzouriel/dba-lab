-- Per-session meditation log with optional before/after mood ratings.
CREATE TABLE [mind].[meditation_sessions]
(
    [id]                INT         IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]           INT         NOT NULL,                             -- 4 bytes
    [session_date]      DATE        NOT NULL,                             -- 3 bytes
    [duration_minutes]  SMALLINT    NOT NULL,                             -- 2 bytes
    [meditation_type]   VARCHAR(50) NOT NULL,                             -- ~15 bytes avg (50 bytes max)
    [mood_before]       SMALLINT    NULL,                                 -- 2 bytes
    [mood_after]        SMALLINT    NULL,                                 -- 2 bytes
    [notes]             VARCHAR(500) NULL,                                -- ~60 bytes avg (500 bytes max)
    [status]            TINYINT     NOT NULL DEFAULT 1,                   -- 1 byte
    [created_at]        DATETIME    NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_meditation_sessions_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [CK_meditation_sessions_duration] CHECK ([duration_minutes] > 0),
    CONSTRAINT [CK_meditation_sessions_mood_before] CHECK ([mood_before] IS NULL OR [mood_before] BETWEEN 1 AND 5),
    CONSTRAINT [CK_meditation_sessions_mood_after] CHECK ([mood_after] IS NULL OR [mood_after] BETWEEN 1 AND 5)
);
-- Estimated row size: 4 + 4 + 3 + 2 + 15 + 2 + 2 + 60 + 1 + 8 = ~101 bytes
-- Plus row overhead (~7 bytes) = ~108 bytes per row
-- 1 million rows ≈ 103 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Per-session meditation log with optional before/after mood ratings.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'meditation_sessions';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each meditation session record (primary key). INT.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'meditation_sessions',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who logged this session. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'meditation_sessions',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the meditation session took place. DATE.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'meditation_sessions',
    @level2type = N'Column', @level2name = N'session_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Length of the session in minutes; must be greater than zero. SMALLINT.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'meditation_sessions',
    @level2type = N'Column', @level2name = N'duration_minutes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Type of meditation practiced (e.g., Guided, Breathing, Body Scan). VARCHAR(50).',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'meditation_sessions',
    @level2type = N'Column', @level2name = N'meditation_type';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional self-reported mood before the session, on a 1-5 scale. SMALLINT.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'meditation_sessions',
    @level2type = N'Column', @level2name = N'mood_before';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional self-reported mood after the session, on a 1-5 scale. SMALLINT.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'meditation_sessions',
    @level2type = N'Column', @level2name = N'mood_after';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional free-text notes about the session. VARCHAR(500).',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'meditation_sessions',
    @level2type = N'Column', @level2name = N'notes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted). TINYINT.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'meditation_sessions',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this session record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'meditation_sessions',
    @level2type = N'Column', @level2name = N'created_at';
GO
