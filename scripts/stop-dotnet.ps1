<#
.SYNOPSIS
    Stop CloudShirt in lokale .NET-modus.

.DESCRIPTION
    Stopt lokale CloudShirt-processen die via dotnet run zijn gestart
    (Web en PublicApi projectprocessen) en ruimt de PID-bestanden op.

.EXAMPLE
    .\scripts\stop-dotnet.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Title)
    Write-Output ""
    Write-Output "===== $Title ====="
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

    if ($processes.Count -eq 0) {
        Write-Output "Geen draaiende CloudShirt .NET-processen gevonden."
        return
    }

    foreach ($process in $processes) {
        Write-Output "CloudShirt-process stoppen: PID $($process.ProcessId)"
        try {
            Stop-Process -Id $process.ProcessId -Force -ErrorAction Stop
        }
        catch {
            Write-Output "PID $($process.ProcessId) was al gestopt."
        }
    }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot

try {
    Write-Section "CloudShirt .NET stoppen"

    Stop-CloudShirtDotNetProcesses

    $pidFiles = @(
        Join-Path $repoRoot "logs\web.pid",
        Join-Path $repoRoot "logs\api.pid"
    )
    foreach ($pidFile in $pidFiles) {
        if (Test-Path $pidFile) {
            Remove-Item -Force $pidFile
        }
    }

    Write-Section "Klaar"
    Write-Output "Lokale monolithische .NET-modus gestopt."
}
finally {
    Pop-Location
}
