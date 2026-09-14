-- AG Configuration: PRIMARY (sql-prod-1)
-- Creates master key, certificate, mirroring endpoint, and the AG itself.
-- Run AFTER databases exist on the primary.

USE master;
GO

-- 1. Master key for certificate encryption
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'AGMasterKey!2024';
    PRINT 'Master key created';
END
GO

-- 2. Certificate for endpoint authentication (no Active Directory needed)
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'AG_Cert')
BEGIN
    CREATE CERTIFICATE AG_Cert
        WITH SUBJECT = 'AG Certificate for dba-lab',
        EXPIRY_DATE = '2030-12-31';
    PRINT 'Certificate created';
END
GO

-- 3. Backup certificate to shared volume (secondary needs it)
BACKUP CERTIFICATE AG_Cert
    TO FILE = '/var/opt/mssql/shared/ag_cert.cer'
    WITH PRIVATE KEY (
        FILE = '/var/opt/mssql/shared/ag_cert.key',
        ENCRYPTION BY PASSWORD = 'CertBackup!2024'
    );
PRINT 'Certificate backed up to shared volume';
GO

-- 4. Database mirroring endpoint (port 5022)
IF NOT EXISTS (SELECT 1 FROM sys.endpoints WHERE name = 'AG_Endpoint')
BEGIN
    CREATE ENDPOINT AG_Endpoint
        STATE = STARTED
        AS TCP (LISTENER_PORT = 5022)
        FOR DATABASE_MIRRORING (
            AUTHENTICATION = CERTIFICATE AG_Cert,
            ROLE = ALL,
            ENCRYPTION = REQUIRED ALGORITHM AES
        );
    PRINT 'Endpoint created on port 5022';
END
GO

-- 5. Create the Availability Group
IF NOT EXISTS (SELECT 1 FROM sys.availability_groups WHERE name = 'AppDB_AG')
BEGIN
    CREATE AVAILABILITY GROUP [AppDB_AG]
    WITH (
        CLUSTER_TYPE = NONE,
        DB_FAILOVER = ON
    )
    FOR DATABASE [AppDB]
    REPLICA ON
        N'sql-prod-1' WITH (
            ENDPOINT_URL = N'TCP://sql-prod-1:5022',
            AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
            FAILOVER_MODE = MANUAL,
            SEEDING_MODE = AUTOMATIC,
            SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL)
        ),
        N'sql-prod-2' WITH (
            ENDPOINT_URL = N'TCP://sql-prod-2:5022',
            AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
            FAILOVER_MODE = MANUAL,
            SEEDING_MODE = AUTOMATIC,
            SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY)
        );
    PRINT 'Availability Group AppDB_AG created';
END
GO

-- 6. Grant the AG permission to create databases on automatic seeding
ALTER AVAILABILITY GROUP [AppDB_AG] GRANT CREATE ANY DATABASE;
PRINT 'AG granted CREATE ANY DATABASE for automatic seeding';
GO
