#Requires -Version 5.1

Write-Host "=== VALIDAR INTEGRIDADE DO PENDRIVE TÉCNICO ===" -ForegroundColor Cyan
Write-Host "Verificando estrutura de pastas e ferramentas instaladas...`n"

$raiz = Split-Path $PSScriptRoot -Parent
$manifesto = Join-Path $raiz 'ferramentas.json'

if (-not (Test-Path -LiteralPath $manifesto)) {
    Write-Error "Arquivo de manifesto não encontrado na raiz!"
    exit 1
}

$dados = Get-Content -LiteralPath $manifesto -Raw -Encoding UTF8 | ConvertFrom-Json
$falhas = 0
$sucessos = 0

# 1. Validar Estrutura de Pastas Esperada
$pastas = @(
    'ISOs\Windows',
    'ISOs\Linux',
    'ISOs\Recovery',
    'ISOs\Utilitarios',
    'Tools',
    'Drivers',
    'Scripts',
    'MS Office setup'
)

Write-Host "--- Estrutura de Diretórios ---" -ForegroundColor Yellow
foreach ($p in $pastas) {
    $caminho = Join-Path $raiz $p
    if (Test-Path -LiteralPath $caminho) {
        Write-Host "  [OK] $p" -ForegroundColor Green
        $sucessos++
    } else {
        Write-Host "  [FALHA] Pasta ausente: $p" -ForegroundColor Red
        $falhas++
    }
}

# 2. Validar Ferramentas do ferramentas.json
Write-Host "`n--- Ferramentas e Utilitários ---" -ForegroundColor Yellow
foreach ($f in $dados.ferramentas) {
    # Resolve pasta
    if ($f.pasta -like "ISOs/*") {
        $pastaDest = Join-Path $raiz ($f.pasta -replace '/', '\')
    } elseif ($f.pasta -eq "Drivers") {
        $pastaDest = Join-Path $raiz "Drivers"
    } else {
        $pastaDest = Join-Path $raiz "Tools\$($f.pasta)"
    }
    
    $arquivoDest = Join-Path $pastaDest $f.arquivo
    
    # Em caso de pasta zipada, verificamos se a pasta está populada
    if ($f.tipo -eq 'zip') {
        if (Test-Path -LiteralPath $pastaDest) {
            $itens = Get-ChildItem -Path $pastaDest -ErrorAction SilentlyContinue
            if ($itens.Count -gt 0) {
                Write-Host "  [OK] $($f.nome) (Descompactado em: Tools\$($f.pasta))" -ForegroundColor Green
                $sucessos++
            } else {
                Write-Host "  [FALHA] $($f.nome) (Pasta vazia ou incompleta!)" -ForegroundColor Red
                $falhas++
            }
        } else {
            Write-Host "  [FALHA] $($f.nome) (Pasta ausente!)" -ForegroundColor Red
            $falhas++
        }
    } else {
        # Portable/Installer comum
        if (Test-Path -LiteralPath $arquivoDest) {
            Write-Host "  [OK] $($f.nome) ($($f.arquivo))" -ForegroundColor Green
            $sucessos++
        } else {
            Write-Host "  [FALHA] $($f.nome) (Arquivo ausente: $($f.arquivo))" -ForegroundColor Red
            $falhas++
        }
    }
}

# Resumo
Write-Host "`n==========================================" -ForegroundColor Cyan
if ($falhas -eq 0) {
    Write-Host "  PÊNDRIVE 100% PRONTO PARA O CAMPO!" -ForegroundColor Green
    Write-Host "  $sucessos testes validados com sucesso." -ForegroundColor Green
} else {
    Write-Host "  ⚠️ PENDRIIVE COM ALGUNS DETALHES PENDENTES" -ForegroundColor Yellow
    Write-Host "  Itens OK: $sucessos | Pendências: $falhas" -ForegroundColor Yellow
    Write-Host "  Dica: Execute '.\Scripts\Baixar.ps1 -Tudo -Verificar' para corrigir as pendências." -ForegroundColor DarkGray
}
Write-Host "==========================================" -ForegroundColor Cyan
