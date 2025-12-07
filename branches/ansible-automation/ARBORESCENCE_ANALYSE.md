# 📊 État Actuel de l'Arborescence Git - /home/cj/gitdata

## 🌳 Branches Git Disponibles

```
├── main                    (branche principale stable)
├── test                    (tests et expérimentations)
├── docker-compose          (⭐ BRANCHE ACTUELLE - stacks Docker Compose)
├── ansible-automation      (automatisation Ansible)
├── uyoop-app              (application UyoopApp)
└── vagrant-vms            (machines virtuelles Vagrant)
```

**Branche actuelle** : `docker-compose`

---

## 📁 Structure du Répertoire /home/cj/gitdata

```
/home/cj/gitdata/
│
├── .git/                           # Dépôt Git
│
├── README.md                       # Documentation racine
│
├── ANSIBLE_GUIDE.md               # ⚠️ NON COMMITÉ sur docker-compose
│
├── ansible.cfg                    # ⚠️ NON COMMITÉ sur docker-compose
├── inventory.ini                  # ⚠️ NON COMMITÉ sur docker-compose
│
├── Docker/                        # Dossier pour Dockerfiles (à peupler)
│
├── docker-compose/                # Stacks Docker Compose
│   └── ServeurRegistryDockerPrivé/
│       ├── Vagrantfile
│       ├── playbook.yml
│       ├── inventory.ini
│       └── README.md
│
├── machines-test/                 # ⚠️ NON COMMITÉ sur docker-compose
│   └── nmt1/                      # Machine Vagrant test registry
│       ├── Vagrantfile
│       ├── playbook.yml
│       ├── inventory.ini
│       └── README.md
│
├── Playbooks/                     # ⚠️ NON COMMITÉ sur docker-compose
│   ├── README.md                  # Documentation 30+ playbooks
│   ├── system-update.yml
│   ├── docker-install.yml
│   ├── gitlab-install.yml
│   ├── kubernetes-setup.yml
│   ├── monitoring-stack-deploy.yml
│   ├── postgresql-install.yml
│   ├── nginx-deploy.yml
│   └── ... (17 playbooks au total)
│
└── roles/                         # ⚠️ NON COMMITÉ sur docker-compose
    ├── README.md                  # Documentation 50+ rôles
    ├── system-update/
    │   ├── tasks/main.yml
    │   ├── defaults/main.yml
    │   ├── handlers/main.yml
    │   └── meta/main.yml
    ├── docker/
    │   ├── tasks/main.yml
    │   ├── defaults/main.yml
    │   ├── handlers/main.yml
    │   └── meta/main.yml
    ├── postgresql/
    │   └── ... (structure complète)
    ├── nginx/
    │   └── ... (structure complète)
    └── ... (50+ rôles au total)
```

---

## ⚠️ PROBLÈME IDENTIFIÉ

**Les playbooks et rôles Ansible sont créés sur la branche `docker-compose` mais ne sont PAS commités !**

### Fichiers non commités actuellement :
- ❌ `ANSIBLE_GUIDE.md`
- ❌ `ansible.cfg`
- ❌ `inventory.ini`
- ❌ `Playbooks/` (répertoire complet avec 17 playbooks)
- ❌ `roles/` (répertoire complet avec 50+ rôles)
- ❌ `machines-test/` (lab Vagrant)

### Ce qui DEVRAIT être l'organisation :

```
Branche: main
└── README.md (documentation générale)

Branche: docker-compose
├── docker-compose/ServeurRegistryDockerPrivé/
└── (autres stacks Docker Compose à ajouter)

Branche: ansible (ou ansible-automation)  ⭐ C'EST ICI QUE ÇA DEVRAIT ÊTRE !
├── ansible.cfg
├── inventory.ini
├── ANSIBLE_GUIDE.md
├── Playbooks/
│   ├── README.md
│   └── (17 playbooks)
└── roles/
    ├── README.md
    └── (50+ rôles)

Branche: test
└── machines-test/nmt1/  (lab Vagrant pour tests)

Branche: vagrant-vms
└── (autres VMs Vagrant)

Branche: uyoop-app
└── UyoopApp/ (application)
```

---

## 🔧 ACTIONS CORRECTIVES RECOMMANDÉES

### Option 1 : Déplacer vers la branche `ansible-automation`

```bash
# 1. Vérifier qu'on est sur docker-compose
git branch --show-current

# 2. Stash les fichiers Ansible non commités
git add Playbooks/ roles/ ansible.cfg inventory.ini ANSIBLE_GUIDE.md
git stash

# 3. Aller sur ansible-automation
git checkout ansible-automation

# 4. Appliquer les fichiers Ansible
git stash pop

# 5. Commiter sur ansible-automation
git add Playbooks/ roles/ ansible.cfg inventory.ini ANSIBLE_GUIDE.md
git commit -m "feat(ansible): add comprehensive playbooks and roles library

- 17 infrastructure playbooks
- 50+ reusable roles
- Complete documentation
- ansible.cfg and inventory template"

# 6. Push
git push origin ansible-automation

# 7. Revenir sur docker-compose
git checkout docker-compose
```

### Option 2 : Créer une nouvelle branche `ansible` dédiée

```bash
# 1. Créer et basculer sur nouvelle branche ansible
git checkout -b ansible

# 2. Commiter les fichiers Ansible
git add Playbooks/ roles/ ansible.cfg inventory.ini ANSIBLE_GUIDE.md
git commit -m "feat(ansible): initialize ansible branch with playbooks and roles"

# 3. Push la nouvelle branche
git push -u origin ansible

# 4. Retourner sur docker-compose et nettoyer
git checkout docker-compose
git clean -fd  # Supprimer les fichiers non trackés
```

### Option 3 : Déplacer machines-test sur branche test

```bash
# 1. Sur docker-compose, stash machines-test
git add machines-test/
git stash

# 2. Aller sur test
git checkout test

# 3. Appliquer
git stash pop
git add machines-test/
git commit -m "feat(test): add nmt1 Vagrant test machine for Docker registry"
git push origin test

# 4. Revenir sur docker-compose
git checkout docker-compose
```

---

## 📋 RÉSUMÉ DE LA SITUATION

| Élément | Branche Actuelle | Branche Recommandée | État |
|---------|-----------------|---------------------|------|
| Playbooks/ | docker-compose | ansible-automation | ⚠️ Non commité |
| roles/ | docker-compose | ansible-automation | ⚠️ Non commité |
| ansible.cfg | docker-compose | ansible-automation | ⚠️ Non commité |
| inventory.ini | docker-compose | ansible-automation | ⚠️ Non commité |
| ANSIBLE_GUIDE.md | docker-compose | ansible-automation | ⚠️ Non commité |
| machines-test/ | docker-compose | test | ⚠️ Non commité |
| docker-compose/ | docker-compose | ✅ Correct | ✅ Commité |
| Docker/ | docker-compose | ✅ Correct | Vide (à peupler) |

---

## 🎯 RECOMMANDATION FINALE

**Je recommande l'Option 1** : déplacer tout le contenu Ansible vers la branche `ansible-automation` existante.

Cela respectera votre organisation initiale et maintiendra une séparation claire :
- `docker-compose` → Stacks Docker Compose
- `ansible-automation` → Playbooks et rôles Ansible
- `test` → Labs de test (machines Vagrant)
- `main` → Code stable et documentation générale

Voulez-vous que j'exécute ces commandes pour corriger l'organisation ?
