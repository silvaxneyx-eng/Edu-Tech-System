#Requires -RunAsAdministrator
param(
    [string]$Pasta = 'C:\MS Office setup',
    [string]$ConfigFile = 'configuração.xml'
)

$Pasta = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Pasta)
$SetupExe = Join-Path $Pasta 'setup.exe'
$ConfigPath = Join-Path $Pasta $ConfigFile

if (-not (Test-Path -LiteralPath $SetupExe)) {
    Write-Error "setup.exe nao encontrado em: $Pasta"
    exit 1
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    # fallback para nome sem acento
    $ConfigPath = Join-Path $Pasta 'configuration.xml'
    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        Write-Error "Arquivo de configuracao nao encontrado. Exporte do OCT como configuração.xml"
        exit 1
    }
}

Write-Host "Baixando Office offline (pode demorar)..." -ForegroundColor Cyan
Push-Location -LiteralPath $Pasta
try {
    & $SetupExe /download $ConfigPath
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    Write-Host "Download concluido. Pasta Office\ criada em: $Pasta" -ForegroundColor Green
} finally {
    Pop-Location
}
