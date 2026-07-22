#!/usr/bin/env bash
# ============================================================
# ISO LOuca — Lançador e Instalador Multiboot (WPE / Live PE)
# Permite selecionar e iniciar/instalar qualquer ISO de SO
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}   🔧 ISO LOuca - Lançador e Instalador Multiboot (WPE)   ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# 1. Procurar e montar partições para encontrar ISOs
echo -e "${YELLOW}[+] Procurando por ISOs em todos os discos e pendrives...${NC}"

SEARCH_DIRS=("/run/media" "/media" "/mnt" "/home/jardson" "/run/initramfs/live")
FOUND_ISOS=()

# Tentar montar partições de armazenamento não montadas
for dev in $(lsblk -lno NAME,TYPE,FSTYPE | awk '$2=="part" && $3~/(ntfs|vfat|ext4|exfat|btrfs)/ {print $1}'); do
    MOUNT_POINT="/mnt/dev_$dev"
    if ! mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
        mkdir -p "$MOUNT_POINT"
        mount -o ro "/dev/$dev" "$MOUNT_POINT" 2>/dev/null || true
    fi
done

# Varrer os diretórios por arquivos .iso
while IFS= read -r -d '' iso_file; do
    FOUND_ISOS+=("$iso_file")
done < <(find "${SEARCH_DIRS[@]}" /mnt -maxdepth 4 -type f -iname "*.iso" -print0 2>/dev/null)

if [ ${#FOUND_ISOS[@]} -eq 0 ]; then
    echo -e "${RED}[!] Nenhuma imagem .iso foi encontrada nos discos ou no pendrive!${NC}"
    echo ""
    echo -e "${YELLOW}Dica: Coloque seus arquivos .iso (Windows 10/11, Ubuntu, Fedora, etc.)${NC}"
    echo -e "${YELLOW}em uma pasta chamada 'ISOs' no seu pendrive ou partição do HD.${NC}"
    echo ""
    read -p "Pressione ENTER para voltar ao menu..."
    exit 0
fi

echo -e "${GREEN}[✓] Foram encontradas ${#FOUND_ISOS[@]} ISO(s) disponíveis:${NC}"
echo ""

# 2. Exibir menu de seleção (Zenity se em modo gráfico, Dialog/CLI se em terminal)
SELECTED_ISO=""

if [ -n "$DISPLAY" ] && command -v zenity >/dev/null 2>&1; then
    ZENITY_ARGS=()
    for iso in "${FOUND_ISOS[@]}"; do
        size=$(du -h "$iso" | cut -f1)
        ZENITY_ARGS+=("$iso" "$(basename "$iso") ($size)")
    done

    SELECTED_ISO=$(zenity --list \
        --title="ISO LOuca - Seleção de ISO Multiboot" \
        --column="Caminho Completo" --column="Arquivo ISO" \
        --height=450 --width=700 \
        "${ZENITY_ARGS[@]}" 2>/dev/null || true)
else
    for i in "${!FOUND_ISOS[@]}"; do
        size=$(du -h "${FOUND_ISOS[$i]}" | cut -f1)
        echo "  [$((i+1))] ${FOUND_ISOS[$i]} ($size)"
    done
    echo ""
    read -p "Digite o número da ISO desejada (ou 0 para cancelar): " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#FOUND_ISOS[@]}" ]; then
        SELECTED_ISO="${FOUND_ISOS[$((choice-1))]}"
    fi
fi

if [ -z "$SELECTED_ISO" ]; then
    echo -e "${YELLOW}[!] Operação cancelada pelo usuário.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}ISO Selecionada:${NC} $SELECTED_ISO"
echo ""

# 3. Ações disponíveis para a ISO escolhida
echo -e "${BLUE}Escolha o método de execução/instalação:${NC}"
echo "  [1] Executar ISO em Máquina Virtual (QEMU/KVM) - Teste/Instalação sem reiniciar"
echo "  [2] Montar ISO e Instalar Windows/Linux em um Disco Físico"
echo "  [3] Gravar ISO diretamente em um Pendrive/Disco (dd)"
echo "  [0] Sair"
echo ""

read -p "Opção desejada: " action_choice

case "$action_choice" in
    1)
        echo -e "${GREEN}[+] Iniciando QEMU com suporte a KVM para carregar a ISO...${NC}"
        RAM="4096"
        CPUS=$(nproc 2>/dev/null || echo 2)
        
        qemu-system-x86_64 \
            -enable-kvm \
            -m "$RAM" \
            -smp "$CPUS" \
            -cpu host \
            -vga virtio \
            -cdrom "$SELECTED_ISO" \
            -boot d &
        echo -e "${GREEN}[✓] Máquina Virtual iniciada!${NC}"
        ;;
    2)
        echo -e "${GREEN}[+] Preparando montagem da ISO para instalação...${NC}"
        MOUNT_DIR="/tmp/selected_iso_mnt"
        mkdir -p "$MOUNT_DIR"
        mount -o loop "$SELECTED_ISO" "$MOUNT_DIR"
        echo -e "${GREEN}[✓] ISO montada em $MOUNT_DIR${NC}"
        echo ""
        ls -la "$MOUNT_DIR"
        echo ""
        if [ -f "$MOUNT_DIR/setup.exe" ] || [ -f "$MOUNT_DIR/sources/install.wim" ] || [ -f "$MOUNT_DIR/sources/install.esd" ]; then
            echo -e "${YELLOW}[i] ISO do Windows detectada!${NC}"
            echo -e "Você pode usar as ferramentas do ISO LOuca (como GParted e WIMLib) para aplicar o Windows."
            if command -v wimlib-imagex >/dev/null 2>&1; then
                echo -e "Para aplicar a imagem em uma partição formatada:"
                echo -e "  ${GREEN}wimlib-imagex apply $MOUNT_DIR/sources/install.wim 1 /mnt/sua_particao${NC}"
            fi
        fi
        read -p "Pressione ENTER quando terminar de usar a ISO montada..."
        umount "$MOUNT_DIR" || true
        ;;
    3)
        echo -e "${RED}[⚠️ ATENÇÃO] Gravar a ISO em um disco irá APAGAR todos os dados desse disco!${NC}"
        lsblk -o NAME,SIZE,TYPE,MODEL,VENDOR
        echo ""
        read -p "Digite o dispositivo de destino (ex: /dev/sdX ou /dev/nvme0n1): " target_dev
        if [ -b "$target_dev" ]; then
            read -p "Tem certeza absoluta que deseja sobrescrever $target_dev? (digite SIM): " confirm
            if [ "$confirm" == "SIM" ]; then
                echo -e "${YELLOW}[+] Gravando $SELECTED_ISO em $target_dev...${NC}"
                dd if="$SELECTED_ISO" of="$target_dev" bs=4M status=progress conv=fsync
                echo -e "${GREEN}[✓] Gravação concluída com sucesso!${NC}"
            fi
        else
            echo -e "${RED}[!] Dispositivo inválido!${NC}"
        fi
        ;;
    *)
        echo -e "${YELLOW}Operação finalizada.${NC}"
        ;;
esac
