terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.60.0"
    }
  }
}


# resource "proxmox_download_file" "latest_debian_13_trixie" {
#   content_type = "vztmpl"
#   datastore_id = var.config.image_storage
#   file_name    = "debian-13-generic-amd64.tar.xz"
#   node_name    = var.node_config.node_name
#   overwrite    = false
#   url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.tar.xz"
# }


resource "proxmox_virtual_environment_container" "lxc" {
  node_name    = var.node_config.node_name
  vm_id        = var.config.id
  description  = var.config.description
  tags         = var.config.tags
  unprivileged = var.config.unprivileged


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
    firewall = true
  }

  operating_system {
    template_file_id = "${var.config.image_storage}:vztmpl/debian-13-generic-amd64.tar.xz"
    type = "debian"
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
    user_account {
      keys     = var.sensitive.ssh_public_key != null ? [var.sensitive.ssh_public_key] : []
      password = var.sensitive.user_password
    }
  }

  lifecycle {
    ignore_changes = [
      initialization,
      operating_system
    ]
  }
}
