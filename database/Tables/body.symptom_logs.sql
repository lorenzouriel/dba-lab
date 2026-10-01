-- Append-only log of symptoms/illness, one row per symptom reported per date, explaining days that
-- fell off the normal routine.
CREATE TABLE [body].[symptom_logs]
(
    [id]          INT          IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]     INT          NOT NULL,                             -- 4 bytes
    [log_date]    DATE         NOT NULL,                             -- 3 bytes
    [symptom]     VARCHAR(100) NOT NULL,                             -- ~25 bytes avg (100 bytes max)
    [severity]    SMALLINT     NULL,                                 -- 2 bytes
    [notes]       VARCHAR(500) ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [CEK_fin_pulse], ENCRYPTION_TYPE = RANDOMIZED, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NULL, -- Always Encrypted; ~60 bytes avg + 65 bytes ciphertext overhead
    [status]      TINYINT      NOT NULL DEFAULT 1,                   -- 1 byte
    [created_at]  DATETIME     NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_symptom_logs_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [CK_symptom_logs_severity] CHECK ([severity] IS NULL OR [severity] BETWEEN 1 AND 5)
);
-- Estimated row size: 4 + 4 + 3 + 25 + 2 + 60 + 1 + 8 = ~107 bytes
-- Plus row overhead (~7 bytes) = ~114 bytes per row
-- 1 million rows ≈ 109 MB
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Append-only log of symptoms/illness, one row per symptom reported per date, explaining days that fell off the normal routine.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'symptom_logs';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each symptom log entry (primary key). INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'symptom_logs',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who logged this symptom. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'symptom_logs',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the symptom was experienced. DATE.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'symptom_logs',
    @level2type = N'Column', @level2name = N'log_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name of the symptom (e.g., Headache, Fever, Sore Throat, Fatigue). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'symptom_logs',
    @level2type = N'Column', @level2name = N'symptom';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional self-reported severity, on a 1-5 scale. SMALLINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'symptom_logs',
    @level2type = N'Column', @level2name = N'severity';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional free-text notes about the symptom or its context. VARCHAR(500). Always Encrypted (randomized): not filterable or maskable; clients need Column Encryption Setting=Enabled and the CMK.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'symptom_logs',
    @level2type = N'Column', @level2name = N'notes';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted). TINYINT.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'symptom_logs',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this symptom log entry was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'body',
    @level1type = N'Table',  @level1name = N'symptom_logs',
    @level2type = N'Column', @level2name = N'created_at';
GO
