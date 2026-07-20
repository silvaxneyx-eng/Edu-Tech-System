#Requires -RunAsAdministrator

$OfficePath = 'C:\MS Office setup'

if (-not (Test-Path -LiteralPath $OfficePath)) {
    New-Item -ItemType Directory -Path $OfficePath -Force | Out-Null
    Write-Host "Pasta criada: $OfficePath" -ForegroundColor Green
} else {
    Write-Host "Pasta ja existe: $OfficePath" -ForegroundColor Yellow
}

Write-Host "`nProximo passo:"
Write-Host "  1. Exporte configuração.xml do Office Customization Tool"
Write-Host "  2. Coloque o arquivo em: $OfficePath"
