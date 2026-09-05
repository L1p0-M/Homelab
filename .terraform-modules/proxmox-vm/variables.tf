variable "target_type" {
  type        = string
  description = "Required for CI/CD Pipeline to know the type to use(OPTIONS ARE 'VM' OR 'LXC')"
}

variable "ansible_groups" {
  type        = list(string)
  default     = []
  description = "Required for CI/CD Pipeline to know which Ansible groups to use"
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
