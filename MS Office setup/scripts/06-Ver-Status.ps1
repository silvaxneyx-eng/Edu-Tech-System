#Requires -RunAsAdministrator

$OsppPath = Join-Path ${env:ProgramFiles} 'Microsoft Office\Office16\ospp.vbs'

if (-not (Test-Path -LiteralPath $OsppPath)) {
    Write-Host 'Office nao instalado.' -ForegroundColor Yellow
    exit 1
}

Push-Location -LiteralPath (Split-Path -Parent $OsppPath)
try {
    cscript //nologo ospp.vbs /dstatus
} finally {
    Pop-Location
}
