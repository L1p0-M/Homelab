# Renovatebot with Cron (Rootless Docker Edition)

A lightweight, secure, and fully automated **Renovatebot** Docker image with an embedded Cron scheduler.

The official Renovate Docker image is designed for one-off runs or CI/CD pipelines. This project enables running Renovate continuously in the background on self-hosted infrastructure (Homelab, VPS, K8s) without relying on host-level schedulers.

---

## 💡 Why This Was Needed (The Problem & Solution)

Official Renovate images do not include an internal scheduler. Running it on a server traditionally required either:
1. Relying on host-system crontabs (less portable and harder to manage).
2. Using third-party images that run processes as `root` (a security risk).

**Key Features of This Image:**
* 🛡️ **Strictly Rootless / Non-Root:** All updates and Git operations run under an unprivileged `renovatebot` user inside the container.
* ⚡ **Immediate Startup Run + Cron:** Executes an initial update check **immediately** upon container startup—no waiting for the first cron interval—before handing off control to the background Cron daemon.
* 🔄 **Zombie-proof Process Handling:** Uses `tini` as PID 1 to reap orphan processes and handle `docker stop` (SIGTERM) signals gracefully.

---

## ⚙️ Environment Variables

> [!NOTE]
> **Full Official Support:** Every single environment variable supported by official Renovate works out-of-the-box here (e.g., `RENOVATE_PLATFORM`, `RENOVATE_AUTODISCOVER`, `LOG_LEVEL`, `RENOVATE_TOKEN`, etc.).  
> Check the official [Renovate Configuration Options Documentation](https://docs.renovatebot.com/configuration-options/) for all available flags.

### Wrapper-Specific Variables

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| **`CRON_SCHEDULE`** | `0 * * * *` | **Cron schedule expression.** *(Details below)* |
| `PUID` | `1000` | User ID for the internal `renovatebot` user. |
| `PGID` | `1000` | Group ID for the internal `renovatebot` group. |
| `TZ` | `Europe/Budapest` | Container timezone for accurate Cron execution. |

---

## ⏰ `CRON_SCHEDULE` Usage
> [!NOTE]
> The **`CRON_SCHEDULE`** environment variable defines how frequently Renovate scans your repositories using standard Cron syntax.

### Common Examples:

* **`0 * * * *`** *(Default)* – **Once every hour** at minute 0.
* **`*/30 * * * *`** – **Every 30 minutes**.
* **`0 */2 * * *`** – **Every 2 hours**.
* **`0 3 * * *`** – **Once a day** at 03:00 AM.
* **`0 8 * * 1-5`** – **Weekdays only** (Monday to Friday) at 08:00 AM.

---

## 🚀 Quickstart (Docker Compose)

Create a `docker-compose.yml` file:

```yaml
services:
  renovate:
    image: ghcr.io/l1p0-m/renovate-cron:latest
    container_name: renovate_bot
    restart: unless-stopped
    environment:
      - TZ=Europe/Budapest
      - PGID=1000
      - PUID=1000
      # Cron schedule: Once every hour
      - CRON_SCHEDULE=0 * * * *
      # Platform Personal Access Token
      - RENOVATE_TOKEN=ghp_your_personal_access_token_here
      # Platform and Discovery settings (Any official Renovate env var works)
      - RENOVATE_PLATFORM=github
      - RENOVATE_AUTODISCOVER=true
      - RENOVATE_REPOSITORIES=user/repo
```

Run the container:
```bash
docker compose up -d
```

---

## 📋 License

This project is licensed under the [**GNU Affero General Public License v3.0 (AGPLv3)**](LICENSE), matching the license of the upstream [Renovatebot](https://github.com/renovatebot/renovate).
