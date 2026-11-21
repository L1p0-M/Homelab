variable "node_config" {
  description = "Common config options on the Node, declared in node.auto.tfvars"
  type = object({
    node_name    = string
    gateway      = string
    storage_name = optional(string, "local-lvm")
  })
}