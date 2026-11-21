
module "public_proxy_records" {
    source = "../modules/nginxproxymanager"

    domain_name = data.sops_file.secrets.data["cloudflare.domain_name"]

    ssl = {
        domain_names = ["*.@"]
        letsencrypt_email = data.sops_file.secrets.data["npm.lets_encrypt.email"]
        ssl_provider = "cloudflare"
        dns_auth_token = data.sops_file.secrets.data["npm.lets_encrypt.cf_auth"]
    }

    records = {
        # ====== public ======
        "bitwarden" = {
            domain_names = ["bitwarden.@"]
            scheme = "http"
            host = "bitwarden"
            port = 80
            advanced_config = "location /admin { deny all; }"
            cert_id = 8
        },
        "bookshelf" = {
            domain_names = ["bookshelf.@"]
            scheme = "http"
            host = "audiobookshelf"
            port = 80
            cert_id = 8
        },
        "portfolio" = {
            domain_names = ["portfolio.@"]
            scheme = "http"
            host = "portfolio"
            port = 8080
            cert_id = 8
        },
        "movies" = {
            domain_names = ["movies.@"]
            scheme = "http"
            host = "192.168.1.252"
            port = 8096
            cert_id = 8
            advanced_config = <<-EOT
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header Host $host;
                EOT
        },
        "contact" = {
            domain_names = ["contact.@"]
            scheme = "http"
            host = "littlelink-server"
            port = 3000
            cert_id = 8
        },
        "hassio" = {
            domain_names = ["hassio.@"]
            scheme = "http"
            host = "192.168.1.22"
            port = 8123
            websocket = true
            cert_id = 8
            andvanced_config = <<-EOT
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                EOT
        },
        "ombi" = {
            domain_names = ["ombi.@"]
            scheme = "http"
            host = "ombi"
            port = 3579
            cert_id = 8
        }
    }
}