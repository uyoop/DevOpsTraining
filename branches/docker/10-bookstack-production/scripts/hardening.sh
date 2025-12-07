#!/bin/bash

# ==========================================
# Script de hardening système
# ==========================================

set -e

echo "🔒 Durcissement du système..."

# Désactiver IPv6 si non utilisé
if [ ! -f /etc/sysctl.d/99-disable-ipv6.conf ]; then
    echo "Désactivation IPv6..."
    cat << EOF | sudo tee /etc/sysctl.d/99-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
    sudo sysctl -p /etc/sysctl.d/99-disable-ipv6.conf
fi

# Configurer le kernel pour la sécurité
if [ ! -f /etc/sysctl.d/99-security.conf ]; then
    echo "Configuration sécurité kernel..."
    cat << EOF | sudo tee /etc/sysctl.d/99-security.conf
# Protection contre SYN flood
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 4096

# Désactiver le routage IP
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Protection contre IP spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignorer les paquets ICMP redirect
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# Ignorer les broadcast pings
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Protection contre bad error messages
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Log suspicious packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
EOF
    sudo sysctl -p /etc/sysctl.d/99-security.conf
fi

# Configuration Fail2Ban pour Docker
if [ -d /etc/fail2ban ]; then
    echo "Configuration Fail2Ban..."
    cat << EOF | sudo tee /etc/fail2ban/jail.d/docker-bookstack.conf
[sshd]
enabled = true
maxretry = 3
bantime = 3600

[traefik-auth]
enabled = true
port = http,https
filter = traefik-auth
logpath = /var/log/traefik/access.log
maxretry = 5
bantime = 3600
EOF

    cat << EOF | sudo tee /etc/fail2ban/filter.d/traefik-auth.conf
[Definition]
failregex = ^<HOST> \- \S+ \[\] \"(GET|POST|HEAD) .+\" 401 .+$
            ^<HOST> \- \S+ \[\] \"(GET|POST|HEAD) .+\" 403 .+$
ignoreregex =
EOF

    sudo systemctl restart fail2ban
    echo "✅ Fail2Ban configuré"
fi

# Configurer les logs
echo "Configuration des logs..."
sudo mkdir -p /var/log/traefik
sudo chown -R 1000:1000 /var/log/traefik

# Désactiver les services inutiles
echo "Désactivation des services inutiles..."
sudo systemctl disable --now avahi-daemon 2>/dev/null || true
sudo systemctl disable --now cups 2>/dev/null || true

# Configuration SSH hardening
if [ -f /etc/ssh/sshd_config ]; then
    echo "Durcissement SSH..."
    sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sudo systemctl reload sshd
    echo "✅ SSH durci"
fi

# Installation et configuration de auditd
if ! command -v auditctl >/dev/null 2>&1; then
    echo "Installation auditd..."
    sudo apt update
    sudo apt install -y auditd audispd-plugins
    sudo systemctl enable auditd
    sudo systemctl start auditd
    echo "✅ auditd installé"
fi

echo ""
echo "✅ Hardening système terminé !"
echo ""
echo "📝 Actions supplémentaires recommandées :"
echo "1. Configurer des clés SSH pour tous les utilisateurs"
echo "2. Mettre en place une politique de mots de passe forts"
echo "3. Activer SELinux ou AppArmor"
echo "4. Configurer un système de détection d'intrusion (AIDE, OSSEC)"
echo "5. Mettre en place une rotation des logs"
