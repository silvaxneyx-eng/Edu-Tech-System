# Kickstart para construir o sistema Live Técnico baseado no Fedora Workstation (GNOME)
# Usado por: livecd-creator

lang pt_BR.UTF-8
keyboard br
timezone America/Sao_Paulo
selinux --disabled
firewall --enabled --service=mdns
xconfig --startxonboot
zerombr
clearpart --all
part / --size 8192 --fstype ext4

# Repositórios Oficiais do Fedora 44
repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-40&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f40&arch=$basearch

%packages
@base-x
@fonts
gnome-shell
nautilus
gnome-terminal
wine-core
wine-common
gparted
firefox
testdisk
ddrescue
ntfs-3g
util-linux
tar
unzip
wget
curl
# Adições úteis para o Técnico de Manutenção:
chntpw
smartmontools
stress-ng
memtester
lm_sensors
htop
partclone
partimage
rclone
pv
nmap
iperf3
cifs-utils
samba-client
# Scanner de vírus offline:
clamav
clamav-update
# Recuperação de arquivos deletados:
photorec
# Reparo de bootloader Windows:
ms-sys
# Limpeza segura de disco:
coreutils
wipe
# Monitoramento e diagnóstico:
iotop
nvme-cli
hdparm
dmidecode
inxi
lshw
# Extras úteis:
rsync
screen
mc
nano
vim-minimal
%end

%post
# Configura o autologin do usuário live 'tecnico'
cat <<EOF > /etc/gdm/custom.conf
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=tecnico
EOF

# Cria o usuário tecnico se não existir
useradd -m -G wheel tecnico

# Copia os scripts úteis para a Área de Trabalho do técnico
mkdir -p /home/tecnico/Desktop
cp /run/initramfs/live/Scripts/resetar-senha-automatico.sh /home/tecnico/Desktop/Resetar-Senha.sh
cp /run/initramfs/live/Scripts/scanner-virus-offline.sh /home/tecnico/Desktop/Scanner-Virus-Offline.sh
cp /run/initramfs/live/Scripts/backup-perfil-automatico.sh /home/tecnico/Desktop/Backup-Perfil-Windows.sh
cp /run/initramfs/live/Scripts/diagnostico-discos.sh /home/tecnico/Desktop/Diagnostico-Discos-SMART.sh
cp /run/initramfs/live/Scripts/reparo-boot-windows.sh /home/tecnico/Desktop/Reparo-Bootloader-Windows.sh
cp /run/initramfs/live/Scripts/limpeza-segura-disco.sh /home/tecnico/Desktop/Limpeza-Segura-Disco.sh
cp /run/initramfs/live/Scripts/menu-tecnico.sh /home/tecnico/Desktop/Menu-Tecnico.sh

chmod +x /home/tecnico/Desktop/*.sh

# Configura tema escuro e desativa bloqueio de tela do GNOME
su - tecnico -c "dbus-launch gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
su - tecnico -c "dbus-launch gsettings set org.gnome.desktop.screensaver lock-enabled false"
su - tecnico -c "dbus-launch gsettings set org.gnome.desktop.session idle-delay 0"

# Script de boas-vindas do Técnico com o visual limpo do GNOME
mkdir -p /home/tecnico/.config/autostart
cat <<EOF > /home/tecnico/.config/autostart/tecnico-welcome.desktop
[Desktop Entry]
Type=Application
Exec=gnome-terminal -- bash -c "/home/tecnico/Desktop/Menu-Tecnico.sh; exec bash"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Abrir Menu de Ferramentas
Comment=Abre o menu interativo com os utilitários do sistema
EOF

chown -R tecnico:tecnico /home/tecnico
%end
