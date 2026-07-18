#Requires -RunAsAdministrator

Write-Host "Parando servicos de update..." -ForegroundColor Cyan
Stop-Service -Name wuauserv, bits, cryptsvc, msiserver -Force -ErrorAction SilentlyContinue

$paths = @(
    'C:\Windows\SoftwareDistribution',
    'C:\Windows\System32\catroot2'
)

foreach ($p in $paths) {
    if (Test-Path -LiteralPath $p) {
        Rename-Item -LiteralPath $p -NewName ("{0}.old_{1}" -f (Split-Path $p -Leaf), (Get-Date -Format 'yyyyMMddHHmmss')) -ErrorAction SilentlyContinue
        Write-Host "Renomeado: $p" -ForegroundColor DarkGray
    }
}

Start-Service -Name wuauserv, bits, cryptsvc, msiserver -ErrorAction SilentlyContinue
Write-Host "Windows Update resetado e servicos iniciados. Reinicie o PC e tente atualizar novamente." -ForegroundColor Green
