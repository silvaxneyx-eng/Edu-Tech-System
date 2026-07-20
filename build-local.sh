#!/bin/bash
set -e

echo "=== Preparando diretório de build ==="
sudo rm -rf build
mkdir -p build/config

# Copiar configurações do live-build
cp -r config/package-lists build/config/
cp -r config/hooks         build/config/
cp -r config/includes.chroot build/config/

# Wallpaper
mkdir -p build/config/includes.chroot/usr/share/backgrounds
cp "Wallpapers/wallpaper4_1440x900.png" \
   build/config/includes.chroot/usr/share/backgrounds/tecnico-wallpaper.png

# Scripts técnicos
mkdir -p build/config/includes.chroot/scripts
cp scripts/*.sh build/config/includes.chroot/scripts/

# Permissões dos hooks
chmod +x build/config/hooks/live/*.hook.chroot

# Criar script que roda dentro do Docker
cat > build/docker-build.sh << 'DOCKERSCRIPT'
#!/bin/bash
set -e

echo "=== Instalando live-build ==="
apt-get update -qq
apt-get install -y live-build

echo "=== Configurando live-build ==="
cd /workspace
lb config \
  --distribution bookworm \
  --architecture amd64 \
  --binary-images iso-hybrid \
  --debian-installer none \
  --chroot-filesystem squashfs \
  --compression xz \
  --apt-recommends true \
  --cache false \
  --archive-areas "main contrib non-free non-free-firmware" \
  --bootappend-live "boot=live components username=jardson" \
  --iso-volume "ISO-LOUCA" \
  --mirror-bootstrap http://deb.debian.org/debian \
  --mirror-chroot http://deb.debian.org/debian \
  --mirror-binary http://deb.debian.org/debian \
  --mirror-chroot-security http://security.debian.org/debian-security \
  --mirror-binary-security http://security.debian.org/debian-security

echo "=== Iniciando build ==="
lb build 2>&1 | tee build.log
echo "=== Build concluído! ==="
DOCKERSCRIPT
chmod +x build/docker-build.sh

echo "=== Iniciando build via Docker (Debian Bookworm) ==="
sudo docker run --rm --privileged \
  -v "$(pwd)/build:/workspace" \
  debian:bookworm \
  bash /workspace/docker-build.sh

echo "=== Finalizando ==="
ISO_FILE=$(find build/ -maxdepth 1 -name "*.iso" | head -1)
if [ -n "$ISO_FILE" ]; then
  sudo cp "$ISO_FILE" build/ISO-LOUCA-LXQt.iso
  sudo chown $USER:$USER build/ISO-LOUCA-LXQt.iso
  ls -lh build/ISO-LOUCA-LXQt.iso
  echo "✅ ISO gerada em: build/ISO-LOUCA-LXQt.iso"
else
  echo "❌ ERRO: ISO não foi gerada!"
  tail -50 build/build.log 2>/dev/null
  exit 1
fi
