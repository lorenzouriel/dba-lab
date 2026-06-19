-- Post-deployment script for AppDB
-- Runs after schema sync (dacpac publish). All scripts must be idempotent.

PRINT '=== PostDeployment: Start ===';
GO

:r .\MigrationScripts\1.0.0_RTC_SeedReferenceData.sql
GO

PRINT '=== PostDeployment: Complete ===';
GO
