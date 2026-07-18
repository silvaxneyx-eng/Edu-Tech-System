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
    $ConfigPath = Join-Path $Pasta 'configuration.xml'
    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        Write-Error "Arquivo de configuracao nao encontrado."
        exit 1
    }
}

Write-Host "Instalando Office SEM ativacao (cliente ativa depois com a chave)..." -ForegroundColor Cyan
Push-Location -LiteralPath $Pasta
try {
    & $SetupExe /configure $ConfigPath
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
