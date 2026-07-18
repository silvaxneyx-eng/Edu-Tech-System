$destino = Join-Path $PSScriptRoot "Sistema-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

$info = @"
=== RELATORIO DO SISTEMA ===
Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Computador: $env:COMPUTERNAME
Usuario: $env:USERNAME

--- Sistema Operacional ---
"@

$info | Out-File -LiteralPath $destino -Encoding UTF8
Get-ComputerInfo | Select-Object CsName, WindowsProductName, WindowsVersion, OsArchitecture, OsInstallDate, BiosSerialNumber, CsManufacturer, CsModel, CsProcessors, OsTotalVisibleMemorySize | Format-List | Out-File -LiteralPath $destino -Append -Encoding UTF8

"`n--- Discos ---" | Out-File -LiteralPath $destino -Append -Encoding UTF8
Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID, VolumeName, FileSystem, @{N='GB';E={[math]::Round($_.Size/1GB,2)}}, @{N='LivreGB';E={[math]::Round($_.FreeSpace/1GB,2)}} | Format-Table -AutoSize | Out-File -LiteralPath $destino -Append -Encoding UTF8

"`n--- Rede ---" | Out-File -LiteralPath $destino -Append -Encoding UTF8
Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike '127.*' } | Select-Object InterfaceAlias, IPAddress | Format-Table -AutoSize | Out-File -LiteralPath $destino -Append -Encoding UTF8

Write-Host "Relatorio salvo em: $destino" -ForegroundColor Green
