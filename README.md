<div align="center">

![img](./assets/logo.png)
# Homelab Infrastructure
Welcome to the documentation and configuration repository for my self-hosted 4-node physical server cluster. This infrastructure powers my private cloud, automated disaster recovery pipelines, custom AI workloads, and CI/CD pipelines.
 

[![Run Ansible Playbook / Deploy Services](https://img.shields.io/github/actions/workflow/status/L1p0-M/Homelab/deploy_ansible_playbook.yml?style=flat-square&logo=ansible&logoColor=white&labelColor=0f1410&color=%23005082&label=Run%20Ansible%20Playbook%20%2F%20Deploy%20Services)](https://github.com/L1p0-M/Homelab/actions/workflows/deploy_ansible_playbook.yml)
[![Deploy/Update Infrastructure](https://img.shields.io/github/actions/workflow/status/L1p0-M/Homelab/infra_plan_deploy.yml?style=flat-square&logo=proxmox&logoColor=white&labelColor=0f1410&color=%23005082&label=Deploy%20%2F%20Update%20Infrastructure)](https://github.com/L1p0-M/Homelab/actions/workflows/infra_plan_deploy.yml)



[![Terraform](https://img.shields.io/badge/Terraform-IaC-378144?style=flat-square&logo=terraform&logoColor=white&labelColor=0f1410&color=%23005082)](https://www.terraform.io)
[![Ansible](https://img.shields.io/badge/Ansible-IaC-378144?style=flat-square&logo=ansible&logoColor=white&labelColor=0f1410&color=%23005082)](https://docs.ansible.com)

[![Last Commit](https://img.shields.io/github/last-commit/L1p0-M/Homelab?style=flat-square&logo=github&logoColor=white&labelColor=0f1410&color=%23005082)](https://github.com/L1p0-M/Homelab/commits/main)
[![License: MIT](https://img.shields.io/github/license/L1p0-M/Homelab?style=flat-square&logo=github&logoColor=white&labelColor=0f1410&color=%23005082)](LICENSE)
![Protected by](https://img.shields.io/badge/Protected%20by-Gitleaks-378144?style=flat-square&logo=github&logoColor=white&labelColor=0f1410&color=%23005082)

</div>


---

## 📐 Network & Architecture Topology

## Hardware

### 🛠️ Hardware & Node Architecture

| Node | Model & Hardware | Hypervisor / OS | Key Roles & Workloads | Storage Setup | IP |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **PVE** | Supermicro H12SSL-I<br>`AMD EPYC 7252 (8C/16T)` / `128GB DDR4 ECC` | Proxmox VE | **Primary Compute & NAS**<br>• TrueNAS VM (PCIe Passthrough)<br>• Docker Prod (40+ Containers)<br>• Self-Hosted CI/CD Runner<br>• Home Assistant VM<br>• Media Server VM<br>• Monitoring VM & Grafana<br>•Wireguard VPN LXC<br>•Print & Scan Server VM (USB Passthrough)<br>• Cloudflare DDNS Updater LXC | **ZFS Mirror**<br>• Pools: 2x3TB + 2x2TB + 2x2TB + 2x4TB + 2x1TB<br>• Direct Passthrough LSI HBA connected to Supermicro JBOD | **IPMI:** 192.168.1.44<br>**IP:** 192.168.1.200 | 
| **BACKUP** | Supermicro X8SIL-F<br>`INTEL XEON L3426 (4C/8T)` / `12GB DDR3 ECC` | Proxmox VE | **Backup Target & Disaster Recovery**<br>• Automated WoL Target<br>• ZFS Replication & Rsync Receiver | High-Capacity ZFS Backup Pool | **IPMI:** 192.168.1.45<br>**IP:** 192.168.1.201 | 
| **FIREWALL** | Asus P10S-M <br>`INTEL XEON E3-1270 V6 (4C/8T)` / `16GB DDR4` | Proxmox VE | **Firewall/Router/VLAN/DNS**<br>• OPNSense VM with NIC Passthrough  | 256GB 2,5" SSD | **IP:** 192.168.1.202 | 
| **AI** | Supermicro X10DRC-LN4+<br>`2x INTEL XEON E5-2637 V3 (8C/16T)` / `128GB DDR4 ECC` / `RTX 3060 12GB` | Proxmox VE | **AI Workloads**<br>• Local LLM Hosting<br>• GPU Acceleration Passthrough | 128GB NVME SSD | **IPMI:** 192.168.1.46<br>**IP:** 192.168.1.203 | 
| **UPS** | Zinto UPS<br>`ZINTO800` | Dedicated NUT LXC on PVE (Debian)<br>**USB Passthrough** | **Power Redundancy & Protection**<br>• Network UPS Tools (NUT)<br>• Automated Graceful Shutdown Trigger | |**NUT IP:** 192.168.1.53 | 


### 🛡️ Disaster Recovery & Backup Strategy (3-2-1 Rule)

Data integrity and high availability are core priorities of this homelab architecture:

* **Primary On-Site Backups:** The **PVE** node backs up local workloads directly to its local ZFS ZRAID1 pool 3 times a week.
* **Cold Offline Backup (Local Storage):** Once a week, the primary **PVE** node executes an automated backup of all critical VMs and LXC containers to a physically attached external hard drive.
* **Automated WoL & Remote Backup Workflow:** 
  * The **BACKUP** node remains powered off to save energy. 
  * Every Sunday, a scheduled cronjob on the primary PVE node executes an orchestration script that powers on the BACKUP node via **IPMI**.
  * Once the BACKUP node is online and pingable, a pull process triggers: **Rsync** syncs the latest ZFS snapshots, followed by a full **ZFS dataset replication**.
  * Upon successful replication, the script automatically triggers a graceful shutdown of the BACKUP node.
* **Offsite Backup:** Critical configuration files, databases, and core data are encrypted and pushed offsite weekly via custom scripts using **Rclone**.

### 📊 Monitoring, Alerting & Observability
System health and performance are continuously tracked via a centralized observability stack:

**Metrics Collection:** Prometheus + Node Exporters (PVE, Docker, IPMI metrics).

**Visualization:** Grafana dashboards for monitoring CPU/RAM/Network usage, ZFS pool status, and hardware temperatures.

**Alerting:** E-Mail / SMS notifications for critical events (e.g., ZFS degraded state, high temperatures, UPS battery alerts, Failed Tasks).

### 🧠 AI Workloads & Local Inference
The purpose-built AI node enables local inference for private LLMs and AI models in a privacy-focused environment:

**Hardware Passthrough:** Direct PCIe passthrough assigns the NVIDIA RTX 3060 (12GB VRAM) to the designated AI LXCs.

**Engine:** Ollama / llama.cpp for model orchestration (Qwen3 With my Own Fine-tune).

**Integration:** Integrated with internal services (Open-WebUI, Home Assistant).

**Tool & Function Calling Integration:** My custom-built FastAPI proxy bridges the local LLMs with external tools, custom APIs, and system-level automation workflows.

---

## 📂 Repository Structure

```
Homelab/
├── 🔧 Terraform Infrastructure
│   ├── modules/                    # Reusable infrastructure modules
│   │   ├── proxmox-vm/            # Proxmox VM configuration template
│   │   ├── proxmox-lxc/           # Proxmox LXC container template
│   │   ├── proxmox-bootstrap/     # Cloud-init VM template for bootstrapping
│   │   └── cloudflare/            # DNS & Cloudflare management
│   ├── PVE/                       # PVE node configuration (complete)
│   │   ├── CI_Worker.tf           # GitHub/Gitea CI Runner
│   │   ├── Cloudflare_DDNS.tf     # Dynamic DNS updater
│   │   ├── Docker.tf              # Docker host + 25+ containers
│   │   ├── Docs_Monitoring.tf     # Grafana, Prometheus, Portainer, Gitea
│   │   ├── Home_Assistant.tf      # Home Assistant VM
│   │   ├── Media.tf               # Jellyfin media server
│   │   ├── Network_UPS.tf         # NUT UPS management
│   │   ├── TrueNAS.tf             # TrueNAS storage VM (PCIe passthrough)
│   │   ├── WHPrinter.tf           # Windows print & scan server
│   │   └── Wireguard.tf           # WireGuard VPN
│   ├── Cloudflare/                # DNS zones & records management
│   └── AI/                        # AI node configuration (in progress)
│       ├── Agent.tf               # LLM agent container
│       ├── Cortana-Model.tf       # Fine-tuned model serving
│       ├── TTS.tf                 # Text-to-Speech service
│       └── Whisper.tf             # Speech-to-text service
├── 🤖 Ansible Playbooks
│   ├── roles/                     # Modular role collection
│   │   ├── base/                  # System hardening, SSH, packages
│   │   ├── ddns/                  # Cloudflare DDNS client
│   │   ├── docker_host/           # Docker setup + stack deployment
│   │   ├── printer/               # CUPS/SANE print server
│   │   ├── ups/                   # NUT UPS monitoring
│   │   └── vpn/                   # WireGuard VPN configuration
│   ├── hosts/                     # Node inventory
│   ├── group_vars/                # Shared variables per group
│   └── host_vars/                 # Per-node variables
├── 📁 PVE Services (per-service config)
│   ├── CI_Worker/                 # CI runner configs
│   ├── Docker/                    # Docker Compose stacks (25+)
│   ├── Docs_Monitoring/           # Monitoring stack configs
│   ├── Home_Assistant/            # HA configuration
│   ├── Media/                     # Jellyfin config
│   ├── Network_UPS/               # NUT config
│   ├── TrueNAS/                   # TrueNAS export settings
│   ├── WHPrinter/                 # Printer configs
│   └── Wireguard/                 # VPN configs
├── 🤖 AI Services
│   ├── Agent/                     # Ollama/LangChain agent
│   ├── Cortana-Model/             # Fine-tuned model config
│   ├── TTS/                       # TTS service config
│   └── Whisper/                   # Whisper STT config
├── 🔒 secrets.yaml.enc            # Git-crypt encrypted secrets
├── 🔄 renovate.json               # Renovate auto-update config
└── 📄 LICENSE                     # MIT License
```

---

## 🚀 Quick Start & Bootstrap

### Prerequisites
* **Proxmox VE** installed on all nodes (8.2+)
* **Terraform** v1.6+ and **Ansible** v8+
* **Cloudflare API token** with DNS and account permissions
* **Git-crypt** for encrypted secrets management

### Bootstrap Workflow

The infrastructure follows a **two-phase bootstrap process**:

#### Phase 1: Terraform Infrastructure Provisioning
```bash
# 1. Initialize Terraform modules
terraform init

# 2. Apply Cloudflare DNS first (DNS must exist before VM creation)
cd terraform/Cloudflare && terraform apply

# 3. Bootstrap PVE node (creates all VMs/LXCs with cloud-init templates)
cd ../PVE && terraform apply -var-file=node.tfvars

# 4. Apply AI node configuration (when ready)
cd ../AI && terraform apply -var-file=node.tfvars
```

#### Phase 2: Ansible Configuration Management
```bash
# Bootstrap all provisioned nodes
ansible-playbook site.yml -i hosts/production

# Deploy specific roles
ansible-playbook roles/docker_host/tasks/main.yml
ansible-playbook roles/vpn/tasks/main.yml
```

### Cloud-init Template
The `proxmox-bootstrap` module creates a **cloud-init enabled VM template** that:
* Sets up hostname, SSH keys, and users automatically
* Configures network interfaces (DHCP/static)
* Installs essential packages on first boot
* Enables unattended provisioning of new VMs/LXCs

---

## 🔐 Secrets Management

All sensitive data is encrypted with **Git-crypt**. To decrypt:
```bash
git-crypt unlock <your-gpg-key-id>
terraform plan -var-file=secrets.yaml.enc
```

### Required Variables
* `cloudflare_api_token` — DNS management API token
* `proxmox_url` — Proxmox API endpoint (e.g., `https://pve:8006/api2/json`)
* `proxmox_user` — Proxmox user (e.g., `root@pam`)
* `proxmox_password` / `proxmox_token` — Authentication

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).
