# 🛡️ Config Drift Watcher Agent

A lightweight Dockerized monitoring agent that automatically detects **configuration drift** between a Git repository (Source of Truth) and host system configurations (e.g., Docker Compose files, `.env` files, templates).

It periodically scans specified directories, compares SHA-256 hashes, generates Markdown reports, and alerts you via **Emails**.

---

## ✨ Features

* **Git-as-Source-of-Truth:** Automatically clones or pulls the latest configurations from a remote Git repository.
* **Hash-based Drift Detection:** Computes SHA-256 digests to detect content mismatches on tracked files (`docker-compose.*`, `.env.enc`, `*.template`).
* **Untracked & Missing File Discovery:** Identifies files missing on the host or new files added on the host.
* **Automated Email Reports:** Converts Markdown reports into styled HTML emails and sends them via SMTP.
* **Scheduled Scans (Cron):** Runs periodically using `crond` and `tini` inside an Alpine-based lightweight container.
* **Non-Root Execution:** Runs internal scripts safely using `su-exec` with configurable `PUID` and `PGID`.

---

## 📁 Repository Structure Expectation

The agent expects your Git repository to follow a specific path structure:

```text
<your-git-repo>/
  ├── <NODE>/
  │   └── <VM_NAME>/
  │       └── Configs/
  │           └── <service-name>/
  │               ├── docker-compose.yml
  │               ├── .env.enc
  │               └── app.template
```

* **`NODE`**: The physical or logical cluster node name.
* **`VM_NAME`**: The specific VM or container host name.

---

## ⚙️ Environment Variables

| Variable | Required | Default | Description |
| :--- | :---: | :---: | :--- |
| `REPO` | **Yes** | — | Target repository in `owner/repo` format (e.g., `l1p0-m/homelab`). |
| `NODE` | **Yes** | — | Node folder inside the repo. |
| `VM_NAME` | **Yes** | — | VM folder inside the repo. |
| `CONFIGDIR` | No | `/app/config` | Host configuration directory path inside the container. |
| `DRY_RUN` | No | `true` | Currently used for controlling automatic fix actions. |
| `CRON_SCHEDULE` | No | `0 23 * * mon` | Cron schedule string (Default: Every Monday at 23:00). |
| `PUID` | No | `1000` | User ID for non-root execution. |
| `PGID` | No | `1000` | Group ID for non-root execution. |

### 📧 SMTP / Email Configuration (Optional)

If all SMTP variables are set, the agent will send an HTML report after every run:

| Variable | Required for Email | Description |
| :--- | :---: | :--- |
| `EMAIL_TO` | Yes | Recipient email address. |
| `EMAIL_FROM` | Yes | Sender email address. |
| `SMTP_SERVER` | Yes | SMTP server hostname or IP. |
| `SMTP_PORT` | Yes | SMTP server port (e.g., `587` or `465`). |
| `SMTP_USER` | Yes | SMTP username for authentication. |
| `SMTP_PASSWORD` | Yes | SMTP password for authentication. |

---

## 🚀 Quick Start & Examples

> ⚠️ **Important:** You must mount your local host configuration directory into the container path defined by `CONFIGDIR`.

### 1. Using Docker CLI

```bash
docker run -d \
  --name watcher-agent \
  --restart unless-stopped \
  -e REPO="myuser/infrastructure-configs" \
  -e NODE="pve-node-01" \
  -e VM_NAME="docker-host-vm" \
  -e CONFIGDIR="/app/config" \
  -e CRON_SCHEDULE="0 2 * * *" \
  -e EMAIL_TO="admin@example.com" \
  -e EMAIL_FROM="watcher@example.com" \
  -e SMTP_SERVER="smtp.example.com" \
  -e SMTP_PORT="587" \
  -e SMTP_USER="watcher@example.com" \
  -e SMTP_PASSWORD="secretpassword" \
  -v /opt/docker/configs:/app/config:ro \
  ghcr.io/l1p0-m/config-watcher-agent
```

---

### 2. Using Docker Compose (Recommended)

Create a `docker-compose.yml` file on your host:

```yml
services:
  drift-watcher:
    image: ghcr.io/l1p0-m/config-watcher-agent:latest
    container_name: drift-watcher
    restart: unless-stopped
    environment:
      # General Configuration
      - REPO=myuser/infrastructure-configs
      - NODE=pve-node-01
      - VM_NAME=docker-host-vm
      - CONFIGDIR=/app/config
      - CRON_SCHEDULE=0 23 * * mon   # Run every Monday at 23:00
      - DRY_RUN=true
      - PUID=1000
      - PGID=1000

      # Email Notifications
      - EMAIL_TO=admin@example.com
      - EMAIL_FROM=watcher@example.com
      - SMTP_SERVER=smtp.example.com
      - SMTP_PORT=587
      - SMTP_USER=watcher@example.com
      - SMTP_PASSWORD=secretpassword
    volumes:
      # Mount the host configuration path to matching CONFIGDIR inside container
      - /opt/docker/configs:/app/config:ro

```

Run the container:

```bash
docker compose up -d
```

---

## 🔍 How it Works

1. **Initialization:** On container launch, `entrypoint.sh` sets up the `watcher` system user with the specified `PUID`/`PGID`.
2. **Cron Setup:** Configures `/var/spool/cron/crontabs/root` using `CRON_SCHEDULE` to run `app.py`.
3. **Execution Pipeline (`app.py`):**
   * Verifies required environment variables.
   * Clones or pulls the configured Git repository (`REPO`).
   * Iterates through tracked template/config files (`docker-compose.*`, `.env.enc`, `*.template`).
   * Calculates **SHA-256** checksums to compare files on the host vs. repository.
   * Detects untracked host files or missing Git files.
   * Renders a Jinja2 Markdown report saved locally to `/app/drift_report.md`.
   * Sends the styled HTML report via SMTP (if configured).

---

## 📄 License

[MIT](LICENSE) - Feel free to adapt and customize for your homelab or production infrastructure!
