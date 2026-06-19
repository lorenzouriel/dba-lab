$saPassword = if ($env:SA_PASSWORD) { $env:SA_PASSWORD } else { "YourStrong!Pass2024" }

Write-Host "============================================"
Write-Host " Availability Group Status"
Write-Host "============================================"

Write-Host ""
Write-Host "--- AG Replicas ---"
docker exec sql-prod-1 /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -Q "SELECT ag.name AS ag_name, ar.replica_server_name AS replica, ars.role_desc AS role, ar.availability_mode_desc AS sync_mode, ars.synchronization_health_desc AS sync_health, ars.connected_state_desc AS connected, ars.operational_state_desc AS state FROM sys.dm_hadr_availability_replica_states ars JOIN sys.availability_replicas ar ON ar.replica_id = ars.replica_id JOIN sys.availability_groups ag ON ag.group_id = ars.group_id;" 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "(Could not reach sql-prod-1)" }

Write-Host ""
Write-Host "--- Database Sync State ---"
docker exec sql-prod-1 /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -Q "SELECT DB_NAME(drs.database_id) AS db_name, ar.replica_server_name AS replica, drs.synchronization_state_desc AS sync_state, drs.synchronization_health_desc AS health, drs.log_send_queue_size AS log_send_queue_kb, drs.redo_queue_size AS redo_queue_kb FROM sys.dm_hadr_database_replica_states drs JOIN sys.availability_replicas ar ON ar.replica_id = drs.replica_id;" 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "(Could not reach sql-prod-1)" }

Write-Host ""
Write-Host "--- Endpoint Status ---"
foreach ($node in @("sql-prod-1", "sql-prod-2")) {
    Write-Host "$node`:"
    docker exec $node /opt/mssql-tools18/bin/sqlcmd `
        -S localhost -U sa -P $saPassword -No -b `
        -Q "SELECT name, state_desc, port FROM sys.tcp_endpoints WHERE type_desc = 'DATABASE_MIRRORING';" 2>$null
    if ($LASTEXITCODE -ne 0) { Write-Host "  (unreachable)" }
}
