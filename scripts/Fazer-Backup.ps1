# =================================================================
# Script de Backup para Migração Linux - EduTechAnderlineNet
# =================================================================
# Este script cria um backup compacto dos seus projetos e dados
# do Antigravity IDE (excluindo navegadores).

$ErrorActionPreference = "SilentlyContinue"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "   BACKUP AUTOMÁTICO PARA MIGRAÇÃO - ANTIGRAVITY / DEBIAN" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

# 2. Definir pastas de origem e destino
$backupDir = "C:\Backup_Temp"
$zipFile = "C:\Backup_Migration_Jardson.zip"

# Limpar backups antigos temporários
if (Test-Path $backupDir) { Remove-Item -Path $backupDir -Recurse -Force }
if (Test-Path $zipFile) { Remove-Item -Path $zipFile -Force }

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$backupItems = @(
    @{ Path = "C:\Users\Jardson\Documents\Iso LOuca"; Dest = "$backupDir\Iso_Louca_Project" },
    @{ Path = "C:\Users\Jardson\.gemini"; Dest = "$backupDir\.gemini" },
    @{ Path = "C:\Users\Jardson\.antigravity-ide"; Dest = "$backupDir\.antigravity-ide" }
)

Write-Host "---------------------------------------------------------"
Write-Host "1. Copiando arquivos críticos..." -ForegroundColor Green

foreach ($item in $backupItems) {
    if (Test-Path $item.Path) {
        Write-Host "   -> Copiando: $($item.Path)" -ForegroundColor Gray
        Copy-Item -Path $item.Path -Destination $item.Dest -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "   -> [Ignorado/Não encontrado]: $($item.Path)" -ForegroundColor DarkGray
    }
}

Write-Host "---------------------------------------------------------"
Write-Host "2. Compactando arquivos em ZIP..." -ForegroundColor Green
Write-Host "Por favor, aguarde..." -ForegroundColor Gray

# Compactar tudo em um arquivo ZIP
Compress-Archive -Path "$backupDir\*" -DestinationPath $zipFile -Force

# 3. Limpar diretório temporário
Write-Host "---------------------------------------------------------"
Write-Host "3. Limpando arquivos temporários..." -ForegroundColor Green
Remove-Item -Path $backupDir -Recurse -Force

Write-Host "=========================================================" -ForegroundColor Green
Write-Host "              BACKUP CONCLUÍDO COM SUCESSO!" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "O seu backup foi salvo em:" -ForegroundColor White
Write-Host "👉 $zipFile" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Red
Write-Host "Se você for formatar o disco C: para instalar o Linux," -ForegroundColor Red
Write-Host "você DEVE copiar esse arquivo '$zipFile' para um" -ForegroundColor Red
Write-Host "pendrive, HD Externo ou Nuvem (Google Drive, Mega, etc.)" -ForegroundColor Red
Write-Host "ANTES de prosseguir com a instalação do sistema operacional!" -ForegroundColor Red
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "Pressione qualquer tecla para finalizar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
