target_type = "LXC"
ansible_groups = ["Whisper"]

config = {
    id             = 402
    name           = "Whisper"
    cpu_cores      = 16
    memory_mb      = 8192
    memory_swap    = 512
    disk_size_gb   = 20
    ip_address     = "192.168.1.226/24"
    network_bridge = "vmbr0"
    network_name   = "eth0"
    nesting        = true
    unprivileged   = true
    keyctl         = false
    image_storage  = "TrueNAS-Share"
    storage_name   = "local"
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
        "debian",
        "linux",
        "production",
        "ai"
    ]
}
