<#
.SYNOPSIS
    Start CloudShirt in Docker-modus.

.DESCRIPTION
    Bouwt en start alle Docker-services voor CloudShirt.
    De stack bevat Web, PublicApi en PostgreSQL.

    Dit script:
    1. Controleert vereiste tools
    2. Zorgt voor een .env-bestand
    3. Start docker compose snel met cachegebruik; build alleen als images ontbreken
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

function Resolve-RequiredPorts {
    param([int[]]$Ports)

    Stop-DockerContainersUsingPorts -Ports $Ports
    Stop-ProcessesUsingPorts -Ports $Ports
}

function Test-ImageExists {
    param([string]$ImageName)

    docker image inspect $ImageName *> $null
    return $LASTEXITCODE -eq 0
}

function Try-PullComposeServiceImage {
    param([string]$ServiceName)

    docker compose pull $ServiceName
    return $LASTEXITCODE -eq 0
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
            Write-Output "${Name}: $($response.StatusCode) (na ${elapsed}s)"
            return $true
        }
        catch {
            $lastError = $_.Exception.Message
            Start-Sleep -Seconds $IntervalSeconds
        }
    }

    Write-Output "$Name check mislukt na ${MaxWaitSeconds}s: $lastError"
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
        Write-Output "Er draait al een compose-stack in deze map."
    }

    Write-Section "Poorten vrijmaken"
    Resolve-RequiredPorts -Ports @(5106, 5200, 5432)

    Write-Section "Docker-services starten"
    $webImageExists = Test-ImageExists -ImageName "cloudshirt-dotnet-web:latest"
    $apiImageExists = Test-ImageExists -ImageName "cloudshirt-dotnet-api:latest"

    if (-not ($webImageExists -and $apiImageExists)) {
        Write-Output "Lokale app-images ontbreken. Eerst prebuilt images proberen te pullen."
        [void](Try-PullComposeServiceImage -ServiceName "web")
        [void](Try-PullComposeServiceImage -ServiceName "api")

        $webImageExists = Test-ImageExists -ImageName "cloudshirt-dotnet-web:latest"
        $apiImageExists = Test-ImageExists -ImageName "cloudshirt-dotnet-api:latest"

        if ($webImageExists -and $apiImageExists) {
            Write-Output "Prebuilt images gevonden. Start zonder lokale build."
            docker compose up -d --remove-orphans
        }
        else {
            Write-Output "Geen bruikbare prebuilt images gevonden. Eenmalige build wordt uitgevoerd."
            docker compose up -d --build --remove-orphans
        }

        if ($LASTEXITCODE -ne 0) {
            Write-Output "FOUT: Docker build/start is mislukt. Stoppen zonder endpoint checks."
            exit $LASTEXITCODE
        }
    }
    else {
        Write-Output "Snelle modus: bestaande images/caches worden hergebruikt."
        docker compose up -d --remove-orphans

        if ($LASTEXITCODE -ne 0) {
            Write-Output "FOUT: Docker start is mislukt. Stoppen zonder endpoint checks."
            exit $LASTEXITCODE
        }
    }

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
