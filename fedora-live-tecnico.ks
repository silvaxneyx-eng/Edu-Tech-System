# Kickstart para ISO Técnico - EduTechAnderlineNet
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

# Repositórios Oficiais do Fedora 40
repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-40&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f40&arch=$basearch

%packages --skip-broken
# Base gráfica mínima
@base-x
gnome-shell
gnome-terminal
nautilus
gdm

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
rclone
chntpw
stress-ng
memtester
%end

%post
# Cria o usuário tecnico
useradd -m -G wheel tecnico
echo "tecnico" | passwd --stdin tecnico 2>/dev/null || true

# Configura autologin
mkdir -p /etc/gdm
cat > /etc/gdm/custom.conf << 'GDMEOF'
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=tecnico
GDMEOF

# Cria pasta Desktop
mkdir -p /home/tecnico/Desktop

# Copia scripts se existirem
for f in resetar-senha-automatico diagnostico-discos reparo-boot-windows limpeza-segura-disco menu-tecnico scanner-virus-offline; do
    if [ -f /run/initramfs/live/scripts/${f}.sh ]; then
        cp /run/initramfs/live/scripts/${f}.sh /home/tecnico/Desktop/${f}.sh
        chmod +x /home/tecnico/Desktop/${f}.sh
    fi
done

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
echo "EduTechAnderlineNet - ISO Técnico" > /etc/issue
%end
