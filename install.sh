#!/bin/bash
# ============================================================
# Instalador Web - EduTech Técnico V4.0 (CustomTkinter)
# Baixa e instala o aplicativo diretamente no seu Linux
# ============================================================

echo "============================================="
echo "   🚀 Instalando EduTech Técnico V4.0       "
echo "============================================="

# Diretórios de instalação
INSTALL_DIR="$HOME/.local/share/edutech-tecnico"
DESKTOP_DIR="$HOME/.local/share/applications"
REPO_URL="https://raw.githubusercontent.com/silvaxneyx-eng/Edu-Tech-System/main/scripts"

echo "[1/5] Criando diretórios..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$DESKTOP_DIR"

echo "[2/5] Baixando scripts e aplicativo..."
# Lista COMPLETA de todos os arquivos
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
    "recupera-dados.sh"
    "clonar-disco.sh"
    "reparo-grub.sh"
    "scanner-rede.sh"
    "backup-drivers-windows.sh"
    "win-hardware.ps1"
    "win-backup.ps1"
    "win-network.ps1"
)

for file in "${FILES[@]}"; do
    echo "  -> Baixando $file..."
    curl -sSL "$REPO_URL/$file" -o "$INSTALL_DIR/$file"
    chmod +x "$INSTALL_DIR/$file"
done

echo "[3/5] Criando atalho no menu..."
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

echo "[4/5] Instalando dependências do Python..."
# Instala pip se não existir e depois o customtkinter
if command -v dnf &> /dev/null; then
    echo "  -> Fedora/RHEL detectado."
    sudo dnf install -y python3-pip python3-tkinter clamav smartmontools inxi nmap testdisk
elif command -v apt-get &> /dev/null; then
    echo "  -> Debian/Ubuntu/Mint detectado."
    sudo apt-get update
    sudo apt-get install -y python3-pip python3-tk clamav smartmontools inxi nmap testdisk
elif command -v pacman &> /dev/null; then
    echo "  -> Arch/Manjaro detectado."
    sudo pacman -Sy --noconfirm python-pip tk clamav smartmontools inxi nmap testdisk
elif command -v zypper &> /dev/null; then
    echo "  -> OpenSUSE detectado."
    sudo zypper install -y python3-pip python3-tk clamav smartmontools inxi nmap testdisk
else
    echo "  ⚠️ Gerenciador de pacotes não reconhecido."
fi

echo "[5/5] Instalando biblioteca gráfica (CustomTkinter)..."
pip3 install customtkinter 2>/dev/null || python3 -m pip install customtkinter

echo "============================================="
echo " ✅ Instalação Concluída com Sucesso!"
echo "============================================="
echo "Você já pode encontrar o 'EduTech Técnico' no menu de aplicativos."
echo "Ou execute: python3 $INSTALL_DIR/edutech-tecnico.py"
