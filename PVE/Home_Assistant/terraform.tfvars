vm_id          = 101
vm_name        = "Home-Assistant"
cpu_cores      = 2
cpu_type       = "qemu64"
memory_mb      = 4096
disk_size_gb   = 32
ip_address     = "192.168.1.22/24"
network_bridge = "vmbr1"
tags = [
    "homeassistant",
    "linux",
    "production",
]
template_vm_id     = null
startup_order      = 4
startup_up_delay   = 10
bios_type          = "ovmf"
efi_disk           = "local-lvm"
scsi_hardware      = "virtio-scsi-pci"
iothread           = false
description        = <<-EOT
            ![HA logo](https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/home-assistant-alt.png)

            # Home Assistant OS
            ### https://github.com/tteck/Proxmox
            ### IOT Szerver
            ### IP: 192.168.1.22
            [![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/D1D7EP4GF)
        EOT
