<#
.SYNOPSIS
    Start CloudShirt in lokale .NET-modus.

.DESCRIPTION
    Start CloudShirt lokaal als monolithische .NET-app met SQLite.
    De app draait zonder Docker-application containers en bewaart data in lokale SQLite-bestanden.

    Dit script:
    1. Controleert vereiste tools
    2. Laadt variabelen uit .env (of maakt .env vanuit .env.example)
    3. Bouwt de Web-app
    4. Start Web als achtergrondproces met logbestand

.EXAMPLE
    .\scripts\run-dotnet.ps1
#>

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

function Stop-CloudShirtDotNetProcesses {
    $processes = @(Get-CimInstance Win32_Process | Where-Object {
        $_.Name -eq 'dotnet.exe' -and (
            $_.CommandLine -like '*src\PublicApi\PublicApi.csproj*' -or
            $_.CommandLine -like '*src/PublicApi/PublicApi.csproj*' -or
            $_.CommandLine -like '*src\Web\Web.csproj*' -or
            $_.CommandLine -like '*src/Web/Web.csproj*'
        )
    })

    if ($processes.Count -gt 0) {
        Write-Output "Deze applicatie draait al. Wordt nu geherstart...."
    }

    foreach ($process in $processes) {
        Write-Output "Oude CloudShirt-processen stoppen: PID $($process.ProcessId)"
        Stop-Process -Id $process.ProcessId -Force
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

    Write-Output "dotnet gevonden."

    Write-Section "Omgeving laden"

    if (-not (Test-Path ".env")) {
        Copy-Item ".env.example" ".env"
        Write-Output "Created .env from .env.example"
    }

    Import-DotEnv -Path ".env"

    Write-Output "Omgevingsvariabelen geladen."

    Stop-CloudShirtDotNetProcesses

    $localDataDir = Join-Path $repoRoot "src\local-data"
    New-Item -ItemType Directory -Force -Path $localDataDir | Out-Null

    $catalogDb = Join-Path $localDataDir "cloudshirt-catalog.db"
    $identityDb = Join-Path $localDataDir "cloudshirt-identity.db"

    Write-Section "Database modus"
    Write-Output "Volledig lokale monolithische modus (SQLite, zonder Docker)."

    $env:DatabaseProvider = 'sqlite'
    $env:UseOnlyInMemoryDatabase = 'false'
    $env:ConnectionStrings__CatalogConnection = "Data Source=$catalogDb"
    $env:ConnectionStrings__IdentityConnection = "Data Source=$identityDb"

    Write-Section "Web bouwen"
    dotnet build .\src\Web\Web.csproj --configuration Debug
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    Write-Section "Web starten"

    $logsDir = Join-Path $repoRoot "logs"
    New-Item -ItemType Directory -Force -Path $logsDir | Out-Null

    $webOut = Join-Path $logsDir "web.out.log"
    $webErr = Join-Path $logsDir "web.err.log"

    $webProcess = Start-Process -FilePath dotnet -ArgumentList @('run', '--no-build', '--no-restore', '--project', '.\src\Web\Web.csproj', '--launch-profile', 'Web') -WorkingDirectory $repoRoot -RedirectStandardOutput $webOut -RedirectStandardError $webErr -WindowStyle Hidden -PassThru

    Set-Content -Path (Join-Path $logsDir 'web.pid') -Value $webProcess.Id

    Write-Section "Klaar"
    Write-Output "Lokale monolithische .NET-modus gestart."
    Write-Output "- Web: https://localhost:5001"
    Write-Output "- SQLite DB's: $catalogDb en $identityDb"
    Write-Output ""
    Write-Output "Proces-ID's:"
    Write-Output "- Web: $($webProcess.Id)"
    Write-Output ""
    Write-Output "Logs:"
    Write-Output "- $webOut"
    Write-Output "- $webErr"
}
finally {
    Pop-Location
}
