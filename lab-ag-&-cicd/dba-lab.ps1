param(
    [Parameter(Position = 0)]
    [ValidateSet(
        "up", "down", "clean",
        "init", "ag", "status", "failover",
        "deploy-dev", "deploy-staging", "deploy-prod", "deploy-all",
        "validate", "help"
    )]
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

switch ($Command) {
    # -- Infrastructure --
    "up" {
        Push-Location $root
        docker compose up -d
        Pop-Location
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

    # -- Database Setup --
    "init" {
        & "$root\scripts\init\init-all.ps1"
    }

    # -- Availability Group --
    "ag" {
        & "$root\scripts\ag\setup-ag.ps1"
    }
    "status" {
        & "$root\scripts\ag\status.ps1"
    }
    "failover" {
        & "$root\scripts\ag\failover.ps1"
    }

    # -- Deployments --
    "deploy-dev" {
        & "$root\scripts\deploy\deploy.ps1" -Env dev -Container sql-dev -Port 1401
    }
    "deploy-staging" {
        & "$root\scripts\deploy\deploy.ps1" -Env staging -Container sql-staging -Port 1402
    }
    "deploy-prod" {
        & "$root\scripts\deploy\deploy.ps1" -Env prod -Container sql-prod-1 -Port 1403
    }
    "deploy-all" {
        & "$root\scripts\deploy\deploy-all.ps1"
    }

    # -- Validation --
    "validate" {
        & "$root\scripts\deploy\validate-schema.ps1"
    }

    # -- Help --
    "help" {
        Write-Host ""
        Write-Host "  DBA Lab - SQL Server CI/CD with Always On AG"
        Write-Host "  ============================================="
        Write-Host ""
        Write-Host "  INFRASTRUCTURE"
        Write-Host "    .\dba-lab.ps1 up            Start SQL Server instances"
        Write-Host "    .\dba-lab.ps1 down           Stop all containers"
        Write-Host "    .\dba-lab.ps1 clean          Stop + remove volumes"
        Write-Host ""
        Write-Host "  DATABASE SETUP"
        Write-Host "    .\dba-lab.ps1 init           Build dacpac + deploy to all instances"
        Write-Host ""
        Write-Host "  AVAILABILITY GROUP"
        Write-Host "    .\dba-lab.ps1 ag             Configure AG (prod-1 <-> prod-2)"
        Write-Host "    .\dba-lab.ps1 status         Show AG replication status"
        Write-Host "    .\dba-lab.ps1 failover       Failover to sql-prod-2"
        Write-Host ""
        Write-Host "  DEPLOYMENTS"
        Write-Host "    .\dba-lab.ps1 deploy-dev     Build + publish dacpac to Dev"
        Write-Host "    .\dba-lab.ps1 deploy-staging Build + publish dacpac to Staging"
        Write-Host "    .\dba-lab.ps1 deploy-prod    Build + publish dacpac to Prod (AG replicates)"
        Write-Host "    .\dba-lab.ps1 deploy-all     Full dacpac pipeline with gates"
        Write-Host "    .\dba-lab.ps1 validate       Cross-env schema drift check"
        Write-Host ""
        Write-Host "  OTHER LABS"
        Write-Host "    octopus-lab/                 Octopus Deploy CI/CD with dacpac"
        Write-Host "    aws-lab/                     AWS EC2 AG (planned)"
        Write-Host "    azure-lab/                   Azure DevOps (planned)"
        Write-Host "    gcp-lab/                     GCP Cloud SQL (planned)"
        Write-Host ""
    }
}
