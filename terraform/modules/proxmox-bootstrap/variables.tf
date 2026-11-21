variable user_data {
  type        = string
  sensitive   = true
}

variable "lxc_key" {
  type        = string
  sensitive   = true
}

variable "node_config" {
  type = object({
    node_name    = string
    gateway      = string
    storage_name = string
  })
}
