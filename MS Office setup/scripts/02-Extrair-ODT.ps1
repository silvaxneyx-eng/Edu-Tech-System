#Requires -RunAsAdministrator
param(
    [Parameter(Mandatory = $true)]
    [string]$OdtExe,

    [string]$Destino = 'C:\MS Office setup'
)

$OdtExe = Resolve-Path -LiteralPath $OdtExe
$Destino = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destino)

if (-not (Test-Path -LiteralPath $Destino)) {
    New-Item -ItemType Directory -Path $Destino -Force | Out-Null
}

Write-Host "Extraindo ODT para: $Destino" -ForegroundColor Cyan
Start-Process -FilePath $OdtExe -ArgumentList "/quiet /extract:`"$Destino`"" -Wait

if (Test-Path -LiteralPath (Join-Path $Destino 'setup.exe')) {
    Write-Host "setup.exe extraido com sucesso." -ForegroundColor Green
} else {
    Write-Error "setup.exe nao encontrado. Extraia manualmente o ODT na pasta destino."
    exit 1
}

Write-Host "`nColoque configuração.xml (exportado do OCT) em: $Destino"
