# ISO Louca — Ambiente Técnico Bootável (Fedora Style)

Este projeto tem como objetivo criar uma imagem **ISO bootável independente** baseada no **Fedora Workstation (Live OS)**, personalizada com uma interface visual minimalista inspirada no GNOME do Fedora, contendo um conjunto de ferramentas e scripts de diagnóstico para manutenção de computadores sem depender do sistema operacional instalado na máquina do cliente.

---

## 🎯 Objetivo do Projeto

Quando um computador não inicia ou está infectado por vírus, o técnico não pode depender do Windows do próprio cliente para realizar tarefas de manutenção. 

Esta ISO bootável resolve isso ao:
1. Iniciar um sistema Linux Fedora diretamente na **Memória RAM** (Live CD/USB).
2. Fornecer uma interface amigável com um visual dark elegante, cantos arredondados e barra superior (estilo GNOME / Fedora Workstation).
3. Disponibilizar um painel de controle simples com ferramentas de teste de hardware, diagnóstico e cópia de arquivos.

---

## 🎨 Interface Visual (Design Fedora Workstation)

A interface do sistema técnico emula o visual limpo do **GNOME desktop**:
* **Tema Escuro Nativo:** Cantos arredondados, paleta de cinzas e azul Fedora.
* **Painel Superior:** Relógio centralizado, status de conexões e menu rápido no canto direito.
* **Gerenciador de Arquivos:** Atalhos rápidos para montar e acessar as partições locais (Windows/Linux) do cliente para realizar backups de emergência.
* **Manutenção Hub:** Uma aplicação simples em tela para rodar ferramentas portáteis em apenas um clique.

---

## 🏗️ Como a ISO é Gerada (Arquitetura)

Usamos a ferramenta oficial **Fedora Livecd-Creator (ou Livemedia-creator)** para construir a ISO. A imagem é construída definindo uma configuração chamada de **Kickstart (.ks)**, que:
1. Define a base do sistema (Fedora Server/Workstation minimal).
2. Instala pacotes essenciais (Gerenciador de arquivos, Wine para rodar executáveis do Windows em caso de necessidade, e browsers).
3. Adiciona as ferramentas portáteis configuradas em `/Tools`.
4. Define o script de inicialização que abre a nossa interface técnica assim que o sistema carrega.

---

## 🛠️ Como Construir a ISO

### Pré-requisitos
* Uma máquina virtual ou física rodando **Fedora Linux** (ou qualquer distribuição Linux com `livecd-tools`).
* 10 GB de espaço em disco livre.
* Acesso à internet para baixar os pacotes do repositório durante a criação.

### Passo a Passo

1. **Instale os utilitários de criação de imagens:**
   ```bash
   sudo dnf install livecd-tools spin-kickstarts
   ```

2. **Prepare a estrutura dos arquivos:**
   Coloque todos os seus scripts e a pasta `/Tools` dentro do diretório `/etc/skel` da imagem de forma que eles apareçam na área de trabalho do usuário técnico do Live OS.

3. **Execute o criador da ISO:**
   ```bash
   sudo livecd-creator --verbose \
     --config=fedora-live-tecnico.ks \
     --fslabel=ISO_LOUCA_2026 \
     --cache=/var/cache/live
   ```

4. **Copie a ISO gerada:**
   O arquivo `ISO_LOUCA_2026.iso` será gerado no diretório atual. Basta copiá-lo para a pasta `ISOs\Utilitarios\` ou `ISOs\Recovery\` no seu pendrive Ventoy!

---

## 📂 Estrutura do Live OS

Ao dar boot pela ISO, a estrutura inicial será:
* **Área de Trabalho:** Atalho para o "Painel de Controle do Técnico".
* **Gerenciador de Arquivos:** Pré-configurado para montar automaticamente partições NTFS (Windows) em modo somente leitura (para segurança contra vírus) ou gravação.
* **Menu de Ferramentas:** Lançador rápido para ferramentas como CPU-Z, GParted, Testadores de Disco e Navegador Web seguro.
