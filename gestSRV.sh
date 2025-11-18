#!/usr/bin/env bash
#=== gestSRV : Gestion Serveur Bash avancée ===
set -Eeuo pipefail

# ---------------------- #
# INITIALISATION STYLE #
# ---------------------- #
RESET="\e[0m"; BOLD="\e[1m"; GREEN="\e[32m"; RED="\e[31m"; YELLOW="\e[33m"; CYAN="\e[36m"
OK="✅"; ERR="❌"; WARN="⚠"; INFO="ℹ"
log_ok()   { echo -e "${OK}  ${GREEN}${1}${RESET}"; }
log_err()  { echo -e "${ERR}  ${RED}${1}${RESET}"; }
log_warn() { echo -e "${WARN} ${YELLOW}${1}${RESET}"; }
log_info() { echo -e "${INFO} ${CYAN}${1}${RESET}"; }

# ------------------------------------- #
#      INSTALLATION SYSTÈME AUTO        #
# ------------------------------------- #
SCRIPT_NAME="gestSRV"
SCRIPT_SRC="$(readlink -f "${BASH_SOURCE[0]}")"
USER_BIN="$HOME/.local/bin"
SYSTEM_BIN="/usr/local/bin"
INSTALL_DIR=""
if [ -w "$SYSTEM_BIN" ]; then INSTALL_DIR="$SYSTEM_BIN"; else INSTALL_DIR="$USER_BIN"; fi
mkdir -p "$USER_BIN"
SCRIPT_INST="$INSTALL_DIR/$SCRIPT_NAME"

# Détection dynamique du nombre de modules
get_function_count() {
  declare -F | awk '{print $3}' | grep '^menu_function_' | sed 's/menu_function_//' | sort -n | tail -1
}
NB_FUNCS=$(get_function_count)
NB_FUNCS=${NB_FUNCS:-0}

# Installe le script et symlinks si nécessaire
if [[ "$SCRIPT_SRC" != "$SCRIPT_INST" ]]; then
  log_info "Installation de $SCRIPT_NAME dans $INSTALL_DIR"
  cp "$SCRIPT_SRC" "$SCRIPT_INST"
  chmod +x "$SCRIPT_INST"
  log_ok "Script principal installé : $SCRIPT_INST"
  # Symlinks dynamiques
  for i in $(seq 1 "$NB_FUNCS"); do ln -sf "$SCRIPT_INST" "$INSTALL_DIR/$SCRIPT_NAME-$i"; done
  log_info "Symlinks automatiques créés."
  if [[ "$INSTALL_DIR" == "$USER_BIN" ]] && ! echo "$PATH" | grep -q "$USER_BIN"; then
    RC="$HOME/.bashrc"; [ -n "${ZSH_VERSION:-}" ] && RC="$HOME/.zshrc"
    echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> "$RC"
    echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> "$HOME/.profile"
    log_ok "Ajout auto à $RC et .profile."
    log_info "source $RC pour activer ou rouvre un terminal."
  fi
  log_ok "Installation finie. Utilise 'gestSRV' ou 'gestSRV-N'."
  exit 0
fi

# ----------- DEPENDANCES ----------- #
declare -A PKG_MAP=( [netstat]="net-tools" [ss]="iproute2" [inotifywait]="inotify-tools" )
missing_list=""
for bin in awk tar grep systemctl ip netstat ss inotifywait; do
  if ! command -v "$bin" &>/dev/null; then
    pkg="${PKG_MAP[$bin]}"
    if [ "$(id -u)" -eq 0 ] && [ -n "$pkg" ]; then
      log_warn "$bin manquant : installation automatique ($pkg)"
      apt update -qq
      apt install -y "$pkg"
    elif [ -n "$pkg" ]; then log_warn "$bin manquant. Installe : sudo apt install $pkg"
    else log_warn "$bin manquant (paquet inconnu)."; fi
    missing_list="$missing_list $bin"
  fi
done
if [ -n "$missing_list" ]; then
  for bin in $missing_list; do
    if ! command -v "$bin" &>/dev/null; then log_warn "$bin est toujours manquant, certaines fonctions seront inaccessibles."; fi
  done
fi

# ----------------------------- #
BACKUP_DEFAULT_DIR="$HOME/backups"
LOG_DIR="$HOME/.local/share/gestSRV/logs"
mkdir -p "$LOG_DIR" "$BACKUP_DEFAULT_DIR"
pause() { read -r -p "Appuyer sur Entrée pour continuer..."; }

# --------------------- OPTIONS CLI --------------------- #
SHOW_HELP=false; SHOW_LIST=false; CALL_MODULE=""; VERBOSE=false
PARSED=$(getopt -o hlm:v --long help,list,module:,verbose -- "$@")
if [[ $? -ne 0 ]]; then log_err "Erreur dans les options"; exit 1; fi
eval set -- "$PARSED"
while true; do case "$1" in
  -h|--help) SHOW_HELP=true; shift;;
  -l|--list) SHOW_LIST=true; shift;;
  -m|--module) CALL_MODULE="$2"; shift 2;;
  -v|--verbose) VERBOSE=true; shift;;
  --) shift; break;;
  *) log_err "Option inconnue : $1"; exit 1;; esac; done

# ---------- gestion aide / liste / module ---------- #
if [ "$SHOW_HELP" = true ]; then
  echo -e "${CYAN}${BOLD}Usage :\n  $SCRIPT_NAME # menu interactif\n  $SCRIPT_NAME -l # liste les modules\n  $SCRIPT_NAME -m N [--verbose] # exécute N\n  $SCRIPT_NAME -h # aide\nOptions :\n  -l, --list      Modules disponibles\n  -m, --module N  Exécute le module n°N\n  -v, --verbose   Mode verbeux (si fonction supporte)\n  -h, --help      Affiche ce message\n${RESET}"
  exit 0
fi

if [ "$SHOW_LIST" = true ]; then
  echo -e "${BOLD}${CYAN}Modules disponibles :${RESET}"
  declare -F | awk '{print $3}' | grep '^menu_function_' | sort -V |
  while read fname; do
    n="${fname#menu_function_}"
    # Résumé si présent en commentaire
    summary=$(type $fname | grep -m1 "#" | sed 's/.*# *//')
    if [[ -n "$summary" ]]; then echo "  $n - $summary";
    else echo "  $n"; fi
  done
  exit 0
fi

if [ -n "$CALL_MODULE" ]; then
  fname="menu_function_${CALL_MODULE}"
  if declare -f "$fname" >/dev/null; then
    $VERBOSE && log_info "Exécution du module $CALL_MODULE en verbose"
    "$fname"
    exit 0
  else
    log_err "Le module/fonction $CALL_MODULE n'existe pas."
    exit 1
  fi
fi

# ------ menu interactif classique ------ #
menu() {
  clear
  echo -e "${BOLD}${CYAN}"
  cat << 'EOF'
#=== MENU GESTION SERVEUR ===
1 - Usage des disques
2 - Usage d'un répertoire
3 - Sauvegarde de répertoire (tgz)
4 - Usage du CPU
5 - Usage de la RAM
6 - Vérifier état d'un service ou process
7 - IPs machine & ports ouverts
8 - Surveillance modifs /var/www/html
(9, 10...) - Fonctions à venir
0 - QUITTER
EOF
  echo -e "${RESET}"
}
main() {
  while true; do
    menu
    read -r -p "Ton choix : " c
    funcname="menu_function_${c:-}"
    case "${c:-}" in
      [1-9]|10|11|12)
        if declare -f "$funcname" >/dev/null; then "$funcname"; else log_warn "Fonction $c non implémentée."; fi
        pause
        ;;
      0) log_info "Bye. À bientôt !"; exit 0;;
      *) log_err "Choix invalide."; pause;;
    esac
  done
}

# ============================= MODULES ============================= #
menu_function_1() { # Utilisation globale des disques
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗"; echo -e "║  Utilisation globale disques           ║"; echo -e "╚══════════════════════════════════════════╝${RESET}"
  printf "${BOLD}%-10s %-12s %-12s %-9s %-10s %-10s${RESET}\n" Filesystem Size Used Avail Use% Mount
  df -h | awk 'NR>1{ printf "%-10s %-12s %-12s %-9s %-10s %-10s\n", $1,$2,$3,$4,$5,$6 }'
  percent=$(df --total -h | awk '/total/{gsub("%","",$5); print $5}')
  echo -ne "\nUsage total (root): "
  if [ "${percent:-0}" -ge 80 ]; then log_warn "$percent% utilisés (Attention !)"; else log_ok "$percent% utilisés"; fi
  echo ""
}
menu_function_2() { # Analyse taille d'un répertoire
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗"; echo -e "║    Analyse taille répertoire            ║"; echo -e "╚══════════════════════════════════════════╝${RESET}"
  read -r -p "→ Chemin du répertoire à analyser : " REP
  if [[ -d "$REP" ]]; then du -h --max-depth=1 "$REP" | sort -hr | awk '{printf "%-10s %s\n", $1, $2}'; else log_err "$REP n'est pas un répertoire valide ou n'existe pas."; fi
  echo ""
}
menu_function_3() { # Sauvegarde d’un répertoire
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗"; echo -e "║   Sauvegarde et archivage dossier          ║"; echo -e "╚══════════════════════════════════════════════╝${RESET}"
  read -r -p "→ Répertoire à sauvegarder : " SRC
  if [[ ! -d "$SRC" ]]; then log_err "$SRC n'est pas un répertoire valide."; return 1; fi
  read -r -p "→ Répertoire de destination (défaut: $BACKUP_DEFAULT_DIR) : " DEST
  [[ -z "$DEST" ]] && DEST="$BACKUP_DEFAULT_DIR"
  mkdir -p "$DEST"
  DATE=$(date +"%Y-%m-%d_%H-%M-%S")
  NAME=$(basename "$SRC")
  ARCHIVE="$DEST/backup_${NAME}_$DATE.tgz"
  tar -czf "$ARCHIVE" "$SRC"
  if [[ $? -eq 0 ]]; then log_ok "Sauvegarde réussie : $ARCHIVE"; else log_err "Échec lors de la sauvegarde."; return 2; fi
  echo ""
}
menu_function_4() { # Usage CPU
  echo -e "${BOLD}${CYAN}╔══════════════════════════════╗"; echo -e "║   Usage du processeur      ║"; echo -e "╚══════════════════════════════╝${RESET}"
  cpu=$(top -bn1 | grep "Cpu(s)" | awk '{usage=$2+$4; printf "%.2f", usage}')
  cpu=${cpu/,/.}
  printf "CPU : "
  if (( $(echo "$cpu > 80" | bc -l) )); then log_warn "$cpu% (Élevé !)"; else log_ok "$cpu%"; fi
  echo ""
}
menu_function_5() { # Usage RAM
  echo -e "${BOLD}${CYAN}╔══════════════════════════════╗"; echo -e "║   Utilisation de la RAM     ║"; echo -e "╚══════════════════════════════╝${RESET}"
  info=$(free -m | awk 'NR==2{printf "RAM: %s/%s MB (%.2f%%)", $3, $2, $3*100/$2}')
  usage=$(free -m | awk 'NR==2{print $3*100/$2}')
  if (( $(echo "$usage > 80" | bc -l) )); then log_warn "$info"; else log_ok "$info"; fi
  echo ""
}
menu_function_6() { # Vérifier un service ou process
  echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗"; echo -e "║   Vérification d'un service ou process      ║"; echo -e "╚══════════════════════════════════════════════╝${RESET}"
  read -r -p "→ Nom exact du service à vérifier : " SERVICE
  if systemctl list-units --type=service | grep -qw "${SERVICE}.service"; then status=$(systemctl is-active "$SERVICE" 2>/dev/null); if [[ "$status" == "active" ]]; then log_ok "$SERVICE : service actif"; else log_err "$SERVICE : service inactif ou défaillant ($status)"; fi
  else if pgrep -x "$SERVICE" >/dev/null; then log_ok "$SERVICE : processus lancé"; else log_err "$SERVICE : non trouvé (ni service systemd ni process en cours)"; fi; fi; echo ""
}
menu_function_7() { # IPs et ports ouverts/prog
  echo -e "${BOLD}${CYAN}╔═════════════ IPs attribuées ══════════════╗${RESET}"
  printf "${BOLD}%-18s | %-8s${RESET}\n" "IP/CIDR" "Interface"
  printf "%s\n" "------------------+---------"
  ip -4 addr show | awk '/inet /{printf "%-18s | %s\n", $2, $NF}'
  echo ""
  echo -e "${BOLD}${CYAN}╔═ Ports ouverts et Processus associés ═╗${RESET}"
  printf "${BOLD}%-7s | %-21s | %-9s | %-18s${RESET}\n" "Proto" "Adresse locale" "Port" "Programme/Processus"
  printf "%s\n" "-------+---------------------+---------+------------------"
  if command -v netstat >/dev/null; then
    netstat -tulnp 2>/dev/null | awk '/LISTEN/ { proto=$1; local=$4; proc=$7; split(local, a, ":"); port=a[length(a)]; printf "%-7s | %-21s | %-9s | %-18s\n", proto, local, port, proc }'
  elif command -v ss >/dev/null; then
    ss -tulnp 2>/dev/null | awk '/LISTEN/ { proto=$1; local=$5; proc=$8; split(local, a, ":"); port=a[length(a)]; printf "%-7s | %-21s | %-9s | %-18s\n", proto, local, port, proc }'
  else log_err "netstat/ss non disponible."; fi
  echo ""
}
menu_function_8() { # Surveillance webroot (avec log live)
  echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════╗"; echo -e "║ Surveillance des modifications /var/www/html      ║"; echo -e "╚════════════════════════════════════════════════════╝${RESET}"
  LOGFILE="$LOG_DIR/modifs_var_www_html.log"
  log_info "Ctrl+C pour arrêter, journal : $LOGFILE"
  if ! command -v inotifywait >/dev/null; then log_err "inotifywait non installé (sudo apt install inotify-tools)"; return 1; fi
  printf "${BOLD}%-19s | %-60s | %-10s${RESET}\n" "Horodatage" "Chemin" "Événement"
  printf "%s\n" "-------------------+------------------------------------------------------------+----------"
  inotifywait -m /var/www/html -e create -e modify -e delete --format '%T | %w%f | %e' --timefmt '%F %T' | while read line; do echo "$line" | tee -a "$LOGFILE"; done
}

# -------- Mode direct symlink -------- #
scriptname="${0##*/}"; scriptbase="${scriptname%%.*}"
if [[ "$scriptbase" =~ gestSRV-([0-9]+)$ ]]; then
  funcnum="${BASH_REMATCH[1]}"; funcname="menu_function_${funcnum}"
  if declare -f "$funcname" >/dev/null; then "$funcname"; exit 0; else log_err "Fonction $funcnum non implémentée."; exit 1; fi
fi
trap 'log_err "Une erreur est survenue. Code $?"; exit 1' ERR

main
