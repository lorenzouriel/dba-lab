$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$saPassword = if ($env:SA_PASSWORD) { $env:SA_PASSWORD } else { "YourStrong!Pass2024" }

Write-Host "============================================"
Write-Host " Full Pipeline: Dev -> Staging -> Prod"
Write-Host "============================================"
Write-Host ""
Write-Host " This simulates the Octopus Deploy lifecycle:"
Write-Host "   1. Deploy to Dev"
Write-Host "   2. Deploy to Staging"
Write-Host "   3. Deploy to Prod (primary only - AG replicates to secondary)"
Write-Host ""

# -- DEV --
Write-Host "========== PHASE 1: DEV =========="
& "$scriptDir\deploy.ps1" -Env dev -Container sql-dev -Port 1401
Write-Host ""
$reply = Read-Host "Dev deployment complete. Promote to Staging? (y/n)"
if ($reply -notmatch '^[Yy]') {
    Write-Host "Pipeline stopped at Dev."
    return
}

# -- STAGING --
Write-Host ""
Write-Host "========== PHASE 2: STAGING =========="
& "$scriptDir\deploy.ps1" -Env staging -Container sql-staging -Port 1402
Write-Host ""
$reply = Read-Host "Staging deployment complete. Promote to Production? (y/n)"
if ($reply -notmatch '^[Yy]') {
    Write-Host "Pipeline stopped at Staging."
    return
}

# -- PROD --
Write-Host ""
Write-Host "========== PHASE 3: PRODUCTION =========="
Write-Host "Deploying to sql-prod-1 (PRIMARY)..."
Write-Host "AG will automatically replicate to sql-prod-2 (SECONDARY)."
Write-Host ""
& "$scriptDir\deploy.ps1" -Env prod -Container sql-prod-1 -Port 1403

# Verify replication
Write-Host ""
Write-Host "--- Verifying AG replication ---"
Start-Sleep -Seconds 5
docker exec sql-prod-2 /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -d AppDB -K ReadOnly `
    -Q "PRINT 'Secondary (sql-prod-2) schema:'; SELECT '  ' + name FROM sys.tables ORDER BY name; SELECT '  ' + name FROM sys.procedures ORDER BY name;" 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "  (secondary not yet synced - check AG status)" }

Write-Host ""
Write-Host "============================================"
Write-Host " Pipeline Complete!"
Write-Host ""
Write-Host " Dev:     sql-dev     -> localhost:1401"
Write-Host " Staging: sql-staging -> localhost:1402"
Write-Host " Prod-1:  sql-prod-1  -> localhost:1403 (PRIMARY)"
Write-Host " Prod-2:  sql-prod-2  -> localhost:1404 (SECONDARY)"
Write-Host "============================================"
