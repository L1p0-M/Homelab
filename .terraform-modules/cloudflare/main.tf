terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

data "cloudflare_zone" "current" {
    filter = {
        name = var.domain_name
    }
}

resource "cloudflare_dns_record" "dns_record" {
  for_each = var.records

  zone_id = data.cloudflare_zone.current.id
  name = each.value.name
  ttl = 1
  type = each.value.type
  content = each.value.content
  private_routing = each.value.private_routing
  proxied = each.value.proxied
  settings = each.value.settings
  comment = (each.value.comment != null && each.value.comment != "") ? each.value.comment : null
  priority = each.value.priority

}