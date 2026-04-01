<#
.SYNOPSIS
    Stop CloudShirt in Docker-modus.

.DESCRIPTION
    Stopt draaiende CloudShirt Docker-services via docker compose.

.EXAMPLE
    .\scripts\stop-docker.ps1
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

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot

try {
    Write-Section "Vooraf controleren"

    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Output "FOUT: Docker CLI niet gevonden."
        exit 1
    }

    Write-Output "Docker CLI gevonden."

    Write-Section "Docker-services stoppen"

    if (-not (Test-CloudShirtDockerRunning)) {
        Write-Output "Geen draaiende CloudShirt Docker-services gevonden."
    }
    else {
        docker compose stop
        Write-Output "CloudShirt Docker-services zijn gestopt."
    }

    Write-Section "Containerstatus"
    docker compose ps

    Write-Section "Klaar"
    Write-Output "Docker-modus gestopt."
}
finally {
    Pop-Location
}
