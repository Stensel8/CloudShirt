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
    $runningServices = docker compose ps --status running --services 2>$null |
        Where-Object { $_ -and $_.Trim().Length -gt 0 }

    return $runningServices.Count -gt 0
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

    try {
        $apiStatus = (Invoke-WebRequest -UseBasicParsing "http://localhost:5200/swagger" -TimeoutSec 15).StatusCode
        Write-Output "PublicApi Swagger: $apiStatus"
    }
    catch {
        Write-Output "PublicApi Swagger check mislukt: $($_.Exception.Message)"
    }

    try {
        $webStatus = (Invoke-WebRequest -UseBasicParsing "http://localhost:5106" -TimeoutSec 15).StatusCode
        Write-Output "Web: $webStatus"
    }
    catch {
        Write-Output "Web check mislukt: $($_.Exception.Message)"
    }

    Write-Section "Klaar"
    Write-Output "Docker-modus gestart."
    Write-Output "- Web: http://localhost:5106"
    Write-Output "- PublicApi Swagger: http://localhost:5200/swagger"
}
finally {
    Pop-Location
}
