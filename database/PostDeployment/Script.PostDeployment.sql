-- Post-deployment script for database
-- Runs after schema sync (dacpac publish). All scripts must be idempotent.

PRINT '=== PostDeployment: Start ===';
GO

:r .\MigrationScripts\1.0.0_SeedAlarmTypes.sql
GO

PRINT '=== PostDeployment: Complete ===';
GO
