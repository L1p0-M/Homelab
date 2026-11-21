
variable "records" {
  type = map(object({
    enabled = optional(string, true)
    domain_names = optional(list(string), [])
    scheme = optional(string, "http")
    host = string
    port = number
    caching = optional(bool, true)
    websocket = optional(bool, false)
    block_exploits = optional(bool, true)
    cert_id = optional(number)
    access_list_id = optional(number, 2)
    advanced_config = optional(string)
  }))
}

variable "ssl" {
  type = object({
    domain_names = list(string)
    letsencrypt_email = string
    ssl_provider = optional(string, "cloudflare")
    dns_auth_token = string 
  })
}

variable "domain_name" {
  type = string
  sensitive = true
}
