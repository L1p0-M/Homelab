# Homelab Infrastructure

Welcome to the documentation and configuration repository for my self-hosted 4-node physical server cluster. This infrastructure powers my private cloud, automated disaster recovery pipelines, custom AI workloads, and CI/CD pipelines.

<div align="center">
 
[![Update Docker Containers](https://github.com/L1p0-M/Homelab/actions/workflows/deploy.yml/badge.svg?branch=main)](https://github.com/L1p0-M/Homelab/actions/workflows/deploy_docker.yml)
[![Build&Pulish Renovate-Cron](https://github.com/L1p0-M/Homelab/actions/workflows/publish_renovate.yml/badge.svg)](https://github.com/L1p0-M/Homelab/actions/workflows/publish_renovate.yml)
[![Build&Publish Watcher-Agent](https://github.com/L1p0-M/Homelab/actions/workflows/publish_watcher_agent.yml/badge.svg)](https://github.com/L1p0-M/Homelab/actions/workflows/publish_watcher_agent.yml)

[![Terraform](https://img.shields.io/badge/Terraform-IaC-378144?style=flat-square&logo=terraform&logoColor=white&labelColor=0f1410)](https://www.terraform.io)
[![Last Commit](https://img.shields.io/github/last-commit/L1p0-M/Homelab?style=flat-square&labelColor=0f1410&color=378144)](https://github.com/L1p0-M/Homelab/commits/main)
[![License: MIT](https://img.shields.io/github/license/L1p0-M/Homelab?style=flat-square&labelColor=0f1410&color=378144)](LICENSE)

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
