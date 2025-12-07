# 🐳 Branche docker — TPs 01 à 18

Snapshot local de la branche `docker` pour consulter tous les TPs sans changer de branche Git.

## 📚 Vue d'ensemble
- Fondamentaux : 01-08 (install, commandes, Compose, registry, réseau, volumes, Dockerfiles, Swarm).
- Apps & Observabilité : 09-14 (BookStack basique/prod, NetBox basique/prod, Prometheus, Prometheus+Grafana).
- Registries & Ops : 15-18 (Harbor basique/prod, Portainer CE/EE).

## 🚀 Navigation rapide
```bash
git checkout docker
ls  # dossiers 01 à 18
```

## 🗂️ Structure (snapshot)
```
01-docker-install/
02-docker-basics/
03-docker-compose/
04-docker-registry-prive/
05-docker-network/
06-docker-volumes/
07-dockerfiles/
08-docker-swarm/
09-bookstack-docker/
10-bookstack-production/
11-netbox-docker/
12-netbox-professionnel/
13-prometheus-docker/
14-prometheus-grafana-pro/
15-harbor-docker/
16-harbor-pro/
17-portainer-docker/
18-portainer-pro/
```

## Notes
- Ce dossier est un miroir de la branche `docker` pour lecture/présentation.
- Pour contribuer ou modifier, travaillez directement sur la branche Git `docker`.
## 💡 Conseils d'Apprentissage

1. **Pratiquez régulièrement** : Docker s'apprend en faisant
2. **Expérimentez** : Cassez des choses, c'est normal !
3. **Lisez les logs** : `docker logs` est votre ami
4. **Utilisez docker inspect** : Pour comprendre ce qui se passe
5. **Nettoyez régulièrement** : `docker system prune` pour libérer de l'espace

## 🐛 Debugging Courant

### Conteneur qui ne démarre pas
```bash
docker logs <container-id>
docker inspect <container-id>
```

### Port déjà utilisé
```bash
sudo netstat -tulpn | grep <port>
sudo lsof -i :<port>
```

### Espace disque saturé
```bash
docker system df
docker system prune -a --volumes
```

### Réseau qui ne fonctionne pas
```bash
docker network inspect <network-name>
docker exec <container> ping <other-container>
```

## 🤝 Contribution

Cette formation est open-source. N'hésitez pas à :
- Signaler des erreurs (Issues)
- Proposer des améliorations (Pull Requests)
- Partager vos retours d'expérience

## 📧 Contact

- **Author** : CJenkins-AFPA
- **GitHub** : [CJenkins-AFPA/CJ-DEVOPS](https://github.com/CJenkins-AFPA/CJ-DEVOPS)
- **Branch** : `docker`

## 📝 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](../LICENSE) pour plus de détails.

---

## 🎯 Checklist de Progression

- [ ] TP 01 - Installation Docker
- [ ] TP 02 - Commandes de base
- [ ] TP 03 - Docker Compose
- [ ] TP 04 - Registry Privé
- [ ] TP 05 - Réseaux Docker
- [ ] TP 06 - Volumes Docker
- [ ] TP 07 - Dockerfiles
- [ ] TP 08 - Docker Swarm

**Bon apprentissage ! 🚀**
