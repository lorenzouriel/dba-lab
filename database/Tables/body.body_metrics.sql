-- History of body measurements (weight, height, body fat) over time, one row per user per date logged,
-- enabling trend tracking.
CREATE TABLE [body].[body_metrics]
(
    [id]                INT          IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]           INT          NOT NULL,                             -- 4 bytes
    [measured_date]     DATE         NOT NULL,                             -- 3 bytes
    [weight_kg]         DECIMAL(5,2) NULL,                                 -- 5 bytes (precision 5)
    [height_cm]         DECIMAL(5,2) NULL,                                 -- 5 bytes (precision 5)
    [body_fat_percent]  DECIMAL(4,2) NULL,                                 -- 5 bytes (precision 4)
    [notes]             VARCHAR(500) NULL,                                 -- ~60 bytes avg (500 bytes max)
    [status]            TINYINT      NOT NULL DEFAULT 1,                   -- 1 byte
    [created_at]        DATETIME     NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_body_metrics_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [UQ_body_metrics_user_date] UNIQUE ([user_id], [measured_date])
);
-- Estimated row size: 4 + 4 + 3 + 5 + 5 + 5 + 60 + 1 + 8 = ~95 bytes
-- Plus row overhead (~7 bytes) = ~102 bytes per row
-- 1 million rows ≈ 97 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'History of body measurements (weight, height, body fat) over time, one row per user per date logged, enabling trend tracking.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'body_metrics';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each body metrics record (primary key). INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'body_metrics',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user this measurement belongs to. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'body_metrics',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the measurements were taken. DATE.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'body_metrics',
    @level2type = N'Column', @level2name = N'measured_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Body weight measured in kilograms. DECIMAL(5,2).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'body_metrics',
    @level2type = N'Column', @level2name = N'weight_kg';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Height measured in centimeters. DECIMAL(5,2).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'body_metrics',
    @level2type = N'Column', @level2name = N'height_cm';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Body fat percentage. DECIMAL(4,2).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'body_metrics',
    @level2type = N'Column', @level2name = N'body_fat_percent';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional notes about this measurement (e.g., method used). VARCHAR(500).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'body_metrics',
    @level2type = N'Column', @level2name = N'notes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted). TINYINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'body_metrics',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this body metrics record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'body_metrics',
    @level2type = N'Column', @level2name = N'created_at';
GO
