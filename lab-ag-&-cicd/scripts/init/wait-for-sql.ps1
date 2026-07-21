param(
    [Parameter(Mandatory)][string]$Container,
    [int]$MaxRetries = 30
)

$saPassword = if ($env:SA_PASSWORD) { $env:SA_PASSWORD } else { "YourStrong!Pass2024" }

Write-Host "Waiting for $Container..."
for ($i = 1; $i -le $MaxRetries; $i++) {
    $result = docker exec $Container /opt/mssql-tools18/bin/sqlcmd `
        -S localhost -U sa -P $saPassword -No `
        -Q "SELECT 1" -b 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$Container is ready."
        return
    }
    Write-Host "  attempt $i/$MaxRetries..."
    Start-Sleep -Seconds 2
}

throw "$Container did not become ready in time."
