# Iso LOuca — Pendrive/ISO multiboot para técnico

Kit pessoal com sistemas bootáveis, instaladores Windows, ferramentas portáteis e scripts de rotina.

## Estrutura

```
E:\  (pendrive Ventoy)
├── ventoy\                    ← instalado pelo Ventoy
├── ISOs\
│   ├── Windows\               ← Win10/11 .iso
│   ├── Linux\
│   ├── Recovery\              ← Hiren, Clonezilla, Memtest
│   └── Utilitarios\
├── Tools\                     ← apps portáteis
├── Drivers\                   ← pacotes offline (SDI, OEM)
├── Scripts\                   ← utilitários do técnico
├── MS Office setup\           ← instalador Office (sem ativação)
└── LEIA-ME.txt
```

## Início rápido

### 1. Preparar pendrive (32 GB+, ideal 64 GB)

```powershell
# PowerShell como Administrador, na pasta do projeto:
.\Setup-Pendrive.ps1 -LetraUSB E
```

### 2. Instalar Ventoy no pendrive

Baixe: https://github.com/ventoy/Ventoy/releases  
Execute `Ventoy2Disk.exe` → instale na partição do USB (UEFI + Legacy).

### 3. Baixar ferramentas portáteis

```powershell
.\scripts\Baixar-Ferramentas.ps1 -Destino "E:\Tools"
```

### 4. Baixar ISOs (manual ou script)

Veja listas em `ISOs\*\README.md` ou:

```powershell
.\scripts\Baixar-ISOs-Guia.ps1
```

### 5. Copiar projeto para o pendrive

```powershell
.\Setup-Pendrive.ps1 -LetraUSB E -CopiarScripts
```

---

## Conteúdo incluído

| Categoria | Itens |
|-----------|--------|
| **Boot** | Ventoy + pastas para ISOs Windows/Linux/Recovery |
| **Office** | ODT + scripts instalação sem ativação |
| **Portáteis** | 7-Zip, Rufus, CPU-Z, CrystalDiskInfo, HWiNFO, LibreOffice, SDI |
| **Scripts** | Limpeza temp, WiFi, admin, info sistema, disco, Windows Update |
| **Drivers** | Snappy Driver Installer + pastas por fabricante |

---

## ISOs recomendadas (baixar manualmente)

| ISO | Onde baixar |
|-----|-------------|
| Windows 11 | https://www.microsoft.com/software-download/windows11 |
| Windows 10 | https://www.microsoft.com/software-download/windows10 |
| Hiren's BootCD PE | https://www.hirensbootcd.org/download/ |
| Clonezilla | https://clonezilla.org/downloads.php |
| MemTest86 | https://www.memtest86.com/download.htm |
| Ubuntu Live | https://ubuntu.com/download/desktop |
| GParted Live | https://gparted.org/download.php |

Copie os `.iso` para as pastas correspondentes em `ISOs\`.

---

## Scripts de técnico

Execute a partir de `Scripts\` no pendrive ou PC:

| Script | Função |
|--------|--------|
| `Limpar-Temp.ps1` | Remove arquivos temporários |
| `Exportar-WiFi.ps1` | Salva perfis Wi-Fi em arquivo |
| `Criar-Admin.ps1` | Cria usuário administrador local |
| `Info-Sistema.ps1` | Exporta relatório do hardware/software |
| `Verificar-Disco.ps1` | CHKDSK + SMART básico |
| `Reset-WindowsUpdate.ps1` | Reinicia serviços/componentes WU |
| `Desativar-Hibernacao.ps1` | Libera espaço em SSD |
| `Listar-Programas-Inicio.ps1` | Lista startup |
| `Backup-Perfil-Usuario.ps1` | Copia Desktop/Documentos |
| `Status-Licenca-Windows.ps1` | Verifica ativação Windows |
| `Menu-Tecnico.ps1` / `.cmd` | Menu interativo com todas as opções |
| `Baixar-Ferramentas.ps1` | Baixa portáteis para `Tools\` |
| `Baixar-ISOs-Guia.ps1` | Links das ISOs recomendadas |

---

## MS Office

Ver `MS Office setup\README.md` — instala sem chave; cliente ativa depois.

---

## Tamanho estimado

| Conteúdo | Tamanho |
|----------|---------|
| Ferramentas portáteis | ~1–2 GB |
| Office offline | ~3–4 GB |
| Win11 ISO | ~6 GB |
| Win10 ISO | ~5 GB |
| Hiren + utilitários | ~2–3 GB |
| **Total sugerido** | **64 GB pendrive** |
