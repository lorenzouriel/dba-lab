-- Records user expenses, including purchase details, amounts, and payment methods.
CREATE TABLE [finance].[expenses]
(
    [id]             INT           IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]        INT           NOT NULL,                             -- 4 bytes
    [category]       VARCHAR(255)  NOT NULL,                             -- ~40 bytes avg (255 bytes max)
    [payment_method] VARCHAR(255)  NOT NULL,                             -- ~40 bytes avg (255 bytes max)
    [amount]         DECIMAL(18,2) NOT NULL,                             -- 9 bytes (precision 18)
    [currency_code]  VARCHAR(10)   NOT NULL,                             -- ~4 bytes avg (10 bytes max)
    [description]    VARCHAR(255)  NULL,                                 -- ~40 bytes avg (255 bytes max)
    [expense_date]   DATETIME      NOT NULL,                             -- 8 bytes
    [created_at]     DATETIME      NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    [status]         TINYINT       NOT NULL DEFAULT 1,                   -- 1 byte
    CONSTRAINT [FK_expenses_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id])
);
-- Estimated row size: 4 + 4 + 40 + 40 + 9 + 4 + 40 + 8 + 8 + 1 = ~158 bytes
-- Plus row overhead (~7 bytes) = ~165 bytes per row
-- 1 million rows ≈ 157 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Records user expenses, including purchase details, amounts, and payment methods.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'expenses';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each expense record (primary key). INT.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who owns the expense record. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Category describing the type of expense (e.g., Food, Transportation, Utilities). VARCHAR(255).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'category';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Method used for payment (e.g., Credit Card, Cash, Bank Transfer). VARCHAR(255).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'payment_method';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total monetary value of the expense transaction. DECIMAL(18,2).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'amount';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Currency code representing the expense currency (e.g., USD, BRL, EUR). VARCHAR(10).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'currency_code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional text providing more details about the expense or its context. VARCHAR(255).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the expense occurred or was recorded. DATETIME.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'expense_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the expense record was created in the system. DATETIME.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'created_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indicates if the expense record is active (1), inactive (0), or archived. TINYINT.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'expenses',
    @level2type = N'Column', @level2name = N'status';
GO
