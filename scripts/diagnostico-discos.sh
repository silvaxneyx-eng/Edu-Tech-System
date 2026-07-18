#!/bin/bash
# Diagnóstico rápido de todos os HDs/SSDs usando smartmontools (smartctl) e nvme-cli

echo "============================================="
echo "   ISO LOUCA - DIAGNÓSTICO S.M.A.R.T.        "
echo "============================================="
echo ""

# Lista todos os discos físicos (excluindo loop, ram, usb live)
discos=$(lsblk -dno NAME,TYPE | grep -E "disk" | awk '{print $1}')

if [ -z "$discos" ]; then
    echo "Nenhum disco físico encontrado."
    exit 1
fi

for disco in $discos; do
    device="/dev/$disco"
    
    # Ignora a mídia do próprio Live USB (geralmente rotulado pelo lsblk)
    if lsblk -no TRAN "$device" | grep -q "usb"; then
        echo "Pulando unidade USB do Técnico: $device"
        continue
    fi

    echo "---------------------------------------------"
    echo "Analisando: $device"
    
    # Pega o modelo do disco
    modelo=$(lsblk -dno MODEL "$device")
    echo "Modelo: $modelo"

    # Verifica se é um drive NVMe
    if [[ "$disco" == nvme* ]]; then
        echo "Tipo de Conexão: NVMe PCIe"
        if command -v nvme >/dev/null; then
            # Pega a saúde e temperatura do NVMe
            nvme smart-log "$device" | grep -E "critical_warning|temperature|percentage_used"
        else
            smartctl -H -A "$device" | grep -E "Result|Temperature|Percentage"
        fi
    else
        echo "Tipo de Conexão: SATA / SAS"
        # Testa se SMART está habilitado
        smartctl -i "$device" | grep -i "SMART support is:"
        
        # Mostra o status geral de saúde
        health=$(smartctl -H "$device" | grep -i "test result" | awk -F: '{print $2}')
        echo "Status Geral: $health"
        
        # Mostra atributos críticos (Realocados, Temperatura, Horas de Uso)
        echo "Atributos Importantes:"
        smartctl -A "$device" | grep -E "Reallocated_Sector_Ct|Power_On_Hours|Temperature_Celsius|Runtime_Bad_Block"
    fi
    echo "---------------------------------------------"
done

echo ""
echo "Legenda NVMe:"
echo "  percentage_used: 100% ou mais indica desgaste severo da vida útil."
echo ""
echo "Legenda SATA:"
echo "  Reallocated_Sector_Ct: Se for maior que 0, o disco tem setores defeituosos físicos (Bad Block)."
echo ""
