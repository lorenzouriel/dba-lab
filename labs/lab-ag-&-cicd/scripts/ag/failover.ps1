$ErrorActionPreference = 'Stop'
$saPassword = if ($env:SA_PASSWORD) { $env:SA_PASSWORD } else { "YourStrong!Pass2024" }

Write-Host "============================================"
Write-Host " Manual Failover: sql-prod-1 -> sql-prod-2"
Write-Host "============================================"

Write-Host ""
Write-Host "--- Current state ---"
docker exec sql-prod-1 /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -Q "SELECT ar.replica_server_name, ars.role_desc, ars.synchronization_health_desc FROM sys.dm_hadr_availability_replica_states ars JOIN sys.availability_replicas ar ON ar.replica_id = ars.replica_id;" 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "(primary may be down)" }

Write-Host ""
Write-Host "--- Failing over to sql-prod-2 ---"
docker exec sql-prod-2 /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -Q "ALTER AVAILABILITY GROUP [AppDB_AG] FORCE_FAILOVER_ALLOW_DATA_LOSS; PRINT 'Failover complete - sql-prod-2 is now PRIMARY';"

Write-Host ""
Write-Host "--- Post-failover state ---"
docker exec sql-prod-2 /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -Q "SELECT ar.replica_server_name, ars.role_desc, ars.synchronization_health_desc FROM sys.dm_hadr_availability_replica_states ars JOIN sys.availability_replicas ar ON ar.replica_id = ars.replica_id;"

Write-Host ""
Write-Host "============================================"
Write-Host " sql-prod-2 is now PRIMARY"
Write-Host " To resume sync, restart sql-prod-1 and run:"
Write-Host "   ALTER AVAILABILITY GROUP [AppDB_AG]"
Write-Host "   SET (ROLE = SECONDARY);"
Write-Host "============================================"
