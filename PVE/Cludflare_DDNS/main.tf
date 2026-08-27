module "proxmox_vm" {
  source = "../../.terraform-modules/proxmox-lxc"
  node_config = var.node_config
  config      = var.config
  sensitive   = var.sensitive
}