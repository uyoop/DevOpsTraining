#!/bin/sh
# Script de healthcheck pour le conteneur PHP

set -e

# Vérifier que PHP-FPM répond
if ! pgrep -x php-fpm > /dev/null; then
    echo "PHP-FPM n'est pas en cours d'exécution"
    exit 1
fi

# Vérifier que le répertoire data existe et est accessible
if [ ! -d /var/www/html/data ]; then
    echo "Le répertoire data n'existe pas"
    exit 1
fi

# Vérifier que le répertoire data est accessible en écriture
if [ ! -w /var/www/html/data ]; then
    echo "Le répertoire data n'est pas accessible en écriture"
    exit 1
fi

echo "Healthcheck OK"
exit 0
