#Requires -Version 5.1
param(
    [string]$Destino = (Join-Path (Split-Path $PSScriptRoot -Parent) 'Tools'),
    [string]$Manifesto = (Join-Path (Split-Path $PSScriptRoot -Parent) 'ferramentas.json'),
    [string[]]$Nome,
    [switch]$Listar,
    [switch]$Tudo,
    [switch]$Verificar # Baixa apenas o que não existir ou estiver corrompido
)

$ErrorActionPreference = 'Continue'

if (-not (Test-Path -LiteralPath $Manifesto)) {
    Write-Error "Manifesto nao encontrado: $Manifesto"
    exit 1
}

$dados = Get-Content -LiteralPath $Manifesto -Raw -Encoding UTF8 | ConvertFrom-Json
$Destino = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destino)

if ($Listar) {
    Write-Host "`n=== FERRAMENTAS (baixar pelo nome) ===" -ForegroundColor Cyan
    foreach ($f in $dados.ferramentas) {
        Write-Host "  - $($f.nome)"
    }
    if ($dados.manual) {
        Write-Host "`n=== MANUAL / ISO (links especiais) ===" -ForegroundColor Yellow
        foreach ($m in $dados.manual) {
            Write-Host "  - $($m.nome) ($($m.url))"
        }
    }
    Write-Host "`nUso: .\Baixar.ps1 -Nome ventoy,rufus   ou   .\Baixar.ps1 -Tudo"
    exit 0
}

# Constrói a lista a baixar
$lista = @()
if ($Tudo) {
    $lista += $dados.ferramentas
    # Adiciona itens manuais que têm arquivo e URL
    foreach ($m in $dados.manual) {
        if ($m.arquivo -and $m.url) {
            $lista += $m
        }
    }
} elseif ($Nome) {
    $filtro = ($Nome -join ',').ToLower() -split '[,\s]+'
    $todosItens = @($dados.ferramentas) + @($dados.manual | Where-Object { $_.arquivo -and $_.url })
    $lista = @($todosItens | Where-Object {
        $n = $_.nome.ToLower()
        foreach ($f in $filtro) {
            if ($n -like "*$f*") { return $true }
        }
        $false
    })
    if ($lista.Count -eq 0) {
        Write-Error "Nenhuma ferramenta encontrada para: $($Nome -join ', '). Use -Listar"
        exit 1
    }
} else {
    Write-Host "Informe o que baixar:" -ForegroundColor Yellow
    Write-Host "  .\Baixar.ps1 -Nome rufus"
    Write-Host "  .\Baixar.ps1 -Nome ventoy,cpu-z"
    Write-Host "  .\Baixar.ps1 -Tudo"
    Write-Host "  .\Baixar.ps1 -Listar"
    Write-Host "  .\Baixar.ps1 -Tudo -Verificar (baixa apenas faltantes)"
    exit 0
}

New-Item -ItemType Directory -Path $Destino -Force | Out-Null

$curlExe = "$env:SystemRoot\System32\curl.exe"
$temCurl = Test-Path $curlExe

$total = $lista.Count
$i = 0
$ok = 0
$falha = 0

# Função para validar SHA-256
function Confirmar-Hash {
    param([string]$caminho, [string]$esperado)
    if ([string]::IsNullOrWhiteSpace($esperado)) { return $true }
    if (-not (Test-Path -LiteralPath $caminho)) { return $false }
    $obtido = (Get-FileHash -Path $caminho -Algorithm SHA256).Hash
    return ($obtido.ToLower() -eq $esperado.ToLower())
}

foreach ($f in $lista) {
    $i++
    # Resolve pasta de destino. Se o campo contiver "ISOs/", é relativo à raiz do projeto.
    if ($f.pasta -like "ISOs/*") {
        $raizProjeto = Split-Path $Destino -Parent
        $pastaDest = Join-Path $raizProjeto ($f.pasta -replace '/', '\')
    } elseif ($f.pasta -eq "Drivers") {
        $raizProjeto = Split-Path $Destino -Parent
        $pastaDest = Join-Path $raizProjeto "Drivers"
    } else {
        $pastaDest = Join-Path $Destino $f.pasta
    }

    $arquivoLocal = Join-Path $pastaDest $f.arquivo
    
    # Se -Verificar foi passado, checa se arquivo já existe e está íntegro
    if ($Verificar -and (Test-Path -LiteralPath $arquivoLocal)) {
        if ([string]::IsNullOrWhiteSpace($f.sha256) -or (Confirmar-Hash $arquivoLocal $f.sha256)) {
            Write-Host "[$i/$total] $($f.nome) já existe e está OK (Pulado)." -ForegroundColor Gray
            $ok++
            continue
        }
    }

    New-Item -ItemType Directory -Path $pastaDest -Force | Out-Null
    Write-Host "[$i/$total] Baixando $($f.nome)..." -ForegroundColor Cyan

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        if ($temCurl) {
            # curl.exe costuma ser muito mais robusto e rápido
            $argsCurl = @('-L', '-o', $arquivoLocal, '-A', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', '--retry', '3', '-f', $f.url)
            & $curlExe @argsCurl
            if ($LASTEXITCODE -ne 0) { throw "curl retornou código de erro $LASTEXITCODE" }
        } else {
            Invoke-WebRequest -Uri $f.url -OutFile $arquivoLocal -UseBasicParsing -TimeoutSec 300
        }

        # Valida hash se especificado
        if (-not ([string]::IsNullOrWhiteSpace($f.sha256))) {
            if (-not (Confirmar-Hash $arquivoLocal $f.sha256)) {
                throw "Falha na verificação de integridade SHA-256!"
            }
        }

        # Descompacta se for zip
        if ($f.tipo -eq 'zip') {
            Write-Host "  Extraindo $($f.arquivo)..." -ForegroundColor Gray
            Expand-Archive -LiteralPath $arquivoLocal -DestinationPath $pastaDest -Force
            Remove-Item -LiteralPath $arquivoLocal -Force
        }

        Write-Host "  OK -> $pastaDest" -ForegroundColor Green
        $ok++
    } catch {
        Write-Warning "  Falha: $($_.Exception.Message)"
        Write-Host "  URL: $($f.url)" -ForegroundColor Yellow
        $falha++
    }
}

Write-Host "`nResultado: $ok OK, $falha falha(s)." -ForegroundColor $(if ($falha -eq 0) { 'Green' } else { 'Yellow' })
