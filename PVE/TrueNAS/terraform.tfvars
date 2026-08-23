vm_id          = 103
vm_name        = "TrueNAS"
cpu_cores      = 2
cpu_type       = "qemu64"
memory_mb      = 32768
disk_size_gb   = 32
ip_address     = "192.168.1.90/24"
network_bridge = "vmbr2"
tags = [
    "linux",
    "nas",
    "production",
]
template_vm_id     = null
startup_order      = 1
startup_up_delay   = 30
scsi_hardware      = "virtio-scsi-single"
iothread           = true
description        = <<-EOT
            <div align='center'>
            <img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/truenas-core.png" height="70px" width="70px"/>

            # TrueNAS VM
            ### Ez a virtuális gép a NAS,ezen vannak a ZFS Poolok!
            ### IP: 192.168.1.90
        EOT

hostpci = [
    {
        device   = "hostpci0"
        id       = "0000:49:00"
    },
    {
        device   = "hostpci1"
        id       = "0000:4a:00"
    },
    {
        device   = "hostpci2"
        id       = "0000:84:00"
    },
    {
        device   = "hostpci3"
        id       = "0000:83:00"
    },
    {
        device   = "hostpci4"
        id       = "0000:c1:00"
    }
]


