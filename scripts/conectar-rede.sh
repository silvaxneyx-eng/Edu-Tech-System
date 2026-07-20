#!/bin/bash
# ============================================================
# Script de Conexão à Pasta Compartilhada na Rede (SMB/CIFS)
# EduTechAnderlineNet - ISO Técnico
# Compatível com GNOME (Nautilus) e LXQt (PCManFM-Qt)
# ============================================================

# Detecta o gerenciador de arquivos
if command -v nautilus &>/dev/null; then
    FILE_MGR="nautilus"
elif command -v pcmanfm-qt &>/dev/null; then
    FILE_MGR="pcmanfm-qt"
else
    FILE_MGR="xdg-open"
fi

# Cria o ponto de montagem na ISO
mkdir -p /mnt/rede_local

# Pergunta o IP ou Nome do Servidor/Computador Windows
server_ip=$(zenity --entry \
    --title="📶 Conectar à Rede - Servidor/PC" \
    --text="Digite o endereço IP do computador na rede local:\n(Ex: 192.168.1.100 ou 10.0.0.5)" \
    --entry-text="192.168.1.")

if [ -z "$server_ip" ]; then
    exit 0
fi

# Pergunta o nome da pasta compartilhada
share_name=$(zenity --entry \
    --title="📂 Conectar à Rede - Compartilhamento" \
    --text="Digite o nome exato da Pasta Compartilhada no Windows/NAS:\n(Ex: Backup, Publico, Dados)" \
    --entry-text="")

if [ -z "$share_name" ]; then
    exit 0
fi

# Pergunta usuário de rede (opcional)
username=$(zenity --entry \
    --title="👤 Conectar à Rede - Usuário" \
    --text="Digite o nome de usuário da rede local (ou deixe em branco para anônimo):" \
    --entry-text="")

# Pergunta senha (opcional)
if [ -n "$username" ]; then
    password=$(zenity --password \
        --title="🔑 Conectar à Rede - Senha" \
        --text="Digite a senha para acessar o compartilhamento:")
else
    password=""
fi

echo "📶 Tentando conectar a: //$server_ip/$share_name..."

# Desmonta se já existir algo lá
sudo umount -f /mnt/rede_local 2>/dev/null || true

# Tenta montar a partição de rede
if [ -n "$username" ]; then
    # Montagem com login e senha
    sudo mount -t cifs -o username="$username",password="$password",iocharset=utf8,vers=3.0,uid=1000,gid=1000 "//$server_ip/$share_name" /mnt/rede_local
else
    # Montagem anônima/sem login
    sudo mount -t cifs -o guest,iocharset=utf8,vers=3.0,uid=1000,gid=1000 "//$server_ip/$share_name" /mnt/rede_local
fi

if [ $? -eq 0 ]; then
    zenity --info \
        --title="✓ Sucesso!" \
        --text="Pasta de rede montada com sucesso em:\n📂 /mnt/rede_local\n\nAbrindo o gerenciador de arquivos..."
    sudo chown -R jardson:jardson /mnt/rede_local 2>/dev/null || true
    $FILE_MGR /mnt/rede_local &
else
    zenity --error \
        --title="❌ Erro na Conexão" \
        --text="Não foi possível conectar a //$server_ip/$share_name.\n\nVerifique:\n1. Se o IP do servidor está correto.\n2. Se a rede Wi-Fi/Cabo está conectada.\n3. Se o usuário e senha de rede estão corretos."
fi
