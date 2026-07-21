$ErrorActionPreference = 'Stop'

$octopusUrl = if ($env:OCTOPUS_URL) { $env:OCTOPUS_URL } else { "http://localhost:8080" }
$apiKey = $env:OCTOPUS_API_KEY
if (-not $apiKey) { throw "Set OCTOPUS_API_KEY in .env (Profile -> API Keys -> New API Key)" }

$saPassword = if ($env:SA_PASSWORD) { $env:SA_PASSWORD } else { "YourStrong!Pass2024" }
$headers = @{
    "X-Octopus-ApiKey" = $apiKey
    "Content-Type"     = "application/json"
}

$spaceId = "Spaces-1"
$api = "$octopusUrl/api/$spaceId"

Write-Host "============================================"
Write-Host " Configuring Octopus Deploy"
Write-Host " URL: $octopusUrl"
Write-Host " Space: $spaceId"
Write-Host "============================================"

# -- 1. Create Environments --
Write-Host ""
Write-Host "--- Creating Environments ---"

foreach ($envName in @("Dev", "Staging", "Production")) {
    Write-Host "  Creating: $envName"
    $body = @{
        Name             = $envName
        Description      = "$envName environment for DBA Lab"
        SortOrder        = 0
        UseGuidedFailure = $false
    } | ConvertTo-Json
    try { Invoke-RestMethod -Uri "$api/environments" -Method Post -Headers $headers -Body $body | Out-Null }
    catch { Write-Host "  (already exists)" }
}

# -- 2. Get Environment IDs --
Write-Host ""
Write-Host "--- Fetching Environment IDs ---"

$envs = Invoke-RestMethod -Uri "$api/environments/all" -Headers $headers
$devId     = ($envs | Where-Object { $_.Name -eq "Dev" }).Id
$stagingId = ($envs | Where-Object { $_.Name -eq "Staging" }).Id
$prodId    = ($envs | Where-Object { $_.Name -eq "Production" }).Id

Write-Host "  Dev:        $devId"
Write-Host "  Staging:    $stagingId"
Write-Host "  Production: $prodId"

# -- 3. Create Lifecycle --
Write-Host ""
Write-Host "--- Creating Lifecycle: Dev -> Staging -> Production ---"

$lcBody = @{
    Name        = "DBA Lab Pipeline"
    Description = "Dev -> Staging -> Production with manual promotion gates"
    Phases      = @()
    ReleaseRetentionPolicy  = @{ Unit = "Days"; QuantityToKeep = 30; ShouldKeepForever = $false }
    TentacleRetentionPolicy = @{ Unit = "Days"; QuantityToKeep = 30; ShouldKeepForever = $false }
} | ConvertTo-Json -Depth 5

$existingLc = (Invoke-RestMethod -Uri "$api/lifecycles/all" -Headers $headers) | Where-Object { $_.Name -eq "DBA Lab Pipeline" }
if ($existingLc) {
    $lcId = $existingLc.Id
    Write-Host "  (already exists: $lcId)"
} else {
    $newLc = Invoke-RestMethod -Uri "$api/lifecycles" -Method Post -Headers $headers -Body $lcBody
    $lcId = $newLc.Id
    Write-Host "  Created: $lcId"
}

$lc = Invoke-RestMethod -Uri "$api/lifecycles/$lcId" -Headers $headers
$lc.Phases = @(
    @{ Name = "Dev";        AutomaticDeploymentTargets = @($devId);     OptionalDeploymentTargets = @(); MinimumEnvironmentsBeforePromotion = 0; IsOptionalPhase = $false }
    @{ Name = "Staging";    AutomaticDeploymentTargets = @($stagingId); OptionalDeploymentTargets = @(); MinimumEnvironmentsBeforePromotion = 0; IsOptionalPhase = $false }
    @{ Name = "Production"; AutomaticDeploymentTargets = @($prodId);    OptionalDeploymentTargets = @(); MinimumEnvironmentsBeforePromotion = 0; IsOptionalPhase = $false }
)
$lcJson = $lc | ConvertTo-Json -Depth 10
Invoke-RestMethod -Uri "$api/lifecycles/$lcId" -Method Put -Headers $headers -Body $lcJson | Out-Null
Write-Host "  Phases configured."

# -- 4. Create Project Group --
Write-Host ""
Write-Host "--- Creating Project Group ---"

$pgBody = @{
    Name        = "Database Deployments"
    Description = "dacpac-based database deployment projects"
} | ConvertTo-Json

try {
    $pg = Invoke-RestMethod -Uri "$api/projectgroups" -Method Post -Headers $headers -Body $pgBody
    $pgId = $pg.Id
}
catch {
    $pgs = Invoke-RestMethod -Uri "$api/projectgroups/all" -Headers $headers
    $pgId = ($pgs | Where-Object { $_.Name -eq "Database Deployments" }).Id
}
Write-Host "  Project Group ID: $pgId"

# -- 5. Lifecycle ID already set above --
Write-Host "  Lifecycle ID: $lcId"

# -- 6. Create Project --
Write-Host ""
Write-Host "--- Creating Project: Database Deployment ---"

$projectBody = @{
    Name           = "Database Deployment"
    Description    = "Deploys AppDB via dacpac"
    ProjectGroupId = $pgId
    LifecycleId    = $lcId
    IsDisabled     = $false
} | ConvertTo-Json

try { Invoke-RestMethod -Uri "$api/projects" -Method Post -Headers $headers -Body $projectBody | Out-Null; Write-Host "  Project created." }
catch { Write-Host "  (already exists)" }

# -- 7. Create Project Variables --
Write-Host ""
Write-Host "--- Creating Project Variables ---"

$projects = Invoke-RestMethod -Uri "$api/projects/all" -Headers $headers
$projectId = ($projects | Where-Object { $_.Name -eq "Database Deployment" }).Id
$project = Invoke-RestMethod -Uri "$api/projects/$projectId" -Headers $headers
$varSetId = $project.VariableSetId

$varUrl = "$api/variables/$varSetId"

$currentVars = Invoke-RestMethod -Uri "$varUrl" -Headers $headers
$version = $currentVars.Version

$varBody = @{
    Id      = $varSetId
    OwnerId = $projectId
    Version = $version
    Variables = @(
        @{ Name = "SqlServer.Host"; Value = "sql-dev";     Type = "String"; IsSensitive = $false; Scope = @{ Environment = @($devId) } }
        @{ Name = "SqlServer.Host"; Value = "sql-staging"; Type = "String"; IsSensitive = $false; Scope = @{ Environment = @($stagingId) } }
        @{ Name = "SqlServer.Host"; Value = "sql-prod-1";  Type = "String"; IsSensitive = $false; Scope = @{ Environment = @($prodId) } }
        @{ Name = "SqlServer.Port"; Value = "1433";         Type = "String"; IsSensitive = $false; Scope = @{} }
        @{ Name = "SqlServer.Password"; Value = $saPassword; Type = "Sensitive"; IsSensitive = $true; Scope = @{} }
        @{ Name = "Database.Name"; Value = "AppDB";         Type = "String"; IsSensitive = $false; Scope = @{} }
        @{ Name = "Deploy.BlockOnPossibleDataLoss"; Value = "True"; Type = "String"; IsSensitive = $false; Scope = @{} }
    )
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "$varUrl" -Method Put -Headers $headers -Body $varBody | Out-Null
Write-Host "  Variables configured."

Write-Host ""
Write-Host "============================================"
Write-Host " Octopus Deploy Configuration Complete!"
Write-Host ""
Write-Host " URL:      $octopusUrl"
Write-Host " Project:  Database Deployment"
Write-Host " Pipeline: Dev -> Staging -> Production"
Write-Host "============================================"
