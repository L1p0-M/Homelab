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
    user_password  = optional(string, null)
    ssh_public_key = optional(string, null)
  })
  default   = {}
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
    vm_id           = number
    vm_name         = string
    cpu_cores    = optional(number, 2)
    cpu_type     = optional(string, "host")
    memory_mb    = optional(number, 2048)
    memory_swap  = optional(number, 512)
    disk_size_gb = optional(number, 32)
    storage_name = optional(string, "local-lvm")
    ip_address   = string # in the format: "192.168.1.50/24"
    description  = optional(string, null)
    tags         = optional(list(string), null)
    bios_type    = optional(string, "seabios")
    efi_disk     = optional(string, "local-lvm")
    iothread     = optional(bool, true)
    tablet_device  = optional(bool, false)
    image_storage  = optional(string, "local")
    network_bridge = optional(string, "vmbr0")
    startup_down_delay = optional(number, -1)
    startup_up_delay   = optional(number, -1)
    startup_order      = optional(number, 0)
    template_vm_id     = optional(number, null)
    scsi_hardware      = optional(string, "virtio-scsi-single")
    usb_passthrough    = optional(list(object({
      host    = optional(string)
      mapping = optional(string)
      usb3    = optional(bool, false)
    })), [])
    hostpci            = optional(list(object({
      device = optional(string)
      id     = optional(string)
      pcie   = optional(bool, false)
      rombar = optional(bool, false)
      xvga   = optional(bool, false)
    })), [])
  })
}


resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.config.vm_name
  node_name   = var.node_config.node_name
  vm_id       = var.config.vm_id
  keyboard_layout = "en-us"
  scsi_hardware = var.config.scsi_hardware
  description = var.config.description
  tags        = var.config.tags
  bios        = var.config.bios_type
  tablet_device = var.config.tablet_device

  dynamic "clone" {
    for_each = var.config.template_vm_id != null ? [1] : []
    content {
      vm_id = var.config.template_vm_id
      full  = true
    }
  }

  cpu {
    cores = var.config.cpu_cores
    type  = var.config.cpu_type
  }

  memory {
    dedicated = var.config.memory_mb
  }

  disk {
    datastore_id = var.config.storage_name
    interface    = "scsi0"
    size         = var.config.disk_size_gb
    discard      = "on"
    ssd          = true
    iothread     = var.config.iothread
  }

  network_device {
    bridge = var.config.network_bridge
    firewall = true
  }

  operating_system {
    type = "l26"
  }

  startup {
    down_delay = var.config.startup_down_delay
    up_delay   = var.config.startup_up_delay
    order      = var.config.startup_order
  }

  agent {
    enabled = true
    trim    = false
    timeout = "15m"
    type    = "virtio"
  }

  dynamic "usb" {
    for_each = var.config.usb_passthrough
    content {
      mapping = usb.value.mapping
      host    = usb.value.host
      usb3    = usb.value.usb3

    }
  }

  dynamic "hostpci" {
    for_each = var.config.hostpci
    content {
      device = hostpci.value.device
      id     = hostpci.value.id
      pcie   = hostpci.value.pcie
      rombar = hostpci.value.rombar
      xvga   = hostpci.value.xvga
    }
  }

  dynamic "initialization" {
    for_each = var.config.ip_address != null ? [1] : []
    content {
      datastore_id = var.config.storage_name
      ip_config {
        ipv4 {
          address = var.config.ip_address
          gateway = var.node_config.gateway
        }
      }
      user_account {
        keys     = compact([var.sensitive.ssh_public_key])
        username = "l1p0"
      }
    }
  }
  dynamic "efi_disk" {
    for_each = var.config.bios_type == "ovmf" ? [1] : []
    content {
      datastore_id = var.config.efi_disk
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