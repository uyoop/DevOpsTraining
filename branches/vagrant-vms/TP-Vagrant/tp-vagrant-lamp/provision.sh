#!/bin/bash

set -e

# Message personnalisé dans /etc/motd
echo "VM TP – LAMP Server" > /etc/motd

# Installer Apache2, PHP et extensions minimales
export DEBIAN_FRONTEND=noninteractive

# Mise à jour des index de paquets
apt-get update

# Installation Apache2 si absent
if ! dpkg -l | grep -q apache2; then
  apt-get install -y apache2
fi

# Installation PHP (+ php-cli)
if ! dpkg -l | grep -q php; then
  apt-get install -y php php-cli
fi

# Activer Apache au démarrage
systemctl enable apache2

# Nettoyer /var/www/html sauf le dossier .vagrant ou dossier partagé
find /var/www/html -mindepth 1 -not -name '.vagrant' -exec rm -rf {} +

# Copier une page index.html "exemple"
if [ ! -f /var/www/html/index.html ]; then
  echo "<!DOCTYPE html>
<html>
  <head>
    <title>TP LAMP - Vagrant</title>
  </head>
  <body>
    <h1>Page index.html - TP Vagrant LAMP</h1>
    <p>Bienvenue sur la VM LAMP !</p>
  </body>
</html>" > /var/www/html/index.html
  chown www-data:www-data /var/www/html/index.html
  chmod 644 /var/www/html/index.html
fi
