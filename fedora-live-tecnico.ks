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
user --name=tecnico --groups=wheel --password=edutecnico --gecos="Tecnico EduTech"

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
# ── Garante usuário e senha (dupla garantia) ──────────────────
useradd -m -G wheel tecnico 2>/dev/null || true
echo 'tecnico:edutecnico' | chpasswd 2>/dev/null || true
echo 'root:edutecnico' | chpasswd 2>/dev/null || true
echo 'edutecnico' | passwd --stdin tecnico 2>/dev/null || true

# ── Auto-login sem senha no GNOME ────────────────────────────
mkdir -p /etc/gdm
cat > /etc/gdm/custom.conf << 'GDMEOF'
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=tecnico
GDMEOF

# ── Cria estrutura de pastas ──────────────────────────────────
mkdir -p /home/tecnico/Desktop
mkdir -p /home/tecnico/Documentos
mkdir -p /home/tecnico/.config/autostart

# ── Tema escuro + Tela sem bloqueio ──────────────────────────
cat > /home/tecnico/.config/autostart/setup.desktop << 'DTEOF'
[Desktop Entry]
Type=Application
Exec=bash -c "gsettings set org.gnome.desktop.interface color-scheme prefer-dark; gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'; gsettings set org.gnome.desktop.screensaver lock-enabled false; gsettings set org.gnome.desktop.session idle-delay 0; gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'; gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/wallpapers/edutecnico/wallpaper4_1920x1080.png'; gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/wallpapers/edutecnico/wallpaper4_1920x1080.png'; gsettings set org.gnome.desktop.background picture-options 'zoom'; gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/wallpapers/edutecnico/wallpaper4_1920x1080.png'"
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Setup Tecnico
DTEOF

# Autostart para Montagem Automática de Discos
cat > /home/tecnico/.config/autostart/montar-discos.desktop << 'MONTEOF'
[Desktop Entry]
Type=Application
Exec=bash -c "gnome-terminal --title='🔍 Montagem Automática' -- bash -c 'sudo bash /home/tecnico/Scripts/montar-discos-automatico.sh; echo; read -p \"Pressione ENTER para fechar...\"'"
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Montar Discos Clientes
MONTEOF

# ── Cria pasta de wallpapers ────────────────────────────────
mkdir -p /usr/share/wallpapers/edutecnico
mkdir -p /usr/share/gnome-background-properties

# ── Atalho na área de trabalho: Menu do Técnico ──────────────
cat > /home/tecnico/Desktop/Menu-Tecnico.desktop << 'MENUEOF'
[Desktop Entry]
Type=Application
Name=Menu Técnico EduTech
Comment=Abrir menu de ferramentas do técnico
Exec=bash -c "bash /home/tecnico/Scripts/menu-tecnico.sh; read -p 'Pressione ENTER para sair...'"
Terminal=true
Icon=utilities-system-monitor
X-GNOME-Autostart-enabled=true
MENUEOF

# ── Atalho: Diagnóstico de Discos ────────────────────────────
cat > /home/tecnico/Desktop/Diagnostico-Discos.desktop << 'DIAGEOF'
[Desktop Entry]
Type=Application
Name=Diagnóstico de Discos
Exec=bash -c "bash /home/tecnico/Scripts/diagnostico-discos.sh; read -p 'Pressione ENTER para sair...'"
Terminal=true
Icon=drive-harddisk
DIAGEOF

# ── Atalho: Scanner de Vírus ──────────────────────────────────
cat > /home/tecnico/Desktop/Scanner-Virus.desktop << 'VIRUSEOF'
[Desktop Entry]
Type=Application
Name=Scanner de Vírus Offline
Exec=bash -c "bash /home/tecnico/Scripts/scanner-virus-offline.sh; read -p 'Pressione ENTER para sair...'"
Terminal=true
Icon=security-high
VIRUSEOF

# ── Atalho: Backup de Perfil ──────────────────────────────────
cat > /home/tecnico/Desktop/Backup-Perfil.desktop << 'BACKUPEOF'
[Desktop Entry]
Type=Application
Name=Backup de Perfil do Usuário
Exec=bash -c "bash /home/tecnico/Scripts/backup-perfil-automatico.sh; read -p 'Pressione ENTER para sair...'"
Terminal=true
Icon=document-save
BACKUPEOF

# ── Atalho: Resetar Senha ─────────────────────────────────────
cat > /home/tecnico/Desktop/Resetar-Senha.desktop << 'SENHAEOF'
[Desktop Entry]
Type=Application
Name=Resetar Senha Windows
Exec=bash -c "bash /home/tecnico/Scripts/resetar-senha-automatico.sh; read -p 'Pressione ENTER para sair...'"
Terminal=true
Icon=dialog-password
SENHAEOF

# ── Atalho: GParted ───────────────────────────────────────────
cat > /home/tecnico/Desktop/GParted.desktop << 'GPARTED'
[Desktop Entry]
Type=Application
Name=GParted - Partições
Exec=pkexec gparted
Icon=gparted
GPARTED

# ── Permissões dos atalhos ────────────────────────────────────
chmod +x /home/tecnico/Desktop/*.desktop

# ── Créditos no sistema ───────────────────────────────────────
cat > /etc/issue << 'ISSUEEOF'
EduTechAnderlineNet - ISO Técnico FULLZÃO
Usuário: tecnico | Senha: edutecnico
ISSUEEOF

cat > /etc/motd << 'MOTDEOF'
============================================
 🔧 EduTechAnderlineNet - ISO Técnico FULL
============================================
 Usuário: tecnico    Senha: edutecnico
 Root:    root       Senha: edutecnico

 Ferramentas na Área de Trabalho:
  - Menu do Técnico (todas as funções)
  - Diagnóstico de Discos
  - Scanner de Vírus Offline
  - Backup de Perfil
  - Resetar Senha Windows
  - GParted
============================================
MOTDEOF

chown -R tecnico:tecnico /home/tecnico
%end

%post --nochroot
# ── Copiar todos os scripts para a ISO ───────────────────────
mkdir -p $INSTALL_ROOT/home/tecnico/Scripts
cp /build/scripts/*.sh $INSTALL_ROOT/home/tecnico/Scripts/ 2>/dev/null || true
cp /build/scripts/*.ps1 $INSTALL_ROOT/home/tecnico/Scripts/ 2>/dev/null || true
cp /build/scripts/*.cmd $INSTALL_ROOT/home/tecnico/Scripts/ 2>/dev/null || true
chmod -R +x $INSTALL_ROOT/home/tecnico/Scripts/
chroot $INSTALL_ROOT chown -R tecnico:tecnico /home/tecnico/Scripts 2>/dev/null || true

# ── Copiar arquivo de explicação de ferramentas para o Desktop ──────
cp /build/Explica-Ferramentas.txt $INSTALL_ROOT/home/tecnico/Desktop/ 2>/dev/null || true
chroot $INSTALL_ROOT chown tecnico:tecnico /home/tecnico/Desktop/Explica-Ferramentas.txt 2>/dev/null || true

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
