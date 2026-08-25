config = {
    vm_id          = 109
    vm_name        = "Media"
    cpu_cores      = 10
    memory_mb      = 16384
    disk_size_gb   = 32
    ip_address     = "192.168.1.252/24"
    network_bridge = "vmbr1"
    tags = [
        "docker",
        "linux",
        "production",
        "ubuntu",
    ]
    startup_order  = 6
    storage_name   = "local-lvm"

}
