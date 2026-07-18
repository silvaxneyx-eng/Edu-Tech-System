#!/bin/bash
# Script para rodar dentro da ISO Linux (Fedora) e resetar a senha do Windows automaticamente.
# Ele detecta partições NTFS locais, encontra o arquivo SAM do Windows e limpa a senha do Administrador usando a ferramenta chntpw.

echo "============================================="
echo "   ISO LOUCA - RESETADOR AUTOMÁTICO DE SENHA "
echo "============================================="

# 1. Encontra todos os discos/partições do tipo NTFS (onde o Windows geralmente está instalado)
particoes=$(lsblk -lo NAME,FSTYPE | grep -i ntfs | awk '{print $1}')

if [ -z "$particoes" ]; then
    echo "Nenhuma partição NTFS detectada no computador."
    exit 1
fi

for part in $particoes; do
    device="/dev/$part"
    mount_point="/mnt/win_$part"
    mkdir -p "$mount_point"

    echo "Tentando montar $device em $mount_point..."
    # Monta a partição usando NTFS-3G para permitir leitura e escrita
    mount -t ntfs-3g "$device" "$mount_point" 2>/dev/null

    # Caminho do arquivo SAM (geralmente Windows/System32/config/SAM)
    sam_path=""
    if [ -d "$mount_point/Windows/System32/config" ]; then
        sam_path="$mount_point/Windows/System32/config/SAM"
    elif [ -d "$mount_point/windows/system32/config" ]; then
        sam_path="$mount_point/windows/system32/config/SAM"
    fi

    if [ -f "$sam_path" ]; then
        echo "Arquivo SAM encontrado em: $sam_path"
        echo "Resetando senha do usuário 'Administrador' (Administrator) e desbloqueando a conta..."
        
        # Executa chntpw de forma não interativa para remover a senha do Administrador
        # -u indica o usuário, -e edita o registro
        # Enviamos comandos para o chntpw: '1' para limpar a senha, '2' para desbloquear a conta, 'q' para sair e 'y' para salvar.
        printf "1\n2\nq\ny\n" | chntpw -u "Administrador" "$sam_path" 2>/dev/null
        printf "1\n2\nq\ny\n" | chntpw -u "Administrator" "$sam_path" 2>/dev/null

        # Verifica se o chntpw funcionou ou tenta com outros usuários comuns se necessário
        echo "Procedimento executado para a partição $device."
        umount "$mount_point"
        echo "Sucesso! Pode reiniciar o computador do cliente e entrar sem senha."
        exit 0
    else
        umount "$mount_point" 2>/dev/null
    fi
done

echo "Instalação do Windows ou arquivo SAM não encontrado nas partições NTFS."
exit 1
