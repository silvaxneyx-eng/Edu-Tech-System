#!/bin/bash
# ============================================================
# EduTech - Scanner de Rede Local
# Mapeia todos os IPs e dispositivos na rede
# ============================================================

echo "============================================="
echo "   ISO LOUCA - SCANNER DE REDE LOCAL (NMAP)  "
echo "============================================="
echo ""

if ! command -v nmap &> /dev/null; then
    echo "⚠️ nmap não instalado. Execute: sudo dnf install nmap"
    exit 1
fi

echo "Interfaces de rede detectadas:"
ip -br a | grep -v "lo"
echo ""

# Pega o IP local e a sub-rede (ex: 192.168.1.0/24)
subnet=$(ip -o -f inet addr show | grep -v "lo" | awk '{print $4}' | head -n 1)

if [ -z "$subnet" ]; then
    echo "❌ Nenhuma conexão de rede detectada."
    exit 1
fi

echo "Sua sub-rede atual: $subnet"
read -p "Pressione ENTER para escanear a rede ou digite uma sub-rede diferente (ex: 10.0.0.0/24): " custom_sub

if [ -n "$custom_sub" ]; then
    subnet="$custom_sub"
fi

echo ""
echo "🔍 Iniciando varredura rápida (pode demorar alguns segundos)..."
echo "------------------------------------------------------------"
sudo nmap -sn "$subnet" | grep -v "Starting" | grep -v "Host is up"
echo "------------------------------------------------------------"
echo ""
echo "✅ Escaneamento concluído. Esses são os dispositivos conectados."
echo ""
read -p "Deseja verificar portas abertas em algum desses IPs? (Digite o IP ou ENTER para sair): " target_ip

if [ -n "$target_ip" ]; then
    echo "🔍 Escaneando portas abertas em $target_ip..."
    sudo nmap -F "$target_ip"
    echo ""
    echo "✅ Concluído!"
fi
