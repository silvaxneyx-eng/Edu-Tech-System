<#
.SYNOPSIS
EduTech - Informações de Hardware (Windows Nativamente)
#>

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   EDUTECH - INFO DE HARDWARE (WINDOWS)      " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[ Processador (CPU) ]" -ForegroundColor Yellow
$cpu = Get-CimInstance Win32_Processor
Write-Host "Modelo: $($cpu.Name)"
Write-Host "Núcleos Físicos: $($cpu.NumberOfCores) | Threads: $($cpu.NumberOfLogicalProcessors)"
Write-Host "Frequência Base: $($cpu.MaxClockSpeed) MHz"
Write-Host ""

Write-Host "[ Memória RAM ]" -ForegroundColor Yellow
$ram = Get-CimInstance Win32_PhysicalMemory
$total_ram = 0
foreach ($stick in $ram) {
    $sizeGB = [math]::Round($stick.Capacity / 1GB, 2)
    $total_ram += $sizeGB
    Write-Host "Pente: $sizeGB GB - $($stick.Speed) MHz ($($stick.Manufacturer))"
}
Write-Host "Total Instalado: $total_ram GB"
Write-Host ""

Write-Host "[ Placa Mãe ]" -ForegroundColor Yellow
$mb = Get-CimInstance Win32_BaseBoard
Write-Host "Fabricante: $($mb.Manufacturer)"
Write-Host "Produto: $($mb.Product)"
Write-Host ""

Write-Host "[ Discos e Armazenamento ]" -ForegroundColor Yellow
$disks = Get-CimInstance Win32_DiskDrive
foreach ($d in $disks) {
    $sizeGB = [math]::Round($d.Size / 1GB, 2)
    Write-Host "$($d.Model) - $sizeGB GB ($($d.InterfaceType))"
}
Write-Host ""

Write-Host "[ Placa de Vídeo (GPU) ]" -ForegroundColor Yellow
$gpu = Get-CimInstance Win32_VideoController
foreach ($g in $gpu) {
    Write-Host "$($g.Name)"
}
Write-Host ""
Write-Host "✅ Diagnóstico Concluído!" -ForegroundColor Green
