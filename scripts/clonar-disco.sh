#!/bin/bash
# ============================================================
# EduTech - Clonagem Completa de Discos
# ============================================================

echo "============================================="
echo "   ISO LOUCA - CLONAGEM DE DISCO (UPGRADE)   "
echo "============================================="
echo ""
echo "⚠️ ATENÇÃO: Esta ferramenta apaga tudo no disco de DESTINO!"

echo "Discos conectados:"
lsblk -lo NAME,SIZE,MODEL,TRAN | grep -E "disk"
echo ""

read -p "Digite o disco de ORIGEM (ex: sda): " origem
if [ ! -b "/dev/$origem" ]; then echo "Origem inválida."; exit 1; fi

read -p "Digite o disco de DESTINO (ex: nvme0n1): " destino
if [ ! -b "/dev/$destino" ]; then echo "Destino inválido."; exit 1; fi

if [ "$origem" == "$destino" ]; then
    echo "❌ Origem e Destino não podem ser iguais!"
    exit 1
fi

echo ""
echo "Resumo da Operação:"
echo "De:   /dev/$origem ($(lsblk -dno SIZE /dev/$origem))"
echo "Para: /dev/$destino ($(lsblk -dno SIZE /dev/$destino))"
echo ""
read -p "Digite 'CLONAR' para iniciar a cópia (Irreversível): " conf
if [ "$conf" != "CLONAR" ]; then echo "Cancelado."; exit 1; fi

echo "Iniciando clonagem bloco-a-bloco com 'dd'..."
sudo dd if="/dev/$origem" of="/dev/$destino" bs=4M status=progress

echo ""
echo "✅ Clonagem Finalizada!"
echo "Caso o disco de destino seja maior, não esqueça de usar o GParted para estender a partição."
