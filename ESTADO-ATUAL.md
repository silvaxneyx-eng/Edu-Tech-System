# 🔧 ISO LOuca — Kit Técnico Bootável (EduTechAnderlineNet)

> **Créditos:** EduTechAnderlineNet  
> **Repositório:** https://github.com/silvaxneyx-eng/Edu-Tech-System

---

## 📌 ESTADO ATUAL DO PROJETO (18/07/2026)

### ✅ O que já foi feito
- Bootstrap do Fedora 40 instalado no WSL via `dnf --installroot`
- `livecd-tools` instalado dentro do bootstrap
- Kickstart (`fedora-live-tecnico.ks`) criado e ajustado várias vezes
- GitHub Actions configurado (`.github/workflows/build-iso.yml`)
- Todos os arquivos enviados ao repositório GitHub via Git
- Git para Windows instalado na máquina

### ❌ Problema atual sendo resolvido
O `livecd-creator` dentro do Docker no GitHub Actions instala automaticamente o pacote `gnome-all-langpacks` como dependência fraca (recommended), e o scriptlet pós-instalação desse pacote **falha dentro do container Docker**, abortando toda a build.

**Último fix enviado (commit: `b9f8fd3`):**
Adicionado ao comando Docker:
```bash
echo 'install_weak_deps=False' >> /etc/dnf/dnf.conf
echo '%_install_langs C' > /etc/rpm/macros.langs
```
Isso impede o DNF de instalar dependências fracas (como langpacks) dentro do container.

### 🔄 Se ainda falhar com langpacks
Tentar as seguintes soluções em ordem:

**Opção A** — Adicionar `tsflags=noscripts` ao dnf.conf:
```bash
echo 'tsflags=noscripts' >> /etc/dnf/dnf.conf
```

**Opção B** — Excluir via kickstart no `%packages`:
```
-gnome-all-langpacks*
-langpacks-*
```

**Opção C** — Trocar imagem Docker de `fedora:latest` para `fedora:40`:
```yaml
docker run --privileged --rm -v ${{ github.workspace }}:/build fedora:40 bash -c ...
```

---

## 📁 Arquivos Importantes

| Arquivo | Descrição |
|---------|-----------|
| `fedora-live-tecnico.ks` | Kickstart que define os pacotes e configuração da ISO |
| `.github/workflows/build-iso.yml` | Pipeline GitHub Actions que compila a ISO na nuvem |
| `Criar-ISO.ps1` | Script PowerShell para empacotamento local (fallback) |

---

## 🏗️ Como Funciona a Build

```
Push para o GitHub
       ↓
GitHub Actions dispara
       ↓
Docker puxa imagem fedora:latest
       ↓
DNF instala livecd-tools
       ↓
livecd-creator lê o fedora-live-tecnico.ks
       ↓
Baixa pacotes do Fedora 40
       ↓
Cria ISO_LOUCA_BOOT.iso
       ↓
Upload como Artifact na aba Actions
```

---

## 📦 Pacotes na ISO (versão mínima atual)

```
util-linux, bash, coreutils, tar, gzip, bzip2, xz
wget, curl, nano, vim-minimal, htop
gparted, testdisk, ntfs-3g, smartmontools
```

> Após a build funcionar, adicionar de volta:
> - `firefox` (navegador)
> - `wine-core` + `wine-common` (rodar .exe)
> - `nmap`, `iperf3`, `samba-client` (rede)
> - `clamav` (antivírus offline)
> - `gnome-shell`, `gdm`, `nautilus` (interface gráfica)
> - `ddrescue`, `partclone` (recuperação de dados)

---

## 🌐 Repositórios Fedora configurados

```
fedora-40: https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-40&arch=$basearch
updates:   https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f40&arch=$basearch
```

---

## 💻 Por que não compila localmente

O WSL do computador está na **versão 1** (kernel antigo sem suporte a loop devices).
Para converter para WSL2 seria necessário:
```powershell
wsl --set-version Ubuntu 2
```
Mas o Windows retorna erro de "Plataforma de Máquina Virtual" mesmo com virtualização ativa na BIOS.
**Solução adotada:** compilar na nuvem via GitHub Actions.

---

## 📥 Como baixar a ISO após build verde

1. Ir em: https://github.com/silvaxneyx-eng/Edu-Tech-System/actions
2. Clicar no último run verde ✅
3. Descer até **Artifacts**
4. Baixar `ISO-LOUCA-BOOT`
5. Extrair o ZIP → copiar o `.iso` para o pendrive Ventoy

---

## 🎯 Próximos passos após build funcionar

1. Testar boot no Ventoy
2. Verificar se GNOME abre (se a versão tiver interface gráfica)  
3. Adicionar pacotes extras um a um
4. Ativar WSL2 (reiniciar PC após ativar recurso Plataforma de Máquina Virtual)
5. Testar build local com Docker

---

*Última atualização: 18/07/2026 — commit b9f8fd3*
