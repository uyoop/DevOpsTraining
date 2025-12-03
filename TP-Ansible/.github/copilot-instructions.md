## Purpose

This repository contains a set of Ansible training projects (TP-Ansible). These instructions give an AI coding agent the minimal, high-value context needed to be productive: architecture, developer workflows, repository conventions, integration points, and concrete examples.

**Big Picture**
- **Roles-based Ansible:** The main deployment lives in `TP-Ansible-2-web_app_deployment` and follows a roles layout: `roles/common` and `roles/webserver` (see `roles/*/tasks/main.yml`).
- **Service boundaries:** `webserver` role builds a systemd/Gunicorn service for a Flask app and configures Nginx as a reverse proxy (templates in `roles/webserver/templates/*.j2`).
- **Dataflow:** Code is `git clone`-ed on target hosts into the app user (default `flask`), a Python `venv` is created and dependencies installed, Gunicorn serves the app, Nginx proxies HTTP traffic to Gunicorn.

**Where to look (key files)**
- `TP-Ansible-2-web_app_deployment/ansible.cfg` : project Ansible settings.
- `TP-Ansible-2-web_app_deployment/inventory.ini` : host definitions used by examples.
- `TP-Ansible-2-web_app_deployment/group_vars/appservers.yml` : canonical variables (app name, user, domain, `service_name`).
- `TP-Ansible-2-web_app_deployment/site.yml` and `webservers.yml` : master and role-specific playbooks.
- `TP-Ansible-2-web_app_deployment/roles/*/tasks/main.yml` : role task flow; use this to learn task ordering and `notify` handlers.
- `TP-Ansible-2-web_app_deployment/roles/*/templates/*.j2` : Jinja2 templates for systemd and Nginx configuration.
- `TP-Ansible-2-web_app_deployment/validate_structure.sh` : project structure checks used by maintainers.

**Conventions & patterns (project-specific)**
- Centralize configuration in `group_vars/appservers.yml`; prefer changing variables there rather than hardcoding in tasks.
- Use `handlers` for idempotent service actions (`handlers/main.yml` in roles). Always trigger via `notify`.
- Long-running operations (git clone, pip install) are executed with `async` to avoid SSH timeouts — preserve this pattern when adding heavy tasks.
- Use `become: yes` for system-level operations (user creation, package installs, systemd unit files).
- Templates use `.j2` and expect variables from `group_vars` (e.g., `app.service_name`, `app.user`, `app.domain`).

**Common workflows & commands**
- Start VMs (project root):
  - `cd TP-Ansible-2-web_app_deployment && vagrant up`
- Run full deployment (from that folder):
  - `ansible-playbook -i inventory.ini site.yml`
- Deploy only webservers role:
  - `ansible-playbook -i inventory.ini webservers.yml`
- Debug a failing run with extra verbosity:
  - `ansible-playbook -i inventory.ini webservers.yml -vvv`
- Check running service on a VM:
  - `vagrant ssh app1` then `sudo systemctl status <service_name>` (service name is `app.service_name` from `group_vars/appservers.yml`).

**Editing guidance for code changes**
- To change the deployed app or domain, update `group_vars/appservers.yml` (e.g., `app.repo_url`, `app.repo_version`, `app.domain`).
- When adding a role: add it under `roles/`, then include it in `site.yml` (or `webservers.yml`) and add any variables to `group_vars`.
- Keep tasks idempotent and emit `notify` for restarts; put restart/reload logic in `roles/*/handlers/main.yml`.

**Integration points & external dependencies**
- System packages (apt) and Python environment (`python3-venv`, `pip`) are installed by the `common` role.
- App code comes from a Git repository (`app.repo_url`) and is checked out on the target host.
- The deployed stack integrates with `systemd` (Gunicorn unit) and `nginx` (site file) — edits to templates affect runtime services.

**Examples (copyable)**
- `group_vars/appservers.yml` snippet:

```yaml
app:
  name: hello
  user: flask
  domain: hello.test
  repo_url: "https://example.com/repo.git"
  repo_version: master
  service_name: flask_hello
```

- Run just the webserver playbook and show verbose output:

```
cd TP-Ansible-2-web_app_deployment
ansible-playbook -i inventory.ini webservers.yml -vvv
```

**What not to change without cross-checking**
- `roles/*/templates/*.j2` — changes here require service reloads and may break runtime if variables differ.
- `group_vars/appservers.yml` keys — many templates and tasks expect exact keys like `app.service_name`.

If anything is unclear or you want more examples (Molecule tests, additional playbook patterns, or a smaller quick-run script), tell me which area to expand and I'll iterate.
