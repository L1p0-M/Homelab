vm_id          = 100
vm_name        = "Docker"
cpu_cores      = 10
memory_mb      = 16384
disk_size_gb   = 85
ip_address     = "192.168.1.24/24"
network_bridge = "vmbr0"
tags = [
    "docker",
    "ubuntu",
    "linux",
    "production",
]
template_vm_id     = null
startup_order      = 3
startup_up_delay   = 80
scsi_hardware      = "virtio-scsi-pci"
iothread           = false
description        = <<-EOT
            <div align='center'>
            <img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/docker-moby.png" height="70px" width="100px"/>

            # Docker Host VM
            ### Ezen a Virtuális gépen megy minden ami Docker!
            ### IP: 192.168.1.24
        EOT
