/*  20-ag-setup.sql
    Availability Group between sql1 (primary) and sql2 (secondary).

    Two plain Linux containers share no domain identity and there's no
    WSFC/Pacemaker in this lab, so this uses CLUSTER_TYPE = NONE (manual
    failover only) and certificate-based HADR endpoint authentication
    instead of Windows auth. Automatic seeding replaces the usual
    backup/restore-with-NORECOVERY dance.

    Run once sql2 reports healthy:
        docker compose --profile ha up -d sql2
        docker compose --profile ha run --rm ag-setup

    Re-runnable: each step is guarded, so a partial failure can be re-run
    after fixing the cause. It is NOT safe to re-run after the AG already
    exists with a *different* DBNAME — drop the AG first in that case.
*/
:setvar DBNAME agdb
:on error exit
SET NOCOUNT ON;
GO

------------------------------------------------------------------ sql1: cert
:CONNECT sql1 -U sa -P $(SAPW)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$(SAPW)';
GO
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'sql1_hadr_cert')
    CREATE CERTIFICATE sql1_hadr_cert WITH SUBJECT = 'sql1 HADR endpoint cert';
GO
DECLARE @exists1 TABLE (file_exists bit, file_is_directory bit, parent_directory_exists bit);
INSERT INTO @exists1 EXEC master.dbo.xp_fileexist '/var/opt/mssql/ag-certs/sql1_hadr_cert.cer';
IF NOT EXISTS (SELECT 1 FROM @exists1 WHERE file_exists = 1)
    BACKUP CERTIFICATE sql1_hadr_cert TO FILE = '/var/opt/mssql/ag-certs/sql1_hadr_cert.cer';
GO

------------------------------------------------------------------ sql2: cert
:CONNECT sql2 -U sa -P $(SAPW)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$(SAPW)';
GO
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'sql2_hadr_cert')
    CREATE CERTIFICATE sql2_hadr_cert WITH SUBJECT = 'sql2 HADR endpoint cert';
GO
DECLARE @exists2 TABLE (file_exists bit, file_is_directory bit, parent_directory_exists bit);
INSERT INTO @exists2 EXEC master.dbo.xp_fileexist '/var/opt/mssql/ag-certs/sql2_hadr_cert.cer';
IF NOT EXISTS (SELECT 1 FROM @exists2 WHERE file_exists = 1)
    BACKUP CERTIFICATE sql2_hadr_cert TO FILE = '/var/opt/mssql/ag-certs/sql2_hadr_cert.cer';
GO

-------------------------------------------------- sql2: trust sql1, endpoint
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hadr_login')
    CREATE LOGIN hadr_login WITH PASSWORD = 'Ag_HADR_Internal_Login_2025!';
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'hadr_login')
    CREATE USER hadr_login FOR LOGIN hadr_login;
GO
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'sql1_hadr_cert')
    CREATE CERTIFICATE sql1_hadr_cert AUTHORIZATION hadr_login
        FROM FILE = '/var/opt/mssql/ag-certs/sql1_hadr_cert.cer';
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_mirroring_endpoints WHERE name = 'hadr_endpoint')
    CREATE ENDPOINT hadr_endpoint
        STATE = STARTED
        AS TCP (LISTENER_PORT = 5022)
        FOR DATABASE_MIRRORING (
            AUTHENTICATION = CERTIFICATE sql2_hadr_cert,
            ENCRYPTION = REQUIRED ALGORITHM AES,
            ROLE = ALL
        );
GO
GRANT CONNECT ON ENDPOINT::hadr_endpoint TO hadr_login;
GO

-------------------------------------------------- sql1: trust sql2, endpoint
:CONNECT sql1 -U sa -P $(SAPW)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hadr_login')
    CREATE LOGIN hadr_login WITH PASSWORD = 'Ag_HADR_Internal_Login_2025!';
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'hadr_login')
    CREATE USER hadr_login FOR LOGIN hadr_login;
GO
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'sql2_hadr_cert')
    CREATE CERTIFICATE sql2_hadr_cert AUTHORIZATION hadr_login
        FROM FILE = '/var/opt/mssql/ag-certs/sql2_hadr_cert.cer';
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_mirroring_endpoints WHERE name = 'hadr_endpoint')
    CREATE ENDPOINT hadr_endpoint
        STATE = STARTED
        AS TCP (LISTENER_PORT = 5022)
        FOR DATABASE_MIRRORING (
            AUTHENTICATION = CERTIFICATE sql1_hadr_cert,
            ENCRYPTION = REQUIRED ALGORITHM AES,
            ROLE = ALL
        );
GO
GRANT CONNECT ON ENDPOINT::hadr_endpoint TO hadr_login;
GO

------------------------------------------------------ sql1: demo db + AG
DECLARE @qagdb sysname = QUOTENAME(N'$(DBNAME)');
IF DB_ID('$(DBNAME)') IS NULL
BEGIN
    EXEC ('CREATE DATABASE ' + @qagdb);
    EXEC ('ALTER DATABASE ' + @qagdb + ' SET RECOVERY FULL');
END
/*  AG membership requires a full backup to close out "bulk logged changes
    not yet backed up" even with automatic seeding. Neither /dev/null nor
    the bind-mounted backups/ folder work for this on Docker Desktop for
    Windows — BACKUP DATABASE pre-allocates the target file with a syscall
    the bind-mount passthrough doesn't support ("DiskChangeFileSize" / OS
    error 31) — so this writes into the sql1-data *named volume* instead,
    which is a real filesystem inside the Docker VM.                    */
EXEC ('BACKUP DATABASE ' + @qagdb
    + ' TO DISK = ''/var/opt/mssql/data/$(DBNAME)_ag-seed.bak'' WITH INIT');
GO

IF NOT EXISTS (SELECT 1 FROM sys.availability_groups WHERE name = 'ag1')
CREATE AVAILABILITY GROUP [ag1]
    WITH (CLUSTER_TYPE = NONE)
    FOR DATABASE [$(DBNAME)]
    REPLICA ON
        N'sql1' WITH (
            ENDPOINT_URL = N'TCP://sql1:5022',
            AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
            FAILOVER_MODE = MANUAL,
            SEEDING_MODE = AUTOMATIC),
        N'sql2' WITH (
            ENDPOINT_URL = N'TCP://sql2:5022',
            AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
            FAILOVER_MODE = MANUAL,
            SEEDING_MODE = AUTOMATIC);
GO
ALTER AVAILABILITY GROUP [ag1] GRANT CREATE ANY DATABASE;
GO

------------------------------------------------------ sql2: join + seed perm
:CONNECT sql2 -U sa -P $(SAPW)

IF NOT EXISTS (SELECT 1 FROM sys.availability_groups WHERE name = 'ag1')
    ALTER AVAILABILITY GROUP [ag1] JOIN WITH (CLUSTER_TYPE = NONE);
GO
ALTER AVAILABILITY GROUP [ag1] GRANT CREATE ANY DATABASE;
GO

PRINT 'AG setup complete. Automatic seeding of $(DBNAME) onto sql2 runs in the background — check sys.dm_hadr_database_replica_states for SYNCHRONIZED.';
GO
