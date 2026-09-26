-- Append-only log of caffeine/alcohol/nicotine intake with a timestamp, so entries can be correlated
-- against the same night's body.sleep_logs.
CREATE TABLE [body].[substance_logs]
(
    [id]              INT          IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]         INT          NOT NULL,                             -- 4 bytes
    [consumed_at]     DATETIME2    NOT NULL,                             -- 8 bytes (default precision)
    [substance_type]  VARCHAR(20)  NOT NULL,                             -- ~8 bytes avg (20 bytes max)
    [amount]          DECIMAL(6,2) NOT NULL,                             -- 5 bytes (precision 6)
    [unit]            VARCHAR(20)  NOT NULL,                             -- ~8 bytes avg (20 bytes max)
    [notes]           VARCHAR(500) NULL,                                 -- ~60 bytes avg (500 bytes max)
    [status]          TINYINT      NOT NULL DEFAULT 1,                   -- 1 byte
    [created_at]      DATETIME     NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_substance_logs_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
);
-- Estimated row size: 4 + 4 + 8 + 8 + 5 + 8 + 60 + 1 + 8 = ~106 bytes
-- Plus row overhead (~7 bytes) = ~113 bytes per row
-- 1 million rows ≈ 108 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Append-only log of caffeine/alcohol/nicotine intake with a timestamp, so entries can be correlated against the same night''s body.sleep_logs.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'substance_logs';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each substance log entry (primary key). INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'substance_logs',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who logged this intake. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'substance_logs',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time the substance was consumed. DATETIME2.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'substance_logs',
    @level2type = N'Column', @level2name = N'consumed_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Type of substance consumed (e.g., Caffeine, Alcohol, Nicotine). VARCHAR(20).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'substance_logs',
    @level2type = N'Column', @level2name = N'substance_type';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Quantity consumed, in the unit given by the unit column (e.g., mg of caffeine, standard drinks of alcohol). DECIMAL(6,2).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'substance_logs',
    @level2type = N'Column', @level2name = N'amount';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unit of measurement for amount (e.g., mg, ml, drinks). VARCHAR(20).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'substance_logs',
    @level2type = N'Column', @level2name = N'unit';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional notes (e.g., drink/product name, context). VARCHAR(500).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'substance_logs',
    @level2type = N'Column', @level2name = N'notes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted). TINYINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'substance_logs',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this substance log entry was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'substance_logs',
    @level2type = N'Column', @level2name = N'created_at';
GO
