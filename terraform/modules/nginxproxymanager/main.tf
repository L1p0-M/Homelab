locals {
  resolved_ssl_domains = [
    for d in var.ssl.domain_names : replace(d, "@", var.domain_name)
  ]
  resolved_records = {
    for k, r in var.records : k => merge(r, {
      domain_names = [
        for d in r.domain_names : replace(d, "@", var.domain_name)
      ]
      # using fixed cert_id because of issues with the provider while creating/updateing the cert, leaving the dynamic approach commented for now
      cert_id = r.cert_id #coalesce(r.cert_id, tonumber(nginxproxymanager_certificate_letsencrypt.certificate.id))
    })
  }
}

# resource "nginxproxymanager_certificate_letsencrypt" "certificate" {
#   domain_names = local.resolved_ssl_domains

#   letsencrypt_email = var.ssl.letsencrypt_email
#   letsencrypt_agree = true

#   dns_challenge            = false
#   dns_provider             = var.ssl.ssl_provider
#   dns_provider_credentials = var.ssl.dns_auth_token

#   lifecycle {
#     ignore_changes = [
#       propagation_seconds,
#     ]
#   }
# }

resource "nginxproxymanager_proxy_host" "host" {
  for_each = local.resolved_records

  enabled = each.value.enabled
  domain_names = each.value.domain_names

  forward_scheme = each.value.scheme
  forward_host   = each.value.host
  forward_port   = each.value.port

  caching_enabled         = each.value.caching
  allow_websocket_upgrade = each.value.websocket
  block_exploits          = each.value.block_exploits

  access_list_id = each.value.access_list_id
  advanced_config = each.value.advanced_config

  certificate_id  = each.value.cert_id
  ssl_forced      = true
  hsts_enabled    = true
  hsts_subdomains = true
  http2_support   = true
}
