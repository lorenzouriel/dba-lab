/*  00-bootstrap.sql
    Instance-level configuration for the DP-800 lab.
    Idempotent — safe to re-run on every `compose up`.
*/
SET NOCOUNT ON;
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE WITH OVERRIDE;
GO

/*  sp_invoke_external_rest_endpoint — HTTPS calls out of the engine.
    Disabled by default in SQL Server 2025. Caller also needs
    EXECUTE ANY EXTERNAL ENDPOINT at the database level.            */
EXEC sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE WITH OVERRIDE;
GO

/*  Local ONNX runtime for CREATE EXTERNAL MODEL ... API_FORMAT = 'ONNX Runtime'.
    Only needed if you run models in-process rather than over REST.  */
EXEC sp_configure 'external AI runtimes enabled', 1;
RECONFIGURE WITH OVERRIDE;
GO

/*  Lab realism knobs. Container has 2+ vCPU; MAXDOP 0 on a small box
    produces parallelism artifacts that muddy tuning exercises.       */
EXEC sp_configure 'max degree of parallelism', 2;
EXEC sp_configure 'cost threshold for parallelism', 50;
EXEC sp_configure 'optimize for ad hoc workloads', 1;
EXEC sp_configure 'backup compression default', 1;
RECONFIGURE WITH OVERRIDE;
GO

/*  Backup/restore paths matching the bind mounts.                    */
EXEC xp_instance_regwrite
     N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer',
     N'BackupDirectory', REG_SZ, N'/var/opt/mssql/backups';
GO

PRINT 'bootstrap complete: ' + @@VERSION;
GO
