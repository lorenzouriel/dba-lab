param(
    [Parameter(Mandatory)][string]$Env,
    [Parameter(Mandatory)][string]$Container,
    [Parameter(Mandatory)][int]$Port
)

$ErrorActionPreference = 'Stop'
$saPassword = if ($env:SA_PASSWORD) { $env:SA_PASSWORD } else { "YourStrong!Pass2024" }
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$msbuild = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe"
$sqlpackage = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\150\sqlpackage.exe"
$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))
$dbProject = Join-Path $repoRoot "db"

Write-Host "============================================"
Write-Host " Deploying to: $Env ($Container`:$Port)"
Write-Host " Timestamp:    $timestamp"
Write-Host "============================================"

# -- STEP 1: BUILD (msbuild -> dacpac) --
Write-Host ""
Write-Host "--- Step 1: BUILD (msbuild -> dacpac) ---"

& $msbuild (Join-Path $dbProject "db.sqlproj") /p:Configuration=Release /v:quiet
if ($LASTEXITCODE -ne 0) { throw "MSBuild failed for db.sqlproj" }
Write-Host "  db.dacpac: OK"

# -- STEP 2: SCRIPT (preview changes) --
Write-Host ""
Write-Host "--- Step 2: SCRIPT (preview changes) ---"

$appDbDacpac = Join-Path $dbProject "bin\Release\db.dacpac"
$connBase = "Server=localhost,$Port;User Id=sa;Password=$saPassword;Encrypt=False"

$appDbScript = Join-Path $repoRoot "scripts\deploy\output\${Env}_AppDB_${timestamp}.sql"

New-Item -ItemType Directory -Force -Path (Join-Path $repoRoot "scripts\deploy\output") | Out-Null

& $sqlpackage /Action:Script /SourceFile:$appDbDacpac /TargetConnectionString:"$connBase;Initial Catalog=AppDB" /OutputPath:$appDbScript /p:IncludeCompositeObjects=True 2>&1
if ($LASTEXITCODE -ne 0) { Write-Host "  (AppDB may not exist yet - will create on publish)" }
else { Write-Host "  AppDB diff script: $appDbScript" }

# -- STEP 3: PUBLISH (apply dacpac) --
Write-Host ""
Write-Host "--- Step 3: PUBLISH (dacpac -> target) ---"

Write-Host "  Publishing AppDB..."
& $sqlpackage /Action:Publish /SourceFile:$appDbDacpac /TargetConnectionString:"$connBase;Initial Catalog=AppDB" /p:CreateNewDatabase=False /p:BlockOnPossibleDataLoss=True /p:IncludeCompositeObjects=True
if ($LASTEXITCODE -ne 0) {
    Write-Host "  AppDB does not exist - creating with dacpac..."
    & $sqlpackage /Action:Publish /SourceFile:$appDbDacpac /TargetConnectionString:"$connBase;Initial Catalog=AppDB" /p:CreateNewDatabase=True /p:IncludeCompositeObjects=True
    if ($LASTEXITCODE -ne 0) { throw "Failed to publish AppDB to $Env" }
}
Write-Host "  AppDB: OK"

# -- STEP 4: VERIFY --
Write-Host ""
Write-Host "--- Step 4: VERIFY ---"
docker exec $Container /opt/mssql-tools18/bin/sqlcmd `
    -S localhost -U sa -P $saPassword -No -b `
    -d AppDB `
    -Q "PRINT '  Tables:'; SELECT '    ' + name FROM sys.tables WHERE is_ms_shipped = 0 ORDER BY name; PRINT '  Procedures:'; SELECT '    ' + name FROM sys.procedures ORDER BY name; PRINT '  Views:'; SELECT '    ' + name FROM sys.views WHERE is_ms_shipped = 0 ORDER BY name;"

Write-Host ""
Write-Host "============================================"
Write-Host " Deploy to $Env complete!"
Write-Host "============================================"
