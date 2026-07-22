#Requires -Version 5.1
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z]$')]
    [string]$LetraUSB,

    [switch]$CopiarScripts
)

$raizUsb = "${LetraUSB}:\"
if (-not (Test-Path -LiteralPath $raizUsb)) {
    Write-Error "Unidade ${LetraUSB}: nao encontrada."
    exit 1
}

$projeto = $PSScriptRoot

$pastas = @(
    'ISOs\Windows',
    'ISOs\Linux',
    'ISOs\Tecnico',
    'ISOs\Recovery',
    'ISOs\Utilitarios',
    'Ghost Toolbox',
    'Tools',
    'Drivers',
    'Drivers\Intel',
    'Drivers\AMD',
    'Drivers\NVIDIA',
    'Drivers\Realtek',
    'Drivers\OEM\Dell',
    'Drivers\OEM\HP',
    'Drivers\OEM\Lenovo',
    'Scripts',
    'MS Office setup',
    'ventoy'
)

foreach ($p in $pastas) {
    $caminho = Join-Path $raizUsb $p
    New-Item -ItemType Directory -Path $caminho -Force | Out-Null
    Write-Host "Pasta: $caminho" -ForegroundColor DarkGray
}

# LEIA-ME na raiz
Copy-Item -LiteralPath (Join-Path $projeto 'LEIA-ME.txt') -Destination (Join-Path $raizUsb 'LEIA-ME.txt') -Force -ErrorAction SilentlyContinue

if ($CopiarScripts) {
    $origemScripts = Join-Path $projeto 'scripts'
    $destScripts = Join-Path $raizUsb 'Scripts'
    Copy-Item -Path (Join-Path $origemScripts '*') -Destination $destScripts -Recurse -Force

    $origemOffice = Join-Path $projeto 'MS Office setup'
    $destOffice = Join-Path $raizUsb 'MS Office setup'
    Copy-Item -Path (Join-Path $origemOffice '*') -Destination $destOffice -Recurse -Force

    Copy-Item -LiteralPath (Join-Path $projeto 'ferramentas.json') -Destination (Join-Path $raizUsb 'ferramentas.json') -Force
    Copy-Item -LiteralPath (Join-Path $projeto 'README.md') -Destination (Join-Path $raizUsb 'README-Projeto.md') -Force
    Copy-Item -LiteralPath (Join-Path $projeto 'Drivers\README.md') -Destination (Join-Path $raizUsb 'Drivers\README.md') -Force

    # Copiar configurações Ventoy (ventoy.json e autounattend.xml)
    $origemConfig = Join-Path $projeto 'config'
    $destVentoy = Join-Path $raizUsb 'ventoy'
    Copy-Item -LiteralPath (Join-Path $origemConfig 'ventoy.json') -Destination (Join-Path $destVentoy 'ventoy.json') -Force -ErrorAction SilentlyContinue
    Copy-Item -LiteralPath (Join-Path $origemConfig 'autounattend.xml') -Destination (Join-Path $destVentoy 'autounattend.xml') -Force -ErrorAction SilentlyContinue
}

Write-Host "`nPendrive ${LetraUSB}: pronto para uso no Ventoy." -ForegroundColor Green
Write-Host "Proximos passos:"
Write-Host "  1. Formate o pendrive com o Ventoy (se ainda nao o fez)"
Write-Host "  2. Copie a ISO do Windows 11 Ghost Spectre para: ${LetraUSB}:\ISOs\Windows\Win11_Ghost_Spectre.iso"
Write-Host "  3. Copie a ISO LOuca para: ${LetraUSB}:\ISOs\Tecnico\ISO_LOUCA_BOOT.iso"

