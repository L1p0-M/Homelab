variable user_data {
  type        = string
  description = "description"
}

variable "node_config" {
  type = object({
    node_name    = string
    gateway      = string
    storage_name = string
  })
}
