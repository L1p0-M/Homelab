
output "host_info" {
  description = "Output Infos about the LXC for generating ansible inventory"
  value = {
    ip    = split("/", var.config.ip_address)[0]
    roles = [for group in try(var.ansible_groups, []) : tostring(group)]
    hostname = var.config.name
    id = var.config.id
    cpu = var.config.cpu_cores
    memory = var.config.memory_mb
    disk = [
      {
        disk_size_gb = var.config.disk_size_gb
        storage_name = var.config.storage_name
      }
    ]
  }
}