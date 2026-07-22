#!/usr/bin/env bash
# ============================================================
# ISO LOuca — Automação de Pendrive Multiboot Ventoy
# Prepara a estrutura completa com ISO LOuca + Ghost Spectre Win 11
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}   ⚙️ ISO LOuca - Configuração de Pendrive Ventoy Multiboot ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

if [ "$#" -ne 1 ]; then
    echo -e "${YELLOW}Uso: sudo $0 /ponto/de/montagem/do/pendrive${NC}"
    echo -e "Exemplo: sudo $0 /run/media/jardson/VENTOY"
    echo ""
    exit 1
fi

USB_PATH="$1"

if [ ! -d "$USB_PATH" ]; then
    echo -e "${RED}[!] O ponto de montagem '$USB_PATH' não existe ou o pendrive não está montado.${NC}"
    exit 1
fi

PROJ_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${GREEN}[+] Criando estrutura de pastas no Pendrive Ventoy em: $USB_PATH${NC}"

# 1. Estrutura de pastas de ISOs e Ferramentas
mkdir -p "$USB_PATH/ISOs/Windows"
mkdir -p "$USB_PATH/ISOs/Linux"
mkdir -p "$USB_PATH/ISOs/Tecnico"
mkdir -p "$USB_PATH/ISOs/Recovery"
mkdir -p "$USB_PATH/ISOs/Utilitarios"
mkdir -p "$USB_PATH/Ghost Toolbox"
mkdir -p "$USB_PATH/Tools"
mkdir -p "$USB_PATH/Drivers/Intel"
mkdir -p "$USB_PATH/Drivers/AMD"
mkdir -p "$USB_PATH/Drivers/NVIDIA"
mkdir -p "$USB_PATH/Drivers/Realtek"
mkdir -p "$USB_PATH/Scripts"
mkdir -p "$USB_PATH/ventoy"

# 2. Copiar arquivos de configuração do Ventoy
echo -e "${YELLOW}[+] Copiando configurações do Ventoy (ventoy.json e autounattend.xml)...${NC}"
cp -f "$PROJ_DIR/config/ventoy.json" "$USB_PATH/ventoy/ventoy.json" 2>/dev/null || true
cp -f "$PROJ_DIR/config/autounattend.xml" "$USB_PATH/ventoy/autounattend.xml" 2>/dev/null || true

# 3. Copiar scripts e utilitários da ISO LOuca
echo -e "${YELLOW}[+] Copiando scripts e arquivos do projeto...${NC}"
cp -rf "$PROJ_DIR/scripts/"* "$USB_PATH/Scripts/" 2>/dev/null || true
cp -f "$PROJ_DIR/LEIA-ME.txt" "$USB_PATH/LEIA-ME.txt" 2>/dev/null || true
cp -f "$PROJ_DIR/ferramentas.json" "$USB_PATH/ferramentas.json" 2>/dev/null || true
cp -f "$PROJ_DIR/README.md" "$USB_PATH/README-Projeto.md" 2>/dev/null || true

# 4. Copiar ISO LOuca se estiver compilada na pasta build/
if [ -f "$PROJ_DIR/build/ISO_LOUCA_BOOT.iso" ]; then
    echo -e "${GREEN}[+] ISO LOuca compilada encontrada! Copiando para /ISOs/Tecnico/...${NC}"
    cp -f "$PROJ_DIR/build/ISO_LOUCA_BOOT.iso" "$USB_PATH/ISOs/Tecnico/ISO_LOUCA_BOOT.iso"
else
    echo -e "${YELLOW}[i] ISO_LOUCA_BOOT.iso ainda não foi gerada em build/.${NC}"
    echo -e "    Baixe a ISO compilada do GitHub Actions e coloque em: $USB_PATH/ISOs/Tecnico/"
fi

# 5. Instruções finais
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}   ✓ Pendrive Ventoy configurado com sucesso!               ${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo -e "${YELLOW}Próximos passos para completar o seu Pendrive Técnico:${NC}"
echo -e "  1. Baixe o Windows 11 Ghost Spectre (.iso) e salve em:"
echo -e "     ${GREEN}$USB_PATH/ISOs/Windows/Win11_Ghost_Spectre.iso${NC}"
echo -e "  2. Baixe o Windows 10 Pro / Linux (.iso) e coloque em:"
echo -e "     ${GREEN}$USB_PATH/ISOs/Windows/ ou $USB_PATH/ISOs/Linux/${NC}"
echo -e "  3. Insira o pendrive no computador de destino e selecione o boot no Ventoy!${NC}"
echo ""
