
# Kit de Ferramentas para Técnico

Este diretório contém o conjunto essencial de ferramentas para manutenção de computadores, automatizado através de um script PowerShell.

## Como utilizar

Para baixar e atualizar todas as ferramentas automaticamente, execute o script a partir do terminal (PowerShell):

`..\scripts\Baixar-Ferramentas.ps1 -Destino "E:\Tools"`

O script lerá o arquivo `ferramentas.json` e realizará o download, extração e organização de todos os itens listados abaixo.

## Ferramentas incluídas

| Ferramenta | Uso |
| :--- | :--- |
| **7-Zip** | Compactar/descompactar |
| **Rufus** | Criar pendrive bootável |
| **CPU-Z** | Info do processador |
| **GPU-Z** | Info da placa de vídeo |
| **CrystalDiskInfo** | Saúde do HD/SSD (SMART) |
| **CrystalDiskMark** | Benchmark de disco |
| **HWiNFO** | Hardware completo |
| **Everything** | Busca instantânea de arquivos |
| **Process Explorer** | Processos avançado (Sysinternals) |
| **Autoruns** | Itens de inicialização |
| **BlueScreenView** | Análise de tela azul |
| **LibreOffice** | Office gratuito |
| **Snappy Driver Installer** | Drivers offline |
| **Ventoy** | Multiboot USB |
| **NTPWedit** | Reset de senha (uso restrito) |
| **Hiren's BootCD PE** | Manutenção e recuperação (ISO) |

---

## Status de Automação
*   **Status:** Totalmente automatizado via `ferramentas.json`.
*   **Observação:** Não é necessário realizar downloads manuais. Caso ocorra alguma falha na rede, o script notificará o erro no console.

---
*Criado para otimizar o fluxo de trabalho de manutenção.*
"@ | Out-File -FilePath "README.md" -Encoding utf8