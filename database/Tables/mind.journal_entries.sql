-- Free-form journal entries with an optional title, mood rating, and category label.
CREATE TABLE [mind].[journal_entries]
(
    [id]          INT           IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 4 bytes
    [user_id]     INT           NOT NULL,                             -- 4 bytes
    [entry_date]  DATE          NOT NULL,                             -- 3 bytes
    [title]       VARCHAR(200)  MASKED WITH (FUNCTION = 'default()') NULL,     -- ~40 bytes avg (200 bytes max)
    [content]     NVARCHAR(MAX) ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [CEK_fin_pulse], ENCRYPTION_TYPE = RANDOMIZED, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL, -- Always Encrypted; ciphertext ~ plaintext + 65 bytes, off-row when large
    [mood]        SMALLINT      NULL,                                 -- 2 bytes
    [category]    VARCHAR(50)   NULL,                                 -- ~15 bytes avg (50 bytes max)
    [status]      TINYINT       NOT NULL DEFAULT 1,                   -- 1 byte
    [created_at]  DATETIME      NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_journal_entries_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE,
    CONSTRAINT [CK_journal_entries_mood] CHECK ([mood] IS NULL OR [mood] BETWEEN 1 AND 5)
);
-- Estimated row size (excluding NVARCHAR(MAX) content): 4 + 4 + 3 + 40 + 2 + 15 + 1 + 8 = ~77 bytes
-- Plus row overhead (~7 bytes) = ~84 bytes per row, plus variable-length content
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Free-form journal entries with an optional title, mood rating, and category label.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'journal_entries';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each journal entry record (primary key). INT.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'journal_entries',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'References the user who wrote this entry. References dbo.users.id. INT.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'journal_entries',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the journal entry was written for. DATE.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'journal_entries',
    @level2type = N'Column', @level2name = N'entry_date';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional short title for the entry. VARCHAR(200).',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'journal_entries',
    @level2type = N'Column', @level2name = N'title';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Full text of the journal entry. NVARCHAR(MAX). Always Encrypted (randomized): not filterable or maskable; clients need Column Encryption Setting=Enabled and the CMK.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'journal_entries',
    @level2type = N'Column', @level2name = N'content';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional self-reported mood at the time of writing, on a 1-5 scale. SMALLINT.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'journal_entries',
    @level2type = N'Column', @level2name = N'mood';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Optional free-text category label (e.g., Gratitude, Reflection, Goals). VARCHAR(50).',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'journal_entries',
    @level2type = N'Column', @level2name = N'category';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Status flag (1=Active, 0=Deleted). TINYINT.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'journal_entries',
    @level2type = N'Column', @level2name = N'status';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when this entry record was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'mind',
    @level1type = N'Table',  @level1name = N'journal_entries',
    @level2type = N'Column', @level2name = N'created_at';
GO
