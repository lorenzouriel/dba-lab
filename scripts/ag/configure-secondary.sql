-- AG Configuration: SECONDARY (sql-prod-2)
-- Restores certificate from shared volume, creates endpoint, joins the AG.
-- Run AFTER configure-primary.sql completes.

USE master;
GO

-- 1. Master key
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'AGMasterKey!2024';
    PRINT 'Master key created';
END
GO

-- 2. Restore certificate from shared volume (created by primary)
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'AG_Cert')
BEGIN
    CREATE CERTIFICATE AG_Cert
        FROM FILE = '/var/opt/mssql/shared/ag_cert.cer'
        WITH PRIVATE KEY (
            FILE = '/var/opt/mssql/shared/ag_cert.key',
            DECRYPTION BY PASSWORD = 'CertBackup!2024'
        );
    PRINT 'Certificate restored from primary';
END
GO

-- 3. Database mirroring endpoint (same port, same cert)
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

-- 4. Join the AG (automatic seeding will replicate the database)
ALTER AVAILABILITY GROUP [AppDB_AG] JOIN WITH (CLUSTER_TYPE = NONE);
PRINT 'Joined Availability Group AppDB_AG';
GO

ALTER AVAILABILITY GROUP [AppDB_AG] GRANT CREATE ANY DATABASE;
PRINT 'AG granted CREATE ANY DATABASE on secondary';
GO
