#!/bin/bash
# ============================================================
# Instalador Web - EduTech Técnico (GTK4)
# Baixa e instala o aplicativo diretamente no seu Linux
# ============================================================

echo "============================================="
echo "   🚀 Instalando EduTech Técnico (GTK4) "
echo "============================================="

# Diretórios de instalação
INSTALL_DIR="$HOME/.local/share/edutech-tecnico"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
REPO_URL="https://raw.githubusercontent.com/silvaxneyx-eng/Edu-Tech-System/main/scripts"

echo "[1/4] Criando diretórios..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"

echo "[2/4] Baixando scripts e aplicativo..."
# Lista de arquivos para baixar
FILES=(
    "edutech-tecnico.py"
    "menu-tecnico.sh"
    "montar-discos-automatico.sh"
    "resetar-senha-automatico.sh"
    "scanner-virus-offline.sh"
    "backup-perfil-automatico.sh"
    "diagnostico-discos.sh"
    "conectar-rede.sh"
    "reparo-boot-windows.sh"
    "limpeza-segura-disco.sh"
)

for file in "${FILES[@]}"; do
    echo "  -> Baixando $file..."
    curl -sSL "$REPO_URL/$file" -o "$INSTALL_DIR/$file"
    chmod +x "$INSTALL_DIR/$file"
done

echo "[3/4] Criando atalhos..."
cat > "$DESKTOP_DIR/edutech-tecnico.desktop" << EOF
[Desktop Entry]
Type=Application
Name=EduTech Técnico
Comment=Kit de ferramentas de manutenção para técnicos
Exec=python3 $INSTALL_DIR/edutech-tecnico.py
Icon=utilities-system-monitor
Terminal=false
Categories=System;Utility;
Keywords=tecnico;reparo;disco;backup;virus;senha;
EOF
chmod +x "$DESKTOP_DIR/edutech-tecnico.desktop"

echo "[4/4] Instalando dependências (requer senha de root)..."
if command -v dnf &> /dev/null; then
    echo "  -> Fedora/RHEL detectado."
    sudo dnf install -y python3-gobject gtk4 libadwaita clamav smartmontools chntpw ms-sys inxi hwinfo
elif command -v apt-get &> /dev/null; then
    echo "  -> Debian/Ubuntu/Mint detectado."
    sudo apt-get update
    sudo apt-get install -y python3-gi gir1.2-gtk-4.0 gir1.2-adw-1 clamav smartmontools chntpw inxi hwinfo
elif command -v pacman &> /dev/null; then
    echo "  -> Arch/Manjaro detectado."
    sudo pacman -Sy --noconfirm python-gobject gtk4 libadwaita clamav smartmontools chntpw inxi hwinfo
elif command -v zypper &> /dev/null; then
    echo "  -> OpenSUSE detectado."
    sudo zypper install -y python3-gobject gtk4 libadwaita clamav smartmontools chntpw inxi hwinfo
else
    echo "  ⚠️ Gerenciador de pacotes não reconhecido. Instale manualmente as bibliotecas GTK4, Python3-gi e as ferramentas técnicas."
fi

echo "============================================="
echo " ✅ Instalação Concluída com Sucesso!"
echo "============================================="
echo "Você já pode encontrar o 'EduTech Técnico' no menu de aplicativos do seu sistema."
echo "Ou execute diretamente pelo terminal rodando: python3 $INSTALL_DIR/edutech-tecnico.py"
