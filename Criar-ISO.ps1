#Requires -Version 5.1
# Script para gerar a imagem ISO do projeto "Iso LOuca" de forma nativa no Windows
# Compila uma classe auxiliar em C# para realizar a cópia de fluxos de dados do COM IStream com performance otimizada

$projectName = "Iso LOuca"
$sourcePath = "C:\Users\Jardson\Documents\Iso LOuca"
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$isoPath = "C:\Users\Jardson\Documents\Iso_LOuca_Tecnico_$timestamp.iso"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "       GERADOR DE ISO - ISO LOUCA            " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path -LiteralPath $sourcePath)) {
    Write-Error "Caminho de origem não encontrado: $sourcePath"
    exit 1
}

# Injeta código C# em tempo de execução para ler o IStream da API do Windows IMAPI2 e salvá-lo no arquivo
$csharpCode = @"
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;

public static class FileUtil {
    public static void WriteIStreamToFile(object istreamObject, string fileName) {
        IStream inputStream = istreamObject as IStream;
        if (inputStream == null) {
            throw new ArgumentException("O objeto informado nao implementa a interface IStream.");
        }

        using (FileStream outputFileStream = File.Create(fileName)) {
            byte[] buffer = new byte[65536]; // Buffer de 64KB para cópia de dados super rápida
            int bytesRead;
            IntPtr readPtr = Marshal.AllocHGlobal(4);
            
            try {
                do {
                    inputStream.Read(buffer, buffer.Length, readPtr);
                    bytesRead = Marshal.ReadInt32(readPtr);
                    if (bytesRead > 0) {
                        outputFileStream.Write(buffer, 0, bytesRead);
                    }
                } while (bytesRead > 0);
            } finally {
                outputFileStream.Flush();
                Marshal.FreeHGlobal(readPtr);
            }
        }
    }
}
"@

try {
    # Carrega a classe utilitária do C#
    Add-Type -TypeDefinition $csharpCode -ErrorAction SilentlyContinue

    Write-Host "Criando estrutura temporária e gerando imagem ISO..." -ForegroundColor Yellow

    # Cria o criador de imagem do sistema de arquivos IMAPI2
    $imageCreator = New-Object -ComObject IMAPI2FS.MsftFileSystemImage
    $imageCreator.ChooseImageDefaultsForMediaType(12) # 12 = DVD Media
    $imageCreator.FileSystemsToCreate = 1             # 1 = ISO9660
    $imageCreator.VolumeName = "ISO_LOUCA"
    
    # Adiciona a pasta inteira do projeto à raiz da ISO
    $rootNode = $imageCreator.Root
    $rootNode.AddTree($sourcePath, $false)
    
    # Gera a imagem
    $resultImage = $imageCreator.CreateResultImage()
    $imageStream = $resultImage.ImageStream
    
    # Salva no arquivo de saída usando nossa classe de fluxo em C#
    [FileUtil]::WriteIStreamToFile($imageStream, $isoPath)
    
    # Libera os objetos da memória
    if ($imageStream -ne $null) {
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($imageStream) | Out-Null
    }
    if ($imageCreator -ne $null) {
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($imageCreator) | Out-Null
    }

    $size = (Get-Item $isoPath).Length / 1MB
    Write-Host "`n✅ ISO criada com sucesso!" -ForegroundColor Green
    Write-Host "Local: $isoPath" -ForegroundColor Green
    Write-Host "Tamanho: $([math]::Round($size, 1)) MB" -ForegroundColor Green
} catch {
    Write-Warning "Falha ao gerar ISO: $($_.Exception.Message)"
    Write-Host "`nAlternativa: Você também pode usar ferramentas visuais como ImgBurn, AnyBurn ou Rufus" -ForegroundColor Yellow
    Write-Host "para criar uma ISO a partir da pasta: $sourcePath" -ForegroundColor Yellow
}
