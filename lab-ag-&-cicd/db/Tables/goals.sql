CREATE TABLE [dbo].[goals]
(
    [id]             INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    [user_id]        INT           NOT NULL,
    [name]           NVARCHAR(255) NOT NULL,
    [description]    NVARCHAR(500) NULL,
    [target_amount]  DECIMAL(18,2) NOT NULL,
    [current_amount] DECIMAL(18,2) NOT NULL DEFAULT 0,
    [currency_code]  NVARCHAR(10)  NOT NULL DEFAULT 'BRL',
    [due_date]       DATETIME      NOT NULL,
    [status]         SMALLINT      NOT NULL DEFAULT 1,
    [created_at]     DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

CREATE INDEX [IX_goals_user_id] ON [dbo].[goals]([user_id]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tracks user-defined financial goals and their progress toward a target amount.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'goals';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each goal (primary key).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Identifier of the user who owns the goal.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Descriptive name of the financial goal (e.g., "Emergency Fund" or "New Car").',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional details about the purpose or motivation behind the goal.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total amount the user aims to reach for this goal.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'target_amount';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Amount currently saved or achieved toward the target.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'current_amount';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Currency associated with the goal (e.g., USD, BRL, EUR).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'currency_code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Target date and time by which the goal should be achieved.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'due_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indicates the goal state (1 = active, 0 = inactive, others for future use).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the goal record was created.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'goals',
    @level2type = N'Column', @level2name = N'created_at';
GO
