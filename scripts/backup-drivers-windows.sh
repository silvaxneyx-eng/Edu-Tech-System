#!/bin/bash
# ============================================================
# EduTech - Backup de Drivers do Windows
# Exporta a pasta FileRepository (DriverStore)
# ============================================================

echo "============================================="
echo "   ISO LOUCA - BACKUP DE DRIVERS (WINDOWS)   "
echo "============================================="
echo ""

particoes=$(lsblk -lo NAME,FSTYPE | grep -i ntfs | awk '{print $1}')
if [ -z "$particoes" ]; then
    echo "❌ Nenhuma partição Windows (NTFS) detectada."
    exit 1
fi

echo "Procurando diretório do Windows..."
encontrado=0
for part in $particoes; do
    device="/dev/$part"
    mount_point="/mnt/drivers_$part"
    mkdir -p "$mount_point"
    mount -t ntfs-3g -o ro "$device" "$mount_point" 2>/dev/null

    # Procura a pasta do DriverStore
    driver_path=""
    if [ -d "$mount_point/Windows/System32/DriverStore/FileRepository" ]; then
        driver_path="$mount_point/Windows/System32/DriverStore/FileRepository"
    elif [ -d "$mount_point/windows/system32/driverstore/filerepository" ]; then
        driver_path="$mount_point/windows/system32/driverstore/filerepository"
    fi

    if [ -n "$driver_path" ]; then
        encontrado=1
        echo "✅ Drivers encontrados em $device"
        read -p "Onde deseja salvar os drivers? (ex: /mnt/clientes/DriversBackup): " dest_dir
        if [ -n "$dest_dir" ]; then
            mkdir -p "$dest_dir"
            echo "Copiando drivers... Isso pode demorar!"
            rsync -ah --info=progress2 "$driver_path/" "$dest_dir/"
            echo "✅ Backup concluído! Salvo em $dest_dir"
        fi
        break
    fi
    umount "$mount_point" 2>/dev/null
done

if [ "$encontrado" -eq 0 ]; then
    echo "❌ Pasta DriverStore não encontrada em nenhuma partição."
fi
