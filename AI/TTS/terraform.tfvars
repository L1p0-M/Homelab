target_type = "LXC"
ansible_groups = ["tts"]

config = {
    id             = 403
    name           = "TTS"
    cpu_cores      = 16
    memory_mb      = 8192
    memory_swap    = 512
    disk_size_gb   = 25
    ip_address     = "192.168.1.227/24"
    network_bridge = "vmbr0"
    network_name   = "eth0"
    nesting        = true
    unprivileged   = true
    keyctl         = false
    image_storage  = "TrueNAS-Share"
    storage_name   = "local"
    startup_order    = 3
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
