<#
.SYNOPSIS
EduTech - Backup Rápido de Perfil (Windows Nativamente via Robocopy)
#>

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   EDUTECH - BACKUP DE PERFIL (WINDOWS)      " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Lista Unidades de Disco Externas
Write-Host "Discos disponíveis para destino do backup:" -ForegroundColor Yellow
$drives = Get-CimInstance Win32_LogicalDisk | Where-Object DriveType -eq 2 # 2=Removable (Pendrive)
if ($drives.Count -eq 0) {
    Write-Host "Nenhum pendrive ou HD externo detectado automaticamente."
    Write-Host "Listando todos os discos locais:"
    $drives = Get-CimInstance Win32_LogicalDisk | Where-Object DriveType -eq 3
}

foreach ($d in $drives) {
    $freeGB = [math]::Round($d.FreeSpace / 1GB, 2)
    $totalGB = [math]::Round($d.Size / 1GB, 2)
    Write-Host "$($d.DeviceID) - $($d.VolumeName) (Livre: $freeGB GB / Total: $totalGB GB)"
}
Write-Host ""

$destDrive = Read-Host "Digite a letra da unidade de destino (ex: E:)"
if (-not (Test-Path $destDrive)) {
    Write-Host "Unidade não encontrada!" -ForegroundColor Red
    exit 1
}

$backupFolder = "$destDrive\EduTech_Backup_$(Get-Date -Format 'yyyyMMdd_HHmm')"
New-Item -ItemType Directory -Force -Path $backupFolder | Out-Null

$usersPath = "C:\Users"
$users = Get-ChildItem -Path $usersPath -Directory | Where-Object Name -NotIn @("Public", "Default", "Default User", "All Users")

Write-Host "Usuários encontrados:" -ForegroundColor Yellow
foreach ($u in $users) {
    Write-Host " - $($u.Name)"
}
Write-Host ""

foreach ($u in $users) {
    Write-Host "Iniciando backup de $($u.Name)..." -ForegroundColor Cyan
    $userDest = "$backupFolder\$($u.Name)"
    New-Item -ItemType Directory -Force -Path $userDest | Out-Null

    $foldersToCopy = @("Desktop", "Documents", "Downloads", "Pictures", "Videos", "Music")
    
    foreach ($folder in $foldersToCopy) {
        $source = "$($u.FullName)\$folder"
        if (Test-Path $source) {
            Write-Host "  -> Copiando $folder..."
            # Usa Robocopy (/E: subpastas vazias, /MT: multi-thread, /R:0 não repete em erro, /W:0 sem espera, /NFL /NDL oculta lista)
            & robocopy $source "$userDest\$folder" /E /MT:8 /R:0 /W:0 /NFL /NDL /NJH /NJS
        }
    }
    Write-Host "✅ Perfil de $($u.Name) concluído!" -ForegroundColor Green
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " BACKUP CONCLUÍDO COM SUCESSO!" -ForegroundColor Green
Write-Host " Destino: $backupFolder"
Write-Host "=============================================" -ForegroundColor Cyan
