# My Enterprise level Homelab

Welcome to the documentation and configuration repository for my self-hosted 4-node physical server cluster. This infrastructure powers my private cloud, automated disaster recovery pipelines, custom AI workloads, and CI/CD pipelines.

---

## 📐 Network & Architecture Topology
TODO

## Hardware

### 🛠️ Hardware & Node Architecture

| Node | Model & Hardware | Hypervisor / OS | Key Roles & Workloads | Storage Setup |
| :--- | :--- | :--- | :--- | :--- |
| **PVE** | Supermicro H12SSL-I<br>`AMD EPYC 7252 (8C/16T)` / `128GB DDR4 ECC` | Proxmox VE | **Primary Compute & NAS**<br>• TrueNAS VM (PCIe Passthrough)<br>• Docker Prod (40+ Containers)<br>• Self-Hosted CI/CD Runner<br>• Home Assistant VM<br>• Media Server<br>• Monitoring VM & Grafana | **ZFS ZRAID1 Mirror**<br>• 3TB+2TB+2TB+4TB+1TB POOLS<br>• Direct Passthrough HBA connected to Supermicro JBOD |
| **BACKUP** | Supermicro 1U<br>`[CPU Modell]` / `RAM` | Proxmox VE | **Backup Target & Disaster Recovery**<br>• Automated WoL Target<br>• ZFS Replication & Rsync Receiver | High-Capacity ZFS Backup Pool |
| **FIREWALL** | Asus P10S-M <br>`INTEL XEON E3-1270 V6 (C/T)` / `16GB DDR4` | Proxmox VE | **Firewall/Router/VLAN/DNS**<br> | 256GB 2,5" SSD |
| **AI** | Supermicro X10DRC-LN4+<br>`2x INTEL XEON E5-2637 V3 (4C/8T)` / `128GB DDR4 ECC` / `RTX 3060 12GB` | Proxmox VE | **AI Workloads**<br>• Local LLM Hosting<br>• GPU Acceleration Passthrough | 128GB NVME SSD
| **UPS** | Zinto UPS<br>`ZINTO800` | Dedicated LXC on PVE(Debian) & USB Passthrough | **Power Redundancy & Protection**<br>• Network UPS Tools (NUT)<br>• Automated Graceful Shutdown Trigger |

