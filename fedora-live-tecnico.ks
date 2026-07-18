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


# Repositórios Oficiais do Fedora 40
repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-40&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f40&arch=$basearch

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

# ── Navegador e Windows Compat ───────────────────────────────
firefox
wine
wine-core
wine-common

# ── Gerenciamento de Partições e Discos ──────────────────────
gparted
testdisk
ntfs-3g
dosfstools
e2fsprogs
btrfs-progs
xfsprogs
parted

# ── Recuperação de dados ──────────────────────────────────────
ddrescue

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

# ── Utilitários de Arquivo ────────────────────────────────────
file-roller

# ── Editor de Texto Gráfico ───────────────────────────────────
gedit

# ── Excluir pacotes problemáticos (apenas os que causam erro no Docker) ───
-gnome-all-langpacks
-langpacks-*
-geolite2*
%end

%post
# ── Garante senhas e permissões (dupla garantia) ──────────────
useradd -m -G wheel jardson 2>/dev/null || true
echo 'root:2412' | chpasswd 2>/dev/null || true
echo 'jardson:2412' | chpasswd 2>/dev/null || true

# Patch no livesys do Fedora Live para usar 'jardson' e senha '2412' no boot
if [ -f /usr/sbin/livesys ]; then
    sed -i 's/liveuser/jardson/g' /usr/sbin/livesys
    echo "echo 'jardson:2412' | chpasswd" >> /usr/sbin/livesys
    echo "echo 'root:2412' | chpasswd" >> /usr/sbin/livesys
fi

# ── Auto-login sem senha no GNOME (Garante jardson) ──────────
mkdir -p /etc/gdm
cat > /etc/gdm/custom.conf << 'GDMEOF'
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=jardson
GDMEOF

# ── Cria estrutura de pastas para o jardson ──────────────────
mkdir -p /home/jardson/Desktop
mkdir -p /home/jardson/Documentos
mkdir -p /home/jardson/.config/autostart

# ── Tema escuro + Tela sem bloqueio ──────────────────────────
cat > /home/jardson/.config/autostart/setup.desktop << 'DTEOF'
[Desktop Entry]
Type=Application
Exec=bash -c "gsettings set org.gnome.desktop.interface color-scheme prefer-dark; gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'; gsettings set org.gnome.desktop.screensaver lock-enabled false; gsettings set org.gnome.desktop.session idle-delay 0; gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'; gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/wallpapers/edutecnico/wallpaper4_1920x1080.png'; gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/wallpapers/edutecnico/wallpaper4_1920x1080.png'; gsettings set org.gnome.desktop.background picture-options 'zoom'; gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/wallpapers/edutecnico/wallpaper4_1920x1080.png'; gsettings set org.gnome.shell favorite-apps \"['menu-tecnico.desktop', 'org.gnome.Nautilus.desktop', 'gparted.desktop', 'firefox.desktop']\""
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Setup Tecnico
DTEOF

# Autostart para o Menu Técnico
cat > /home/jardson/.config/autostart/abrir-menu.desktop << 'MENUSTARTEOF'
[Desktop Entry]
Type=Application
Exec=bash /home/jardson/Scripts/menu-tecnico.sh
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Abrir Menu Tecnico
MENUSTARTEOF

# Autostart para Montagem Automática de Discos
cat > /home/jardson/.config/autostart/montar-discos.desktop << 'MONTEOF'
[Desktop Entry]
Type=Application
Exec=bash -c "gnome-terminal --title='🔍 Montagem Automática' -- bash -c 'sudo bash /home/jardson/Scripts/montar-discos-automatico.sh; echo; read -p \"Pressione ENTER para fechar...\"'"
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
Exec=bash /home/jardson/Scripts/menu-tecnico.sh
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
Exec=bash /home/jardson/Scripts/menu-tecnico.sh
Terminal=false
Icon=utilities-system-monitor
X-GNOME-Autostart-enabled=true
MENUEOF

# ── Atalho: Diagnóstico de Discos ────────────────────────────
cat > /home/jardson/Desktop/Diagnostico-Discos.desktop << 'DIAGEOF'
[Desktop Entry]
Type=Application
Name=Diagnóstico de Discos
Exec=bash -c "bash /home/jardson/Scripts/diagnostico-discos.sh; read -p 'Pressione ENTER para sair...'"
Terminal=true
Icon=drive-harddisk
DIAGEOF

# ── Atalho: Scanner de Vírus ──────────────────────────────────
cat > /home/jardson/Desktop/Scanner-Virus.desktop << 'VIRUSEOF'
[Desktop Entry]
Type=Application
Name=Scanner de Vírus Offline
Exec=bash -c "bash /home/jardson/Scripts/scanner-virus-offline.sh; read -p 'Pressione ENTER para sair...'"
Terminal=true
Icon=security-high
VIRUSEOF

# ── Atalho: Backup de Perfil ──────────────────────────────────
cat > /home/jardson/Desktop/Backup-Perfil.desktop << 'BACKUPEOF'
[Desktop Entry]
Type=Application
Name=Backup de Perfil do Usuário
Exec=bash -c "bash /home/jardson/Scripts/backup-perfil-automatico.sh; read -p 'Pressione ENTER para sair...'"
Terminal=true
Icon=document-save
BACKUPEOF

# ── Atalho: Resetar Senha ─────────────────────────────────────
cat > /home/jardson/Desktop/Resetar-Senha.desktop << 'SENHAEOF'
[Desktop Entry]
Type=Application
Name=Resetar Senha Windows
Exec=bash -c "bash /home/jardson/Scripts/resetar-senha-automatico.sh; read -p 'Pressione ENTER para sair...'"
Terminal=true
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

# ── Permissões dos atalhos ────────────────────────────────────
chmod +x /home/jardson/Desktop/*.desktop

# ── Créditos no sistema ───────────────────────────────────────
cat > /etc/issue << 'ISSUEEOF'
EduTechAnderlineNet - ISO Técnico FULLZÃO
Usuário: jardson | Senha: 2412
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
 Usuário: jardson    Senha: 2412
 Root:    root       Senha: 2412

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
cp /build/scripts/*.ps1 $INSTALL_ROOT/home/jardson/Scripts/ 2>/dev/null || true
cp /build/scripts/*.cmd $INSTALL_ROOT/home/jardson/Scripts/ 2>/dev/null || true
chmod -R +x $INSTALL_ROOT/home/jardson/Scripts/
chroot $INSTALL_ROOT chown -R jardson:jardson /home/jardson/Scripts 2>/dev/null || true

# ── Copiar arquivo de explicação de ferramentas para o Desktop ──────
cp /build/Explica-Ferramentas.txt $INSTALL_ROOT/home/jardson/Desktop/ 2>/dev/null || true
chroot $INSTALL_ROOT chown jardson:jardson /home/jardson/Desktop/Explica-Ferramentas.txt 2>/dev/null || true

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
