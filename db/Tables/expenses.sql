CREATE TABLE [dbo].[expenses]
(
    [id]             INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    [user_id]        INT           NOT NULL,
    [amount]         DECIMAL(18,2) NOT NULL,
    [category]       NVARCHAR(100) NOT NULL,
    [description]    NVARCHAR(500) NULL,
    [expense_date]   DATETIME      NOT NULL,
    [payment_method] NVARCHAR(100) NOT NULL,
    [currency_code]  NVARCHAR(10)  NOT NULL DEFAULT 'BRL',
    [status]         SMALLINT      NOT NULL DEFAULT 1,
    [created_at]     DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

CREATE INDEX [IX_expenses_user_id] ON [dbo].[expenses]([user_id]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Records user expenses, including purchase details, amounts, and payment methods.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'expenses';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each expense record (primary key).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who owns the expense record.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total monetary value of the expense transaction.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'amount';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Category describing the type of expense (e.g., Food, Transportation, Utilities).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'category';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional text providing more details about the expense or its context.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the expense occurred or was recorded.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'expense_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Method used for payment (e.g., Credit Card, Cash, Bank Transfer).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'payment_method';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Currency code representing the expense currency (e.g., USD, BRL, EUR).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'currency_code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indicates if the expense record is active (1), inactive (0), or archived.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the expense record was created in the system.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'created_at';
GO
