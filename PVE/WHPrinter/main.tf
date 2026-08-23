module "proxmox_vm" {
  source = "../../.terraform-modules/proxmox-vm"

  node_name      = var.node_name
  storage_name   = var.storage_name
  network_bridge = var.network_bridge
  gateway        = var.gateway
  template_vm_id = var.template_vm_id

  vm_id          = var.vm_id
  vm_name        = var.vm_name
  cpu_cores      = var.cpu_cores
  memory_mb      = var.memory_mb
  disk_size_gb   = var.disk_size_gb
  ip_address     = var.ip_address
  startup_order  = var.startup_order
  tags           = var.tags
  description    = var.description
  scsi_hardware  = var.scsi_hardware
  startup_up_delay   = var.startup_up_delay
  startup_down_delay = var.startup_down_delay
  iothread       = var.iothread
  usb_passthrough = var.usb_passthrough
}
