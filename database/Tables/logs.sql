-- System/audit trail: who did what, when. entity_type/entity_id point at the affected row.
CREATE TABLE [dbo].[logs]
(
    [id]          BIGINT        IDENTITY (1, 1) PRIMARY KEY NOT NULL, -- 8 bytes
    [tenant_id]   INT           NULL,                                 -- 4 bytes
    [user_id]     INT           NULL,                                 -- 4 bytes
    [action]      VARCHAR(100)  NOT NULL,                             -- ~20 bytes avg (100 bytes max)
    [entity_type] VARCHAR(50)   NULL,                                 -- ~10 bytes avg (50 bytes max)
    [entity_id]   BIGINT        NULL,                                 -- 8 bytes
    [details]     NVARCHAR(MAX) NULL,                                 -- ~200 bytes avg (LOB type; in-row up to 8,000 bytes, then off-row with only a pointer kept in-row)
    [ip_address]  VARCHAR(45)   NULL,                                 -- ~15 bytes avg (45 bytes max, IPv6 worst case)
    [created_at]  DATETIME      NOT NULL DEFAULT GETDATE(),           -- 8 bytes
    CONSTRAINT [FK_logs_tenants] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[tenants] ([id]),
    CONSTRAINT [FK_logs_users] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id])
);
-- Estimated row size: 8 + 4 + 4 + 20 + 10 + 8 + 200 + 15 + 8 = ~277 bytes
-- Plus row overhead (~7 bytes) = ~284 bytes per row
-- 1 million rows ≈ 271 MB -- 10 million rows ≈ 2.71 GB
GO

CREATE INDEX [IX_logs_tenant_id_created_at] ON [dbo].[logs]([tenant_id], [created_at]);
GO

------------------------------------------------------------
-- TABLE DESCRIPTION
------------------------------------------------------------
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'System/audit trail: who did what, when. entity_type/entity_id point at the affected row.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'logs';
GO

------------------------------------------------------------
-- COLUMN DESCRIPTIONS
------------------------------------------------------------

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Unique identifier for each log entry (primary key). BIGINT: high-volume audit table.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'logs',
    @level2type = N'Column', @level2name = N'id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Tenant the action was performed under, if any. References tenants.id. INT, nullable for system-level actions.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'logs',
    @level2type = N'Column', @level2name = N'tenant_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'User who performed the action, if any. References users.id. INT, nullable for system-initiated actions.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'logs',
    @level2type = N'Column', @level2name = N'user_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Action performed (e.g. LOGIN, CREATE_VEHICLE, DELETE_DEVICE). VARCHAR(100).',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'logs',
    @level2type = N'Column', @level2name = N'action';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Type of entity affected (e.g. vehicle, device). VARCHAR(50), nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'logs',
    @level2type = N'Column', @level2name = N'entity_type';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key of the affected entity row. BIGINT, nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'logs',
    @level2type = N'Column', @level2name = N'entity_id';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Free-form additional detail about the action, typically JSON. NVARCHAR(MAX), nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'logs',
    @level2type = N'Column', @level2name = N'details';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Source IP address of the request, IPv4 or IPv6. VARCHAR(45), nullable.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'logs',
    @level2type = N'Column', @level2name = N'ip_address';
GO

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Timestamp when the log entry was created. DATETIME.',
    @level0type = N'Schema', @level0name = N'dbo',
    @level1type = N'Table',  @level1name = N'logs',
    @level2type = N'Column', @level2name = N'created_at';
GO
