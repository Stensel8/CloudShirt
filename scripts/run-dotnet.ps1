[CmdletBinding()]
param(
    [ValidateSet('inmemory', 'docker')]
    [string]$DbMode = 'inmemory'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Stop-ProcessFromPidFile {
    param(
        [string]$PidFilePath,
        [string]$Name
    )

    if (-not (Test-Path $PidFilePath)) {
        return
    }

    $rawPid = (Get-Content $PidFilePath -ErrorAction SilentlyContinue | Select-Object -First 1)
    $processId = 0
    if ([int]::TryParse($rawPid, [ref]$processId) -and $processId -gt 0) {
        try {
            Stop-Process -Id $processId -Force -ErrorAction Stop
            Write-Output "$Name proces gestopt (PID $processId)."
        }
        catch {
            Write-Output "$Name proces was al gestopt (PID $processId)."
        }
    }

    Remove-Item -Path $PidFilePath -Force -ErrorAction SilentlyContinue
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot

try {
    Write-Output '===== Vooraf controleren ====='

    if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
        Write-Output 'FOUT: dotnet CLI niet gevonden.'
        exit 1
    }

    if (-not (Test-Path '.env')) {
        Copy-Item '.env.example' '.env'
        Write-Output 'Created .env from .env.example'
    }

    Write-Output ''
    Write-Output '===== Omgeving laden ====='

    Get-Content '.env' |
        Where-Object { $_ -and -not $_.StartsWith('#') -and $_.Contains('=') } |
        ForEach-Object {
            $parts = $_.Split('=', 2)
            [Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim(), 'Process')
        }

    if ($DbMode -eq 'docker') {
        if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
            Write-Output 'FOUT: Docker CLI niet gevonden, maar DbMode=docker is gekozen.'
            exit 1
        }

        Write-Output 'DbMode: docker'
        docker compose up -d db
        if ($LASTEXITCODE -ne 0) {
            exit $LASTEXITCODE
        }

        $env:DatabaseProvider = 'postgres'
        $env:UseOnlyInMemoryDatabase = 'false'
        $env:ConnectionStrings__CatalogConnection = "Host=localhost;Port=5432;Database=eshop_catalog;Username=$($env:POSTGRES_USER);Password=$($env:POSTGRES_PASSWORD);"
        $env:ConnectionStrings__IdentityConnection = "Host=localhost;Port=5432;Database=eshop_identity;Username=$($env:POSTGRES_USER);Password=$($env:POSTGRES_PASSWORD);"
    }
    else {
        Write-Output 'DbMode: inmemory'
        Write-Output 'Let op: data is niet persistent en reset na stoppen/herstarten.'
        $env:DatabaseProvider = 'inmemory'
        $env:UseOnlyInMemoryDatabase = 'true'
    }

    Write-Output ''
    Write-Output '===== Bestaande monoliet stoppen ====='

    $logsDir = Join-Path $repoRoot 'logs'
    New-Item -ItemType Directory -Force -Path $logsDir | Out-Null

    Stop-ProcessFromPidFile -PidFilePath (Join-Path $logsDir 'web.pid') -Name 'Web'
    Stop-ProcessFromPidFile -PidFilePath (Join-Path $logsDir 'api.pid') -Name 'PublicApi'

    dotnet restore .\src\Web\Web.csproj
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    dotnet restore .\src\PublicApi\PublicApi.csproj
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    dotnet build .\src\Web\Web.csproj --no-restore
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    dotnet build .\src\PublicApi\PublicApi.csproj --no-restore
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Output ''
    Write-Output '===== Web en PublicApi starten ====='

    $webOut = Join-Path $logsDir 'web.out.log'
    $webErr = Join-Path $logsDir 'web.err.log'
    $apiOut = Join-Path $logsDir 'api.out.log'
    $apiErr = Join-Path $logsDir 'api.err.log'

    $webArgs = @('run', '--no-build', '--project', '.\src\Web\Web.csproj', '--urls', 'http://localhost:5106')
    $apiArgs = @('run', '--no-build', '--project', '.\src\PublicApi\PublicApi.csproj', '--urls', 'http://localhost:5200')

    $webProcess = Start-Process -FilePath dotnet -ArgumentList $webArgs -WorkingDirectory $repoRoot -RedirectStandardOutput $webOut -RedirectStandardError $webErr -NoNewWindow -PassThru
    $apiProcess = Start-Process -FilePath dotnet -ArgumentList $apiArgs -WorkingDirectory $repoRoot -RedirectStandardOutput $apiOut -RedirectStandardError $apiErr -NoNewWindow -PassThru

    Set-Content -Path (Join-Path $logsDir 'web.pid') -Value $webProcess.Id
    Set-Content -Path (Join-Path $logsDir 'api.pid') -Value $apiProcess.Id

    Write-Output ''
    Write-Output '===== Klaar ====='
    Write-Output 'Monoliet gestart.'
    Write-Output '- Web: http://localhost:5106'
    Write-Output '- PublicApi Swagger: http://localhost:5200/swagger'
    if ($DbMode -eq 'docker') {
        Write-Output '- PostgreSQL: localhost:5432 (docker db)'
    }
    else {
        Write-Output '- Database: in-memory'
    }
}
finally {
    Pop-Location
}
