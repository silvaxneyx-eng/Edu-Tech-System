# Kickstart MINIMO - EduTechAnderlineNet
# Expanda depois que a build funcionar

lang pt_BR.UTF-8
keyboard br
timezone America/Sao_Paulo
selinux --disabled
firewall --disabled
zerombr
clearpart --all
part / --size 4096 --fstype ext4

# Repositórios Fedora 40
repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-40&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f40&arch=$basearch

%packages
# Apenas o essencial para funcionar
util-linux
bash
coreutils
tar
gzip
bzip2
xz
wget
curl
nano
vim-minimal
htop
gparted
testdisk
ntfs-3g
smartmontools
%end

%post
echo "EduTechAnderlineNet - ISO Tecnico" > /etc/issue
%end
