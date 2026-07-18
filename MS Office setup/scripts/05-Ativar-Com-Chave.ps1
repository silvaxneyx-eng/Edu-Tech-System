#Requires -RunAsAdministrator
param(
    [Parameter(Mandatory = $true)]
    [string]$Chave
)

$OsppPath = Join-Path ${env:ProgramFiles} 'Microsoft Office\Office16\ospp.vbs'

if (-not (Test-Path -LiteralPath $OsppPath)) {
    Write-Error 'Office nao encontrado. Instale antes de ativar.'
    exit 1
}

$OsppDir = Split-Path -Parent $OsppPath
Push-Location -LiteralPath $OsppDir
try {
    Write-Host 'Aplicando chave de produto...' -ForegroundColor Cyan
    cscript //nologo ospp.vbs /inpkey:$Chave
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host 'Ativando online...' -ForegroundColor Cyan
    cscript //nologo ospp.vbs /act
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host "`nStatus da licenca:" -ForegroundColor Green
    cscript //nologo ospp.vbs /dstatus
} finally {
    Pop-Location
}
