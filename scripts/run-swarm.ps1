<#
.SYNOPSIS
    Start CloudShirt in Docker Swarm mode.

.DESCRIPTION
    Bouwt images en deployed de CloudShirt stack naar Docker Swarm.

.EXAMPLE
    .\scripts\run-swarm.ps1
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

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot

try {
    Write-Section "Vooraf controleren"

    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Output "FOUT: Docker CLI niet gevonden."
        exit 1
    }

    if (-not (Test-Path ".env")) {
        Copy-Item ".env.example" ".env"
        Write-Output "Created .env from .env.example"
    }

    $swarmState = docker info --format "{{.Swarm.LocalNodeState}}"
    if ($swarmState -eq "inactive") {
        Write-Section "Swarm initialiseren"
        docker swarm init | Out-Null
        Write-Output "Docker Swarm geinitialiseerd."
    }

    Write-Section "Images bouwen"
    docker compose build eshopwebmvc eshoppublicapi

    Write-Section "Stack deployen"
    docker stack deploy -c .\swarm-stack.yml cloudshirt

    Write-Section "Services"
    docker stack services cloudshirt

    Write-Section "Klaar"
    Write-Output "CloudShirt draait in Swarm-modus."
    Write-Output "- Web: http://localhost:5106"
    Write-Output "- PublicApi Swagger: http://localhost:5200/swagger"
}
finally {
    Pop-Location
}
