/*  20-ag-setup.sql
    Availability Group between prod1 (primary) and prod2 (read-only
    secondary).

    Two plain Linux containers share no domain identity and there's no
    WSFC/Pacemaker in this lab, so this uses CLUSTER_TYPE = NONE (manual
    failover only) and certificate-based HADR endpoint authentication
    instead of Windows auth. Automatic seeding replaces the usual
    backup/restore-with-NORECOVERY dance. prod2 is configured with
    SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY) plus a read-only
    routing list, so ApplicationIntent=ReadOnly connections to prod1 get
    routed to prod2.

    Run once prod2 reports healthy:
        docker compose --profile ha up -d prod2
        docker compose --profile ha run --rm ag-setup

    DBNAME comes from the ag-setup service's `-v DBNAME=${AGDB:-agdb}` --
    deliberately not re-defaulted here with :setvar, since sqlcmd applies a
    script's own :setvar unconditionally and it would silently clobber
    whatever value -v passed in.
*/
:on error exit
SET NOCOUNT ON;
GO

---------------------------------------------------------------- prod1: cert
:CONNECT prod1 -U sa -P $(SAPW)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$(SAPW)';
GO
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'prod1_hadr_cert')
    CREATE CERTIFICATE prod1_hadr_cert WITH SUBJECT = 'prod1 HADR endpoint cert';
GO
DECLARE @exists1 TABLE (file_exists bit, file_is_directory bit, parent_directory_exists bit);
INSERT INTO @exists1 EXEC master.dbo.xp_fileexist '/var/opt/mssql/ag-certs/prod1_hadr_cert.cer';
IF NOT EXISTS (SELECT 1 FROM @exists1 WHERE file_exists = 1)
    BACKUP CERTIFICATE prod1_hadr_cert TO FILE = '/var/opt/mssql/ag-certs/prod1_hadr_cert.cer';
GO

---------------------------------------------------------------- prod2: cert
:CONNECT prod2 -U sa -P $(SAPW)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$(SAPW)';
GO
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'prod2_hadr_cert')
    CREATE CERTIFICATE prod2_hadr_cert WITH SUBJECT = 'prod2 HADR endpoint cert';
GO
DECLARE @exists2 TABLE (file_exists bit, file_is_directory bit, parent_directory_exists bit);
INSERT INTO @exists2 EXEC master.dbo.xp_fileexist '/var/opt/mssql/ag-certs/prod2_hadr_cert.cer';
IF NOT EXISTS (SELECT 1 FROM @exists2 WHERE file_exists = 1)
    BACKUP CERTIFICATE prod2_hadr_cert TO FILE = '/var/opt/mssql/ag-certs/prod2_hadr_cert.cer';
GO

----------------------------------------------- prod2: trust prod1, endpoint
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hadr_login')
    CREATE LOGIN hadr_login WITH PASSWORD = 'Ag_HADR_Internal_Login_2025!';
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'hadr_login')
    CREATE USER hadr_login FOR LOGIN hadr_login;
GO
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'prod1_hadr_cert')
    CREATE CERTIFICATE prod1_hadr_cert AUTHORIZATION hadr_login
        FROM FILE = '/var/opt/mssql/ag-certs/prod1_hadr_cert.cer';
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_mirroring_endpoints WHERE name = 'hadr_endpoint')
    CREATE ENDPOINT hadr_endpoint
        STATE = STARTED
        AS TCP (LISTENER_PORT = 5022)
        FOR DATABASE_MIRRORING (
            AUTHENTICATION = CERTIFICATE prod2_hadr_cert,
            ENCRYPTION = REQUIRED ALGORITHM AES,
            ROLE = ALL
        );
GO
GRANT CONNECT ON ENDPOINT::hadr_endpoint TO hadr_login;
GO

----------------------------------------------- prod1: trust prod2, endpoint
:CONNECT prod1 -U sa -P $(SAPW)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hadr_login')
    CREATE LOGIN hadr_login WITH PASSWORD = 'Ag_HADR_Internal_Login_2025!';
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'hadr_login')
    CREATE USER hadr_login FOR LOGIN hadr_login;
GO
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'prod2_hadr_cert')
    CREATE CERTIFICATE prod2_hadr_cert AUTHORIZATION hadr_login
        FROM FILE = '/var/opt/mssql/ag-certs/prod2_hadr_cert.cer';
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_mirroring_endpoints WHERE name = 'hadr_endpoint')
    CREATE ENDPOINT hadr_endpoint
        STATE = STARTED
        AS TCP (LISTENER_PORT = 5022)
        FOR DATABASE_MIRRORING (
            AUTHENTICATION = CERTIFICATE prod1_hadr_cert,
            ENCRYPTION = REQUIRED ALGORITHM AES,
            ROLE = ALL
        );
GO
GRANT CONNECT ON ENDPOINT::hadr_endpoint TO hadr_login;
GO

------------------------------------------------------- prod1: demo db + AG
DECLARE @qagdb sysname = QUOTENAME(N'$(DBNAME)');
IF DB_ID('$(DBNAME)') IS NULL
    EXEC ('CREATE DATABASE ' + @qagdb);
/*  AG membership requires FULL recovery regardless of whether the database
    is brand new (defaults to SIMPLE) or pre-existing (e.g. the schema's own
    'database' DB, deployed separately before this script runs) -- set it
    unconditionally rather than only on the just-created branch.           */
EXEC ('ALTER DATABASE ' + @qagdb + ' SET RECOVERY FULL');
/*  AG membership requires a full backup to close out "bulk logged changes
    not yet backed up" even with automatic seeding. Neither /dev/null nor
    the bind-mounted backups/ folder work for this on Docker Desktop for
    Windows — BACKUP DATABASE pre-allocates the target file with a syscall
    the bind-mount passthrough doesn't support ("DiskChangeFileSize" / OS
    error 31) — so this writes into the prod1-data *named volume* instead,
    which is a real filesystem inside the Docker VM.                    */
EXEC ('BACKUP DATABASE ' + @qagdb
    + ' TO DISK = ''/var/opt/mssql/data/$(DBNAME)_ag-seed.bak'' WITH INIT');
GO

-- READ_ONLY_ROUTING_URL/LIST are rejected inside CREATE AVAILABILITY GROUP
-- on this build regardless of nesting (Msg 153) -- set with ALTER ...
-- MODIFY REPLICA once the AG and both replicas exist, further down.
IF NOT EXISTS (SELECT 1 FROM sys.availability_groups WHERE name = 'ag1')
CREATE AVAILABILITY GROUP [ag1]
    WITH (CLUSTER_TYPE = NONE)
    FOR DATABASE [$(DBNAME)]
    REPLICA ON
        N'prod1' WITH (
            ENDPOINT_URL = N'TCP://prod1:5022',
            AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
            FAILOVER_MODE = MANUAL,
            SEEDING_MODE = AUTOMATIC),
        N'prod2' WITH (
            ENDPOINT_URL = N'TCP://prod2:5022',
            AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
            FAILOVER_MODE = MANUAL,
            SEEDING_MODE = AUTOMATIC,
            SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));
GO
ALTER AVAILABILITY GROUP [ag1] GRANT CREATE ANY DATABASE;
GO

--------------------------------------------------------- prod2: join + seed perm
:CONNECT prod2 -U sa -P $(SAPW)

IF NOT EXISTS (SELECT 1 FROM sys.availability_groups WHERE name = 'ag1')
    ALTER AVAILABILITY GROUP [ag1] JOIN WITH (CLUSTER_TYPE = NONE);
GO
ALTER AVAILABILITY GROUP [ag1] GRANT CREATE ANY DATABASE;
GO

------------------------------------------- prod1: read-only routing, once both replicas exist
-- READ_ONLY_ROUTING_URL belongs under SECONDARY_ROLE (the URL to use when
-- THIS replica is the one serving read-only traffic); READ_ONLY_ROUTING_LIST
-- belongs under PRIMARY_ROLE (where to send read-only traffic when THIS
-- replica is primary). Both are rejected at CREATE AVAILABILITY GROUP time
-- on this build (Msg 153) -- only valid via ALTER ... MODIFY REPLICA, once
-- the AG and both replicas already exist.
:CONNECT prod1 -U sa -P $(SAPW)

ALTER AVAILABILITY GROUP [ag1] MODIFY REPLICA ON N'prod1' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://prod1:1433'));
GO
ALTER AVAILABILITY GROUP [ag1] MODIFY REPLICA ON N'prod2' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://prod2:1433'));
GO
ALTER AVAILABILITY GROUP [ag1] MODIFY REPLICA ON N'prod1' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST = ('prod2')));
GO
ALTER AVAILABILITY GROUP [ag1] MODIFY REPLICA ON N'prod2' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST = ('prod1')));
GO

PRINT 'AG setup complete. prod2 is a read-only secondary (ApplicationIntent=ReadOnly routes there from prod1). Automatic seeding of $(DBNAME) runs in the background — check sys.dm_hadr_database_replica_states for SYNCHRONIZED.';
GO
