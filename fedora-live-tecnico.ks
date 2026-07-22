# ============================================================
# Kickstart ISO Técnico FULLZÃO - EduTechAnderlineNet
# Versão completa com GNOME, todas as ferramentas e scripts
# ============================================================

lang pt_BR.UTF-8
keyboard br
timezone America/Sao_Paulo
selinux --disabled
firewall --disabled
xconfig --startxonboot
zerombr
clearpart --all
part / --size 8192 --fstype ext4

# Senha padrão: edutecnico
rootpw --plaintext edutecnico


# Repositórios Oficiais do Fedora 44
repo --name=fedora --baseurl=https://dl.fedoraproject.org/pub/fedora/linux/releases/44/Everything/$basearch/os/
repo --name=updates --baseurl=https://dl.fedoraproject.org/pub/fedora/linux/updates/44/Everything/$basearch/

%packages
# ── Boot e Kernel (OBRIGATÓRIO) ──────────────────────────────
kernel
kernel-modules
kernel-modules-extra
syslinux
grub2-efi-ia32-cdboot
grub2-efi-x64-cdboot
grub2-pc
grub2-pc-modules
shim-ia32
shim-x64
dracut-live
efibootmgr

# ── Interface Gráfica (GNOME) ─────────────────────────────────
@base-x
gnome-shell
gnome-terminal
gnome-control-center
gnome-system-monitor
gnome-disk-utility
nautilus
gdm
polkit
NetworkManager
NetworkManager-wifi
nm-connection-editor
zenity

# ── Navegador e Windows Compat ───────────────────────────────
firefox
wine
wine-core
wine-common

# ── Gerenciamento de Partições e Discos ──────────────────────
gparted
testdisk
chntpw
ntfs-3g
dosfstools
e2fsprogs
btrfs-progs
xfsprogs
parted

# ── Recuperação de dados ──────────────────────────────────────
ddrescue
testdisk

# ── Rede e Conectividade ──────────────────────────────────────
nmap
iperf3
cifs-utils
samba-client
openssh-clients
wireshark
traceroute
net-tools
bind-utils
wget
curl

# ── Diagnóstico de Hardware ───────────────────────────────────
smartmontools
lm_sensors
hdparm
dmidecode
lshw
inxi
iotop
nvme-cli
pciutils
usbutils

# ── Antivírus Offline ─────────────────────────────────────────
clamav
clamav-update

# ── Ferramentas de Sistema ────────────────────────────────────
util-linux
tar
unzip
zip
p7zip
p7zip-plugins
wget
rsync
htop
mc
nano
vim-minimal
screen
pv
tree
ncdu
tmux
bash-completion

# ── Bibliotecas para App GTK Gráfico ──────────────────────────
python3
python3-gobject
gtk4
libadwaita

# ── Utilitários de Arquivo ────────────────────────────────────
file-roller

# ── Utilitários WPE / Multiboot ────────────────────────────────
wimlib-utils
dialog
qemu-kvm
qemu-system-x86-core

# ── Editor de Texto Gráfico ───────────────────────────────────
gedit

# ── Excluir pacotes problemáticos (apenas os que causam erro no Docker) ───
-gnome-all-langpacks
-langpacks-*
-geolite2*
%end

%post
# ── Garante senhas e permissões (sem senha para o técnico) ────────
useradd -m -G wheel jardson 2>/dev/null || true
passwd -d root 2>/dev/null || true
passwd -d jardson 2>/dev/null || true

# Patch no livesys do Fedora Live para usar 'jardson' sem senha no boot
if [ -f /usr/sbin/livesys ]; then
    sed -i 's/liveuser/jardson/g' /usr/sbin/livesys
    sed -i '2i useradd -m -G wheel jardson 2>/dev/null || true\nchown -R jardson:jardson /home/jardson 2>/dev/null || true\npasswd -d root\npasswd -d jardson' /usr/sbin/livesys
fi

# ── Auto-login sem senha no GNOME (Garante jardson) ──────────
mkdir -p /etc/gdm
cat > /etc/gdm/custom.conf << 'GDMEOF'
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=jardson
GDMEOF

# ── Configurar Wallpaper na Tela de Login (GDM) ──────────────
mkdir -p /etc/dconf/db/gdm.d
cat > /etc/dconf/db/gdm.d/00-background << 'GDMWALL'
[org/gnome/desktop/background]
picture-uri='file:///usr/share/wallpapers/edutecnico/wallpaper4_1920x1080.png'
picture-uri-dark='file:///usr/share/wallpapers/edutecnico/wallpaper4_1920x1080.png'
picture-options='zoom'
GDMWALL

# Cria o perfil gdm se não existir
mkdir -p /etc/dconf/profile
cat > /etc/dconf/profile/gdm << 'GDMPROFILE'
user-db:user
system-db:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults
GDMPROFILE

dconf update || true

# ── Cria estrutura de pastas para o jardson ──────────────────
mkdir -p /home/jardson/Desktop
mkdir -p /home/jardson/Documentos
mkdir -p /home/jardson/.config/autostart

# ── Tema escuro + Tela sem bloqueio + Wallpaper (via dconf) ──────────────────────────
mkdir -p /etc/dconf/profile
cat > /etc/dconf/profile/user << 'PROFILEEOF'
user-db:user
system-db:local
PROFILEEOF

mkdir -p /etc/dconf/db/local.d
cat > /etc/dconf/db/local.d/00-tecnico << 'DCONFEOF'
[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='Adwaita-dark'

[org/gnome/desktop/background]
picture-uri='file:///usr/share/wallpapers/edutecnico/wallpaper4_1920x1080.png'
picture-uri-dark='file:///usr/share/wallpapers/edutecnico/wallpaper4_1920x1080.png'
picture-options='zoom'

[org/gnome/desktop/screensaver]
lock-enabled=false
picture-uri='file:///usr/share/wallpapers/edutecnico/wallpaper4_1920x1080.png'

[org/gnome/desktop/session]
idle-delay=uint32 0

[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-type='nothing'

[org/gnome/shell]
favorite-apps=['menu-tecnico.desktop', 'org.gnome.Nautilus.desktop', 'gparted.desktop', 'firefox.desktop']
DCONFEOF

dconf update || true

# Autostart para o Menu Técnico
cat > /home/jardson/.config/autostart/abrir-menu.desktop << 'MENUSTARTEOF'
[Desktop Entry]
Type=Application
Exec=python3 /home/jardson/Scripts/edutech-tecnico.py
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Abrir Menu Tecnico
MENUSTARTEOF

# Autostart para Montagem Automática de Discos
cat > /home/jardson/.config/autostart/montar-discos.desktop << 'MONTEOF'
[Desktop Entry]
Type=Application
Exec=gnome-terminal --title="🔍 Montagem Automática" -- bash -c "sudo bash /home/jardson/Scripts/montar-discos-automatico.sh; echo; read -p 'Pressione ENTER para fechar...'"
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Montar Discos Clientes
MONTEOF

# ── Cria pasta de wallpapers ────────────────────────────────
mkdir -p /usr/share/wallpapers/edutecnico
mkdir -p /usr/share/gnome-background-properties

# ── Registrar Menu Técnico no sistema de aplicativos global ────
mkdir -p /usr/share/applications
cat > /usr/share/applications/menu-tecnico.desktop << 'GLOBALMENUEOF'
[Desktop Entry]
Type=Application
Name=Menu Técnico EduTech
Comment=Painel de ferramentas de reparo
Exec=python3 /home/jardson/Scripts/edutech-tecnico.py
Terminal=false
Icon=utilities-system-monitor
Categories=System;Utility;
GLOBALMENUEOF

# ── Atalho na área de trabalho: Menu do Técnico ──────────────
cat > /home/jardson/Desktop/Menu-Tecnico.desktop << 'MENUEOF'
[Desktop Entry]
Type=Application
Name=Menu Técnico EduTech
Comment=Abrir menu de ferramentas do técnico
Exec=python3 /home/jardson/Scripts/edutech-tecnico.py
Terminal=false
Icon=utilities-system-monitor
MENUEOF

# ── Atalho: Diagnóstico de Discos ────────────────────────────
cat > /home/jardson/Desktop/Diagnostico-Discos.desktop << 'DIAGEOF'
[Desktop Entry]
Type=Application
Name=Diagnóstico de Discos
Exec=gnome-terminal --title="🔍 Diagnóstico de Discos" -- bash -c "bash /home/jardson/Scripts/diagnostico-discos.sh; read -p 'Pressione ENTER para sair...'"
Terminal=false
Icon=drive-harddisk
DIAGEOF

# ── Atalho: Scanner de Vírus ──────────────────────────────────
cat > /home/jardson/Desktop/Scanner-Virus.desktop << 'VIRUSEOF'
[Desktop Entry]
Type=Application
Name=Scanner de Vírus Offline
Exec=gnome-terminal --title="🛡️ Scanner de Vírus" -- bash -c "bash /home/jardson/Scripts/scanner-virus-offline.sh; read -p 'Pressione ENTER para sair...'"
Terminal=false
Icon=security-high
VIRUSEOF

# ── Atalho: Backup de Perfil ──────────────────────────────────
cat > /home/jardson/Desktop/Backup-Perfil.desktop << 'BACKUPEOF'
[Desktop Entry]
Type=Application
Name=Backup de Perfil do Usuário
Exec=gnome-terminal --title="📂 Backup de Perfil" -- bash -c "bash /home/jardson/Scripts/backup-perfil-automatico.sh; read -p 'Pressione ENTER para sair...'"
Terminal=false
Icon=document-save
BACKUPEOF

# ── Atalho: Resetar Senha ─────────────────────────────────────
cat > /home/jardson/Desktop/Resetar-Senha.desktop << 'SENHAEOF'
[Desktop Entry]
Type=Application
Name=Resetar Senha Windows
Exec=gnome-terminal --title="🔑 Resetar Senha" -- bash -c "bash /home/jardson/Scripts/resetar-senha-automatico.sh; read -p 'Pressione ENTER para sair...'"
Terminal=false
Icon=dialog-password
SENHAEOF

# ── Atalho: GParted ───────────────────────────────────────────
cat > /home/jardson/Desktop/GParted.desktop << 'GPARTED'
[Desktop Entry]
Type=Application
Name=GParted - Partições
Exec=pkexec gparted
Icon=gparted
GPARTED

# ── Atalho: Lançador Multiboot de ISOs (WPE) ─────────────────
cat > /home/jardson/Desktop/Lancador-ISOs.desktop << 'ISOEOF'
[Desktop Entry]
Type=Application
Name=Lançador de ISOs (WPE Multiboot)
Comment=Carregar e instalar ISOs do Windows ou Linux
Exec=gnome-terminal --title="💿 Lançador de ISOs" -- bash -c "sudo bash /home/jardson/Scripts/iso-launcher.sh"
Terminal=false
Icon=media-optical
ISOEOF

# ── Atalho: Ghost Toolbox ────────────────────────────────────
cat > /home/jardson/Desktop/Ghost-Toolbox.desktop << 'GHOSTEOF'
[Desktop Entry]
Type=Application
Name=Ghost Toolbox Rev11
Comment=Ferramenta de otimização e pacotes Ghost Spectre
Exec=wine /home/jardson/Tools/GhostToolbox/Ghost.Toolbox-Rev11_setup.x64.exe
Terminal=false
Icon=preferences-other
GHOSTEOF

# ── Permissões dos atalhos ────────────────────────────────────
chmod +x /home/jardson/Desktop/*.desktop

# ── Créditos no sistema ───────────────────────────────────────
cat > /etc/issue << 'ISSUEEOF'
EduTechAnderlineNet - ISO Técnico FULLZÃO
Usuário: jardson | Senha: (sem senha/em branco)
ISSUEEOF

# ── Permissões Especiais: Sudo Sem Senha ─────────────────────
echo "jardson ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/jardson
chmod 0440 /etc/sudoers.d/jardson

# ── Permissões Especiais: Polkit Sem Senha para GParted ──────
mkdir -p /etc/polkit-1/rules.d
cat > /etc/polkit-1/rules.d/49-nopasswd-jardson.rules << 'POLKITEOF'
polkit.addRule(function(action, subject) {
    if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
POLKITEOF
chmod 0644 /etc/polkit-1/rules.d/49-nopasswd-jardson.rules
chown root:root /etc/polkit-1/rules.d/49-nopasswd-jardson.rules


cat > /etc/motd << 'MOTDEOF'
============================================
 🔧 EduTechAnderlineNet - ISO Técnico FULL
============================================
  Usuário: jardson    Senha: (sem senha/em branco)
  Root:    root       Senha: (sem senha/em branco)

  Ferramentas na Área de Trabalho:
   - Menu do Técnico (todas as funções)
   - Diagnóstico de Discos
   - Scanner de Vírus Offline
   - Backup de Perfil
   - Resetar Senha Windows
   - GParted
============================================
MOTDEOF

chown -R jardson:jardson /home/jardson
%end

%post --nochroot
# ── Copiar todos os scripts para a ISO ───────────────────────
mkdir -p $INSTALL_ROOT/home/jardson/Scripts
cp /build/scripts/*.sh $INSTALL_ROOT/home/jardson/Scripts/ 2>/dev/null || true
cp /build/scripts/*.py $INSTALL_ROOT/home/jardson/Scripts/ 2>/dev/null || true
cp /build/scripts/*.ps1 $INSTALL_ROOT/home/jardson/Scripts/ 2>/dev/null || true
cp /build/scripts/*.cmd $INSTALL_ROOT/home/jardson/Scripts/ 2>/dev/null || true
chmod -R +x $INSTALL_ROOT/home/jardson/Scripts/
chroot $INSTALL_ROOT chown -R jardson:jardson /home/jardson/Scripts 2>/dev/null || true

# ── Copiar arquivo de explicação de ferramentas para o Desktop ──────
cp /build/Explica-Ferramentas.txt $INSTALL_ROOT/home/jardson/Desktop/ 2>/dev/null || true
chroot $INSTALL_ROOT chown jardson:jardson /home/jardson/Desktop/Explica-Ferramentas.txt 2>/dev/null || true

# ── Copiar Ghost Toolbox para a ISO ─────────────────────────
mkdir -p "$INSTALL_ROOT/home/jardson/Tools/GhostToolbox"
cp -rf /build/Ghost\ Toolbox/* "$INSTALL_ROOT/home/jardson/Tools/GhostToolbox/" 2>/dev/null || true
chroot $INSTALL_ROOT chown -R jardson:jardson /home/jardson/Tools 2>/dev/null || true

# ── Copiar wallpapers para dentro da ISO ─────────────────────
mkdir -p $INSTALL_ROOT/usr/share/wallpapers/edutecnico
mkdir -p $INSTALL_ROOT/usr/share/gnome-background-properties
cp /build/Wallpapers/*.png $INSTALL_ROOT/usr/share/wallpapers/edutecnico/ 2>/dev/null || true
cp /build/Wallpapers/*.jpg $INSTALL_ROOT/usr/share/wallpapers/edutecnico/ 2>/dev/null || true

# Registrar wallpapers no seletor do GNOME
cat > $INSTALL_ROOT/usr/share/gnome-background-properties/edutecnico.xml << 'WALLEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
  <wallpaper deleted="false">
    <name>EduTechAnderlineNet - 1920x1080</name>
    <filename>/usr/share/wallpapers/edutecnico/wallpaper4_1920x1080.png</filename>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor>#000000</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>EduTechAnderlineNet - 1440x900</name>
    <filename>/usr/share/wallpapers/edutecnico/wallpaper4_1440x900.png</filename>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor>#000000</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
  <wallpaper deleted="false">
    <name>EduTechAnderlineNet - 1152x864</name>
    <filename>/usr/share/wallpapers/edutecnico/wallpaper4_1152x864.png</filename>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor>#000000</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
</wallpapers>
WALLEOF


# ── WORKAROUND: Desmontagem forçada ──────────────────────────
umount -l $INSTALL_ROOT/var/cache/dnf || true
%end
