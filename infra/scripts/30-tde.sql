/*  30-tde.sql
    Enables Transparent Data Encryption (AES-256) on fin_pulse.

    TDE is instance-scoped (the certificate lives in master), so it can't ship in the
    dacpac -- run it after 02-deploy-fin-pulse.sql. On Azure SQL Database TDE is on by
    default with a service-managed key; this script is only for the SQL Server lab.

        docker compose exec prod1 /opt/mssql-tools18/bin/sqlcmd `
          -S localhost -U sa -P "$env:MSSQL_SA_PASSWORD" -C -b `
          -v TDE_KEY_PASSWORD="$env:TDE_KEY_PASSWORD" -i /scripts/30-tde.sql

    Idempotent. The certificate + private key are backed up to /var/opt/mssql/backups
    (-> infra/backups). Keep those files and the password OFF the server: without them
    a TDE-protected .bak can't be restored anywhere else. If fin_pulse is ever added to
    an availability group, restore the same certificate on every replica first.
*/
:on error exit
SET NOCOUNT ON;
GO

USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$(TDE_KEY_PASSWORD)';
GO

IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = 'tde_fin_pulse_cert')
BEGIN
    CREATE CERTIFICATE tde_fin_pulse_cert WITH SUBJECT = 'TDE certificate for fin_pulse';

    BACKUP CERTIFICATE tde_fin_pulse_cert
        TO FILE = '/var/opt/mssql/backups/tde_fin_pulse_cert.cer'
        WITH PRIVATE KEY (
            FILE = '/var/opt/mssql/backups/tde_fin_pulse_cert.pvk',
            ENCRYPTION BY PASSWORD = '$(TDE_KEY_PASSWORD)');
END
GO

USE fin_pulse;
GO

IF NOT EXISTS (SELECT 1 FROM sys.dm_database_encryption_keys WHERE database_id = DB_ID())
    CREATE DATABASE ENCRYPTION KEY
        WITH ALGORITHM = AES_256
        ENCRYPTION BY SERVER CERTIFICATE tde_fin_pulse_cert;
GO

IF (SELECT is_encrypted FROM sys.databases WHERE name = 'fin_pulse') = 0
    ALTER DATABASE fin_pulse SET ENCRYPTION ON;
GO

-- encryption_state: 2 = in progress, 3 = encrypted
SELECT DB_NAME(database_id) AS [database], encryption_state, percent_complete, key_algorithm, key_length
FROM sys.dm_database_encryption_keys
WHERE database_id IN (DB_ID('fin_pulse'), 2);   -- 2 = tempdb, encrypted automatically
GO
