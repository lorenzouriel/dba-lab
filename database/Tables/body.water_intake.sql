-- Daily water intake as a running total, one row per user per day, incremented as water is logged throughout
-- the day.
CREATE TABLE [body].[water_intake]
(
    [id]          INT      IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]     INT      NOT NULL,                             -- 4 bytes
    [intake_date] DATE     NOT NULL,                             -- 3 bytes
    [amount_ml]   INT      NOT NULL DEFAULT 0,                   -- 4 bytes
    [status]      TINYINT  NOT NULL DEFAULT 1,                   -- 1 byte
    [created_at]  DATETIME NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_water_intake_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [UQ_water_intake_user_date] UNIQUE ([user_id], [intake_date])
);
-- Estimated row size: 4 + 4 + 3 + 4 + 1 + 8 = ~24 bytes
-- Plus row overhead (~7 bytes) = ~31 bytes per row
-- 1 million rows ≈ 30 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Daily water intake as a running total -- one row per user per day, incremented as water is logged throughout the day.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'water_intake';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each water intake record (primary key). INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'water_intake',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who logged this water intake. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'water_intake',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the water intake total applies to. DATE.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'water_intake',
    @level2type = N'Column', @level2name = N'intake_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Running total amount of water consumed on this date, in milliliters. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'water_intake',
    @level2type = N'Column', @level2name = N'amount_ml';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted). TINYINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'water_intake',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this water intake record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'water_intake',
    @level2type = N'Column', @level2name = N'created_at';
GO
