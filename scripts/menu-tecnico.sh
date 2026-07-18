#!/bin/bash
# ============================================================
# Menu Técnico Gráfico (Zenity) - EduTechAnderlineNet
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_menu() {
    local choice
    choice=$(zenity --list \
        --title="🔧 Menu Técnico - EduTechAnderlineNet" \
        --text="Selecione a ferramenta de manutenção que deseja executar:" \
        --width=620 --height=450 \
        --column="Ícone" --column="Opção" --column="Descrição" \
        "🔑" "Resetar Senha" "Resetar a senha de contas do Windows local" \
        "🛡️" "Scanner de Vírus" "Varredura antivírus offline com ClamAV" \
        "💾" "Backup de Perfil" "Fazer backup automático das pastas do Windows" \
        "💽" "Saúde do Disco (SMART)" "Verificar integridade física e erros do HD/SSD" \
        "ℹ️" "Info do Hardware" "Mostrar detalhes técnicos da máquina (Processador, RAM, etc)" \
        "🗃️" "GParted (Partições)" "Abrir o editor de partições de disco" \
        "📁" "Nautilus (Arquivos)" "Abrir o gerenciador de arquivos como root" \
        "💻" "Abrir Terminal" "Abrir terminal do sistema técnico" \
        --ok-label="Executar" --cancel-label="Sair")

    if [ $? -ne 0 ]; then
        exit 0
    fi

    case "$choice" in
        "Resetar Senha")
            gnome-terminal --title="🔑 Resetar Senha Windows" -- bash -c "sudo bash '$SCRIPT_DIR/resetar-senha-automatico.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Scanner de Vírus")
            gnome-terminal --title="🛡️ Scanner de Vírus ClamAV" -- bash -c "sudo bash '$SCRIPT_DIR/scanner-virus-offline.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Backup de Perfil")
            gnome-terminal --title="💾 Backup de Perfil Windows" -- bash -c "sudo bash '$SCRIPT_DIR/backup-perfil-automatico.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Saúde do Disco (SMART)")
            gnome-terminal --title="💽 Saúde do Disco (SMART)" -- bash -c "sudo bash '$SCRIPT_DIR/diagnostico-discos.sh'; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "Info do Hardware")
            gnome-terminal --title="ℹ️ Informações de Hardware" -- bash -c "echo -e '--- Informações de Hardware ---\n'; inxi -F 2>/dev/null || sudo lshw -short; echo -e '\nPressione ENTER para fechar...'; read"
            ;;
        "GParted (Partições)")
            sudo gparted &
            ;;
        "Nautilus (Arquivos)")
            sudo nautilus &
            ;;
        "Abrir Terminal")
            gnome-terminal &
            ;;
    esac
}

# Loop para manter o menu aberto até clicar em Sair
while true; do
    show_menu
done
