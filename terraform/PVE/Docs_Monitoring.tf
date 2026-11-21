module "docs_monitoring" {
    source = "../modules/proxmox-vm"
    node_config = var.node_config
    depends_on = [module.bootstrap]

    ansible_groups = ["docker_hosts"]

    config = {
        vm_id          = 105
        template_vm_id = 999
        vm_name        = "Docs-Monitoring"
        cpu_cores      = 2
        memory_mb      = 2048
        ip_address     = "192.168.1.26/24"
        network_bridge = "vmbr1"
        tags = [
            "docker",
            "linux",
            "production",
            "ubuntu",
        ]
        startup_order      = 5
        startup_down_delay = 10
        startup_up_delay   = 10
        disk = [
            { 
                disk_size_gb  = 32
                iothread      = true
                storage_name = "local-lvm"
                interface    = "scsi0"
                ssd          = true
            }
        ]
    }
}
