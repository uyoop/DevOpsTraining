# QUICK START - Application Covoiturage

## Déploiement rapide en 5 étapes

### 1️⃣ Démarrer les VMs
```bash
vagrant up
```

### 2️⃣ Tester la connectivité
```bash
ansible appservers -m ping
```

### 3️⃣ Sécuriser les credentials
```bash
ansible-vault encrypt group_vars/vault.yml
# Créer un mot de passe fort et le conserver !
```

### 4️⃣ Déployer l'application
```bash
ansible-playbook webapp_deploy.yml --ask-vault-pass
```

### 5️⃣ Accéder à l'application
Ouvrir dans le navigateur :
- http://192.168.56.111
- http://192.168.56.112

---

## Commandes avec Makefile

```bash
make setup     # Étape 1 : Démarrer VMs
make test      # Étape 2 : Tester connectivité
# Étape 3 : ./setup_vault.sh ou make vault-encrypt
make deploy    # Étape 4 : Déployer
make verify    # Bonus : Vérifier le déploiement
```

---

## Déploiement sélectif

```bash
# Base de données seulement
make deploy-db

# Application seulement
make deploy-app

# Serveur web seulement
make deploy-web
```

---

## Vérification

```bash
# Vérifier les services
ansible appservers -m systemd -a "name=apache2" -b
ansible appservers -m systemd -a "name=mysql" -b
ansible appservers -m systemd -a "name=php8.3-fpm" -b

# Playbook de vérification
make verify
```

---

## Troubleshooting rapide

### ❌ "Vault password required"
```bash
ansible-vault encrypt group_vars/vault.yml
```

### ❌ "Host unreachable"
```bash
vagrant status
vagrant up
```

### ❌ "Permission denied"
```bash
ls -la ~/.vagrant.d/insecure_private_key
```

### ❌ Services ne démarrent pas
```bash
vagrant ssh app1
sudo systemctl status apache2
sudo systemctl status mysql
sudo systemctl status php8.3-fpm
```

---

## Stack déployée

| Composant | Technologie | Port |
|-----------|-------------|------|
| Web Server | Apache 2 | 80 |
| Application | PHP 8.3 | - |
| Runtime | PHP-FPM | Socket Unix |
| Database | MySQL | 3306 |
| VMs | Ubuntu 24.04 | - |

---

## Documentation complète

- **README.md** - Vue d'ensemble
- **GUIDE_DEPLOIEMENT.md** - Guide pas à pas détaillé
- **ROLES_DOCUMENTATION.md** - Documentation technique des rôles
- **RESUME_MODIFICATIONS.md** - Résumé des modifications

---

## Support

En cas de problème, consulter dans l'ordre :
1. Ce QUICK_START.md
2. GUIDE_DEPLOIEMENT.md (section Dépannage)
3. ROLES_DOCUMENTATION.md (section Troubleshooting)
4. Les logs sur les VMs : `vagrant ssh app1`

---

**Prêt à déployer !** 🚀
