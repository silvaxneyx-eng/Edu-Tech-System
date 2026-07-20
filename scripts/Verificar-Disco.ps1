#Requires -RunAsAdministrator
param(
    [string]$Unidade = 'C:'
)

Write-Host "Executando CHKDSK online em $Unidade (pode demorar)..." -ForegroundColor Cyan
chkdsk $Unidade /scan

Write-Host "`nStatus SMART (via WMI):" -ForegroundColor Cyan
Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction SilentlyContinue |
    Select-Object InstanceName, PredictFailure, Reason |
    Format-Table -AutoSize

Write-Host "Para SMART detalhado, use CrystalDiskInfo em Tools\" -ForegroundColor Yellow
