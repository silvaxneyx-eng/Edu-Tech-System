#!/bin/bash
# ============================================================
# Menu Técnico Gráfico (Zenity) - EduTechAnderlineNet
# ISO Louca — Debian Live / LXQt Dark
# ============================================================

SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

show_menu() {
    local choice
    choice=$(zenity --list \
        --title="🔧 Menu Técnico - EduTechAnderlineNet" \
        --text="Selecione a ferramenta de manutenção que deseja executar:" \
        --width=640 --height=480 \
        --column="Ícone" --column="Opção" --column="Descrição" \
        "🔑" "Resetar Senha" "Resetar a senha de contas do Windows local" \
        "🛡️" "Scanner de Vírus" "Varredura antivírus offline com ClamAV" \
        "💾" "Backup de Perfil" "Fazer backup automático das pastas do Windows" \
        "📶" "Conectar à Rede (SMB)" "Montar pasta compartilhada da rede local/NAS" \
        "💽" "Saúde do Disco (SMART)" "Verificar integridade física e erros do HD/SSD" \
        "ℹ️" "Info do Hardware" "Mostrar detalhes técnicos da máquina (Processador, RAM, etc)" \
        "🗃️" "GParted (Partições)" "Abrir o editor de partições de disco" \
        "📁" "Arquivos (PCManFM)" "Abrir o gerenciador de arquivos como root" \
        "💻" "Abrir Terminal" "Abrir terminal do sistema técnico" \
        --ok-label="Executar" --cancel-label="Sair")

    if [ $? -ne 0 ]; then
        exit 0
    fi

    case "$choice" in
        "Resetar Senha")
            qterminal --title "🔑 Resetar Senha Windows" -e bash -c "sudo bash '$SCRIPT_DIR/resetar-senha-automatico.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Scanner de Vírus")
            qterminal --title "🛡️ Scanner de Vírus ClamAV" -e bash -c "sudo bash '$SCRIPT_DIR/scanner-virus-offline.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Backup de Perfil")
            qterminal --title "💾 Backup de Perfil Windows" -e bash -c "sudo bash '$SCRIPT_DIR/backup-perfil-automatico.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Conectar à Rede (SMB)")
            bash "$SCRIPT_DIR/conectar-rede.sh"
            ;;
        "Saúde do Disco (SMART)")
            qterminal --title "💽 Saúde do Disco (SMART)" -e bash -c "sudo bash '$SCRIPT_DIR/diagnostico-discos.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Info do Hardware")
            qterminal --title "ℹ️ Informações de Hardware" -e bash -c "echo -e '--- Informações de Hardware ---\n'; inxi -F 2>/dev/null || sudo lshw -short; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "GParted (Partições)")
            sudo gparted &
            ;;
        "Arquivos (PCManFM)")
            sudo pcmanfm-qt &
            ;;
        "Abrir Terminal")
            qterminal &
            ;;
    esac
}

# Loop para manter o menu aberto até clicar em Sair
while true; do
    show_menu
done
