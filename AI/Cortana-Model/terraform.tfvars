target_type = "LXC"
ansible_groups = ["AI"]

config = {
    id             = 401
    name           = "Cortana-Model"
    cpu_cores      = 16
    memory_mb      = 122880
    memory_swap    = 512
    disk_size_gb   = 120
    ip_address     = "192.168.1.225/24"
    network_bridge = "vmbr0"
    network_name   = "eth0"
    nesting        = true
    unprivileged   = true
    keyctl         = false
    image_storage  = "NASBackup"
    startup_order    = 1
    device_passthrough = [
        {
            path = "/dev/nvidia0",
        },
        {
            path = "/dev/nvidiactl",
        },
        {
            path = "/dev/nvidia-uvm"
        },
        {
            path = "/dev/nvidia-uvm-tools"
        },
        {
            path = "/dev/nvidia-caps/nvidia-cap1"
        },
        {
            path = "/dev/nvidia-caps/nvidia-cap2"
        }
    ]
    tags = [
        "ubuntu",
        "linux",
        "production",
        "ai"
    ]
}
