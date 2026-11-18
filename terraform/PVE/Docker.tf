module "docker" {
    source = "../modules/proxmox-vm"
    node_config = var.node_config
    depends_on = [module.bootstrap]

    ansible_groups = ["docker_hosts", "node_exporters"]

    config = {
        vm_id          = 100
        vm_name        = "Docker"
        cpu_cores      = 10
        memory_mb      = 16384
        ip_address     = "192.168.1.24/24"
        network_bridge = "vmbr0"
        tags = [
            "docker",
            "ubuntu",
            "linux",
            "production",
        ]
        startup_order    = 3
        startup_up_delay = 80
        scsi_hardware    = "virtio-scsi-pci"
        description      = <<-EOT
                    <div align='center'>
                    <img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/docker-moby.png" height="70px" width="100px"/>

                    # Docker Host VM
                    ### Ezen a Virtuális gépen megy minden ami Docker!
                    ### IP: 192.168.1.24
                EOT
        disk = [
            { 
                disk_size_gb  = 85
                iothread      = false
                storage_name = "local-lvm"
                interface    = "scsi0"
                ssd          = true
            }
        ]
    }
}