-- Per-meal nutrition log. Daily totals are computed by summing this table's rows for a given date/user,
-- not stored separately.
CREATE TABLE [body].[meals]
(
    [id]             INT          IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]        INT          NOT NULL,                             -- 4 bytes
    [meal_date]      DATE         NOT NULL,                             -- 3 bytes
    [meal_type]      VARCHAR(50)  NOT NULL,                             -- ~15 bytes avg (50 bytes max)
    [description]    VARCHAR(500) NULL,                                 -- ~60 bytes avg (500 bytes max)
    [calories]       DECIMAL(8,2) NOT NULL,                             -- 5 bytes (precision 8)
    [protein_grams]  DECIMAL(6,2) NULL,                                 -- 5 bytes (precision 6)
    [carbs_grams]    DECIMAL(6,2) NULL,                                 -- 5 bytes (precision 6)
    [fat_grams]      DECIMAL(6,2) NULL,                                 -- 5 bytes (precision 6)
    [status]         TINYINT      NOT NULL DEFAULT 1,                   -- 1 byte
    [created_at]     DATETIME     NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_meals_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
);
-- Estimated row size: 4 + 4 + 3 + 15 + 60 + 5 + 5 + 5 + 5 + 1 + 8 = ~115 bytes
-- Plus row overhead (~7 bytes) = ~122 bytes per row
-- 1 million rows ≈ 116 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Per-meal nutrition log. Daily totals are computed by summing this table''s rows for a given date/user, not stored separately.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'meals';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each meal record (primary key). INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'meals',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who logged this meal. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'meals',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the meal was consumed. DATE.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'meals',
    @level2type = N'Column', @level2name = N'meal_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Type of meal (e.g., Breakfast, Lunch, Dinner, Snack). VARCHAR(50).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'meals',
    @level2type = N'Column', @level2name = N'meal_type';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional description of what was eaten. VARCHAR(500).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'meals',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total calories for this meal. DECIMAL(8,2).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'meals',
    @level2type = N'Column', @level2name = N'calories';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Grams of protein in this meal. DECIMAL(6,2).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'meals',
    @level2type = N'Column', @level2name = N'protein_grams';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Grams of carbohydrates in this meal. DECIMAL(6,2).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'meals',
    @level2type = N'Column', @level2name = N'carbs_grams';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Grams of fat in this meal. DECIMAL(6,2).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'meals',
    @level2type = N'Column', @level2name = N'fat_grams';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted). TINYINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'meals',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this meal record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'meals',
    @level2type = N'Column', @level2name = N'created_at';
GO
