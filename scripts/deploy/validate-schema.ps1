$saPassword = if ($env:SA_PASSWORD) { $env:SA_PASSWORD } else { "YourStrong!Pass2024" }

Write-Host "============================================"
Write-Host " Schema Validation: Cross-Environment Diff"
Write-Host "============================================"

$containers = @("sql-dev", "sql-staging", "sql-prod-1", "sql-prod-2")

foreach ($container in $containers) {
    Write-Host ""
    Write-Host "--- $container ---"
    $readOnly = if ($container -eq "sql-prod-2") { @("-K", "ReadOnly") } else { @() }
    docker exec $container /opt/mssql-tools18/bin/sqlcmd `
        -S localhost -U sa -P $saPassword -No -b `
        -d AppDB @readOnly `
        -Q "SELECT type, name FROM (SELECT 'TABLE' AS type, name FROM sys.tables WHERE is_ms_shipped = 0 UNION ALL SELECT 'PROC', name FROM sys.procedures UNION ALL SELECT 'VIEW', name FROM sys.views WHERE is_ms_shipped = 0) x ORDER BY type, name;" 2>$null
    if ($LASTEXITCODE -ne 0) { Write-Host "  (database not deployed)" }
}

Write-Host ""
Write-Host "============================================"
Write-Host " If all environments show identical objects,"
Write-Host " schema is consistent (no region drift)."
Write-Host "============================================"
