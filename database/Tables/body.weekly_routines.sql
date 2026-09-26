-- Reusable weekly training plan template: what is normally planned for each day of the week, one row per user per day.
CREATE TABLE [body].[weekly_routines]
(
    [id]           INT          IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]      INT          NOT NULL,                             -- 4 bytes
    [day_of_week]  SMALLINT     NOT NULL,                             -- 2 bytes
    [routine_name] VARCHAR(100) NOT NULL,                             -- ~25 bytes avg (100 bytes max)
    [description]  VARCHAR(500) NULL,                                 -- ~60 bytes avg (500 bytes max)
    [status]       TINYINT      NOT NULL DEFAULT 1,                   -- 1 byte
    [created_at]   DATETIME     NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_weekly_routines_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [CK_weekly_routines_day_of_week] CHECK ([day_of_week] BETWEEN 0 AND 6),
    CONSTRAINT [UQ_weekly_routines_user_day] UNIQUE ([user_id], [day_of_week])
);
-- Estimated row size: 4 + 4 + 2 + 25 + 60 + 1 + 8 = ~104 bytes
-- Plus row overhead (~7 bytes) = ~111 bytes per row
-- 1 million rows ≈ 106 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Reusable weekly training plan template: what is normally planned for each day of the week, one row per user per day.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'weekly_routines';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each weekly routine entry (primary key). INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'weekly_routines',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who owns this routine. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'weekly_routines',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Day of week this routine applies to: 0=Sunday, 1=Monday, ..., 6=Saturday. SMALLINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'weekly_routines',
    @level2type = N'Column', @level2name = N'day_of_week';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name of the planned routine for this day (e.g., Push Day, Rest Day, Leg Day). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'weekly_routines',
    @level2type = N'Column', @level2name = N'routine_name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional details about what this routine involves. VARCHAR(500).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'weekly_routines',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted). TINYINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'weekly_routines',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this routine entry was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'weekly_routines',
    @level2type = N'Column', @level2name = N'created_at';
GO
