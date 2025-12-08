# TP21 - Dive + Harbor (Production) avec Ansible

Automatiser l'audit des images poussées sur Harbor (stack TP16) avec l'outil Dive, en mode non interactif et intégrable en CI/CD.

## 🎯 Objectifs
- Déployer automatiquement Dive sur un bastion/runner via Ansible.
- Analyser une image issue de Harbor en mode CI (`--ci`) avec seuil d'efficacité.
- Exporter un rapport JSON/HTML pour vos pipelines.

## 🗂️ Contenu
- `ansible/inventory.ini` : exemple d'inventaire.
- `ansible/playbook.yml` : installation de Dive + analyse d'une image Harbor.

## ✅ Prérequis
- Accès SSH à un hôte d'analyse (Ubuntu/Debian) avec Docker 20.10+ et Compose 2+.
- Ansible 2.14+ lancé depuis votre poste.
- Un compte Harbor avec droits de pull sur le projet ciblé.
- Variables Harbor (hostname, projet, image, tag) à définir dans le playbook ou via `--extra-vars`.

## 🚀 Quickstart
```bash
cd 21-Dive-harbor-Docker-pro/ansible

# 1) Adapter l'inventaire
cp inventory.ini inventory.local.ini
# éditer l'hôte et l'utilisateur SSH

# 2) Lancer le playbook
ansible-playbook -i inventory.local.ini playbook.yml \
  -e harbor_host=harbor.example.com \
  -e harbor_project=prod \
  -e harbor_image=api \
  -e harbor_tag=2025.01.0 \
  -e harbor_username=ci-bot \
  -e harbor_password="<token>" \
  -e lowest_efficiency=0.90
```

## 🔧 Paramètres clés (variables)
- `dive_version` : version binaire (défaut: 0.12.0).
- `lowest_efficiency` : seuil minimal d'efficacité Dive (défaut: 0.90).
- `harbor_host` / `harbor_project` / `harbor_image` / `harbor_tag` : cible d'analyse.
- `harbor_username` / `harbor_password` : credentials de pull.
- `report_dir` : dossier de sortie des rapports (`/tmp/dive-reports` par défaut).

## 📈 Résultat attendu
- Dive installé sur l'hôte cible.
- Image `harbor_host/harbor_project/harbor_image:harbor_tag` pullée.
- Rapport JSON `dive-report.json` (et texte `dive-report.txt`) généré dans `report_dir`.
- Échec du playbook si l'efficacité est < `lowest_efficiency` (idéal pour gating CI/CD).

## 🧪 Intégration CI/CD (exemple GitLab)
```yaml
dive_audit:
  stage: test
  image: python:3.12-slim
  before_script:
    - apt-get update && apt-get install -y ansible sshpass
  script:
    - ansible-playbook -i ansible/inventory.local.ini ansible/playbook.yml \
        -e harbor_host=$HARBOR_HOST \
        -e harbor_project=$CI_PROJECT_NAME \
        -e harbor_image=api \
        -e harbor_tag=$CI_COMMIT_SHORT_SHA \
        -e harbor_username=$HARBOR_USER \
        -e harbor_password=$HARBOR_PASS \
        -e lowest_efficiency=0.92
  artifacts:
    paths:
      - ansible/dive-report.json
      - ansible/dive-report.txt
```

## 📚 Ressources
- Dive : https://github.com/wagoodman/dive
- Harbor : https://goharbor.io/
- Article Dive : https://blog.stephane-robert.info/docs/conteneurs/outils/dive/
- TP16 Harbor Pro : `16-harbor-pro/`
