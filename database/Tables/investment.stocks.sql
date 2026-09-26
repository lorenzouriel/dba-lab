-- Historical or real-time stock market price data, including open, close, high, low, and volume for a given date.
CREATE TABLE [investment].[stocks]
(
    [id]          INT            IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [name]        NVARCHAR(100)  NOT NULL,                             -- ~50 bytes avg (200 bytes max)
    [description] NVARCHAR(255)  NULL,                                 -- ~80 bytes avg (510 bytes max)
    [broker]      VARCHAR(100)   NULL,                                 -- ~25 bytes avg (100 bytes max)
    [date]        DATETIME       NOT NULL,                             -- 8 bytes
    [open_price]  DECIMAL(18,4)  NOT NULL,                             -- 9 bytes (precision 18)
    [close_price] DECIMAL(18,4)  NOT NULL,                             -- 9 bytes (precision 18)
    [high_price]  DECIMAL(18,4)  NOT NULL,                             -- 9 bytes (precision 18)
    [low_price]   DECIMAL(18,4)  NOT NULL,                             -- 9 bytes (precision 18)
    [volume]      BIGINT         NOT NULL,                             -- 8 bytes
    [created_at]  DATETIME       NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    [status]      TINYINT        NOT NULL DEFAULT 1                    -- 1 byte
);
-- Estimated row size: 4+50+80+25+8+9+9+9+9+8+8+1 = ~220 bytes
-- Plus row overhead (~7 bytes) = ~227 bytes per row
-- 1 million rows ≈ 217 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stores historical or real-time stock market price data, including open, close, high, low, and volume for a given date.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each stock price record. INT.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name of the stock. NVARCHAR(100).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks',
    @level2type = N'Column', @level2name = N'name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Description of the stock. NVARCHAR(255).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Financial platform or broker managing the investment (e.g., XP, Nubank, Binance). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks',
    @level2type = N'Column', @level2name = N'broker';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date or timestamp of the market data (daily or intraday). DATETIME.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks',
    @level2type = N'Column', @level2name = N'date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stock price at the beginning of the trading session. DECIMAL(18,4).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks',
    @level2type = N'Column', @level2name = N'open_price';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stock price at the end of the trading session. DECIMAL(18,4).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks',
    @level2type = N'Column', @level2name = N'close_price';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Highest traded price during the session. DECIMAL(18,4).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks',
    @level2type = N'Column', @level2name = N'high_price';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Lowest traded price during the session. DECIMAL(18,4).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks',
    @level2type = N'Column', @level2name = N'low_price';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Total number of shares traded during the session. BIGINT.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks',
    @level2type = N'Column', @level2name = N'volume';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the record was created in the system. DATETIME.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks',
    @level2type = N'Column', @level2name = N'created_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag indicating if the record is active (1) or inactive (0). TINYINT.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'stocks',
    @level2type = N'Column', @level2name = N'status';
GO
