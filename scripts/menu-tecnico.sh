#!/bin/bash
# ============================================================
# Menu Técnico Gráfico (Zenity) - EduTechAnderlineNet
# ISO Louca — Fedora 44 / GNOME
# ============================================================

SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Detecta o terminal disponível
if command -v gnome-terminal &>/dev/null; then
    TERM_CMD="gnome-terminal --wait --"
elif command -v qterminal &>/dev/null; then
    TERM_CMD="qterminal -e"
else
    TERM_CMD="xterm -e"
fi

# Detecta o gerenciador de arquivos disponível
if command -v nautilus &>/dev/null; then
    FILE_MGR="nautilus"
elif command -v pcmanfm-qt &>/dev/null; then
    FILE_MGR="pcmanfm-qt"
else
    FILE_MGR="xdg-open"
fi

show_menu() {
    local choice
    choice=$(zenity --list \
        --title="🔧 Menu Técnico - EduTechAnderlineNet" \
        --text="Selecione a ferramenta de manutenção que deseja executar:" \
        --width=700 --height=560 \
        --column="Ícone" --column="Opção" --column="Descrição" \
        "🔌" "Montar Discos" "Detectar e montar automaticamente todos os discos do cliente" \
        "🔑" "Resetar Senha" "Resetar a senha de contas do Windows local" \
        "🛡️" "Scanner de Vírus" "Varredura antivírus offline com ClamAV" \
        "💾" "Backup de Perfil" "Fazer backup automático das pastas do Windows" \
        "📶" "Conectar à Rede (SMB)" "Montar pasta compartilhada da rede local/NAS" \
        "💽" "Saúde do Disco (SMART)" "Verificar integridade física e erros do HD/SSD" \
        "🔧" "Reparo de Boot" "Regravar MBR/VBR do Windows com ms-sys" \
        "🧹" "Limpeza Segura" "Wipe completo do disco antes de descarte/venda" \
        "ℹ️" "Info do Hardware" "Mostrar detalhes técnicos da máquina" \
        "🗃️" "GParted (Partições)" "Abrir o editor de partições de disco" \
        "📁" "Arquivos" "Abrir o gerenciador de arquivos como root" \
        "💻" "Abrir Terminal" "Abrir terminal do sistema técnico" \
        --ok-label="Executar" --cancel-label="Sair")

    if [ $? -ne 0 ]; then
        exit 0
    fi

    case "$choice" in
        "Montar Discos")
            $TERM_CMD bash -c "sudo bash '$SCRIPT_DIR/montar-discos-automatico.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Resetar Senha")
            $TERM_CMD bash -c "sudo bash '$SCRIPT_DIR/resetar-senha-automatico.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Scanner de Vírus")
            $TERM_CMD bash -c "sudo bash '$SCRIPT_DIR/scanner-virus-offline.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Backup de Perfil")
            $TERM_CMD bash -c "sudo bash '$SCRIPT_DIR/backup-perfil-automatico.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Conectar à Rede (SMB)")
            bash "$SCRIPT_DIR/conectar-rede.sh"
            ;;
        "Saúde do Disco (SMART)")
            $TERM_CMD bash -c "sudo bash '$SCRIPT_DIR/diagnostico-discos.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Reparo de Boot")
            $TERM_CMD bash -c "sudo bash '$SCRIPT_DIR/reparo-boot-windows.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Limpeza Segura")
            zenity --warning --title="⚠️ ATENÇÃO" --text="Este procedimento APAGA TODOS os dados do disco escolhido de forma IRRECUPERÁVEL!\n\nTem certeza que deseja continuar?" --ok-label="Sim, continuar" 2>/dev/null
            if [ $? -eq 0 ]; then
                $TERM_CMD bash -c "sudo bash '$SCRIPT_DIR/limpeza-segura-disco.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            fi
            ;;
        "Info do Hardware")
            $TERM_CMD bash -c "echo -e '--- Informações de Hardware ---\n'; inxi -F 2>/dev/null || sudo lshw -short; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "GParted (Partições)")
            pkexec gparted &
            ;;
        "Arquivos")
            pkexec $FILE_MGR /mnt/clientes &
            ;;
        "Abrir Terminal")
            $TERM_CMD &
            ;;
    esac
}

# Loop para manter o menu aberto até clicar em Sair
while true; do
    show_menu
done
