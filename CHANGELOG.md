# Changelog

## [1.1.0] - 2026-07-18
### Adicionado
- Script [Teste-Saude-Completo.ps1](file:///c:/Users/Jardson/Documents/Iso%20LOuca/scripts/Teste-Saude-Completo.ps1) para diagnóstico automatizado rápido.
- Script [Validar-Pendrive.ps1](file:///c:/Users/Jardson/Documents/Iso%20LOuca/scripts/Validar-Pendrive.ps1) para auto-diagnóstico do pendrive.
- Script [menu-tecnico.sh](file:///c:/Users/Jardson/Documents/Iso%20LOuca/scripts/menu-tecnico.sh) (Linux) com interface para Live OS.
- Arquivo [.gitignore](file:///c:/Users/Jardson/Documents/Iso%20LOuca/.gitignore) para controle de versão.
- Suporte a hashes SHA-256 e download via curl no downloader consolidado.

### Modificado
- [Baixar.ps1](file:///c:/Users/Jardson/Documents/Iso%20LOuca/scripts/Baixar.ps1) consolidado e otimizado (unificando scripts de downloads).
- [Menu-Tecnico.ps1](file:///c:/Users/Jardson/Documents/Iso%20LOuca/scripts/Menu-Tecnico.ps1) reestruturado em loop contínuo e categorizado.
- [Backup-Perfil-Usuario.ps1](file:///c:/Users/Jardson/Documents/Iso%20LOuca/scripts/Backup-Perfil-Usuario.ps1) adicionada barra de progresso, estimativa de tamanho e cópia de favoritos do Chrome/Edge.
- [fedora-live-tecnico.ks](file:///c:/Users/Jardson/Documents/Iso%20LOuca/fedora-live-tecnico.ks) agora configura tema escuro global e desativa screen lock no GNOME.

### Corrigido
- Caminho base em `$projeto` corrigido no [Setup-Pendrive.ps1](file:///c:/Users/Jardson/Documents/Iso%20LOuca/Setup-Pendrive.ps1#L16).
- Lógica de parada e reinício de serviços corrigida no [Reset-WindowsUpdate.ps1](file:///c:/Users/Jardson/Documents/Iso%20LOuca/scripts/Reset-WindowsUpdate.ps1).
- Compatibilidade de idioma corrigida no [Criar-Admin.ps1](file:///c:/Users/Jardson/Documents/Iso%20LOuca/scripts/Criar-Admin.ps1#L12) via SID do grupo.
- Bug de tipo de arquivos resolvido no [Limpar-Temp.ps1](file:///c:/Users/Jardson/Documents/Iso%20LOuca/scripts/Limpar-Temp.ps1#L15).
- Preenchimento do script [Status-Licenca-Windows.ps1](file:///c:/Users/Jardson/Documents/Iso%20LOuca/scripts/Status-Licenca-Windows.ps1) anteriormente vazio.
