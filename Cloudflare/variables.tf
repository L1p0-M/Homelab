variable "domain_name" {
    type = string
}

variable "records" {
  type = map(object({
    name     = string
    type     = optional(string, "CNAME")
    content  = string
    proxied  = optional(bool, true)
    comment  = optional(string, null)
    private_routing = optional(bool, null)
    priority = optional(number, null)
    settings        = optional(object({
      flatten_cname = optional(bool, null)
      ipv4_only     = optional(bool, null)
      ipv6_only     = optional(bool, null)
    }), {})
  }))
}
