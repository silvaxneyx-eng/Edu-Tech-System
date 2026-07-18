#Requires -Version 5.1

$ErrorActionPreference = 'Continue'

function Mostrar-Cabecalho {
    Clear-Host
    Write-Host @"

   ╔══════════════════════════════════════════════════════════════╗
   ║                 ISO LOUCA — MENU TÉCNICO                     ║
   ║          Kit de Manutenção e Diagnóstico Windows             ║
   ╚══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan
}

$menu = @(
    # Diagnóstico e Informações
    @{ N = '1';  Script = 'Info-Sistema.ps1';             Desc = 'Coletar Relatório do Sistema (Hardware/Rede)'; Cat = 'Diagnóstico' }
    @{ N = '2';  Script = 'Status-Licenca-Windows.ps1';   Desc = 'Verificar Status da Licença do Windows';       Cat = 'Diagnóstico' }
    @{ N = '3';  Script = 'Verificar-Disco.ps1';          Desc = 'Verificar Saúde do Disco (CHKDSK e SMART)';    Cat = 'Diagnóstico' }
    @{ N = '4';  Script = 'Teste-Saude-Completo.ps1';     Desc = 'Executar Teste de Saúde Geral (One-Click)';    Cat = 'Diagnóstico' }
    
    # Limpeza e Otimização
    @{ N = '5';  Script = 'Limpar-Temp.ps1';              Desc = 'Remover Arquivos Temporários e Lixo';          Cat = 'Limpeza e Otimização' }
    @{ N = '6';  Script = 'Desativar-Hibernacao.ps1';     Desc = 'Desativar Hibernação (Liberar Espaço SSD)';    Cat = 'Limpeza e Otimização' }
    @{ N = '7';  Script = 'Listar-Programas-Inicio.ps1';  Desc = 'Listar Programas na Inicialização (Startup)';  Cat = 'Limpeza e Otimização' }
    
    # Reparo e Configurações
    @{ N = '8';  Script = 'Reset-WindowsUpdate.ps1';      Desc = 'Resetar Componentes do Windows Update';        Cat = 'Reparos e Contas' }
    @{ N = '9';  Script = 'Criar-Admin.ps1';              Desc = 'Criar Novo Usuário Administrador Local';       Cat = 'Reparos e Contas' }
    @{ N = '10'; Script = 'Exportar-WiFi.ps1';            Desc = 'Exportar Perfis e Senhas Wi-Fi';               Cat = 'Reparos e Contas' }
    
    # Backup e Office
    @{ N = '11'; Script = 'Backup-Perfil-Usuario.ps1';    Desc = 'Realizar Backup de Perfil do Usuário';         Cat = 'Backup e Office' }
    @{ N = '12'; Script = '..\MS Office setup\scripts\04-Instalar-Office.ps1'; Desc = 'Instalar Microsoft Office (LTSC)'; Cat = 'Backup e Office' }
    @{ N = '13'; Script = '..\MS Office setup\scripts\06-Ver-Status.ps1';    Desc = 'Verificar Licenciamento do Office';  Cat = 'Backup e Office' }
    
    # Extras
    @{ N = '14'; Script = 'Validar-Pendrive.ps1';         Desc = 'Validar Integridade deste Pendrive';           Cat = 'Utilidades' }
)

while ($true) {
    Mostrar-Cabecalho
    
    # Imprime agrupado por categoria
    $categorias = $menu | Select-Object -ExpandProperty Cat -Unique
    foreach ($cat in $categorias) {
        Write-Host " ─── $cat ───" -ForegroundColor Yellow
        $menu | Where-Object { $_.Cat -eq $cat } | ForEach-Object {
            Write-Host ("  [{0,2}] {1}" -f $_.N, $_.Desc)
        }
        Write-Host ""
    }
    
    Write-Host "  [ 0] Sair" -ForegroundColor Red
    Write-Host ""
    
    $opcao = Read-Host "Escolha uma opção"
    
    if ($opcao -eq '0' -or [string]::IsNullOrWhiteSpace($opcao)) {
        Write-Host "`nSaindo..." -ForegroundColor Yellow
        break
    }
    
    $escolha = $menu | Where-Object { $_.N -eq $opcao }
    
    if (-not $escolha) {
        Write-Host "`nOpção inválida!" -ForegroundColor Red
        Start-Sleep -Seconds 1
        continue
    }
    
    # Resolve caminho do script
    $scriptPath = Join-Path $PSScriptRoot $escolha.Script
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        $scriptPath = Join-Path (Split-Path $PSScriptRoot -Parent) ($escolha.Script -replace '^\.\.\\', '')
    }
    
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        Write-Host "`nErro: Arquivo do script não encontrado: $scriptPath" -ForegroundColor Red
        Write-Host "Pressione qualquer tecla para continuar..."
        $null = [Console]::ReadKey($true)
        continue
    }

    # Cabeçalho da execução
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host " Executando: $($escolha.Desc)" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""

    # Confirmação de segurança para ações críticas
    if ($opcao -in '8', '9', '11') {
        $confirmar = Read-Host "Deseja realmente prosseguir com esta ação? (S/N)"
        if ($confirmar -notlike 's*') {
            Write-Host "`nAção cancelada pelo usuário." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            continue
        }
    }

    # Execução customizada conforme script
    try {
        if ($escolha.Script -eq 'Criar-Admin.ps1') {
            $user = Read-Host 'Nome do novo usuário administrador'
            $pass = Read-Host 'Senha temporária' -AsSecureString
            $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass)
            $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
            & $scriptPath -Usuario $user -Senha $plain
        } else {
            & $scriptPath
        }
    } catch {
        Write-Host "`nOcorreu um erro ao executar o script: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "`nExecução concluída." -ForegroundColor Green
    Write-Host "Pressione qualquer tecla para voltar ao menu..."
    $null = [Console]::ReadKey($true)
}
