#Requires -RunAsAdministrator

Write-Host "=== STATUS DE LICENÇA DO WINDOWS ===" -ForegroundColor Cyan

try {
    # Obtém status via SoftwareLicensingProduct (filtrando pelo status de ativação)
    $wmi = Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL"
    
    foreach ($prod in $wmi) {
        $status = switch ($prod.LicenseStatus) {
            0 { "Não licenciado" }
            1 { "Licenciado (Ativado)" }
            2 { "OOB Grace (Período de carência inicial)" }
            3 { "OOT Grace (Período de carência fora do padrão)" }
            4 { "Período de carência expirado" }
            5 { "Período de carência de notificação" }
            default { "Desconhecido" }
        }
        
        Write-Host "`nNome: $($prod.Name)"
        Write-Host "Descrição: $($prod.Description)"
        Write-Host "Chave Parcial: $($prod.PartialProductKey)"
        if ($prod.LicenseStatus -eq 1) {
            Write-Host "Status de Ativação: $status" -ForegroundColor Green
        } else {
            Write-Host "Status de Ativação: $status" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`nVerificando via slmgr.vbs..." -ForegroundColor DarkGray
    cscript //nologo $env:SystemRoot\System32\slmgr.vbs /dli
} catch {
    Write-Warning "Não foi possível coletar todas as informações de licença: $($_.Exception.Message)"
}

Write-Host "`nPressione qualquer tecla para voltar..."
$null = [Console]::ReadKey($true)
