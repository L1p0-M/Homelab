variable "node_config" {
  type = object({
    node_name    = string
    gateway      = string
    storage_name = optional(string, "local-lvm")
  })
}