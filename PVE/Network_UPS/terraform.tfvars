target_type = "LXC"

config = {
    id             = 102
    name           = "Network-UPS"
    cpu_cores      = 1
    memory_mb      = 206
    memory_swap    = 512
    disk_size_gb   = 10
    ip_address     = "192.168.1.53/24"
    network_bridge = "vmbr0"
    network_name   = "eth0"
    nesting        = true
    unprivileged   = true
    keyctl         = false
    image_storage  = "NASBackup"
    startup_up_delay = 40
    startup_order    = 2
    device_passthrough = [
        {
            path = "/dev/bus/usb/005/002",
        }
    ]
    tags = [
        "debian",
        "linux",
        "production",
    ]
    description        = <<-EOT
                <div align='center'>
                <img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/network-ups-tools.png" height="70px" width="70px"/>


                # Network-UPS-Tools LXC
                ### NUT Server Host
                ### Ehhez az LXC-hez csatlakozik az UPS USB-je.
                ### IP: 192.168.1.53
            EOT


}
