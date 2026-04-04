<#
.SYNOPSIS
    Stop CloudShirt in Docker Swarm mode.

.DESCRIPTION
    Verwijdert de CloudShirt stack uit Docker Swarm.

.EXAMPLE
    .\scripts\stop-swarm.ps1
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
    Write-Section "Stack verwijderen"
    docker stack rm cloudshirt

    Write-Section "Klaar"
    Write-Output "CloudShirt Swarm-stack is verwijderd."
}
finally {
    Pop-Location
}
