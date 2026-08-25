config = {
  vm_id          = 120
  vm_name        = "WHPrinter"
  cpu_cores      = 1
  memory_mb      = 512
  disk_size_gb   = 8
  ip_address     = "192.168.1.250/24"
  network_bridge = "vmbr0"
  tags = [
      "alpine",
      "linux",
      "production",
  ]
  storage_name    = "local-lvm"
  scsi_hardware   = "virtio-scsi-single"
  iothread        = true
  usb_passthrough = [
    {
      host = "03f0:8911"
      usb3 = false
    }
  ]

}
