
resource "cloudflare_dns_record" "dns_record" {
  for_each = var.records

  zone_id = data.cloudflare_zone.current.id
  name = replace(each.value.name, "@", var.domain_name)
  ttl = 1
  type = each.value.type
  content = replace(each.value.content, "@", var.domain_name)
  private_routing = each.value.private_routing
  proxied = each.value.proxied
  settings = each.value.settings
  comment = (each.value.comment != null && each.value.comment != "") ? each.value.comment : null
  priority = each.value.priority

}