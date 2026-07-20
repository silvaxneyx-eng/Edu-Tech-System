#Requires -Version 5.1
param(
    [Parameter(Mandatory = $true)]
    [string]$Destino,

    [string]$Manifesto = (Join-Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) '..\ferramentas.json')
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Manifesto)) {
    Write-Error "Manifesto nao encontrado: $Manifesto"
    exit 1
}

$Destino = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destino)
New-Item -ItemType Directory -Path $Destino -Force | Out-Null

$dados = Get-Content -LiteralPath $Manifesto -Raw -Encoding UTF8 | ConvertFrom-Json
$total = $dados.ferramentas.Count
$i = 0

foreach ($f in $dados.ferramentas) {
    $i++
    $pastaDest = Join-Path $Destino $f.pasta
    New-Item -ItemType Directory -Path $pastaDest -Force | Out-Null

    $arquivoLocal = Join-Path $pastaDest $f.arquivo
    Write-Host "[$i/$total] $($f.nome)..." -ForegroundColor Cyan

    try {
        Invoke-WebRequest -Uri $f.url -OutFile $arquivoLocal -UseBasicParsing

        if ($f.tipo -eq 'zip') {
            Expand-Archive -LiteralPath $arquivoLocal -DestinationPath $pastaDest -Force
        }

        Write-Host "  OK -> $pastaDest" -ForegroundColor Green
    } catch {
        Write-Warning "  Falha: $($f.nome) - $($_.Exception.Message)"
        Write-Host "  Baixe manualmente: $($f.url)" -ForegroundColor Yellow
    }
}

Write-Host "`nConcluido. Verifique pastas com aviso de falha." -ForegroundColor Green

$manifestFull = Get-Content -LiteralPath $Manifesto -Raw -Encoding UTF8 | ConvertFrom-Json
if ($manifestFull.manual) {
    Write-Host "`n--- Download manual ---" -ForegroundColor Yellow
    foreach ($m in $manifestFull.manual) {
        Write-Host "$($m.nome): $($m.url)"
        if ($m.nota) { Write-Host "  $($m.nota)" -ForegroundColor DarkGray }
    }
}
