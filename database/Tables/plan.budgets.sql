-- User-created financial budgets with spending limits and date ranges.
CREATE TABLE [plan].[budgets]
(
    [id]            INT           IDENTITY (1, 1) PRIMARY KEY NOT NULL,     -- 4 bytes
    [user_id]       INT           NOT NULL,                                 -- 4 bytes
    [name]          VARCHAR(100)  NOT NULL,                                 -- ~25 bytes avg (100 bytes max)
    [description]   VARCHAR(255)  NULL,                                     -- ~40 bytes avg (255 bytes max)
    [amount_limit]  DECIMAL(18,2) NOT NULL,                                 -- 9 bytes (precision 18)
    [currency_code] VARCHAR(10)   NOT NULL,                                 -- ~4 bytes avg (10 bytes max)
    [start_date]    DATETIME      NOT NULL,                                 -- 8 bytes
    [end_date]      DATETIME      NOT NULL,                                 -- 8 bytes
    [created_at]    DATETIME      NOT NULL DEFAULT GETDATE(),               -- 8 bytes
    [status]        TINYINT       NOT NULL DEFAULT 1,                      -- 1 byte
    CONSTRAINT [FK_budgets_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id])
);
-- Estimated row size: 4 + 4 + 25 + 40 + 9 + 4 + 8 + 8 + 8 + 1 = ~111 bytes
-- Plus row overhead (~7 bytes) = ~118 bytes per row
-- 1 million rows ≈ 113 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Defines user-created financial budgets within the planning module.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'budgets';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each budget (primary key). INT.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'budgets',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Identifier of the user who owns or created the budget. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'budgets',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name assigned to the budget (e.g., "Vacation 2025" or "Monthly Groceries"). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'budgets',
    @level2type = N'Column', @level2name = N'name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional detailed description of the budget purpose or scope. VARCHAR(255).',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'budgets',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total monetary limit allocated for this budget period. DECIMAL(18,2).',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'budgets',
    @level2type = N'Column', @level2name = N'amount_limit';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Currency associated with the budget (e.g., USD, BRL, EUR). VARCHAR(10).',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'budgets',
    @level2type = N'Column', @level2name = N'currency_code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the budget becomes active. DATETIME.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'budgets',
    @level2type = N'Column', @level2name = N'start_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the budget period ends. DATETIME.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'budgets',
    @level2type = N'Column', @level2name = N'end_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the budget record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'budgets',
    @level2type = N'Column', @level2name = N'created_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indicates whether the budget is active (1), inactive (0), or archived. TINYINT.',
    @level0type = N'Schema', @level0name = N'plan',
    @level1type = N'Table',  @level1name = N'budgets',
    @level2type = N'Column', @level2name = N'status';
GO
