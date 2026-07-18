#Requires -RunAsAdministrator

$relatorioPath = Join-Path $PSScriptRoot "Saude-Completa-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

function Log {
    param([string]$texto, [string]$cor = 'White')
    Write-Host $texto -ForegroundColor $cor
    $texto | Out-File -LiteralPath $relatorioPath -Append -Encoding UTF8
}

# Inicializa arquivo
"=== RELATÓRIO DE SAÚDE COMPLETA DO SISTEMA ===" | Out-File -LiteralPath $relatorioPath -Encoding UTF8
"Data/Hora: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" | Out-File -LiteralPath $relatorioPath -Append -Encoding UTF8
"Máquina: $env:COMPUTERNAME" | Out-File -LiteralPath $relatorioPath -Append -Encoding UTF8
"Usuário Executor: $env:USERNAME" | Out-File -LiteralPath $relatorioPath -Append -Encoding UTF8
"------------------------------------------------" | Out-File -LiteralPath $relatorioPath -Append -Encoding UTF8

Log "Iniciando Diagnóstico Rápido de Saúde..." 'Cyan'

# 1. Informações Básicas de SO e Hardware
Log "`n[1/5] Verificando Sistema e Processador..." 'Cyan'
try {
    $info = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsArchitecture, BiosSerialNumber, CsManufacturer, CsModel
    Log "  SO: $($info.WindowsProductName) ($($info.WindowsVersion) - $($info.OsArchitecture))"
    Log "  Fabricante/Modelo: $($info.CsManufacturer) - $($info.CsModel)"
    Log "  Serial BIOS: $($info.BiosSerialNumber)"
} catch {
    Log "  Falha ao obter info de hardware: $($_.Exception.Message)" 'Yellow'
}

# 2. Espaço em Disco e Sistema de Arquivos
Log "`n[2/5] Verificando Espaço em Disco..." 'Cyan'
try {
    $discos = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } # Discos Locais
    foreach ($d in $discos) {
        $totalGB = [math]::Round($d.Size / 1GB, 1)
        $livreGB = [math]::Round($d.FreeSpace / 1GB, 1)
        $percentLivre = [math]::Round(($livreGB / $totalGB) * 100, 1)
        
        $corEspaco = if ($percentLivre -lt 10) { 'Red' } else { 'Green' }
        Log "  Unidade $($d.DeviceID) ($($d.VolumeName)) | Total: $totalGB GB | Livre: $livreGB GB ($percentLivre%)" $corEspaco
    }
} catch {
    Log "  Falha ao verificar espaço em disco: $($_.Exception.Message)" 'Yellow'
}

# 3. Status SMART Rápido (Disco Físico)
Log "`n[3/5] Consultando Predição de Falhas SMART..." 'Cyan'
try {
    $smart = Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction SilentlyContinue
    if ($smart) {
        foreach ($s in $smart) {
            if ($s.PredictFailure) {
                Log "  ⚠️ ATENÇÃO: Disco $($s.InstanceName) com Alerta de Falha Crítica SMART (PredictFailure=True)!" 'Red'
            } else {
                Log "  Físico $($s.InstanceName): OK (SMART Saudável)" 'Green'
            }
        }
    } else {
        Log "  Nenhum drive SMART compatível exposto via WMI." 'Yellow'
    }
} catch {
    Log "  Falha ao obter predição SMART: $($_.Exception.Message)" 'Yellow'
}

# 4. Status de Ativação do Windows
Log "`n[4/5] Verificando Licença do Windows..." 'Cyan'
try {
    $prod = Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" | Select-Object -First 1
    if ($prod) {
        $ativado = $prod.LicenseStatus -eq 1
        $statusStr = if ($ativado) { "Licenciado/Ativado" } else { "Não Ativado (Status: $($prod.LicenseStatus))" }
        $corLicenca = if ($ativado) { 'Green' } else { 'Yellow' }
        Log "  Licença: $statusStr" $corLicenca
    } else {
        Log "  Nenhuma licença com chave parcial ativa encontrada." 'Yellow'
    }
} catch {
    Log "  Falha ao verificar licença: $($_.Exception.Message)" 'Yellow'
}

# 5. Integridade do Windows Update
Log "`n[5/5] Analisando Serviços Essenciais..." 'Cyan'
$servicos = @('wuauserv', 'bits', 'cryptsvc', 'WinDefend')
foreach ($s in $servicos) {
    try {
        $svc = Get-Service -Name $s -ErrorAction Stop
        $statusColor = if ($svc.Status -eq 'Running') { 'Green' } else { 'Yellow' }
        Log "  Serviço '$s': $($svc.Status)" $statusColor
    } catch {
        Log "  Serviço '$s': NÃO INSTALADO ou Inacessível" 'Red'
    }
}

Log "`n================================================" 'Cyan'
Log "Diagnóstico concluído! Relatório salvo em:" 'Green'
Log $relatorioPath 'White'
Log "================================================" 'Cyan'
