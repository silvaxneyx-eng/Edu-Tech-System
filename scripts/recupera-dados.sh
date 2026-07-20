#!/bin/bash
# ============================================================
# EduTech - Recuperação de Dados Deletados
# Usa PhotoRec para recuperar fotos e documentos apagados
# ============================================================

echo "============================================="
echo "   ISO LOUCA - RECUPERAÇÃO DE ARQUIVOS       "
echo "============================================="
echo ""

# Verifica se o photorec está instalado
if ! command -v photorec &> /dev/null; then
    echo "⚠️ A ferramenta PhotoRec/TestDisk não está instalada."
    echo "Instale com: sudo dnf install testdisk"
    exit 1
fi

echo "Discos disponíveis para varredura:"
lsblk -lo NAME,SIZE,FSTYPE,MODEL | grep -v "loop" | grep -v "squashfs"
echo ""

read -p "Digite o NOME do disco ou partição onde os arquivos foram apagados (ex: sdb1): " source_dev
if [ ! -b "/dev/$source_dev" ]; then
    echo "❌ Disco inválido."
    exit 1
fi

echo ""
echo "Agora precisamos de um lugar SEGURO para salvar os arquivos recuperados."
echo "NUNCA salve os arquivos no mesmo disco que está sendo recuperado!"
read -p "Digite o caminho da pasta destino (ex: /mnt/clientes/backup): " dest_dir

if [ ! -d "$dest_dir" ]; then
    echo "Criando diretório $dest_dir..."
    mkdir -p "$dest_dir"
fi

echo ""
echo "🚀 Iniciando PhotoRec no modo Terminal (TUI)..."
echo "Siga as instruções na tela. O PhotoRec vai perguntar o tipo de partição e iniciar a varredura."
read -p "Pressione ENTER para continuar..."

sudo photorec "/dev/$source_dev" -d "$dest_dir"

echo ""
echo "✅ Concluído! Seus arquivos devem estar na pasta: $dest_dir"
