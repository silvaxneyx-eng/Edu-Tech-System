#!/bin/bash
# Limpeza segura (Wipe) de drives para eliminação definitiva de dados pessoais antes de descarte ou venda do PC

echo "============================================="
echo "   ISO LOUCA - LIMPEZA SEGURA DE DISCO       "
echo "============================================="
echo ""
echo "⚠️  ATENÇÃO: ESTE PROCEDIMENTO APAGA TODOS OS DADOS DE FORMA IRRECUPERÁVEL!"
echo "Certifique-se de escolher o disco correto!"
echo ""

# Exibe discos locais
lsblk -lo NAME,SIZE,MODEL,TRAN | grep -E "disk"
echo ""

read -p "Digite o NOME exato do disco a ser completamente APAGADO (ex: sda ou nvme0n1): " disco_escolhido
device="/dev/$disco_escolhido"

if [ ! -b "$device" ] || [ -z "$disco_escolhido" ]; then
    echo "Erro: Dispositivo inválido ou vazio."
    exit 1
fi

# Prevenção: Impede o usuário de limpar a própria unidade do Live USB
if lsblk -no TRAN "$device" | grep -q "usb"; then
    echo "❌ OPERAÇÃO CANCELADA: Você escolheu o disco USB do técnico. Isso destruiria o próprio sistema bootável!"
    exit 1
fi

echo ""
echo "Você escolheu o disco: $device (Modelo: $(lsblk -dno MODEL $device))"
echo "Tamanho: $(lsblk -dno SIZE $device)"
echo ""
read -p "Deseja continuar? Digite 'APAGAR' em letras maiúsculas para confirmar: " confirmacao

if [ "$confirmacao" != "APAGAR" ]; then
    echo "Operação cancelada pelo usuário."
    exit 1
fi

echo ""
echo "Iniciando processo de Wipe..."
echo "Escrevendo ZEROS (Zero-Fill) em toda a extensão do disco. Por favor, aguarde..."
echo ""

# Executa o dd com o pipeviewer (pv) para ver progresso real
dd if=/dev/zero | pv | dd of="$device" bs=4M status=progress

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Disco limpo com sucesso! Todos os setores foram preenchidos com zeros."
else
    echo ""
    echo "❌ Ocorreu um erro ou o processo foi interrompido. Verifique o estado físico do disco."
fi
