# Dockerfile pour UyoopApp
FROM php:8.4-fpm-alpine

# Installer les extensions PHP nécessaires
RUN apk add --no-cache \
    sqlite \
    sqlite-dev \
    && docker-php-ext-install pdo pdo_sqlite

# Créer le répertoire de travail
WORKDIR /var/www/html

# Copier les fichiers de l'application
COPY . .

# Copier le script de healthcheck
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

# Créer le répertoire data et définir les permissions
RUN mkdir -p /var/www/html/data && \
    chown -R www-data:www-data /var/www/html/data && \
    chmod -R 755 /var/www/html/data && \
    chown -R www-data:www-data /var/www/html

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Exposer le port PHP-FPM
EXPOSE 9000

# Lancer PHP-FPM
CMD ["php-fpm"]
