-- Historical or real-time cryptocurrency price data including open, close, high, low, and volume for a given date.
CREATE TABLE [investment].[cryptos]
(
    [id]          INT           IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [name]        NVARCHAR(100) NOT NULL,                             -- ~50 bytes avg (200 bytes max)
    [description] NVARCHAR(255) NULL,                                 -- ~80 bytes avg (510 bytes max)
    [date]        DATETIME      NOT NULL,                             -- 8 bytes
    [open_price]  DECIMAL(18,4) NOT NULL,                             -- 9 bytes (precision 18)
    [close_price] DECIMAL(18,4) NOT NULL,                             -- 9 bytes (precision 18)
    [high_price]  DECIMAL(18,4) NOT NULL,                             -- 9 bytes (precision 18)
    [low_price]   DECIMAL(18,4) NOT NULL,                             -- 9 bytes (precision 18)
    [volume]      DECIMAL(28,8) NOT NULL,                             -- 13 bytes (precision 28; fractional coin amounts)
    [created_at]  DATETIME      NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    [status]      TINYINT       NOT NULL DEFAULT 1                    -- 1 byte
);
-- Estimated row size: 4+50+80+8+9+9+9+9+13+8+1 = ~200 bytes
-- Plus row overhead (~7 bytes) = ~207 bytes per row
-- 1 million rows ≈ 197 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stores historical or real-time cryptocurrency price data including open, close, high, low, and volume for a given date.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'cryptos';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each cryptocurrency record. INT.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'cryptos',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name of the crypto. NVARCHAR(100).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'cryptos',
    @level2type = N'Column', @level2name = N'name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Description of the crypto. NVARCHAR(255).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'cryptos',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date or timestamp of the market data (daily or intraday). DATETIME.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'cryptos',
    @level2type = N'Column', @level2name = N'date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Price at the beginning of the trading session. DECIMAL(18,4).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'cryptos',
    @level2type = N'Column', @level2name = N'open_price';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Price at the end of the trading session. DECIMAL(18,4).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'cryptos',
    @level2type = N'Column', @level2name = N'close_price';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Highest traded price during the session. DECIMAL(18,4).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'cryptos',
    @level2type = N'Column', @level2name = N'high_price';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Lowest traded price during the session. DECIMAL(18,4).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'cryptos',
    @level2type = N'Column', @level2name = N'low_price';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total traded volume of the cryptocurrency during the session (can include fractions). DECIMAL(28,8).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'cryptos',
    @level2type = N'Column', @level2name = N'volume';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the cryptocurrency record was created in the system. DATETIME.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'cryptos',
    @level2type = N'Column', @level2name = N'created_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag indicating if the record is active (1) or inactive (0). TINYINT.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'cryptos',
    @level2type = N'Column', @level2name = N'status';
GO
