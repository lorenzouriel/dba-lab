-- Post-deployment script for database
-- Runs after schema sync (dacpac publish). All scripts must be idempotent.
-- No seed data required for this schema; add :r includes under MigrationScripts\ as needed.

PRINT '=== PostDeployment: Start ===';
GO

PRINT '=== PostDeployment: Complete ===';
GO
