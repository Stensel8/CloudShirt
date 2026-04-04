<#
.SYNOPSIS
    Start CloudShirt in lokale .NET-modus.

.DESCRIPTION
    Start CloudShirt lokaal als monolithische .NET-app.
    De monoliet gebruikt PostgreSQL (dezelfde database-technologie als Docker).

    Dit script:
    1. Controleert vereiste tools
    2. Laadt variabelen uit .env (of maakt .env vanuit .env.example)
    3. Bouwt en start de Web-app

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

function Wait-ForPostgresContainer {
    param(
        [int]$MaxWaitSeconds = 45,
        [int]$IntervalSeconds = 2
    )

    $startedAt = Get-Date

    while (((Get-Date) - $startedAt).TotalSeconds -lt $MaxWaitSeconds) {
        try {
            docker compose exec -T db pg_isready -U $env:POSTGRES_USER -d postgres *> $null
            if ($LASTEXITCODE -eq 0) {
                return $true
            }
        }
        catch {
            # Retry until timeout.
        }

        Start-Sleep -Seconds $IntervalSeconds
    }

    return $false
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

function Stop-DockerContainersUsingPorts {
    param([int[]]$Ports)

    $containerLines = @(docker ps --format "{{.ID}}|{{.Names}}|{{.Ports}}" 2>$null)
    $containerIdsToStop = [System.Collections.Generic.HashSet[string]]::new()

    foreach ($line in $containerLines) {
        if (-not $line) { continue }

        $parts = $line -split "\|", 3
        if ($parts.Count -lt 3) { continue }

        $containerId = $parts[0]
        $containerName = $parts[1]
        $portsText = $parts[2]
        $isCloudShirtContainer = $containerName -like "cloudshirt-*"

        foreach ($port in $Ports) {
            if ($portsText -like "*:$port->*") {
                if (-not $isCloudShirtContainer) {
                    Write-Output "FOUT: poort $port wordt gebruikt door niet-CloudShirt container '$containerName'."
                    Write-Output "Stop deze container handmatig en probeer opnieuw."
                    exit 1
                }

                if ($containerIdsToStop.Add($containerId)) {
                    Write-Output "Poort $port in gebruik door container '$containerName'. Container wordt gestopt."
                }
                break
            }
        }
    }

    foreach ($containerId in $containerIdsToStop) {
        docker stop $containerId *> $null
        docker rm $containerId *> $null
    }
}

function Stop-ProcessesUsingPorts {
    param([int[]]$Ports)

    $processIds = [System.Collections.Generic.HashSet[int]]::new()

    foreach ($port in $Ports) {
        $connections = @(Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue)
        foreach ($connection in $connections) {
            if ($connection.OwningProcess -gt 4) {
                [void]$processIds.Add($connection.OwningProcess)
            }
        }
    }

    foreach ($procId in $processIds) {
        try {
            $process = Get-Process -Id $procId -ErrorAction Stop
            $commandLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $procId" -ErrorAction SilentlyContinue).CommandLine
            $isCloudShirtProcess = $false

            if ($process.ProcessName -eq "dotnet" -and $commandLine) {
                $isCloudShirtProcess = $commandLine -like "*CloudShirt*"
            }

            if ($isCloudShirtProcess) {
                Write-Output "Poortconflict opgelost: CloudShirt-proces '$($process.ProcessName)' (PID $procId) wordt gestopt."
                Stop-Process -Id $procId -Force -ErrorAction Stop
            }
            else {
                Write-Output "FOUT: poortconflict door niet-CloudShirt proces '$($process.ProcessName)' (PID $procId)."
                Write-Output "Stop dit proces handmatig en probeer opnieuw."
                exit 1
            }
        }
        catch {
            Write-Output "Waarschuwing: proces op PID $procId kon niet worden geverifieerd/gestopt."
        }
    }
}

function Ensure-RequiredPortsAvailable {
    param([int[]]$Ports)

    Stop-DockerContainersUsingPorts -Ports $Ports
    Stop-ProcessesUsingPorts -Ports $Ports
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

    Write-Section "Poorten vrijmaken"
    Ensure-RequiredPortsAvailable -Ports @(5106, 5200, 5432)

    Stop-CloudShirtDotNetProcesses

    Write-Section "Database modus"
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Output "FOUT: Docker CLI niet gevonden, nodig voor PostgreSQL in monolietmodus."
        exit 1
    }

    Write-Output "Monolietmodus met PostgreSQL (zelfde database-technologie als Docker)."
    Write-Output "PostgreSQL-container starten (alleen database)..."

    docker compose up -d db
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    if (-not (Wait-ForPostgresContainer)) {
        Write-Output "FOUT: PostgreSQL werd niet op tijd klaar."
        exit 1
    }

    $env:DatabaseProvider = 'postgres'
    $env:UseOnlyInMemoryDatabase = 'false'
    $env:ConnectionStrings__CatalogConnection = "Host=localhost;Port=5432;Database=eshop_catalog;Username=$($env:POSTGRES_USER);Password=$($env:POSTGRES_PASSWORD);"
    $env:ConnectionStrings__IdentityConnection = "Host=localhost;Port=5432;Database=eshop_identity;Username=$($env:POSTGRES_USER);Password=$($env:POSTGRES_PASSWORD);"

    Write-Section "Web en PublicApi starten"

    $logsDir = Join-Path $repoRoot "logs"
    New-Item -ItemType Directory -Force -Path $logsDir | Out-Null

    $webOut  = Join-Path $logsDir "web.out.log"
    $webErr  = Join-Path $logsDir "web.err.log"
    $apiOut  = Join-Path $logsDir "api.out.log"
    $apiErr  = Join-Path $logsDir "api.err.log"

    $webProcess = Start-Process -FilePath dotnet -ArgumentList @('run', '--no-restore', '--project', '.\src\Web\Web.csproj', '--urls', 'http://localhost:5106') -WorkingDirectory $repoRoot -RedirectStandardOutput $webOut -RedirectStandardError $webErr -WindowStyle Hidden -PassThru

    $apiProcess = Start-Process -FilePath dotnet -ArgumentList @('run', '--no-restore', '--project', '.\src\PublicApi\PublicApi.csproj', '--urls', 'http://localhost:5200') -WorkingDirectory $repoRoot -RedirectStandardOutput $apiOut -RedirectStandardError $apiErr -WindowStyle Hidden -PassThru

    Set-Content -Path (Join-Path $logsDir 'web.pid') -Value $webProcess.Id
    Set-Content -Path (Join-Path $logsDir 'api.pid') -Value $apiProcess.Id

    Write-Section "Klaar"
    Write-Output "Lokale monolithische .NET-modus gestart."
    Write-Output "- Web:              http://localhost:5106"
    Write-Output "- PublicApi Swagger: http://localhost:5200/swagger  (geen root-pagina, alleen /swagger en /api/...)"
    Write-Output "- PostgreSQL: localhost:5432 (databasecontainer uit docker-compose)"
    Write-Output ""
    Write-Output "Proces-ID's:"
    Write-Output "- Web:       $($webProcess.Id)"
    Write-Output "- PublicApi: $($apiProcess.Id)"
    Write-Output ""
    Write-Output "Logs:"
    Write-Output "- $webOut"
    Write-Output "- $webErr"
    Write-Output "- $apiOut"
    Write-Output "- $apiErr"
}
finally {
    Pop-Location
}
