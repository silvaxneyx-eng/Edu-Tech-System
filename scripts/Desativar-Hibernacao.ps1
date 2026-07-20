#Requires -RunAsAdministrator

powercfg /hibernate off
Write-Host "Hibernacao desativada. Espaco liberado em C:\hiberfil.sys" -ForegroundColor Green
