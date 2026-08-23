variable "node_name"      { type = string }
variable "storage_name"   { type = string }
variable "network_bridge" { type = string }
variable "gateway"        { type = string }
variable "template_vm_id" { type = number }

variable "vm_id"          { type = number }
variable "vm_name"        { type = string }
variable "cpu_cores"      { type = number }
variable "memory_mb"      { type = number }
variable "disk_size_gb"   { type = number }
variable "ip_address"     { type = string }
variable "ssh_public_key" {
	type = string
	default = null
}
variable "user_password" {
	type = string
	sensitive = true
	default = null
}

variable tags {
  type        = list
  default     = null
}

variable startup_order {
  type        = number
  default     = 0
}

variable startup_down_delay {
  type        = number
  default     = -1
}

variable startup_up_delay {
  type        = number
  default     = -1
}

