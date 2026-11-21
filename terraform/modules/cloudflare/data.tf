
data "cloudflare_zone" "current" {
    filter = {
        name = var.domain_name
    }
}