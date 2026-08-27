config = {
    id             = 111
    name           = "Cloudflare-DDNS"
    cpu_cores      = 2
    memory_mb      = 1024
    memory_swap    = 512
    disk_size_gb   = 3
    ip_address     = "192.168.1.124/24"
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
                <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cloudflare.svg" height="100px" width="100px"/>
                <h2 style='font-size: 24px; margin: 20px 0;'>Cloudflare-DDNS LXC</h2>

                ### IP: 192.168.1.124
            EOT

}
