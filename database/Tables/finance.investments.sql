-- Detailed records of user investments across multiple asset types and platforms.
CREATE TABLE [finance].[investments]
(
    [id]                    INT           IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]               INT           NOT NULL,                             -- 4 bytes
    [investment_type]       VARCHAR(50)   NOT NULL,                             -- ~15 bytes avg (50 bytes max)
    [category]              VARCHAR(100)  NOT NULL,                             -- ~25 bytes avg (100 bytes max)
    [asset_name]             VARCHAR(100) NOT NULL,                             -- ~25 bytes avg (100 bytes max)
    [broker]                VARCHAR(100)  NULL,                                 -- ~25 bytes avg (100 bytes max)
    [currency_code]         VARCHAR(10)   NOT NULL,                             -- ~4 bytes avg (10 bytes max)
    [invested_amount]       DECIMAL(18,2) NOT NULL,                             -- 9 bytes (precision 18)
    [current_value]         DECIMAL(18,2) NULL,                                 -- 9 bytes (precision 18)
    [purchase_date]         DATETIME      NOT NULL,                             -- 8 bytes
    [maturity_date]         DATETIME      NULL,                                 -- 8 bytes
    [annual_yield_percent]  DECIMAL(8,4)  NULL,                                 -- 5 bytes (precision 8)
    [profit_loss]           DECIMAL(18,2) NULL,                                 -- 9 bytes (precision 18)
    [created_at]            DATETIME      NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    [status]                TINYINT       NOT NULL DEFAULT 1,                   -- 1 byte
    CONSTRAINT [FK_investments_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id])
);
-- Estimated row size: 4+4+15+25+25+25+4+9+9+8+8+5+9+8+1 = ~159 bytes
-- Plus row overhead (~7 bytes) = ~166 bytes per row
-- 1 million rows ≈ 158 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stores detailed records of user investments across multiple asset types and platforms.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each investment record (primary key). INT.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who owns the investment. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Investment type classification (e.g., Fixed Income, Variable Income, Crypto, Fund, Treasury, Real Estate). VARCHAR(50).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'investment_type';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Subcategory within the investment type (e.g., CDB, Stocks, REITs). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'category';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name or ticker symbol of the invested asset (e.g., PETR4, CDB Itaú, Tesouro IPCA+). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'asset_name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Financial platform or broker managing the investment (e.g., XP, Nubank, Binance). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'broker';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Currency code representing the investment currency. VARCHAR(10).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'currency_code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total amount of money originally invested in the asset. DECIMAL(18,2).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'invested_amount';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Current market value of the investment, updated periodically. DECIMAL(18,2).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'current_value';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the investment was made or asset was acquired. DATETIME.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'purchase_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the investment matures or ends (applicable mainly to fixed income). DATETIME.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'maturity_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Annual percentage yield or expected return of the investment. DECIMAL(8,4).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'annual_yield_percent';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Profit or loss amount calculated as current_value minus invested_amount. DECIMAL(18,2).',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'profit_loss';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the investment record was created in the system. DATETIME.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'created_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indicates if the investment record is active (1), inactive (0), or archived. TINYINT.',
    @level0type = N'Schema', @level0name = N'finance',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'status';
GO
