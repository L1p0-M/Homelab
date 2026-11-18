module "truenas" {
    source = "../modules/proxmox-vm"
    node_config = var.node_config
    depends_on = [module.bootstrap]

    ansible_groups = ["excluded", "nas"]

    config = {
        vm_id          = 103
        vm_name        = "TrueNAS"
        cpu_cores      = 2
        cpu_type       = "qemu64"
        memory_mb      = 32768
        ip_address     = "192.168.1.90/24"
        network_bridge = "vmbr2"
        tags = [
            "linux",
            "nas",
            "production",
        ]
        startup_order    = 1
        startup_up_delay = 30
        scsi_hardware    = "virtio-scsi-single"
        description      = <<-EOT
                    <div align='center'>
                    <img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/truenas-core.png" height="70px" width="70px"/>

                    # TrueNAS VM
                    ### Ez a virtuális gép a NAS,ezen vannak a ZFS Poolok!
                    ### IP: 192.168.1.90
                EOT
        disk = [
            { 
                disk_size_gb  = 32
                iothread      = true
                storage_name = "local-lvm"
                interface    = "scsi0"
                ssd          = true
            },
            { 
                disk_size_gb  = 32
                iothread      = true
                storage_name = "local-lvm"
                interface    = "scsi1"
                ssd          = true
                backup       = false
            }
        ]
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
    }
}