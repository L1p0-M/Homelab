target_type = "VM"
ansible_groups = ["docker-hosts"]

config = {
    vm_id          = 105
    vm_name        = "Docs-Monitoring"
    cpu_cores      = 2
    memory_mb      = 2048
    disk_size_gb   = 32
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

}
