terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.60.0"
    }
  }
}

variable "node_name" { type = string }
variable "vm_id" { type = number }
variable "vm_name" { type = string }
variable "cpu_cores" {
  type = number
  default = 2 
}

variable "cpu_type" {
  type = string
  default = "host"
}

variable "memory_mb" {
  type = number
  default = 2048
}

variable "disk_size_gb" {
  type = number
  default = 32 
}

variable "storage_name" {
  type = string
  default = "local-lvm"
}

variable "network_bridge" {
  type = string
  default = "vmbr0"
}

variable "ip_address" { type = string } # in the format: "192.168.1.50/24"

variable "gateway" { type = string }

variable "template_vm_id" {
  type = number
  default = null 
}

variable "ssh_public_key" {
  type = string
  default = null
}

variable "user_password" {
  type = string
  sensitive = true
  default = null
}

variable "tags" {
  type        = list
  default     = null
}

variable startup_down_delay {
  type        = number
  default     = -1
}

variable startup_up_delay {
  type        = number
  default     = -1
}

variable startup_order {
  type        = number
  default     = 0
}

variable bios_type {
  type        = string
  default     = "seabios"
}

variable efi_disk {
  type        = string
  default     = "local-lvm"
}

variable scsi_hardware {
  type        = string
  default     = "virtio-scsi-single"
}

variable description {
  type        = string
  default     = null
}

variable tablet_device {
  type        = bool
  default     = false
}

variable iothread {
  type        = bool
  default     = true
}









resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.vm_name
  node_name   = var.node_name
  vm_id       = var.vm_id
  keyboard_layout = "en-us"
  scsi_hardware = var.scsi_hardware
  description = var.description
  tags        = var.tags
  bios        = var.bios_type
  tablet_device = var.tablet_device

  dynamic "clone" {
    for_each = var.template_vm_id != null ? [1] : []
    content {
      vm_id = var.template_vm_id
      full  = true
    }
  }

  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = var.storage_name
    interface    = "scsi0"
    size         = var.disk_size_gb
    discard      = "on"
    ssd          = true
    iothread     = var.iothread
  }

  network_device {
    bridge = var.network_bridge
    firewall = true
  }

  operating_system {
    type = "l26"
  }

  startup {
    down_delay = var.startup_down_delay
    up_delay   = var.startup_up_delay
    order      = var.startup_order
  }

  agent {
    enabled = true
    trim    = false
    timeout = "15m"
    type    = "virtio"
  }

  dynamic "initialization" {
    for_each = var.ip_address != null ? [1] : []
    content {
      datastore_id = var.storage_name
      ip_config {
        ipv4 {
          address = var.ip_address
          gateway = var.gateway
        }
      }
      user_account {
        keys     = compact([var.ssh_public_key])
        username = "l1p0"
      }
    }
  }
  dynamic "efi_disk" {
    for_each = var.bios_type == "ovmf" ? [1] : []
    content {
      datastore_id = var.efi_disk
      file_format  = "raw"
      type         = "4m"
    }
  }

  lifecycle {
    ignore_changes = [
      initialization,
    ]
  }
}