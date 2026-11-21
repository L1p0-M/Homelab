
resource "proxmox_virtual_environment_container" "lxc" {
  node_name    = var.node_config.node_name
  vm_id        = var.config.id
  description  = var.config.description
  tags         = var.config.tags
  unprivileged = var.config.unprivileged

  dynamic "clone" {
    for_each = var.config.template_id != null ? [1] : []
    content {
      vm_id = var.config.template_id
      full  = true
    }
  }

  features {
    nesting = var.config.nesting
    keyctl  = var.config.keyctl
  }

  console {
    enabled   = true
    tty_count = 2
    type      = "tty"
  }

  cpu {
    cores = var.config.cpu_cores
  }

  memory {
    dedicated = var.config.memory_mb
    swap      = var.config.memory_swap
  }

  disk {
    datastore_id = var.config.storage_name
    size         = var.config.disk_size_gb
  }

  network_interface {
    name   = var.config.network_name
    bridge = var.config.network_bridge
    firewall = var.config.firewall
  }

  startup {
    down_delay = var.config.startup_down_delay
    up_delay   = var.config.startup_up_delay
    order      = var.config.startup_order
  }


  dynamic "device_passthrough" {
    for_each = var.config.device_passthrough
    content {
      path = device_passthrough.value.path
    }
  }

  initialization {
    hostname = var.config.name
    ip_config {
      ipv4 {
        address = var.config.ip_address
        gateway = var.node_config.gateway
      }
    }
  }

  lifecycle {
    ignore_changes = [
      initialization,
      operating_system,
      clone,
    ]
  }
}
