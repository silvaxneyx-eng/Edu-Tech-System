#Requires -Version 5.1

Write-Host "=== GUIA DE DOWNLOAD DE ISOs ===" -ForegroundColor Cyan
Write-Host "Abra os links abaixo e salve os .iso nas pastas indicadas.`n"

$isos = @(
    @{ Nome = 'Windows 11'; Pasta = 'ISOs\Windows'; Url = 'https://www.microsoft.com/software-download/windows11' }
    @{ Nome = 'Windows 10'; Pasta = 'ISOs\Windows'; Url = 'https://www.microsoft.com/software-download/windows10' }
    @{ Nome = "Hiren's BootCD PE"; Pasta = 'ISOs\Recovery'; Url = 'https://www.hirensbootcd.org/download/' }
    @{ Nome = 'Clonezilla'; Pasta = 'ISOs\Recovery'; Url = 'https://clonezilla.org/downloads.php' }
    @{ Nome = 'MemTest86'; Pasta = 'ISOs\Recovery'; Url = 'https://www.memtest86.com/download.htm' }
    @{ Nome = 'Ubuntu Desktop'; Pasta = 'ISOs\Linux'; Url = 'https://ubuntu.com/download/desktop' }
    @{ Nome = 'GParted Live'; Pasta = 'ISOs\Linux'; Url = 'https://gparted.org/download.php' }
)

foreach ($iso in $isos) {
    Write-Host "$($iso.Nome)" -ForegroundColor Yellow
    Write-Host "  Pasta: $($iso.Pasta)"
    Write-Host "  Link:  $($iso.Url)`n"
}

$abrir = Read-Host 'Abrir pagina do Windows 11 no navegador? (S/N)'
if ($abrir -match '^[Ss]') {
    Start-Process 'https://www.microsoft.com/software-download/windows11'
}
