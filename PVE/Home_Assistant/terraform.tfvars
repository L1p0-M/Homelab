config = {
    vm_id          = 101
    vm_name        = "Home-Assistant"
    cpu_cores      = 2
    cpu_type       = "qemu64"
    memory_mb      = 4096
    disk_size_gb   = 32
    ip_address     = "192.168.1.22/24"
    network_bridge = "vmbr1"
    tags = [
        "homeassistant",
        "linux",
        "production",
    ]
    storage_name       = "local-lvm"
    startup_order      = 4
    startup_up_delay   = 10
    bios_type          = "ovmf"
    efi_disk           = "local-lvm"
    scsi_hardware      = "virtio-scsi-pci"
    iothread           = false
    description        = <<-EOT
                <div align='center'>
                <img src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/home-assistant-alt.png" height="70px" width="80px"/>

                # Home Assistant OS
                ### IOT Szerver
                ### IP: 192.168.1.22
            EOT

}
