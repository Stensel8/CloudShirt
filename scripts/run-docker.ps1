<#
.SYNOPSIS
    Start CloudShirt in Docker-modus.

.DESCRIPTION
    Bouwt en start alle Docker-services voor CloudShirt.
    De stack bevat Web, PublicApi en PostgreSQL.

    Dit script:
    1. Controleert vereiste tools
    2. Zorgt voor een .env-bestand
    3. Start docker compose met rebuild en orphan cleanup
    4. Toont status en basis endpoint-checks

.EXAMPLE
    .\scripts\run-docker.ps1
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Title)
    Write-Output ""
    Write-Output "===== $Title ====="
}

function Test-CloudShirtDockerRunning {
    $runningServices = @(docker compose ps --status running --services 2>$null |
        Where-Object { $_ -and $_.Trim().Length -gt 0 })

    return $runningServices.Count -gt 0
}

function Test-EndpointWithRetry {
    param(
        [string]$Name,
        [string]$Url,
        [int]$MaxWaitSeconds = 45,
        [int]$IntervalSeconds = 2
    )

    $lastError = "Onbekende fout."
    $startedAt = Get-Date

    while (((Get-Date) - $startedAt).TotalSeconds -lt $MaxWaitSeconds) {
        try {
            $response = Invoke-WebRequest -UseBasicParsing $Url -TimeoutSec 8
            $elapsed = [int]((Get-Date) - $startedAt).TotalSeconds
            Write-Host "${Name}: $($response.StatusCode) (na ${elapsed}s)"
            return $true
        }
        catch {
            $lastError = $_.Exception.Message
            Start-Sleep -Seconds $IntervalSeconds
        }
    }

    Write-Host "$Name check mislukt na ${MaxWaitSeconds}s: $lastError"
    return $false
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot

try {
    Write-Section "Vooraf controleren"

    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Output "FOUT: Docker CLI niet gevonden."
        exit 1
    }

    Write-Output "Docker CLI gevonden."

    Write-Section "Omgeving voorbereiden"

    if (-not (Test-Path ".env")) {
        Copy-Item ".env.example" ".env"
        Write-Output "Created .env from .env.example"
    }

    if (Test-CloudShirtDockerRunning) {
        Write-Output "Deze applicatie draait al. Wordt nu geherstart...."
    }

    Write-Section "Docker-services starten"
    docker compose up -d --build --remove-orphans

    Write-Section "Containerstatus"
    docker compose ps

    Write-Section "Endpoint checks"

    $apiReady = Test-EndpointWithRetry -Name "PublicApi Swagger" -Url "http://localhost:5200/swagger"
    $webReady = Test-EndpointWithRetry -Name "Web" -Url "http://localhost:5106"

    Write-Section "Klaar"
    if ($apiReady -and $webReady) {
        Write-Output "Docker-modus gestart en endpoints zijn bereikbaar."
    }
    else {
        Write-Output "Docker-modus gestart, maar niet alle endpoints zijn al bereikbaar."
        Write-Output "Tip: bekijk logs met: docker compose logs --tail=100"
    }
    Write-Output "- Web:              http://localhost:5106"
    Write-Output "- PublicApi Swagger: http://localhost:5200/swagger  (geen root-pagina, alleen /swagger en /api/...)"
}
finally {
    Pop-Location
}
