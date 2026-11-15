target_type = "VM"
ansible_groups = ["docker_hosts"]

config = {
    vm_id          = 109
    vm_name        = "Media"
    cpu_cores      = 10
    memory_mb      = 16384
    ip_address     = "192.168.1.252/24"
    network_bridge = "vmbr1"
    tags = [
        "docker",
        "linux",
        "production",
        "ubuntu",
    ]
    startup_order  = 6
    tablet_device  = true
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
