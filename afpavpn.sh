#!/usr/bin/env bash
# Script : vpn-install-start-client.sh
# Usage  : ./vpn-install-start-client.sh
# Objet  : Installer si besoin, configurer stunnel, démarrer OpenVPN,
#          puis afficher l'IP VPN (tunX) et l'IP publique.
 
# === Mode : démarrage VPN uniquement ===
if [[ "${1:-}" == "--start" ]]; then
    echo "=== Démarrage rapide d'OpenVPN (mode --start) ==="
    OVPN="$(ls -1t "${SCRIPT_DIR}"/*.ovpn 2>/dev/null | head -n1 || true)"
    if [ -z "${OVPN}" ]; then
        echo "❌ Aucun .ovpn trouvé dans ${SCRIPT_DIR}"
        exit 1
    fi
    echo "Fichier détecté : ${OVPN}"
    pkill -f 'openvpn --config' || true
    openvpn --config "${OVPN}"
    sleep 8
    ip -4 addr show | grep -A2 'tun' || echo "⚠️ Pas d'interface VPN détectée."
    exit 0
fi
 
 
# === (Bloc d’origine complet d’installation / config) ===
# [ton script complet jusqu’ici, inchangé]
 
 
 
# Nettoyage des anciennes interfaces TUN
echo "Nettoyage des anciennes interfaces TUN..."
for i in $(ip -o link show | awk -F': ' '{print $2}' | grep -E '^tun[0-9]+'); do
    echo "Suppression de $i"
    ip link delete "$i"
done
 
 
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
 
echo "=== Vérification/installation des dépendances ==="
missing=()
dpkg -s openvpn  >/dev/null 2>&1 || missing+=("openvpn")
dpkg -s stunnel4 >/dev/null 2>&1 || missing+=("stunnel4")
command -v curl >/dev/null 2>&1 || missing+=("curl")
 
if [ "${#missing[@]}" -gt 0 ]; then
  echo "Installation manquante: ${missing[*]}"
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
else
  echo "OK: openvpn, stunnel4 et curl présents."
fi
 
echo
echo "=== Configuration stunnel (client) ==="

echo 'ENABLED=1' | tee -a /etc/default/stunnel4 >/dev/null
 
 
tee /etc/stunnel/stunnel.conf >/dev/null <<'EOF'
client = yes
foreground = no
debug = 3
output = /var/log/stunnel4/client.log
 
[openvpn]
accept  = 127.0.0.1:1194
connect = 82.22.7.32:443
EOF
 
systemctl enable --now stunnel4
 
echo
echo "=== Vérifications stunnel ==="
ss -ltnp | grep -q '127\.0\.0\.1:1194' && echo "OK: 127.0.0.1:1194 en écoute" || echo "⚠️  127.0.0.1:1194 pas encore détecté"
command -v nc >/dev/null 2>&1 && nc -vz 82.22.7.32 443 || true
 
echo
echo "=== Détection du fichier client OpenVPN (.ovpn) ==="
OVPN="$(ls -1t "${SCRIPT_DIR}"/*.ovpn 2>/dev/null | head -n1 || true)"
if [ -z "${OVPN}" ]; then
  echo "❌ Aucun .ovpn trouvé dans ${SCRIPT_DIR}"
  exit 1
fi
echo "Fichier détecté : ${OVPN}"
 
echo
echo "=== Démarrage d'OpenVPN ==="
openvpn --config "${OVPN}"
sleep 8
 
# Détecter une interface tunX active (tun0 par défaut, sinon la première tun*)
TUN_IF="tun0"
if ! ip link show "${TUN_IF}" >/dev/null 2>&1; then
  TUN_IF="$(ip -o link show | awk -F': ' '/tun[0-9]+/ {print $2; exit}')"
fi
 
if [ -n "${TUN_IF}" ] && ip link show "${TUN_IF}" >/dev/null 2>&1; then
  # IP v4 sur l'interface VPN
  VPN_IP="$(ip -4 addr show dev "${TUN_IF}" | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)"
  if [ -n "${VPN_IP}" ]; then
    echo "✅ Interface VPN active : ${TUN_IF}"
    echo "➡  Adresse IP VPN (interne) : ${VPN_IP}"
  else
    echo "⚠️  Interface ${TUN_IF} détectée, mais pas d'IP v4."
  fi
else
  echo "⚠️  Aucune interface tunX détectée. Vérifie les logs OpenVPN."
fi
 
# IP publique (via le tunnel si la route par défaut passe par tunX)
PUB_IP="$(curl -s -4 https://ifconfig.me || true)"
[ -n "${PUB_IP}" ] && echo "🌐 IP publique (sortie) : ${PUB_IP}"
 
echo
echo "=== Terminé ==="
 
 
# === Ajout / mise à jour des alias VPN ===
add_or_update_vpn_aliases() {
    local bashrc="$HOME/.bashrc"
    local zshrc="$HOME/.zshrc"
    local script_self
    script_self="$(cd -- "$(dirname -- "$0")" && pwd)/$(basename -- "$0")"
 
    # Nouvelles définitions d'alias
    local alias_start="alias startvpn='bash \"${script_self}\" --start'"
    local alias_stop="alias stopvpn=\"pkill -f 'openvpn --config' || true; for i in \$(ip -o link show | awk -F': ' '{print \$2}' | grep -E '^tun[0-9]+'); do ip link delete \"\$i\" 2>/dev/null || true; done\""
    local alias_status="alias vpnstatus='pgrep -fa \"openvpn --config\" || echo \"OpenVPN non démarré\"; ip -4 addr show dev tun0 2>/dev/null | awk '/inet /{print \\\$2}' || true'"
 
 
    update_in_file() {
        local file="$1"
        [ -f "$file" ] || return
        sed -i '/alias startvpn=/d;/alias stopvpn=/d;/alias vpnstatus=/d/' "$file"
        echo "$alias_start"  >> "$file"
        echo "$alias_stop"   >> "$file"
        echo "$alias_status" >> "$file"
        echo "[INFO] Alias VPN mis à jour dans $file"
    }
 
    update_in_file "$bashrc"
    update_in_file "$zshrc"
 
    unalias startvpn stopvpn vpnstatus 2>/dev/null || true
    eval "$alias_start"
    eval "$alias_stop"
    eval "$alias_status"
}
 
add_or_update_vpn_aliases
