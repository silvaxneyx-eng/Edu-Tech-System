#!/bin/bash
# ============================================================
# EduTech - Reparo de GRUB (Chroot Automático)
# Monta partições Linux e recria o GRUB no disco
# ============================================================

echo "============================================="
echo "   ISO LOUCA - REPARO DE GRUB (LINUX)        "
echo "============================================="
echo ""

echo "Partições Linux disponíveis:"
lsblk -lo NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT | grep -E "ext4|btrfs|xfs"
echo ""

read -p "Digite a partição RAIZ do Linux quebrado (ex: sda2): " root_part
if [ ! -b "/dev/$root_part" ]; then exit 1; fi

read -p "O sistema usa UEFI? Digite a partição EFI/boot (ex: sda1) ou deixe vazio para BIOS Legacy: " efi_part

mount_dir="/mnt/linux_repair"
sudo mkdir -p "$mount_dir"

# Monta o root
echo "Montando /dev/$root_part em $mount_dir..."
sudo mount "/dev/$root_part" "$mount_dir"

# BTRFS workaround
if [ -d "$mount_dir/root" ] && [ -d "$mount_dir/home" ]; then
    sudo umount "$mount_dir"
    sudo mount -o subvol=root "/dev/$root_part" "$mount_dir"
elif [ -d "$mount_dir/@" ]; then
    sudo umount "$mount_dir"
    sudo mount -o subvol=@ "/dev/$root_part" "$mount_dir"
fi

if [ -n "$efi_part" ]; then
    sudo mkdir -p "$mount_dir/boot/efi"
    sudo mount "/dev/$efi_part" "$mount_dir/boot/efi"
fi

# Monta arquivos virtuais do sistema
sudo mount --bind /dev "$mount_dir/dev"
sudo mount --bind /proc "$mount_dir/proc"
sudo mount --bind /sys "$mount_dir/sys"
sudo mount --bind /run "$mount_dir/run"

echo "================================================="
echo " Entrando no ambiente Chroot. Digite os comandos de reparo!"
echo " Exemplo (Ubuntu/Mint): grub-install /dev/sda && update-grub"
echo " Exemplo (Fedora): grub2-mkconfig -o /boot/grub2/grub.cfg"
echo " Para sair, digite 'exit'"
echo "================================================="

sudo chroot "$mount_dir" /bin/bash

# Limpeza após sair
echo "Desmontando sistema de arquivos virtual..."
sudo umount "$mount_dir/run"
sudo umount "$mount_dir/sys"
sudo umount "$mount_dir/proc"
sudo umount "$mount_dir/dev"
if [ -n "$efi_part" ]; then sudo umount "$mount_dir/boot/efi"; fi
sudo umount "$mount_dir"
echo "✅ Concluído!"
