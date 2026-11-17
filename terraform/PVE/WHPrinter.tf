module "whprinter" {
    source = "../modules/proxmox-vm"
    node_config = var.node_config
    depends_on = [module.bootstrap]

    target_type = "VM"
    ansible_groups = ["printer"]

    config = {
        vm_id          = 120
        vm_name        = "WHPrinter"
        cpu_cores      = 1
        memory_mb      = 512
        ip_address     = "192.168.1.250/24"
        network_bridge = "vmbr0"
        tags = [
        "alpine",
        "linux",
        "production",
        ]
        scsi_hardware   = "virtio-scsi-single"
        usb_passthrough = [
        {
            host = "03f0:8911"
            usb3 = false
        }
        ]
        disk = [
            { 
                disk_size_gb  = 8
                iothread      = true
                storage_name = "local-lvm"
                interface    = "scsi0"
                ssd          = true
            }
        ]
    }
}
