target_type = "LXC"
ansible_groups = ["agent"]

config = {
    id             = 404
    name           = "Agent"
    cpu_cores      = 16
    memory_mb      = 8192
    memory_swap    = 512
    disk_size_gb   = 20
    ip_address     = "192.168.1.228/24"
    network_bridge = "vmbr0"
    network_name   = "eth0"
    nesting        = true
    unprivileged   = true
    keyctl         = false
    image_storage  = "TrueNAS-Share"
    storage_name   = "local"
    startup_order    = 4
    tags = [
        "debian",
        "linux",
        "production",
        "ai"
    ]
}
