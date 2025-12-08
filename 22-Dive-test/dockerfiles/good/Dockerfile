# Dockerfile optimisé
FROM python:3.12-slim

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# 1) Déps système minimales + nettoyage immédiat
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2) Déps Python en premier (cache Docker optimal)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3) Copie de l'app uniquement (grâce au .dockerignore)
COPY app.py .

# 4) Utilisateur non-root
RUN useradd -ms /bin/bash appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

ENV FLASK_ENV=production
ENV APP_ENV=prod
ENV USE_DEBUG=False

CMD ["python", "app.py"]
