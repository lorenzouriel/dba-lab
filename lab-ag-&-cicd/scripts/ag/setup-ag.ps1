$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$initDir = Join-Path (Split-Path -Parent $scriptDir) "init"
$saPassword = if ($env:SA_PASSWORD) { $env:SA_PASSWORD } else { "YourStrong!Pass2024" }

Write-Host "============================================"
Write-Host " Setting up Always On Availability Group"
Write-Host "============================================"
Write-Host ""

# Wait for both prod nodes
& "$initDir\wait-for-sql.ps1" -Container "sql-prod-1" -MaxRetries 30
& "$initDir\wait-for-sql.ps1" -Container "sql-prod-2" -MaxRetries 30

# Verify HADR is enabled
Write-Host ""
Write-Host "--- Verifying HADR is enabled ---"
foreach ($node in @("sql-prod-1", "sql-prod-2")) {
    $hadr = docker exec $node /opt/mssql-tools18/bin/sqlcmd `
        -S localhost -U sa -P $saPassword -No -b `
        -Q "SELECT SERVERPROPERTY('IsHadrEnabled')" -h -1 -W 2>$null
    $hadrValue = ($hadr | Select-Object -First 1).Trim()
    if ($hadrValue -ne "1") {
        throw "HADR not enabled on $node. Check MSSQL_ENABLE_HADR env var."
    }
    Write-Host "$node`: HADR enabled"
}

# Fix shared volume permissions (mssql user = uid 10001)
Write-Host ""
Write-Host "--- Fixing shared volume permissions ---"
docker exec --user root sql-prod-1 chmod 777 /var/opt/mssql/shared
docker exec --user root sql-prod-2 chmod 777 /var/opt/mssql/shared
Write-Host "Shared volume writable"

# Set FULL recovery on primary
Write-Host ""
Write-Host "--- Setting FULL recovery model ---"
docker exec sql-prod-1 /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -Q "ALTER DATABASE [AppDB] SET RECOVERY FULL; PRINT 'AppDB set to FULL recovery';"

# Full backup (required for AG)
Write-Host ""
Write-Host "--- Taking full backup on primary ---"
docker exec sql-prod-1 /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -Q "BACKUP DATABASE [AppDB] TO DISK = '/var/opt/mssql/shared/AppDB_full.bak' WITH FORMAT, INIT, COMPRESSION; PRINT 'Full backup complete';"

# Configure primary
Write-Host ""
Write-Host "--- Configuring PRIMARY (sql-prod-1) ---"
docker exec sql-prod-1 /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -i /scripts/ag/configure-primary.sql

# Wait for cert files on shared volume
Start-Sleep -Seconds 3

# Drop AppDB on secondary so auto-seeding creates it from primary
Write-Host ""
Write-Host "--- Preparing secondary (dropping local AppDB for auto-seeding) ---"
docker exec sql-prod-2 /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -Q "IF DB_ID('AppDB') IS NOT NULL BEGIN DROP DATABASE [AppDB]; PRINT 'Dropped local AppDB (AG will re-create from primary)'; END ELSE PRINT 'AppDB not present - ready for seeding';"

# Configure secondary
Write-Host ""
Write-Host "--- Configuring SECONDARY (sql-prod-2) ---"
docker exec sql-prod-2 /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -i /scripts/ag/configure-secondary.sql

# Wait for automatic seeding
Write-Host ""
Write-Host "--- Waiting for automatic seeding ---"
Start-Sleep -Seconds 15

# Verify AG status
Write-Host ""
Write-Host "--- Verifying AG Status ---"
docker exec sql-prod-1 /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -Q "SELECT ag.name AS ag_name, ar.replica_server_name AS replica, ars.role_desc AS role, ars.synchronization_health_desc AS sync_health, ars.connected_state_desc AS connected FROM sys.dm_hadr_availability_replica_states ars JOIN sys.availability_replicas ar ON ar.replica_id = ars.replica_id JOIN sys.availability_groups ag ON ag.group_id = ars.group_id;"

Write-Host ""
Write-Host "============================================"
Write-Host " AG Setup Complete!"
Write-Host " Primary:   sql-prod-1 (localhost:1403)"
Write-Host " Secondary: sql-prod-2 (localhost:1404)"
Write-Host "============================================"
