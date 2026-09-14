$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$deployDir = Join-Path (Split-Path -Parent $scriptDir) "deploy"

$containers = @(
    @{ Name = "sql-dev";     Port = 1401 },
    @{ Name = "sql-staging"; Port = 1402 },
    @{ Name = "sql-prod-1";  Port = 1403 },
    @{ Name = "sql-prod-2";  Port = 1404 }
)

Write-Host "============================================"
Write-Host " Initializing all instances via dacpac"
Write-Host "============================================"

foreach ($c in $containers) {
    Write-Host ""
    Write-Host "--- $($c.Name) ---"

    & "$scriptDir\wait-for-sql.ps1" -Container $c.Name -MaxRetries 30

    $env = switch ($c.Name) {
        "sql-dev"     { "dev" }
        "sql-staging" { "staging" }
        "sql-prod-1"  { "prod" }
        "sql-prod-2"  { "prod-secondary" }
    }

    & "$deployDir\deploy.ps1" -Env $env -Container $c.Name -Port $c.Port

    Write-Host "$($c.Name): DONE"
}

Write-Host ""
Write-Host "============================================"
Write-Host " All instances initialized successfully"
Write-Host "============================================"
