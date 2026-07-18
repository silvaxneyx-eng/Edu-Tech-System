#!/bin/bash
# Menu Técnico Interativo para a ISO Bootável (Fedora Live OS)

# Cores
VERDE='\033[0;32m'
CIANO='\033[0;36m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
NC='\033[0m' # No Color

mostrar_cabecalho() {
    clear
    echo -e "${CIANO}=====================================================${NC}"
    echo -e "${CIANO}             ISO LOUCA — MENU LINUX LIVE OS          ${NC}"
    echo -e "${CIANO}=====================================================${NC}"
    echo ""
}

while true; do
    mostrar_cabecalho
    
    echo -e "  [1] Resetar Senha do Windows (chntpw)"
    echo -e "  [2] Scanner de Vírus Offline (ClamAV)"
    echo -e "  [3] Backup Automático de Perfis Windows"
    echo -e "  [4] Diagnóstico SMART e Discos (smartctl)"
    echo -e "  [5] Informações do Sistema Completa (inxi / lshw)"
    echo -e "  [6] Teste de Estresse da CPU (stress-ng)"
    echo -e "  [7] Abrir GParted (Gerenciador de Partições)"
    echo -e "  [8] Abrir Gerenciador de Arquivos (Nautilus)"
    echo -e "  [0] Sair / Abrir Terminal Bash"
    echo ""
    
    read -p "Escolha uma opção: " opcao
    
    case $opcao in
        1)
            echo -e "\n${AMARELO}Iniciando resetador de senha...${NC}"
            sudo bash "$(dirname "$0")/resetar-senha-automatico.sh"
            ;;
        2)
            echo -e "\n${AMARELO}Iniciando varredura antivírus offline...${NC}"
            sudo bash "$(dirname "$0")/scanner-virus-offline.sh"
            ;;
        3)
            echo -e "\n${AMARELO}Iniciando backup automático de perfis...${NC}"
            sudo bash "$(dirname "$0")/backup-perfil-automatico.sh"
            ;;
        4)
            echo -e "\n${CIANO}--- Saúde dos Discos (SMART) ---${NC}"
            discos=$(lsblk -dlo NAME,TYPE | grep disk | awk '{print $1}')
            for d in $discos; do
                echo -e "\n${AMARELO}Verificando /dev/$d:${NC}"
                sudo smartctl -H "/dev/$d"
            done
            ;;
        5)
            echo -e "\n${CIANO}--- Informações do Hardware ---${NC}"
            if command -v inxi &> /dev/null; then
                inxi -F
            else
                sudo lshw -short
            fi
            ;;
        6)
            echo -e "\n${AMARELO}Rodando teste de estresse de 30 segundos na CPU...${NC}"
            stress-ng --cpu 0 --timeout 30s --metrics-brief
            ;;
        7)
            echo -e "\n${AMARELO}Abrindo GParted em background...${NC}"
            sudo gparted &>/dev/null &
            ;;
        8)
            echo -e "\n${AMARELO}Abrindo Nautilus...${NC}"
            nautilus &>/dev/null &
            ;;
        0)
            echo -e "\n${VERDE}Saindo para o terminal...${NC}"
            break
            ;;
        *)
            echo -e "\n${VERMELHO}Opção inválida!${NC}"
            sleep 1
            continue
            ;;
    esac
    
    echo -e "\n${VERDE}Ação finalizada.${NC} Pressione [Enter] para voltar ao menu."
    read
done
