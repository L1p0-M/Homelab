target_type = "LXC"

config = {
    id             = 104
    name           = "Wireguard"
    cpu_cores      = 1
    memory_mb      = 206
    memory_swap    = 512
    disk_size_gb   = 5
    ip_address     = "192.168.1.55/24"
    network_bridge = "vmbr0"
    network_name   = "eth0"
    nesting        = true
    unprivileged   = true
    keyctl         = true
    image_storage  = "NASBackup"
    tags = [
        "debian",
        "linux",
        "production",
    ]
    description        = <<-EOT
                <div align='center'>
                <img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/wireguard.png" height="70px" width="70px"/>

                # Wireguard LXC
                ### Wireguard Server Host
                ### Ezen az LXC-n fut a Wireguard tunnel szerver.
                ### IP: 192.168.1.55
            EOT

}
