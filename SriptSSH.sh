#!/bin/bash

# ------------- VARIABLES PRINCIPALES -------------
# Fichiers utilisés
AUTHORIZED_KEYS="$HOME/.ssh/authorized_keys"         # Fichier des clés autorisées
AJOUTS_LOG="$HOME/.ssh/gestSRV_ajouts.log"           # Log local des modifications gestSRV
LOGFILE="/var/log/auth.log"                          # Fichier de logs SSH (Debian)

# Couleurs pour une meilleure lisibilité
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

# ------------- FONCTIONS PRINCIPALES -------------

# ⏩ Ajout guidé d'une clé SSH utilisateur
add_user_ssh_key() {
  echo -e "${BOLD}${CYAN}Ajout d'une clé SSH utilisateur${RESET}"
  read -p "Nom d'utilisateur ou identifiant (pour annotation, ex: alice@labo) : " USR_COMMENT
  echo "\nCollez la clé publique fournie (commence par 'ssh-...') :"
  read -r PUBKEY
  # 🛑 Vérification rudimentaire du format
  if [[ -z "$PUBKEY" || ! "$PUBKEY" =~ ^ssh- ]]; then
    echo -e "${RED}Clé invalide (doit commencer par 'ssh-'). Abandon.${RESET}"
    return
  fi
  mkdir -p "$HOME/.ssh"                 # Créer dossier si absent
  touch "$AUTHORIZED_KEYS"               # Créer fichier si absent
  chmod 700 "$HOME/.ssh"
  chmod 600 "$AUTHORIZED_KEYS"
  # ✅ Ajoute clé avec annotation utilisateur et date
  echo "$PUBKEY # $USR_COMMENT | ajouté le $(date +'%F %T')" >> "$AUTHORIZED_KEYS"
  chmod 600 "$AUTHORIZED_KEYS"
  echo -e "${GREEN}Clé ajoutée pour $USR_COMMENT.${RESET}"
  echo "[AJOUT] $USR_COMMENT - $(date +'%F %T')" >> "$AJOUTS_LOG"
}

# ⏩ Suppression directe d'une clé  (sélection par numéro)
del_user_ssh_key() {
  if ! [[ -f "$AUTHORIZED_KEYS" ]]; then
    echo "Aucun fichier authorized_keys trouvé."; return
  fi
  echo -e "\n${BOLD}Clés actives actuellement :${RESET}"
  nl -ba -w2 -s'. ' "$AUTHORIZED_KEYS"
  echo
  read -p "Numéro de clé à supprimer : " NUM
  # 🛑 Vérif entrée numérique
  if ! [[ "$NUM" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Entrée invalide.${RESET}"; return
  fi
  TMPFILE=$(mktemp)
  # Supprime la ligne N (clé + annotation)
  awk -v n="$NUM" 'NR != n' "$AUTHORIZED_KEYS" > "$TMPFILE"
  cp "$TMPFILE" "$AUTHORIZED_KEYS"
  rm "$TMPFILE"
  chmod 600 "$AUTHORIZED_KEYS"
  echo -e "${YELLOW}Clé n°$NUM supprimée du fichier authorized_keys.${RESET}"
  echo "[SUPPRESSION] clé n°$NUM - $(date +'%F %T')" >> "$AJOUTS_LOG"
}

# ⏩ Liste claire des clés actives (numérotées avec commentaires)
list_ssh_keys() {
  echo -e "${BOLD}Clés actuellement autorisées :${RESET}"
  if [[ -f "$AUTHORIZED_KEYS" ]]; then
    nl -ba -w2 -s'. ' "$AUTHORIZED_KEYS"
  else
    echo "Aucune clé enregistrée."
  fi
}

# ⏩ Consultation de l'historique d'ajout/suppression
display_ajouts_log() {
  echo -e "\n${CYAN}Historique des ajouts & suppressions de clés :${RESET}"
  if [[ -f "$AJOUTS_LOG" ]]; then
    cat "$AJOUTS_LOG"
  else
    echo "Pas encore d'opérations enregistrées."
  fi
}

# ⏩ Affichage humain des derniers logs de connexion SSH
show_ssh_logs() {
  echo -e "\n${CYAN}Dernières connexions SSH (20 entrées)${RESET}"
  echo "------------------------------------------------------------------"
  sudo grep 'sshd' "$LOGFILE" 2>/dev/null | \
  grep -E 'Accepted|Failed' | \
  sed -r -e 's/^([A-Z][a-z]{2} [ 0-9]{2} [0-9:]{8}) (.*)sshd\[[0-9]+\]: (Accepted|Failed) (password|publickey) for ([^ ]+) from ([^ ]+) .*/Date: \1 | Utilisateur: \5 | IP: \6 | Méthode: \4 | Statut: \3/' | \
  tail -n 20
  echo "------------------------------------------------------------------"
}

# ------------- MENU PRINCIPAL -------------
main() {
  while true; do
    echo -e "\n${BOLD}${CYAN}==== MENU GESTION ACCÈS SSH MULTI-UTILISATEURS ====${RESET}"
    echo "1 - Ajouter une clé SSH pour un utilisateur (installation guidée)"
    echo "2 - Lister les clés autorisées (multi-utilisateurs)"
    echo "3 - Supprimer une clé autorisée (par numéro)"
    echo "4 - Consulter l'historique des ajouts/suppressions"
    echo "5 - Afficher les logs de connexion SSH (dernier accès)"
    echo "0 - Quitter"
    echo -n "> Votre choix : "
    read CHOIX
    case "$CHOIX" in
      1) add_user_ssh_key;;
      2) list_ssh_keys;;
      3) del_user_ssh_key;;
      4) display_ajouts_log;;
      5) show_ssh_logs;;
      0) echo "Au revoir."; exit 0;;
      *) echo -e "${YELLOW}Saisie non reconnue.${RESET}";;
    esac
    echo -e "\n${CYAN}Appuyez sur Entrée pour continuer...${RESET}"; read
  done
}

main
