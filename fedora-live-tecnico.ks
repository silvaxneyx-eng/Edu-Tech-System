# Kickstart para ISO Técnico FULL - EduTechAnderlineNet
# Créditos: EduTechAnderlineNet

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
# Boot e Kernel Essenciais (OBRIGATÓRIO PARA BOOT EFI/BIOS)
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

# Base gráfica mínima
@base-x
gnome-shell
gnome-terminal
nautilus
gdm
NetworkManager
NetworkManager-wifi

# Navegador e Windows Compat
firefox
wine-core
wine-common

# Utilitários essenciais de técnico
gparted
testdisk
ntfs-3g
util-linux
tar
unzip
wget
curl
rsync
htop
mc
nano
vim-minimal

# Diagnóstico de hardware
smartmontools
lm_sensors
hdparm
dmidecode
lshw
inxi
iotop
nvme-cli

# Rede
nmap
iperf3
cifs-utils
samba-client

# Recuperação de dados
ddrescue
partclone

# Antivírus offline
clamav
clamav-update

# Extras
screen
pv

# Excluir pacotes problemáticos
-*langpacks*
-langpacks*
-geolite2*
%end

%post
# Garante que o usuario tecnico existe e a senha está correta (dupla garantia)
useradd -m -G wheel tecnico 2>/dev/null || true
# Metodo 1: chpasswd (mais confiavel)
echo 'tecnico:edutecnico' | chpasswd 2>/dev/null || true
echo 'root:edutecnico' | chpasswd 2>/dev/null || true
# Metodo 2: passwd (backup)
echo 'edutecnico' | passwd --stdin tecnico 2>/dev/null || true

# Configura autologin
mkdir -p /etc/gdm
cat > /etc/gdm/custom.conf << 'GDMEOF'
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=tecnico
GDMEOF

# Cria pasta Desktop
mkdir -p /home/tecnico/Desktop

# Tema escuro (melhor esforço)
mkdir -p /home/tecnico/.config/autostart
cat > /home/tecnico/.config/autostart/setup.desktop << 'DTEOF'
[Desktop Entry]
Type=Application
Exec=bash -c "gsettings set org.gnome.desktop.interface color-scheme prefer-dark; gsettings set org.gnome.desktop.screensaver lock-enabled false; gsettings set org.gnome.desktop.session idle-delay 0"
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Setup
DTEOF

chown -R tecnico:tecnico /home/tecnico

# Créditos no sistema
echo "EduTechAnderlineNet - ISO Técnico FULL" > /etc/issue
%end

%post --nochroot
# Copiar os scripts da pasta do projeto local para a Área de Trabalho do técnico na ISO
cp -r /build/scripts $INSTALL_ROOT/home/tecnico/Desktop/Meus_Scripts_de_Backup
chroot $INSTALL_ROOT chown -R tecnico:tecnico /home/tecnico/Desktop/Meus_Scripts_de_Backup
chroot $INSTALL_ROOT chmod -R +x /home/tecnico/Desktop/Meus_Scripts_de_Backup

# WORKAROUND: Forçar desmontagem preguiçosa do cache do DNF
umount -l $INSTALL_ROOT/var/cache/dnf || true
%end
