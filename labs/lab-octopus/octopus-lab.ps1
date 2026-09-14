param(
    [Parameter(Position = 0)]
    [ValidateSet("up", "down", "clean", "setup", "build", "pack", "push", "help")]
    [string]$Command = "help"
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# Load .env if exists
$envFile = Join-Path $root ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            [System.Environment]::SetEnvironmentVariable($Matches[1].Trim(), $Matches[2].Trim(), "Process")
        }
    }
}

$saPassword = if ($env:SA_PASSWORD) { $env:SA_PASSWORD } else { "YourStrong!Pass2024" }

switch ($Command) {
    # -- Infrastructure --
    "up" {
        Write-Host "Starting Octopus Deploy (requires dba-lab network)..."
        Write-Host "Make sure dba-lab is running: ..\ag-&-cicd-lab\dba-lab.ps1 up"
        Write-Host ""
        Push-Location $root
        docker compose up -d
        Pop-Location
        Write-Host ""
        Write-Host "Octopus initializing (~2 min)..."
        Write-Host "Open http://localhost:8080 when ready."
    }
    "down" {
        Push-Location $root
        docker compose down
        Pop-Location
    }
    "clean" {
        Push-Location $root
        docker compose down -v
        Pop-Location
    }

    # -- Octopus Configuration --
    "setup" {
        & "$root\scripts\setup-octopus.ps1"
    }

    # -- Build dacpac --
    "build" {
        $dbProjectDir = Join-Path $root "db"
        $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
        if (-not (Test-Path $vswhere)) { throw "vswhere not found. Install Visual Studio with SSDT." }
        $msbuild = & $vswhere -latest -requires Microsoft.Component.MSBuild -find "MSBuild\**\Bin\MSBuild.exe" | Select-Object -First 1
        if (-not $msbuild) { throw "MSBuild not found." }

        Write-Host "============================================"
        Write-Host " Building dacpac from SSDT projects"
        Write-Host "============================================"
        Write-Host ""

        Write-Host "Building AppDB..."
        & $msbuild (Join-Path $dbProjectDir "db.sqlproj") /p:Configuration=Release /v:quiet /nologo
        if ($LASTEXITCODE -ne 0) { throw "AppDB build failed." }
        Write-Host "  -> $(Join-Path $dbProjectDir 'bin\Release\db.dacpac')"

        Write-Host ""
        Write-Host "Build complete."
    }

    # -- Package dacpac for Octopus --
    "pack" {
        $dbProjectDir = Join-Path $root "db"
        $artifactsDir = Join-Path $root "artifacts"
        if (-not (Test-Path $artifactsDir)) { New-Item -ItemType Directory -Path $artifactsDir | Out-Null }

        $version = Get-Date -Format "yyyy.MM.dd.HHmm"

        Write-Host "============================================"
        Write-Host " Packaging dacpac (version: $version)"
        Write-Host "============================================"
        Write-Host ""

        $dacpacPath = Join-Path $dbProjectDir "bin\Release\db.dacpac"
        if (-not (Test-Path $dacpacPath)) { throw "db.dacpac not found. Run '.\octopus-lab.ps1 build' first." }

        $zipName = "DbaLab.AppDB.$version.zip"
        $zipPath = Join-Path $artifactsDir $zipName

        Write-Host "Packaging DbaLab.AppDB ($version)..."
        Compress-Archive -Path $dacpacPath -DestinationPath $zipPath -Force
        Write-Host "  -> $zipPath"
        Write-Host ""
        Write-Host "Package ready in: $artifactsDir"
    }

    # -- Push to Octopus feed --
    "push" {
        $artifactsDir = Join-Path $root "artifacts"
        $octopusUrl = if ($env:OCTOPUS_URL) { $env:OCTOPUS_URL } else { "http://localhost:8080" }
        $apiKey = $env:OCTOPUS_API_KEY
        if (-not $apiKey) { throw "Set OCTOPUS_API_KEY in .env" }

        Write-Host "============================================"
        Write-Host " Pushing packages to Octopus"
        Write-Host "============================================"
        Write-Host ""

        $packages = Get-ChildItem "$artifactsDir\*.zip" -ErrorAction SilentlyContinue
        if (-not $packages) { throw "No packages found in $artifactsDir. Run '.\octopus-lab.ps1 pack' first." }

        foreach ($pkg in $packages) {
            Write-Host "Pushing $($pkg.Name)..."
            $uri = "$octopusUrl/api/Spaces-1/packages/raw?replace=true"
            curl.exe -s -X POST $uri -H "X-Octopus-ApiKey: $apiKey" -F "fileData=@$($pkg.FullName)" | Out-Null
            if ($LASTEXITCODE -ne 0) { throw "Failed to push $($pkg.Name)" }
            Write-Host "  $($pkg.Name): OK"
        }

        Write-Host ""
        Write-Host "Packages pushed to $octopusUrl"
    }

    # -- Help --
    "help" {
        Write-Host ""
        Write-Host "  Octopus Lab - dacpac CI/CD with Octopus Deploy"
        Write-Host "  ================================================"
        Write-Host ""
        Write-Host "  PREREQUISITE: dba-lab must be running (..\ag-&-cicd-lab\dba-lab.ps1 up + init)"
        Write-Host ""
        Write-Host "  INFRASTRUCTURE"
        Write-Host "    .\octopus-lab.ps1 up         Start Octopus (DB + Server)"
        Write-Host "    .\octopus-lab.ps1 down        Stop Octopus containers"
        Write-Host "    .\octopus-lab.ps1 clean       Stop + remove Octopus volumes"
        Write-Host ""
        Write-Host "  CONFIGURATION"
        Write-Host "    .\octopus-lab.ps1 setup       Configure environments + project"
        Write-Host ""
        Write-Host "  BUILD & DEPLOY"
        Write-Host "    .\octopus-lab.ps1 build       Build dacpac from db\ SSDT projects"
        Write-Host "    .\octopus-lab.ps1 pack        Package dacpac into .nupkg"
        Write-Host "    .\octopus-lab.ps1 push        Push .nupkg to Octopus built-in feed"
        Write-Host ""
        Write-Host "  WORKFLOW"
        Write-Host "    1. ..\ag-&-cicd-lab\dba-lab.ps1 up + init   (start SQL instances)"
        Write-Host "    2. .\octopus-lab.ps1 up       (start Octopus)"
        Write-Host "    3. .\octopus-lab.ps1 setup    (configure via API)"
        Write-Host "    4. .\octopus-lab.ps1 build    (compile SSDT -> dacpac)"
        Write-Host "    5. .\octopus-lab.ps1 pack     (dacpac -> nupkg)"
        Write-Host "    6. .\octopus-lab.ps1 push     (nupkg -> Octopus feed)"
        Write-Host "    7. Create release + deploy in Octopus UI"
        Write-Host ""
    }
}
