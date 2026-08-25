config = {
    vm_id          = 106
    vm_name        = "CI-Worker"
    cpu_cores      = 2
    memory_mb      = 2048
    disk_size_gb   = 32
    ip_address     = "192.168.1.125/24"
    network_bridge = "vmbr0"
    storage_name   = "local-lvm"
    tags = [
        "docker",
        "linux",
        "production",
        "ubuntu",
        "ci"
    ]

}
