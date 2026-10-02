-- Defines bills and recurring payment obligations for users, including due dates, amounts, and status tracking.
CREATE TABLE [finance].[bills]
(
    [id]                  INT           IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]             INT           NOT NULL,                             -- 4 bytes
    [bill_name]           VARCHAR(255)  NOT NULL,                             -- ~40 bytes avg (255 bytes max)
    [category]            VARCHAR(255)  NOT NULL,                             -- ~40 bytes avg (255 bytes max)
    [payment_method]      VARCHAR(255)  NULL,                                 -- ~40 bytes avg (255 bytes max)
    [amount]              DECIMAL(18,2) NOT NULL,                             -- 9 bytes (precision 18)
    [currency_code]       VARCHAR(10)   NOT NULL,                             -- ~4 bytes avg (10 bytes max)
    [due_date]            DATE          NOT NULL,                             -- 3 bytes
    [recurrence_type]     VARCHAR(50)   NULL,                                 -- ~15 bytes avg (50 bytes max)
    [recurrence_interval] INT           NULL DEFAULT 1,                       -- 4 bytes
    [next_due_date]       DATE          NULL,                                 -- 3 bytes
    [paid_date]           DATE          NULL,                                 -- 3 bytes
    [description]         VARCHAR(255)  NULL,                                 -- ~40 bytes avg (255 bytes max)
    [created_at]          DATETIME      NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    [updated_at]          DATETIME      NULL,                                 -- 8 bytes
    [status]              TINYINT       NOT NULL DEFAULT 1,                   -- 1 byte
    CONSTRAINT [FK_bills_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id])
);
-- Estimated row size: 4+4+40+40+40+9+4+3+15+4+3+3+40+8+8+1 = ~226 bytes
-- Plus row overhead (~7 bytes) = ~233 bytes per row
-- 1 million rows ≈ 222 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Defines bills and recurring payment obligations for users, including due dates, amounts, and status tracking.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each bill record (primary key). INT.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who owns the bill record. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Descriptive name of the bill (e.g., Electricity, Internet, Rent). VARCHAR(255).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'bill_name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Category describing the type of bill (e.g., Utilities, Housing, Subscriptions). VARCHAR(255).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'category';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Method used for bill payment (e.g., Credit Card, Debit, Bank Transfer). VARCHAR(255).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'payment_method';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Monetary amount due for the bill. DECIMAL(18,2).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'amount';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Currency code representing the bill currency (e.g., USD, BRL, EUR). VARCHAR(10).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'currency_code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date when the bill is due for payment. DATE.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'due_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Type of recurrence pattern (e.g., Monthly, Yearly, None). VARCHAR(50).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'recurrence_type';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Interval between bill recurrences (e.g., every 2 months). INT.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'recurrence_interval';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Next scheduled due date for recurring bills. DATE.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'next_due_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date when the bill was paid, if applicable. DATE.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'paid_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional description providing additional context about the bill or payment details. VARCHAR(255).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the bill record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'created_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the bill record was last updated. DATETIME.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'updated_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag for the bill (1=Active, 0=Inactive, 2=Paid, 3=Cancelled). TINYINT.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'bills',
    @level2type = N'Column', @level2name = N'status';
GO
