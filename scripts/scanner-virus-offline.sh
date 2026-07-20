#!/bin/bash
# Scanner de vírus offline — Escaneia partições Windows sem ligar o sistema do cliente
# Usa ClamAV (gratuito e open-source)

echo "============================================="
echo "   ISO LOUCA - SCANNER DE VÍRUS OFFLINE      "
echo "============================================="
echo ""

# Atualiza as definições de vírus (se houver internet)
echo "[1/3] Atualizando base de vírus..."
freshclam 2>/dev/null
if [ $? -eq 0 ]; then
    echo "  Base atualizada com sucesso."
else
    echo "  Sem internet. Usando base local (pode estar desatualizada)."
fi

# Detecta partições NTFS
particoes=$(lsblk -lo NAME,FSTYPE | grep -i ntfs | awk '{print $1}')

if [ -z "$particoes" ]; then
    echo "⚠️ Nenhuma partição Windows (NTFS) detectada."
    echo "Alternativas disponíveis:"
    echo "1) Escanear discos montados do Linux/Mac em /mnt/clientes"
    echo "2) Escanear a pasta Downloads do usuário atual"
    echo "3) Sair"
    read -p "Escolha uma opção: " op_scan
    if [ "$op_scan" == "1" ]; then
        if [ ! -d "/mnt/clientes" ] || [ -z "$(ls -A /mnt/clientes 2>/dev/null)" ]; then
            echo "A pasta /mnt/clientes está vazia. Por favor, execute 'Montar Discos' primeiro."
            exit 1
        fi
        particoes="clientes"
    elif [ "$op_scan" == "2" ]; then
        particoes="downloads"
    else
        exit 1
    fi
fi

echo ""
echo "[2/3] Montando partições e escaneando..."

infectados=0
for part in $particoes; do
    if [ "$part" == "clientes" ]; then
        mount_point="/mnt/clientes"
        device="Discos Montados (Linux/Mac)"
        targets="\"$mount_point\""
    elif [ "$part" == "downloads" ]; then
        mount_point="$HOME/Downloads"
        device="Pasta Downloads"
        targets="\"$mount_point\""
    else
        device="/dev/$part"
        mount_point="/mnt/scan_$part"
        mkdir -p "$mount_point"

        # Monta somente leitura para segurança
        mount -t ntfs-3g -o ro "$device" "$mount_point" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "  Não conseguiu montar $device. Pulando..."
            continue
        fi

        # Para NTFS, procura pastas padrão
        targets=""
        for dir in "Windows/Temp" "Users" "ProgramData" "Program Files" "Program Files (x86)"; do
            if [ -d "$mount_point/$dir" ]; then
                targets="$targets \"$mount_point/$dir\""
            fi
        done

        if [ -z "$targets" ]; then
            targets="\"$mount_point\""
        fi
    fi

    echo ""
    echo "  Escaneando $device..."
    echo "  (Isso pode demorar vários minutos)"
    echo "  Alvos: $targets"
    echo ""

    eval "clamscan -r --bell --infected $targets" 2>/dev/null | tee /tmp/scan_${part}.log

    found=$(grep "Infected files:" /tmp/scan_${part}.log 2>/dev/null | awk '{print $3}')
    if [ -n "$found" ] && [ "$found" -gt 0 ]; then
        infectados=$((infectados + found))
        echo ""
        echo "  ⚠️  $found arquivo(s) infectado(s) em $device!"
    else
        echo "  ✅ Nenhum vírus encontrado em $device."
    fi

    # Desmonta apenas se foi nós que montamos
    if [ "$part" != "clientes" ] && [ "$part" != "downloads" ]; then
        umount "$mount_point" 2>/dev/null
    fi
done

echo ""
echo "============================================="
if [ "$infectados" -gt 0 ]; then
    echo "  RESULTADO: $infectados arquivo(s) infectado(s) encontrado(s)!"
    echo "  Logs salvos em /tmp/scan_*.log"
else
    echo "  RESULTADO: Sistema limpo! Nenhum vírus detectado."
fi
echo "============================================="
