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
    device_passthrough = optional(list(object({
      path = optional(string, null)
      })), [])
  })
}

