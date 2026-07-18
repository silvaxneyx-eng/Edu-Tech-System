#!/bin/bash
# ============================================================
# Script de Montagem Automática de Discos do Cliente
# EduTechAnderlineNet - ISO Técnico
# ============================================================

# Cria o diretório base de montagem
mkdir -p /mnt/clientes

echo "🔍 Detectando e montando discos dos clientes..."

# Procura por partições do tipo NTFS, FAT32 e ext4 (exclui o loop do LiveCD)
particoes=$(lsblk -lo NAME,FSTYPE,TYPE | grep -E "ntfs|vfat|ext4" | grep -v "loop" | awk '{print $1}')

for part in $particoes; do
    # Obtém o rótulo (LABEL) da partição se existir, ou usa o nome do dispositivo
    label=$(lsblk -no LABEL "/dev/$part" | tr -d ' ' | tr -cd '[:alnum:]_')
    fstype=$(lsblk -no FSTYPE "/dev/$part")
    
    if [ -z "$label" ]; then
        mount_point="/mnt/clientes/$part"
    else
        mount_point="/mnt/clientes/${part}_${label}"
    fi

    # Se já estiver montado em algum lugar, ignora
    if mountpoint -q "$mount_point" 2>/dev/null || mount | grep -q "/dev/$part"; then
        echo "[!] Partição /dev/$part já está montada."
        continue
    fi

    mkdir -p "$mount_point"

    # Tenta montar com permissões adequadas
    case "$fstype" in
        ntfs)
            # ntfs-3g para escrita total e ignorar arquivos de hibernação rápida do Windows
            if sudo mount -t ntfs-3g -o remove_hiberfile,rw,utf8,uid=1000,gid=1000 "/dev/$part" "$mount_point" 2>/dev/null; then
                echo "[✓] Montado Windows (NTFS): /dev/$part -> $mount_point"
            else
                # Fallback somente leitura se o disco estiver corrompido
                sudo mount -t ntfs-3g -o ro,utf8 "/dev/$part" "$mount_point" && \
                echo "[!] Montado Windows (NTFS) [SOMENTE LEITURA - disco precisa de chkdsk]: /dev/$part -> $mount_point"
            fi
            ;;
        vfat)
            sudo mount -o rw,utf8,uid=1000,gid=1000 "/dev/$part" "$mount_point" 2>/dev/null && \
            echo "[✓] Montado Partição FAT32: /dev/$part -> $mount_point"
            ;;
        ext4)
            sudo mount -o rw "/dev/$part" "$mount_point" 2>/dev/null && \
            echo "[✓] Montado Linux (ext4): /dev/$part -> $mount_point"
            ;;
    esac
done

# Dá permissão ao usuário técnico para acessar a pasta de montagem
chown -R tecnico:tecnico /mnt/clientes 2>/dev/null || true
echo "✨ Detecção e montagem finalizadas. Discos prontos em /mnt/clientes/"
