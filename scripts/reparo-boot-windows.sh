#!/bin/bash
# Reparo de bootloader MBR/BCD do Windows a partir do Linux usando ms-sys

echo "============================================="
echo "   ISO LOUCA - REPARADOR DE BOOT WINDOWS     "
echo "============================================="
echo ""

# Encontra discos físicos
discos=$(lsblk -dno NAME,TYPE | grep -E "disk" | awk '{print $1}')

if [ -z "$discos" ]; then
    echo "Nenhum disco encontrado."
    exit 1
fi

echo "Discos físicos detectados:"
lsblk -lo NAME,SIZE,TYPE,MODEL | grep -E "disk"
echo ""

read -p "Selecione o disco alvo do bootloader (ex: sda ou nvme0n1): " disco_escolhido
device="/dev/$disco_escolhido"

if [ ! -b "$device" ]; then
    echo "Erro: Dispositivo inválido."
    exit 1
fi

# Avisos de partição
echo ""
echo "Gravando registro MBR padrão compatível com Windows 7/10/11..."
# Roda o ms-sys para gravar a tabela Master Boot Record do Windows 7 a 11
ms-sys -7 "$device"

if [ $? -eq 0 ]; then
    echo "✅ MBR gravado com sucesso no disco $device!"
else
    echo "❌ Falha ao gravar MBR. O disco pode estar protegido ou com falhas."
fi

# Detectando partições NTFS de boot
echo ""
echo "Buscando partição NTFS ativa para gravar o registro de inicialização de partição (VBR)..."
particoes=$(lsblk -lo NAME,FSTYPE "$device" | grep -i ntfs | awk '{print $1}')

for part in $particoes; do
    part_device="/dev/$part"
    echo "Gravando VBR (Volume Boot Record) em $part_device..."
    ms-sys -ntfs "$part_device"
    if [ $? -eq 0 ]; then
        echo "  ✅ VBR NTFS gravado com sucesso em $part_device!"
    fi
done

echo ""
echo "Operação concluída. Reinicie a máquina do cliente e teste."
