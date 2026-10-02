-- Tracks user-defined financial goals and their progress toward a target amount.
CREATE TABLE [plan].[goals]
(
    [id]             INT           IDENTITY (1, 1) PRIMARY KEY NOT NULL,   -- 4 bytes
    [user_id]        INT           NOT NULL,                               -- 4 bytes
    [name]           VARCHAR(100)  NOT NULL,                               -- ~25 bytes avg (100 bytes max)
    [description]    VARCHAR(255)  NULL,                                   -- ~40 bytes avg (255 bytes max)
    [target_amount]  DECIMAL(18,2) NOT NULL,                               -- 9 bytes (precision 18)
    [current_amount] DECIMAL(18,2) NOT NULL DEFAULT 0,                     -- 9 bytes (precision 18)
    [currency_code]  VARCHAR(10)   NOT NULL,                               -- ~4 bytes avg (10 bytes max)
    [due_date]       DATETIME      NOT NULL,                               -- 8 bytes
    [created_at]     DATETIME      NOT NULL DEFAULT GETDATE(),             -- 8 bytes
    [status]         TINYINT       NOT NULL DEFAULT 1,                    -- 1 byte
    CONSTRAINT [FK_goals_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id])
);
-- Estimated row size: 4 + 4 + 25 + 40 + 9 + 9 + 4 + 8 + 8 + 1 = ~112 bytes
-- Plus row overhead (~7 bytes) = ~119 bytes per row
-- 1 million rows ≈ 114 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tracks user-defined financial goals and their progress toward a target amount.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'goals';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each goal (primary key). INT.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Identifier of the user who owns the goal. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Descriptive name of the financial goal (e.g., "Emergency Fund" or "New Car"). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional details about the purpose or motivation behind the goal. VARCHAR(255).',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total amount the user aims to reach for this goal. DECIMAL(18,2).',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'target_amount';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Amount currently saved or achieved toward the target. DECIMAL(18,2).',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'current_amount';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Currency associated with the goal (e.g., USD, BRL, EUR). VARCHAR(10).',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'currency_code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Target date and time by which the goal should be achieved. DATETIME.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'due_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the goal record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'created_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indicates the goal state (1 = active, 0 = inactive, others for future use). TINYINT.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'status';
GO
