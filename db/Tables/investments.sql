CREATE TABLE [dbo].[investments]
(
    [id]                   INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    [user_id]              INT           NOT NULL,
    [asset_name]           NVARCHAR(255) NOT NULL,
    [investment_type]      NVARCHAR(100) NOT NULL,
    [category]             NVARCHAR(100) NOT NULL,
    [invested_amount]      DECIMAL(18,2) NOT NULL,
    [current_value]        DECIMAL(18,2) NULL,
    [profit_loss]          DECIMAL(18,2) NULL,
    [annual_yield_percent] DECIMAL(8,4)  NULL,
    [broker]               NVARCHAR(255) NULL,
    [purchase_date]        DATETIME      NOT NULL,
    [maturity_date]        DATETIME      NULL,
    [currency_code]        NVARCHAR(10)  NOT NULL DEFAULT 'BRL',
    [status]               SMALLINT      NOT NULL DEFAULT 1,
    [created_at]           DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

CREATE INDEX [IX_investments_user_id] ON [dbo].[investments]([user_id]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stores detailed records of user investments across multiple asset types and platforms.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each investment record (primary key).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who owns the investment.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name or ticker symbol of the invested asset (e.g., PETR4, CDB Itaú, Tesouro IPCA+).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'asset_name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Investment type classification (e.g., Fixed Income, Variable Income, Crypto, Fund, Treasury, Real Estate).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'investment_type';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Subcategory within the investment type (e.g., CDB, Stocks, REITs).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'category';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total amount of money originally invested in the asset.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'invested_amount';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Current market value of the investment, updated periodically.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'current_value';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Profit or loss amount calculated as current_value minus invested_amount.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'profit_loss';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Annual percentage yield or expected return of the investment.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'annual_yield_percent';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Financial platform or broker managing the investment (e.g., XP, Nubank, Binance).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'broker';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the investment was made or asset was acquired.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'purchase_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date and time when the investment matures or ends (applicable mainly to fixed income).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'maturity_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Currency code representing the investment currency.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'currency_code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indicates if the investment record is active (1), inactive (0), or archived.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the investment record was created in the system.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'investments',
    @level2type = N'Column', @level2name = N'created_at';
GO
