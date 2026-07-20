#!/bin/bash
# Resetador Automático de Senhas Multi-SO (Windows, Linux, macOS)
# EduTechAnderlineNet

echo "============================================="
echo "   ISO LOUCA - RESETADOR DE SENHA (MULTI-SO) "
echo "============================================="
echo ""

# Cria pasta base para montagem
mkdir -p /mnt/pwd_reset

# Detecta partições
particoes=$(lsblk -lo NAME,FSTYPE,SIZE | grep -v "loop" | grep -v "squashfs" | grep -v "iso9660")

echo "Buscando Sistemas Operacionais instalados nos discos..."
echo ""

encontrou_algo=0

# ==================== WINDOWS ====================
for part in $(echo "$particoes" | grep -i "ntfs" | awk '{print $1}'); do
    device="/dev/$part"
    mount_point="/mnt/pwd_reset/win_$part"
    mkdir -p "$mount_point"
    mount -t ntfs-3g "$device" "$mount_point" 2>/dev/null

    sam_path=""
    if [ -f "$mount_point/Windows/System32/config/SAM" ]; then
        sam_path="$mount_point/Windows/System32/config/SAM"
    elif [ -f "$mount_point/windows/system32/config/SAM" ]; then
        sam_path="$mount_point/windows/system32/config/SAM"
    fi

    if [ -n "$sam_path" ]; then
        encontrou_algo=1
        echo "💻 [WINDOWS] Encontrado em $device"
        echo "   Listando usuários do Windows:"
        chntpw -l "$sam_path" | grep -E "^\|" | grep -v "RID" | awk -F'|' '{print "   - " $2}'
        echo ""
        read -p "   Digite o nome do usuário do Windows para RESETAR a senha (ou 'pular'): " win_user
        
        if [ "$win_user" != "pular" ] && [ -n "$win_user" ]; then
            # '1' limpa senha, '2' desbloqueia, 'q' sai, 'y' salva
            printf "1\n2\nq\ny\n" | chntpw -u "$win_user" "$sam_path" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "   ✅ Senha do Windows removida com sucesso para o usuário '$win_user'!"
            else
                echo "   ❌ Erro ao remover senha do Windows."
            fi
        fi
        echo "---------------------------------------------"
    fi
    umount "$mount_point" 2>/dev/null
done

# ==================== LINUX ====================
for part in $(echo "$particoes" | grep -E "ext4|xfs|btrfs" | awk '{print $1}'); do
    device="/dev/$part"
    mount_point="/mnt/pwd_reset/lin_$part"
    mkdir -p "$mount_point"
    mount "$device" "$mount_point" 2>/dev/null

    # Btrfs pode usar subvolumes como "root/" (Fedora) ou "@/" (Ubuntu)
    sys_root="$mount_point"
    if [ -f "$mount_point/root/etc/shadow" ]; then
        sys_root="$mount_point/root"
    elif [ -f "$mount_point/@/etc/shadow" ]; then
        sys_root="$mount_point/@"
    fi

    if [ -f "$sys_root/etc/shadow" ]; then
        encontrou_algo=1
        echo "🐧 [LINUX] Encontrado em $device"
        echo "   Usuários comuns no sistema Linux:"
        awk -F':' '$3 >= 1000 && $3 < 60000 {print "   - " $1}' "$sys_root/etc/passwd"
        echo "   - root"
        echo ""
        read -p "   Digite o nome do usuário Linux para REMOVER a senha (ou 'pular'): " lin_user
        
        if [ "$lin_user" != "pular" ] && [ -n "$lin_user" ]; then
            # Faz chroot e remove a senha do usuário
            chroot "$sys_root" passwd -d "$lin_user" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "   ✅ Senha do Linux removida! O usuário '$lin_user' entrará sem senha."
            else
                echo "   ❌ Erro ao remover senha via chroot (verifique se a arquitetura é compatível)."
            fi
        fi
        echo "---------------------------------------------"
    fi
    umount "$mount_point" 2>/dev/null
done

# ==================== macOS ====================
for part in $(echo "$particoes" | grep -i "apfs\|hfsplus" | awk '{print $1}'); do
    device="/dev/$part"
    mount_point="/mnt/pwd_reset/mac_$part"
    mkdir -p "$mount_point"
    mount "$device" "$mount_point" 2>/dev/null

    if [ -d "$mount_point/var/db" ] || [ -d "$mount_point/private/var/db" ]; then
        encontrou_algo=1
        db_path="$mount_point/var/db"
        [ -d "$mount_point/private/var/db" ] && db_path="$mount_point/private/var/db"

        echo "🍎 [macOS] Encontrado em $device"
        echo "   Para o macOS, não apagamos a senha diretamente."
        echo "   O que fazemos é excluir o arquivo de configuração inicial (.AppleSetupDone)."
        echo "   Isso fará o Mac abrir a tela de boas-vindas novamente e deixar você criar uma NOVA"
        echo "   conta de Administrador (sem perder os arquivos das contas antigas)."
        echo ""
        read -p "   Deseja aplicar o reset no macOS? (s/N): " mac_resp
        
        if [[ "$mac_resp" == "s" || "$mac_resp" == "S" ]]; then
            if [ -f "$db_path/.AppleSetupDone" ]; then
                rm -f "$db_path/.AppleSetupDone"
                echo "   ✅ Arquivo .AppleSetupDone removido!"
                echo "   Reinicie o Mac. Ele abrirá como se fosse novo. Crie um novo usuário."
                echo "   Depois, vá em Preferências do Sistema > Usuários e resete a senha da conta original!"
            else
                echo "   ⚠️ O arquivo .AppleSetupDone não foi encontrado (ou o disco está criptografado com FileVault)."
            fi
        fi
        echo "---------------------------------------------"
    fi
    umount "$mount_point" 2>/dev/null
done

if [ "$encontrou_algo" -eq 0 ]; then
    echo "❌ Nenhum sistema operacional suportado (Windows, Linux ou macOS decriptado) foi encontrado nas partições."
    echo "Verifique se o disco está criptografado (BitLocker, LUKS ou FileVault) ou se está com erros."
fi

echo ""
echo "Concluído!"
