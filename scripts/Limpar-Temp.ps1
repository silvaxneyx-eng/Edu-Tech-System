#Requires -RunAsAdministrator

$tempPaths = @(
    $env:TEMP,
    $env:TMP,
    'C:\Windows\Temp',
    (Join-Path $env:LOCALAPPDATA 'Temp')
)

$totalBytes = 0
foreach ($path in $tempPaths) {
    if (-not (Test-Path -LiteralPath $path)) { continue }
    Get-ChildItem -LiteralPath $path -Force -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            if ($_ -is [System.IO.DirectoryInfo]) {
                $size = ($_ | Get-ChildItem -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                if ($null -eq $size) { $size = 0 }
            } else {
                $size = $_.Length
            }
            Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop
            $totalBytes += $size
        } catch {
            Write-Warning "Nao removido: $($_.FullName)"
        }
    }
}

$mb = [math]::Round($totalBytes / 1MB, 2)
Write-Host "Limpeza concluida. Aproximadamente $mb MB liberados." -ForegroundColor Green
