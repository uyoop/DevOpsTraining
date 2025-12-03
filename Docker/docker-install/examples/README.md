# Exemples de Dockerfile pour les TPs

Ce dossier contient des exemples de Dockerfile pour différents cas d'usage.

## Utilisation

### 1. Serveur web statique (Nginx)

```bash
# Créer le contenu
mkdir html
echo "<h1>Mon site Docker</h1>" > html/index.html

# Construire l'image
docker build -f Dockerfile.nginx -t mon-nginx .

# Lancer le conteneur
docker run -d -p 8080:80 mon-nginx

# Tester
curl localhost:8080
```

### 2. Application Python

```bash
# Créer l'application
cat > app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from Docker Python!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Créer les dépendances
cat > requirements.txt << 'EOF'
flask==2.3.0
EOF

# Construire l'image
docker build -f Dockerfile.python -t mon-python-app .

# Lancer le conteneur
docker run -d -p 5000:5000 mon-python-app

# Tester
curl localhost:5000
```

### 3. Application Node.js

```bash
# Créer l'application
cat > server.js << 'EOF'
const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello from Docker Node.js!\n');
});

server.listen(3000, '0.0.0.0', () => {
  console.log('Server running on port 3000');
});
EOF

# Créer package.json
cat > package.json << 'EOF'
{
  "name": "docker-node-app",
  "version": "1.0.0",
  "description": "Simple Node.js app",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  }
}
EOF

# Construire l'image
docker build -f Dockerfile.nodejs -t mon-node-app .

# Lancer le conteneur
docker run -d -p 3000:3000 mon-node-app

# Tester
curl localhost:3000
```

## Bonnes pratiques utilisées

1. **Images légères** : Utilisation de variantes Alpine quand possible
2. **Multi-stage builds** : Pour réduire la taille des images
3. **Sécurité** : Utilisation d'utilisateurs non-root
4. **Cache** : Copie des dépendances avant le code source
5. **Layer optimization** : Minimisation du nombre de layers
