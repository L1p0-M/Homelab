
output "host_info" {
  description = "Output Infos about the LXC for generating ansible inventory"
  value = {
    ip    = split("/", var.config.ip_address)[0]
    roles = [for group in try(var.ansible_groups, []) : tostring(group)]
    hostname = var.config.name
  }
}