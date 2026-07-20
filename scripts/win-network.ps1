<#
.SYNOPSIS
EduTech - Scanner de Rede Local (Windows Nativamente)
#>

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   EDUTECH - SCANNER DE REDE LOCAL (WINDOWS) " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

$ipConfig = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch "Loopback|Pseudo" }
if ($ipConfig.Count -eq 0) {
    Write-Host "❌ Nenhuma conexão de rede detectada." -ForegroundColor Red
    exit 1
}

$localIP = $ipConfig[0].IPAddress
Write-Host "Seu IP atual: $localIP" -ForegroundColor Yellow

$baseIP = $localIP.Substring(0, $localIP.LastIndexOf('.'))
Write-Host "Sub-rede base: $baseIP.x"
Write-Host ""

Write-Host "🔍 Iniciando varredura ARP da rede local..." -ForegroundColor Cyan
# Usa Test-Connection (ping rápido) num range curto para popular o cache ARP
# Para ser rápido no powershell sem módulos extras, faremos apenas o cache ARP ativo
arp -a | Select-String "dinâmico|dynamic" | ForEach-Object {
    $line = $_.ToString().Trim() -replace '\s+', ' '
    $parts = $line.Split(' ')
    if ($parts.Count -ge 2) {
        $ip = $parts[0]
        $mac = $parts[1]
        Write-Host "Dispositivo encontrado: IP = $ip  |  MAC = $mac"
    }
}

Write-Host ""
Write-Host "✅ Varredura concluída!" -ForegroundColor Green
