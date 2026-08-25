terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.60.0"
    }
  }
}

variable "sensitive" {
  type = object({
    ssh_public_key = optional(string, null)
    user_password  = optional(string, null)
  })
  default = {}
  sensitive = true
}

variable "node_config" {
  type = object({
    node_name    = string
    gateway      = string
  })
}

variable "config" {
  type = object({
    id           = number
    name         = string
    cpu_cores    = optional(number, 2)
    memory_mb    = optional(number, 512)
    memory_swap  = optional(number, 512)
    disk_size_gb = optional(number, 8)
    storage_name = optional(string, "local-lvm")
    network_name = optional(string, "eth0")
    ip_address   = string # in the format: "192.168.1.50/24"
    description  = optional(string, null)
    keyctl       = optional(bool, true)
    nesting      = optional(bool, true)
    unprivileged = optional(bool, true)
    tags         = optional(list(string), null)
    image_storage  = optional(string, "local")
    network_bridge = optional(string, "vmbr0")
    startup_down_delay = optional(number, -1)
    startup_up_delay   = optional(number, -1)
    startup_order      = optional(number, 0)
    

  })
}

# variable "usb_passthrough" {
#   type = list(object({
#     host    = optional(string)
#     mapping = optional(string)
#     usb3    = optional(bool, false)
#   }))
#   default     = []
# }

# variable "hostpci" {
#   type = list(object({
#     device = optional(string)
#     id     = optional(string)
#     pcie   = optional(bool, false)
#     rombar = optional(bool, false)
#     xvga   = optional(bool, false)
#   }))
#   default     = []
# }

resource "proxmox_download_file" "latest_debian_13_trixie" {
  content_type = "vztmpl"
  datastore_id = var.config.image_storage
  file_name    = "debian-13-generic-amd64.tar.xz"
  node_name    = var.node_config.node_name
  overwrite    = false
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.tar.xz"
}

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
    template_file_id = proxmox_download_file.latest_debian_13_trixie.id
    type = "debian"
  }

  startup {
    down_delay = var.config.startup_down_delay
    up_delay   = var.config.startup_up_delay
    order      = var.config.startup_order
  }


  # dynamic "usb" {
  #   for_each = var.usb_passthrough
  #   content {
  #     mapping = usb.value.mapping
  #     host    = usb.value.host
  #     usb3    = usb.value.usb3

  #   }
  # }

  # dynamic "hostpci" {
  #   for_each = var.hostpci
  #   content {
  #     device = hostpci.value.device
  #     id     = hostpci.value.id
  #     pcie   = hostpci.value.pcie
  #     rombar = hostpci.value.rombar
  #     xvga   = hostpci.value.xvga
  #   }
  # }

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
