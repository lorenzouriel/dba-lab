-- Append-only history of personal records, a new row is inserted each time a record is broken for a given
-- exercise/metric_type, not updated in place.
CREATE TABLE [body].[personal_records]
(
    [id]             INT           IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]        INT           NOT NULL,                             -- 4 bytes
    [exercise_name]  VARCHAR(100)  NOT NULL,                             -- ~25 bytes avg (100 bytes max)
    [metric_type]    VARCHAR(50)   NOT NULL,                             -- ~15 bytes avg (50 bytes max)
    [value]          DECIMAL(10,2) NOT NULL,                             -- 9 bytes (precision 10)
    [unit]           VARCHAR(20)   NOT NULL,                             -- ~8 bytes avg (20 bytes max)
    [achieved_date]  DATE          NOT NULL,                             -- 3 bytes
    [notes]          VARCHAR(500)  NULL,                                 -- ~60 bytes avg (500 bytes max)
    [status]         TINYINT       NOT NULL DEFAULT 1,                   -- 1 byte
    [created_at]     DATETIME      NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_personal_records_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE
);
-- Estimated row size: 4 + 4 + 25 + 15 + 9 + 8 + 3 + 60 + 1 + 8 = ~137 bytes
-- Plus row overhead (~7 bytes) = ~144 bytes per row
-- 1 million rows ≈ 137 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Append-only history of personal records, a new row is inserted each time a record is broken for a given exercise/metric_type, not updated in place.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'personal_records';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each personal record entry (primary key). INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'personal_records',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who achieved this record. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'personal_records',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name of the exercise this record applies to (e.g., Bench Press, Deadlift, 5k Run). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'personal_records',
    @level2type = N'Column', @level2name = N'exercise_name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Type of metric being recorded (e.g., Max Weight, Max Reps, Best Time). VARCHAR(50).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'personal_records',
    @level2type = N'Column', @level2name = N'metric_type';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Numeric value achieved for this record. DECIMAL(10,2).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'personal_records',
    @level2type = N'Column', @level2name = N'value';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unit of measurement for the value (e.g., kg, reps, seconds). VARCHAR(20).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'personal_records',
    @level2type = N'Column', @level2name = N'unit';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the record was achieved. DATE.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'personal_records',
    @level2type = N'Column', @level2name = N'achieved_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional notes about the conditions under which the record was set. VARCHAR(500).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'personal_records',
    @level2type = N'Column', @level2name = N'notes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted). TINYINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'personal_records',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this personal record entry was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'personal_records',
    @level2type = N'Column', @level2name = N'created_at';
GO
