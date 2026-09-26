-- Historical foreign exchange rates between a currency and a base currency for a given date.
CREATE TABLE [investment].[currencies]
(
    [id]                  INT           IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [name]                NVARCHAR(100) NOT NULL,                             -- ~50 bytes avg (200 bytes max)
    [description]         NVARCHAR(255) NULL,                                 -- ~80 bytes avg (510 bytes max)
    [currency_code]       VARCHAR(10)   NOT NULL,                             -- ~4 bytes avg (10 bytes max)
    [base_currency_code]  VARCHAR(10)   NOT NULL,                             -- ~4 bytes avg (10 bytes max)
    [date]                DATETIME      NOT NULL,                             -- 8 bytes
    [rate]                DECIMAL(18,6) NOT NULL,                             -- 9 bytes (precision 18)
    [created_at]          DATETIME      NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    [status]              TINYINT       NOT NULL DEFAULT 1                    -- 1 byte
);
-- Estimated row size: 4+50+80+4+4+8+9+8+1 = ~168 bytes
-- Plus row overhead (~7 bytes) = ~175 bytes per row
-- 1 million rows ≈ 167 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Stores historical foreign exchange rates between a currency and a base currency for a given date.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'currencies';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each FX rate record. INT.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'currencies',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name of the currency code. NVARCHAR(100).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'currencies',
    @level2type = N'Column', @level2name = N'name';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Description of the currency code. NVARCHAR(255).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'currencies',
    @level2type = N'Column', @level2name = N'description';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Currency code being converted. VARCHAR(10).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'currencies',
    @level2type = N'Column', @level2name = N'currency_code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Base currency code used for conversion. VARCHAR(10).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'currencies',
    @level2type = N'Column', @level2name = N'base_currency_code';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date of the exchange rate. DATETIME.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'currencies',
    @level2type = N'Column', @level2name = N'date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Exchange rate of currency_code to base_currency_code on the given date. DECIMAL(18,6).',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'currencies',
    @level2type = N'Column', @level2name = N'rate';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the FX rate record was created in the system. DATETIME.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'currencies',
    @level2type = N'Column', @level2name = N'created_at';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Indicates if the FX rate record is active (1) or inactive (0). TINYINT.',
    @level0type = N'Schema', @level0name = N'investment',
    @level1type = N'Table',  @level1name = N'currencies',
    @level2type = N'Column', @level2name = N'status';
GO
