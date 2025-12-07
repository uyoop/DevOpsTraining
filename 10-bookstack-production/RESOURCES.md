# 📚 Ressources & Références - TP10 BookStack Production

## 🔗 Repository & Branches

- **Repository Principal** : https://github.com/CJenkins-AFPA/CJ-DEVOPS
- **Branche Docker** : https://github.com/CJenkins-AFPA/CJ-DEVOPS/tree/docker
- **TP10 Dossier** : https://github.com/CJenkins-AFPA/CJ-DEVOPS/tree/docker/10-bookstack-production

## 📖 Documentation Interne

### Démarrage & Déploiement
- 📄 **QUICKSTART.md** - Déployer en 10 minutes
- 📄 **ARCHITECTURE.md** - Architecture détaillée avec diagrammes
- 📄 **README.md** - Guide production complet (500+ lignes)
- 📄 **COMPLETION_SUMMARY.md** - Ce que vous lisez

### Ansible & Automation
- 📄 **ansible/README.md** - Guide déploiement Ansible
- 📄 **ansible/deploy.yml** - Playbook complet
- 📄 **ansible/inventory.ini** - Template inventory
- 📄 **ansible/ansible.cfg** - Configuration Ansible

### Scripts Opérationnels
- 🔧 **scripts/install.sh** - Installation/setup automatisé
- 🔧 **scripts/backup.sh** - Sauvegarde chiffrée (Restic + GPG)
- 🔧 **scripts/restore.sh** - Restauration point-in-time
- 🔧 **scripts/hardening.sh** - Hardening système complet

## 🛠️ Technologies & Versions

### Core Infrastructure
| Technologie | Version | Rôle |
|-------------|---------|------|
| Docker | 24.x | Container runtime |
| Docker Compose | 2.x | Orchestration |
| Ubuntu/Debian | 20.04+ / 11+ | OS |

### Reverse Proxy & SSL
| Technologie | Version | Rôle |
|-------------|---------|------|
| Traefik | v3.x | Reverse proxy |
| Let's Encrypt | Latest | SSL/TLS certificates |
| Cloudflare | API v4 | DNS challenge |

### Authentication & Security
| Technologie | Version | Rôle |
|-------------|---------|------|
| Authelia | 4.x | 2FA/SSO |
| CrowdSec | Latest | IDS/IPS |
| UFW | Built-in | Firewall |
| Fail2Ban | Latest | Brute-force protection |

### Application & Database
| Technologie | Version | Rôle |
|-------------|---------|------|
| BookStack | Latest | Documentation platform |
| MySQL | 8.0 | Database |
| Node.js | 18+ | (if using JavaScript apps) |

### Backup & Recovery
| Technologie | Version | Rôle |
|-------------|---------|------|
| Restic | Latest | Backup engine |
| GPG | 2.2+ | Encryption |
| tar | Built-in | Archive creation |

### Monitoring & Observability
| Technologie | Version | Rôle |
|-------------|---------|------|
| Prometheus | Latest | Metrics collection |
| Grafana | 9.x+ | Visualization |
| Node-exporter | Latest | System metrics |

### Infrastructure as Code
| Technologie | Version | Rôle |
|-------------|---------|------|
| Ansible | 2.9+ | Automation |
| Vagrant | 2.4+ | VM provisioning (optional) |

## 📚 Ressources Externes

### Traefik
- 🌐 **Official Docs** : https://doc.traefik.io/traefik/
- 📖 **Reverse Proxy Guide** : https://doc.traefik.io/traefik/routing/overview/
- 🔒 **SSL/TLS Setup** : https://doc.traefik.io/traefik/https/overview/
- 🔌 **Middleware** : https://doc.traefik.io/traefik/middlewares/overview/

### Authelia
- 🌐 **Official Docs** : https://www.authelia.com/
- 🔐 **Authentication** : https://www.authelia.com/docs/authentication/
- 📋 **Access Control** : https://www.authelia.com/docs/access-control/
- 🕒 **TOTP 2FA** : https://www.authelia.com/docs/authentication/totp/

### CrowdSec
- 🌐 **Official Docs** : https://docs.crowdsec.net/
- 🛡️ **IDS/IPS** : https://docs.crowdsec.net/docs/getting_started/
- 🔌 **Traefik Plugin** : https://docs.crowdsec.net/docs/bouncers/traefik/
- 🤝 **Community** : https://www.crowdsec.net/

### Docker & Docker Compose
- 🌐 **Docker Docs** : https://docs.docker.com/
- 🐳 **Docker Compose** : https://docs.docker.com/compose/
- 🔐 **Docker Secrets** : https://docs.docker.com/engine/swarm/secrets/
- 🌐 **Docker Hub** : https://hub.docker.com/

### MySQL
- 🌐 **MySQL Docs** : https://dev.mysql.com/doc/
- 📊 **InnoDB Tuning** : https://dev.mysql.com/doc/refman/8.0/en/innodb-parameters.html
- 🔒 **Security** : https://dev.mysql.com/doc/refman/8.0/en/security.html

### BookStack
- 🌐 **Official Site** : https://www.bookstackapp.com/
- 📖 **Documentation** : https://www.bookstackapp.com/docs/
- 🚀 **Installation** : https://www.bookstackapp.com/docs/admin/installation/
- 🔧 **Configuration** : https://www.bookstackapp.com/docs/admin/

### Prometheus & Grafana
- 🌐 **Prometheus Docs** : https://prometheus.io/docs/
- 📊 **Grafana Docs** : https://grafana.com/docs/grafana/
- 📈 **Metrics Query** : https://prometheus.io/docs/prometheus/latest/querying/
- 📊 **Dashboard Library** : https://grafana.com/grafana/dashboards/

### Ansible
- 🌐 **Ansible Docs** : https://docs.ansible.com/
- 📖 **Getting Started** : https://docs.ansible.com/ansible/latest/getting_started/
- 🔌 **Module Index** : https://docs.ansible.com/ansible/latest/collections/index.html
- 🎯 **Best Practices** : https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html

### Restic
- 🌐 **Official Site** : https://restic.net/
- 📖 **Documentation** : https://restic.readthedocs.io/
- 🔐 **Encryption** : https://restic.readthedocs.io/en/latest/manual_backup/
- 🤖 **Automation** : https://restic.readthedocs.io/en/latest/030_managing_repos/

## 🎓 Tutoriels & Guides Recommandés

### Traefik
- 📺 "Traefik v2 + Let's Encrypt Setup" (YouTube)
- 📺 "Docker Compose + Traefik Complete Guide"
- 📄 Traefik Official Documentation

### Security
- 📖 "Docker Security Best Practices"
- 📖 "Kubernetes/Docker Network Security"
- 📖 "OWASP Top 10 for Container Security"

### DevOps
- 📖 "Infrastructure as Code" (Terraform/Ansible)
- 📖 "The Phoenix Project" (IT Operations)
- 📖 "The DevOps Handbook"

### Monitoring
- 📖 "Prometheus: Up and Running"
- 📖 "Grafana Fundamentals"
- 📖 "SRE: Site Reliability Engineering"

## 💻 Outils Additionnels Recommandés

### CLI Tools
```bash
# Container management
docker ps
docker logs
docker exec

# Image scanning
docker scan <image>
trivy <image>

# Networking
netstat
ss
nslookup

# Monitoring
htop
iotop
nethogs

# Security
nmap
openssl
fail2ban-client
```

### Browser Extensions
- **uBlock Origin** - Ad blocker
- **HTTPS Everywhere** - Force HTTPS
- **Wappalyzer** - Tech stack detector
- **Let's Debug** - SSL certificate checker

### Development Tools
- **VS Code** with extensions:
  - Docker (ms-azuretools.vscode-docker)
  - YAML (redhat.vscode-yaml)
  - Ansible (redhat.ansible)
  - Remote SSH (ms-vscode-remote.remote-ssh)

## 📊 Dashboards Grafana Recommandés

Pre-configured dans TP10:

| ID | Nom | Source |
|----|----|--------|
| 1860 | Node Exporter Full | prometheus |
| 12250 | MySQL 8.0 | prometheus |
| 7362 | Docker | prometheus |

Pour importer d'autres:
1. Aller sur https://grafana.com/grafana/dashboards/
2. Chercher un dashboard
3. Copier l'ID
4. Dans Grafana: + → Import → Entrer l'ID

## 🔒 Security Checklist

Avant production:

- [ ] SSL certificates configured
- [ ] 2FA enabled for all users
- [ ] Firewall configured (UFW)
- [ ] Fail2Ban active
- [ ] CrowdSec running
- [ ] Backups working & tested
- [ ] Monitoring alerts configured
- [ ] Log aggregation working
- [ ] Secrets not in git (.gitignore)
- [ ] Container images scanned
- [ ] Network isolation verified
- [ ] SSH keys configured
- [ ] Rate limiting enabled
- [ ] DDoS protection active
- [ ] Disaster recovery tested

## 🚨 Incident Response

### Service Down
```bash
docker compose ps                    # Check status
docker logs <service>               # Check logs
docker compose restart <service>    # Restart
```

### Disk Space
```bash
df -h                               # Check disk
docker system df                    # Docker usage
docker system prune -a             # Clean up
```

### Memory Leak
```bash
docker stats                        # Monitor
docker logs <service>              # Check errors
docker compose restart <service>   # Restart
```

### Network Issue
```bash
docker network ls                  # List networks
docker network inspect <network>   # Details
ping <container>                   # Test connectivity
```

## 💬 Community & Support

- 🐛 **GitHub Issues** : https://github.com/CJenkins-AFPA/CJ-DEVOPS/issues
- 💬 **GitHub Discussions** : https://github.com/CJenkins-AFPA/CJ-DEVOPS/discussions
- 📧 **Email Support** : (Configure in your repo)
- 🤝 **Contributing** : See CONTRIBUTING.md

## 📝 Version History

### TP10 Versions

**v1.0** (Current)
- ✅ 11-service stack
- ✅ Traefik v3 + Authelia 2FA
- ✅ CrowdSec IDS/IPS
- ✅ Prometheus + Grafana
- ✅ Ansible automation
- ✅ Complete documentation

**Future v1.1**
- [ ] Kubernetes deployment
- [ ] Vault integration
- [ ] WAF (ModSecurity)
- [ ] SIEM integration

## 🎯 Quick Links

| Ressource | Lien |
|-----------|------|
| Repository | https://github.com/CJenkins-AFPA/CJ-DEVOPS |
| TP10 Folder | github.com/.../docker/10-bookstack-production |
| Traefik Docs | https://doc.traefik.io/traefik/ |
| Authelia Docs | https://www.authelia.com/ |
| CrowdSec Docs | https://docs.crowdsec.net/ |
| Docker Docs | https://docs.docker.com/ |
| Ansible Docs | https://docs.ansible.com/ |
| Prometheus | https://prometheus.io/docs/ |
| Grafana | https://grafana.com/docs/grafana/ |

---

**Last Updated**: December 2024
**Status**: Production Ready ✅
**Maintenance**: Monthly security updates recommended

