#!/bin/bash
set -e

# Verificar se livecd-tools está instalado
if ! command -v livecd-creator &> /dev/null; then
    echo "=== Instalando livecd-tools ==="
    sudo dnf install -y livecd-tools
fi

# Criar link simbólico temporário para manter compatibilidade com o Kickstart (/build)
echo "=== Criando link simbólico temporário /build ==="
sudo rm -f /build
sudo ln -s "$(pwd)" /build

# Limpar arquivos de builds anteriores
echo "=== Limpando arquivos anteriores ==="
sudo rm -f ISO_LOUCA_BOOT.iso

# Iniciar o build da ISO
echo "=== Iniciando compilação da ISO Fedora 44 (GNOME) ==="
sudo livecd-creator \
    --verbose \
    --config=fedora-live-tecnico.ks \
    --fslabel=ISO_LOUCA_BOOT \
    --cache=/var/cache/live

# Limpar link simbólico temporário
echo "=== Removendo link simbólico temporário /build ==="
sudo rm -f /build

echo "=== Concluído! ISO criada em: $(pwd)/ISO_LOUCA_BOOT.iso ==="
