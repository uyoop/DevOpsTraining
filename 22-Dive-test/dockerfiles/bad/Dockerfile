# Dockerfile pourri (version non optimisée du TP)
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# On bosse chez root (of course…)
WORKDIR /root

# 1) Update séparé (sans install, sans cleanup)
RUN apt-get update

# 2) On installe plein d'outils dont on n'a pas vraiment besoin
RUN apt-get install -y \
    python3 \
    python3-pip \
    git \
    curl \
    wget \
    vim \
    nano \
    build-essential \
    zip \
    unzip \
    man-db \
    locales \
    tzdata

# 3) On copie TOUT le contexte (y compris .git, node_modules, venv, etc.)
COPY . /app

# 4) On installe deux fois les dépendances Python 
RUN pip3 install flask requests numpy pandas
RUN cd /app && pip3 install -r requirements.txt

# 5) On régénère encore un update + install…
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    iputils-ping \
    net-tools

# 6) On crée des fichiers temporaires qui resteront dans l'image
RUN mkdir -p /tmp/bigfiles && \
    dd if=/dev/zero of=/tmp/bigfiles/zero1.bin bs=1M count=50 && \
    dd if=/dev/zero of=/tmp/bigfiles/zero2.bin bs=1M count=50

# 7) On laisse les caches APT, les logs, etc. (aucun rm -rf)
# 8) On ne définit pas d'utilisateur non-root, ni d'ENTRYPOINT propre
WORKDIR /app

ENV FLASK_ENV=development
ENV APP_ENV=dev
ENV USE_DEBUG=True

CMD ["python3", "app.py"]
