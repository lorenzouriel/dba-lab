/*  21-ag-add-prod3.sql
    Adds prod3 to the existing ag1 Availability Group (created by
    20-ag-setup.sql on prod1+prod2) as a third, ASYNCHRONOUS_COMMIT,
    read-only replica -- read-scale capacity, not another synchronous HA
    partner. Automatic seeding then copies every database already in ag1
    (fin_pulse, agdb, ...) onto prod3 without a manual backup/restore.

    Certificate trust is set up full-mesh (prod3<->prod1 AND prod3<->prod2),
    not just prod3<->prod1, so that if you ever manually fail over to prod2,
    it can still talk to prod3 directly as the new primary.

    Run once ag-setup has already run and prod3 reports healthy:
        docker compose --profile ha up -d prod3
        docker compose --profile ha run --rm ag-add-prod3

    SAPW comes from the ag-add-prod3 service's `-v SAPW=...` -- deliberately
    not re-defaulted here with :setvar, for the same reason as 20-ag-setup.sql.
*/
:on error exit
SET NOCOUNT ON;
GO

---------------------------------------------------------------- prod3: cert
:CONNECT prod3 -U sa -P $(SAPW)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$(SAPW)';
GO
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'prod3_hadr_cert')
    CREATE CERTIFICATE prod3_hadr_cert WITH SUBJECT = 'prod3 HADR endpoint cert';
GO
DECLARE @exists3 TABLE (file_exists bit, file_is_directory bit, parent_directory_exists bit);
INSERT INTO @exists3 EXEC master.dbo.xp_fileexist '/var/opt/mssql/ag-certs/prod3_hadr_cert.cer';
IF NOT EXISTS (SELECT 1 FROM @exists3 WHERE file_exists = 1)
    BACKUP CERTIFICATE prod3_hadr_cert TO FILE = '/var/opt/mssql/ag-certs/prod3_hadr_cert.cer';
GO

----------------------------------------------- prod3: trust prod1, endpoint
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
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'prod2_hadr_cert')
    CREATE CERTIFICATE prod2_hadr_cert AUTHORIZATION hadr_login
        FROM FILE = '/var/opt/mssql/ag-certs/prod2_hadr_cert.cer';
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_mirroring_endpoints WHERE name = 'hadr_endpoint')
    CREATE ENDPOINT hadr_endpoint
        STATE = STARTED
        AS TCP (LISTENER_PORT = 5022)
        FOR DATABASE_MIRRORING (
            AUTHENTICATION = CERTIFICATE prod3_hadr_cert,
            ENCRYPTION = REQUIRED ALGORITHM AES,
            ROLE = ALL
        );
GO
GRANT CONNECT ON ENDPOINT::hadr_endpoint TO hadr_login;
GO

----------------------------------------------- prod1: trust prod3, endpoint
:CONNECT prod1 -U sa -P $(SAPW)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'prod3_hadr_cert')
    CREATE CERTIFICATE prod3_hadr_cert AUTHORIZATION hadr_login
        FROM FILE = '/var/opt/mssql/ag-certs/prod3_hadr_cert.cer';
GO

----------------------------------------------- prod2: trust prod3, endpoint
-- Full mesh: prod2 needs to trust prod3 (and vice versa, above) in case
-- prod2 is ever manually failed over to and becomes the primary talking to
-- prod3 directly.
:CONNECT prod2 -U sa -P $(SAPW)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'prod3_hadr_cert')
    CREATE CERTIFICATE prod3_hadr_cert AUTHORIZATION hadr_login
        FROM FILE = '/var/opt/mssql/ag-certs/prod3_hadr_cert.cer';
GO

:CONNECT prod3 -U sa -P $(SAPW)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'prod2_hadr_cert')
    CREATE CERTIFICATE prod2_hadr_cert AUTHORIZATION hadr_login
        FROM FILE = '/var/opt/mssql/ag-certs/prod2_hadr_cert.cer';
GO

--------------------------------------------------- prod1: add prod3 replica
:CONNECT prod1 -U sa -P $(SAPW)

IF NOT EXISTS (SELECT 1 FROM sys.availability_replicas WHERE replica_server_name = 'prod3')
ALTER AVAILABILITY GROUP [ag1] ADD REPLICA ON
    N'prod3' WITH (
        ENDPOINT_URL = N'TCP://prod3:5022',
        AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT,
        FAILOVER_MODE = MANUAL,
        SEEDING_MODE = AUTOMATIC,
        SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY));
GO

--------------------------------------------------------- prod3: join + seed perm
:CONNECT prod3 -U sa -P $(SAPW)

IF NOT EXISTS (SELECT 1 FROM sys.availability_groups WHERE name = 'ag1')
    ALTER AVAILABILITY GROUP [ag1] JOIN WITH (CLUSTER_TYPE = NONE);
GO
ALTER AVAILABILITY GROUP [ag1] GRANT CREATE ANY DATABASE;
GO

------------------------------------------- prod1: fold prod3 into read-only routing
-- prod3 gets its own SECONDARY_ROLE URL, and prod1's (and prod2's, in case
-- of failover to prod2) PRIMARY_ROLE routing list becomes a load-balanced
-- set across BOTH read-only replicas instead of just prod2. prod3 gets no
-- PRIMARY_ROLE list of its own -- it's read-scale-only, not a failover
-- target this lab routes traffic through if it ever became primary.
:CONNECT prod1 -U sa -P $(SAPW)

ALTER AVAILABILITY GROUP [ag1] MODIFY REPLICA ON N'prod3' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://prod3:1433'));
GO
ALTER AVAILABILITY GROUP [ag1] MODIFY REPLICA ON N'prod1' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST = (('prod2', 'prod3'))));
GO
ALTER AVAILABILITY GROUP [ag1] MODIFY REPLICA ON N'prod2' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST = (('prod1', 'prod3'))));
GO

PRINT 'prod3 added to ag1 as an asynchronous-commit, read-only replica. ApplicationIntent=ReadOnly connections now load-balance across prod2 and prod3. Automatic seeding runs in the background -- check sys.dm_hadr_database_replica_states for SYNCHRONIZED (prod3 catches up asynchronously, so brief lag there is normal).';
GO
