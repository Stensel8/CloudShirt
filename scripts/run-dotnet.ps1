<#
.SYNOPSIS
    Start CloudShirt in lokale .NET-modus.

.DESCRIPTION
    Start de PublicApi en Web als losse .NET-processen op je machine.
    De database draait via de PostgreSQL-container uit docker-compose.

    Dit script:
    1. Controleert vereiste tools
    2. Laadt variabelen uit .env (of maakt .env vanuit .env.example)
    3. Start optioneel PostgreSQL
    4. Start PublicApi en Web in aparte PowerShell-vensters

.PARAMETER SkipPostgres
    Slaat het starten van de PostgreSQL-container over.

.EXAMPLE
    .\scripts\run-dotnet.ps1
    .\scripts\run-dotnet.ps1 -SkipPostgres
#>

[CmdletBinding()]
param(
    [switch]$SkipPostgres
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Title)
    Write-Output ""
    Write-Output "===== $Title ====="
}

function Import-DotEnv {
    param([string]$Path)

    Get-Content $Path |
        Where-Object { $_ -and -not $_.StartsWith("#") -and $_.Contains("=") } |
        ForEach-Object {
            $parts = $_.Split("=", 2)
            [Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim(), "Process")
        }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot

try {
    Write-Section "Vooraf controleren"

    if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
        Write-Output "FOUT: dotnet CLI niet gevonden."
        exit 1
    }

    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Output "FOUT: Docker CLI niet gevonden."
        exit 1
    }

    Write-Output "dotnet en docker gevonden."

    Write-Section "Omgeving laden"

    if (-not (Test-Path ".env")) {
        Copy-Item ".env.example" ".env"
        Write-Output "Created .env from .env.example"
    }

    Import-DotEnv -Path ".env"

    $postgresUser = $env:POSTGRES_USER
    $postgresPassword = $env:POSTGRES_PASSWORD

    if ([string]::IsNullOrWhiteSpace($postgresUser) -or [string]::IsNullOrWhiteSpace($postgresPassword)) {
        Write-Output "FOUT: POSTGRES_USER en POSTGRES_PASSWORD moeten in .env staan."
        exit 1
    }

    Write-Output "Omgevingsvariabelen geladen."

    if (-not $SkipPostgres) {
        Write-Section "PostgreSQL starten"
        docker compose up -d postgres
    }

    Write-Section "PublicApi en Web starten"

    $apiCommand = @"
`$env:DatabaseProvider = 'postgres'
`$env:UseOnlyInMemoryDatabase = 'false'
`$env:ConnectionStrings__CatalogConnection = 'Host=localhost;Port=5432;Database=eshop_catalog;Username=$postgresUser;Password=$postgresPassword;'
`$env:ConnectionStrings__IdentityConnection = 'Host=localhost;Port=5432;Database=eshop_identity;Username=$postgresUser;Password=$postgresPassword;'
dotnet run --project .\src\PublicApi\PublicApi.csproj --launch-profile PublicApi
"@

    $webCommand = @"
`$env:DatabaseProvider = 'postgres'
`$env:UseOnlyInMemoryDatabase = 'false'
`$env:ConnectionStrings__CatalogConnection = 'Host=localhost;Port=5432;Database=eshop_catalog;Username=$postgresUser;Password=$postgresPassword;'
`$env:ConnectionStrings__IdentityConnection = 'Host=localhost;Port=5432;Database=eshop_identity;Username=$postgresUser;Password=$postgresPassword;'
dotnet run --project .\src\Web\Web.csproj --launch-profile Web
"@

    Start-Process pwsh -ArgumentList "-NoExit", "-Command", $apiCommand
    Start-Process pwsh -ArgumentList "-NoExit", "-Command", $webCommand

    Write-Section "Klaar"
    Write-Output "Lokale .NET-modus gestart."
    Write-Output "- Web: https://localhost:5001"
    Write-Output "- PublicApi Swagger: https://localhost:5099/swagger"
}
finally {
    Pop-Location
}
