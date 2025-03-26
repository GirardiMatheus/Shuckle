#!/bin/bash

# Carrega variáveis de ambiente de forma segura
if [ -f .env ]; then
    set -o allexport
    source .env 2>/dev/null
    set +o allexport
else
    echo "Arquivo .env não encontrado. Usando configurações padrão."
fi

# Definir valores padrão caso não sejam carregados
ALLOWED_PORTS=${ALLOWED_PORTS:-"22 80 443"}
BLOCKED_PORTS=${BLOCKED_PORTS:-"23 21 137 138 139 445"}
NETWORK_INTERFACE=${NETWORK_INTERFACE:-"eth0"}
TRUSTED_IPS=${TRUSTED_IPS:-""}
LOG_DROPPED=${LOG_DROPPED:-"yes"}
IPTABLES_SAVE_FILE=${IPTABLES_SAVE_FILE:-"/etc/iptables.rules"}
VERBOSE=${VERBOSE:-"yes"}

# Função para configurar o firewall
configure_firewall() {
    # Limpar todas as regras existentes
    iptables -F
    iptables -X
    iptables -Z

    # Políticas padrão
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    # Permitir loopback
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    # Permitir conexões estabelecidas e relacionadas
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Permitir ICMP (ping)
    iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

    # Permitir portas essenciais
    for port in $ALLOWED_PORTS; do
        iptables -A INPUT -p tcp --dport $port -j ACCEPT
        [ "$VERBOSE" = "yes" ] && echo "Porta $port/tcp permitida"
    done

    # Bloquear portas específicas
    for port in $BLOCKED_PORTS; do
        iptables -A INPUT -p tcp --dport $port -j DROP
        iptables -A INPUT -p udp --dport $port -j DROP
        [ "$VERBOSE" = "yes" ] && echo "Porta $port/tcp e $port/udp bloqueada"
    done

    # Permitir IPs confiáveis
    for ip in $TRUSTED_IPS; do
        iptables -A INPUT -s $ip -j ACCEPT
        [ "$VERBOSE" = "yes" ] && echo "IP $ip permitido"
    done

    # Logar tentativas de acesso bloqueado
    if [ "$LOG_DROPPED" = "yes" ]; then
        iptables -A INPUT -j LOG --log-prefix "IPTABLES DROPPED: " --log-level 4
    fi

    # Salvar regras
    save_rules

    echo "Firewall configurado com sucesso!"
}

# Função para salvar regras
save_rules() {
    if [ -n "$IPTABLES_SAVE_FILE" ]; then
        iptables-save > $IPTABLES_SAVE_FILE
        echo "Regras salvas em $IPTABLES_SAVE_FILE"
    else
        echo "Variável IPTABLES_SAVE_FILE não definida. Regras não foram salvas."
    fi
}

# Função para restaurar regras
restore_rules() {
    if [ -f "$IPTABLES_SAVE_FILE" ]; then
        iptables-restore < $IPTABLES_SAVE_FILE
        echo "Regras restauradas de $IPTABLES_SAVE_FILE"
    else
        echo "Arquivo de regras $IPTABLES_SAVE_FILE não encontrado."
    fi
}

# Função para mostrar status
default_policy="$(iptables -L INPUT --line-numbers | grep 'Chain INPUT (policy' | awk '{print $4}')"
show_status() {
    echo "=== Regras do Firewall ==="
    iptables -L -v -n
    echo ""
    echo "=== Regras NAT ==="
    iptables -t nat -L -v -n
}

# Menu principal
case "$1" in
    start)
        configure_firewall
        ;;
    stop)
        iptables -F
        iptables -P INPUT ACCEPT
        iptables -P FORWARD ACCEPT
        iptables -P OUTPUT ACCEPT
        echo "Firewall desativado. Todas as conexões estão permitidas."
        ;;
    save)
        save_rules
        ;;
    restore)
        restore_rules
        ;;
    status)
        show_status
        ;;
    *)
        echo "Uso: $0 {start|stop|save|restore|status}"
        exit 1
        ;;
esac

exit 0