# My Enterprise level Homelab

Welcome to the documentation and configuration repository for my self-hosted 4-node physical server cluster. This infrastructure powers my private cloud, automated disaster recovery pipelines, custom AI workloads, and CI/CD pipelines.

---

## 📐 Network & Architecture Topology
TODO

## Hardware

### 🛠️ Hardware & Node Architecture

| Node | Model & Hardware | Hypervisor / OS | Key Roles & Workloads | Storage Setup | IP |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **PVE** | Supermicro H12SSL-I<br>`AMD EPYC 7252 (8C/16T)` / `128GB DDR4 ECC` | Proxmox VE | **Primary Compute & NAS**<br>• TrueNAS VM (PCIe Passthrough)<br>• Docker Prod (40+ Containers)<br>• Self-Hosted CI/CD Runner<br>• Home Assistant VM<br>• Media Server VM<br>• Monitoring VM & Grafana<br>•Wireguard VPN LXC<br>•Print & Scan Server VM(USB Passthrough)<br>• Cloudflare DDNS Updater LXC | **ZFS ZRAID1 Mirror**<br>• Pools: 3TB + 2TB + 2TB + 4TB + 1TB<br>• Direct Passthrough LSI HBA connected to Supermicro JBOD | **IPMI:** 192.168.1.44<br>**IP:** 192.168.1.200 | 
| **BACKUP** | Supermicro X8SIL-F<br>`INTEL XEON L3426 (4C/8T)` / `12GB DDR3 ECC` | Proxmox VE | **Backup Target & Disaster Recovery**<br>• Automated WoL Target<br>• ZFS Replication & Rsync Receiver | High-Capacity ZFS Backup Pool | **IPMI:** 192.168.1.45<br>**IP:** 192.168.1.201 | 
| **FIREWALL** | Asus P10S-M <br>`INTEL XEON E3-1270 V6 (4C/8T)` / `16GB DDR4` | Proxmox VE | **Firewall/Router/VLAN/DNS**<br> | 256GB 2,5" SSD | **IP:** 192.168.1.202 | 
| **AI** | Supermicro X10DRC-LN4+<br>`2x INTEL XEON E5-2637 V3 (8C/16T)` / `128GB DDR4 ECC` / `RTX 3060 12GB` | Proxmox VE | **AI Workloads**<br>• Local LLM Hosting<br>• GPU Acceleration Passthrough | 128GB NVME SSD | **IPMI:** 192.168.1.46<br>**IP:** 192.168.1.203 | 
| **UPS** | Zinto UPS<br>`ZINTO800` | Dedicated LXC on PVE(Debian) & USB Passthrough | **Power Redundancy & Protection**<br>• Network UPS Tools (NUT)<br>• Automated Graceful Shutdown Trigger | |**IP:** 192.168.1.53 | 

