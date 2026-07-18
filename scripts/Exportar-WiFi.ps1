#Requires -RunAsAdministrator

$destino = Join-Path $PSScriptRoot "WiFi-Perfis-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
$saida = netsh wlan show profiles 2>&1
$saida | Out-File -LiteralPath $destino -Encoding UTF8

$perfis = $saida | Select-String 'All User Profile\s*:\s*(.+)' | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }

foreach ($perfil in $perfis) {
    "`n=== $perfil ===" | Out-File -LiteralPath $destino -Append -Encoding UTF8
    netsh wlan show profile name="$perfil" key=clear 2>&1 | Out-File -LiteralPath $destino -Append -Encoding UTF8
}

Write-Host "Perfis Wi-Fi exportados para:" -ForegroundColor Green
Write-Host $destino
