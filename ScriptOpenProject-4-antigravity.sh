#!/bin/bash
set -e

# === 1. Saisie personnalisée du nom de domaine ===
if [ -n "$1" ]; then
  DOMAIN="$1"
else
  echo "Voulez-vous définir un nom de domaine pour OpenProject ?"
  echo "   1) Je saisis un nom de domaine personnalisé"
  echo "   2) Pas de nom de domaine (déploiement local/test)"
  read -p "Votre choix (1/2) : " choix
  if [ "$choix" = "1" ]; then
    read -p "Entrez le nom de domaine (ex: openproject.mondomaine.fr) : " DOMAIN
  else
    DOMAIN=""
  fi
fi

if [ -z "$DOMAIN" ]; then
  echo "[INFO] Aucun nom de domaine fourni : certaines fonctions HTTPS/OpenProject limitées."
else
  echo "[INFO] Le nom de domaine utilisé sera : $DOMAIN"
fi

# === 2. Vérification des prérequis système (Debian 12 ou supérieure) ===
DEBVER=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$DEBVER" -lt 12 ]; then
  echo "[ERREUR] Ce script nécessite Debian 12 ou plus. Version actuelle : $DEBVER"
  exit 1
fi

if [ "$(uname -m)" != "x86_64" ]; then
  echo "[ERREUR] Système non 64 bits. Script interrompu."
  exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo "[ERREUR] Ce script doit être lancé en tant que root."
  exit 1
fi

if ! ping -c1 -W2 8.8.8.8 >/dev/null 2>&1; then
  echo "[ERREUR] Pas de connexion Internet détectée. Abandon."
  exit 1
fi

# === 3. Vérification des ports et conflits locaux ===
for p in 22 80 443; do
  if ! ss -tuln | grep -q ":$p "; then
    echo "[ATTENTION] Port $p non à l'écoute localement. Ouvrez-le dans le firewall/VM si nécessaire."
  fi
done

for p in 80 443; do
  # Uniquement bloquant si un serveur inconnu écoute
  if ss -ltnp | grep -q ":$p "; then
    if ! ss -ltnp | grep ":$p " | grep -Eq 'apache2|nginx'; then
      echo "[ERREUR] Un processus serveur inconnu écoute déjà sur le port $p. Abandon."
      ss -ltnp | grep ":$p "
      exit 1
    fi
  fi
done

# === 4. Test HTTP/HTTPS réel du domaine fourni ===
if [ -n "$DOMAIN" ]; then
  if curl -Is --max-time 5 http://$DOMAIN | grep -q '200 OK'; then
    echo "[OK] HTTP ouvert sur $DOMAIN."
  else
    echo "[AVERTISSEMENT] HTTP fermé/inaccessible sur $DOMAIN. Vérifiez DNS/firewall."
  fi
  if curl -Is --max-time 5 https://$DOMAIN | grep -q -e '200' -e '301' -e '302'; then
    echo "[OK] HTTPS ouvert sur $DOMAIN."
  else
    echo "[AVERTISSEMENT] HTTPS fermé/inaccessible sur $DOMAIN. Certificat ou firewall manquant ?"
  fi
fi

# === 5. Mise à jour système et installation dépendances (PostgreSQL/Apache) ===
apt update && apt upgrade -y
# OpenProject nécessite PostgreSQL, pas MariaDB/PHP
apt install -y apache2 postgresql libpq-dev unzip wget iptables-persistent ca-certificates gpg apt-transport-https fail2ban

# === 6. Sécurisation iptables (firewall minimal) ===
PORT_SSH=22

# Sauvegarde des règles existantes si elles existent
if [ -f /etc/iptables/rules.v4 ]; then
    cp /etc/iptables/rules.v4 /etc/iptables/rules.v4.bak.$(date +%F_%T)
    echo "[INFO] Règles iptables existantes sauvegardées."
fi

cat <<EOF > /etc/iptables/rules.v4
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp --dport $PORT_SSH -j ACCEPT
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT
# ICMP (Ping) est utile pour le diagnostic
-A INPUT -p icmp -j ACCEPT
COMMIT
EOF
iptables-restore < /etc/iptables/rules.v4
netfilter-persistent save

# === 7. Protection Fail2ban ===
if [ ! -f /etc/fail2ban/jail.local ]; then
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
fi

# On vérifie si la config existe déjà pour éviter les doublons
if ! grep -q "\[apache-auth\]" /etc/fail2ban/jail.local; then
cat <<EOF >> /etc/fail2ban/jail.local

[apache-auth]
enabled  = true
port     = http,https
filter   = apache-auth
logpath  = /var/log/apache*/*error.log
maxretry = 3

[sshd]
enabled = true
port    = $PORT_SSH
filter  = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF
fi
systemctl enable fail2ban
systemctl restart fail2ban

# === 8. Installation OpenProject (liens directs) ===
echo "[INSTALLATION] Dépôt et paquet OpenProject Debian (16.x)"
apt install -y apt-transport-https ca-certificates wget gpg
wget -qO- https://dl.packager.io/srv/opf/openproject/key | gpg --dearmor > /etc/apt/trusted.gpg.d/packager-io.gpg
wget -O /etc/apt/sources.list.d/openproject.list \
  https://dl.packager.io/srv/opf/openproject/stable/16/installer/debian/12.repo
apt update
apt install -y openproject

# === 9. Configuration interactive OpenProject (guide à l'utilisateur) ===
echo "[CONFIGURATION] Pour finir l'installation :"
echo "  Lancez la commande : openproject configure"
echo "  Répondez aux questions : domaine ($DOMAIN), Apache, SSL, email, etc."
echo "  Documentez les choix pour la maintenance."

# === 10. Vérification des services installés ===
# === 10. Vérification des services installés ===
systemctl status apache2 postgresql fail2ban openproject || true

echo -e "\nINSTALLATION AUTOMATIQUE TERMINÉE. Vérifiez l'accès OpenProject en HTTP/HTTPS sur : $DOMAIN ou l'IP.\n"
