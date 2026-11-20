
module "private_proxy_records" {
    source = "../modules/nginxproxymanager"

    domain_name = data.sops_file.secrets.data["cloudflare.domain_name"]

    ssl = {
        domain_names = ["*.local.@"]
        letsencrypt_email = data.sops_file.secrets.data["npm.lets_encrypt.email"]
        ssl_provider = "cloudflare"
        dns_auth_token = data.sops_file.secrets.data["npm.lets_encrypt.cf_auth"]
    }

    records = {
        # ====== Private ======
        "bookshelf" = {
            domain_names = ["bookshelf.local.@"]
            scheme = "http"
            host = "audiobookshelf"
            port = 80
            cert_id = 7
        },
        "cadvisor" = {
            domain_names = ["cadvisor.local.@"]
            scheme = "http"
            host = "cadvisor"
            port = 8080
            cert_id = 7
        },
        "esphome" = {
            domain_names = ["esphome.local.@"]
            scheme = "http"
            host = "esphome"
            port = 6052
            websocket = true
            cert_id = 7
        },
        "gitea" = {
            domain_names = ["git.local.@"]
            scheme = "http"
            host = "192.168.1.26"
            port = 3030
            cert_id = 7
        },
        "glances" = {
            enabled = true
            domain_names = ["glances.local.@"]
            scheme = "http"
            host = "glances"
            port = 61208
            cert_id = 7
        },
        "grafana" = {
            domain_names = ["grafana.local.@"]
            scheme = "http"
            host = "192.168.1.26"
            port = 3000
            cert_id = 7
        },
        "home" = {
            domain_names = ["home.local.@"]
            scheme = "http"
            host = "homepage"
            port = 3000
            cert_id = 7
        },
        "it-tools" = {
            domain_names = ["it-tools.local.@"]
            scheme = "http"
            host = "it-tools"
            port = 80
            cert_id = 7
        },
        "jackett" = {
            domain_names = ["jackett.local.@"]
            scheme = "http"
            host = "jackett"
            port = 9117
            cert_id = 7
        },
        "jellyfin" = {
            domain_names = ["jellyfin.local.@"]
            scheme = "http"
            host = "192.168.1.252"
            port = 8096
            cert_id = 7
        },
        "music" = {
            domain_names = ["music.local.@"]
            scheme = "http"
            host = "navidrome"
            port = 4533
            cert_id = 7
        },
        "npm" = {
            domain_names = ["npm.local.@"]
            scheme = "http"
            host = "localhost"
            port = 81
            cert_id = 7
        },
        "openwebui" = {
            domain_names = ["openwebui.local.@"]
            scheme = "http"
            host = "192.168.1.224"
            port = 3000
            cert_id = 7
        },
        "portainer" = {
            domain_names = ["portainer.local.@"]
            scheme = "http"
            host = "192.168.1.24"
            port = 9000
            cert_id = 7
        },
        "prometheus" = {
            domain_names = ["prometheus.local.@"]
            scheme = "http"
            host = "192.168.1.26"
            port = 9090
            cert_id = 7
        },
        "prowlarr" = {
            domain_names = ["prowlarr.local.@"]
            scheme = "http"
            host = "prowlarr"
            port = 9696
            cert_id = 7
        },
        "radarr" = {
            domain_names = ["radarr.local.@"]
            scheme = "http"
            host = "radarr"
            port = 7878
            cert_id = 7
        },
        "recept" = {
            domain_names = ["recept.local.@"]
            scheme = "http"
            host = "mealie"
            port = 9000
            cert_id = 7
        },
        "sonarr" = {
            domain_names = ["sonarr.local.@"]
            scheme = "http"
            host = "sonarr"
            port = 8989
            cert_id = 7
        },
        "speedtest" = {
            domain_names = ["speedtest.local.@"]
            scheme = "http"
            host = "192.168.1.26"
            port = 30000
            cert_id = 7
        },
        "torrent" = {
            domain_names = ["torrent.local.@"]
            scheme = "http"
            host = "qbittorrent"
            port = 8300
            cert_id = 7
        },
        "ups" = {
            domain_names = ["ups.local.@"]
            scheme = "http"
            host = "PeaNUT"
            port = 8080
            cert_id = 7
        },
        "vscode" = {
            domain_names = ["vscode.local.@"]
            scheme = "http"
            host = "code-server"
            port = 8443
            cert_id = 7
        },
        "youtube-dl" = {
            domain_names = ["youtubedl.local.@"]
            scheme = "http"
            host = "youtube-dl"
            port = 17442
            cert_id = 7
        }
    }
}