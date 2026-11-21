output "host_info" {
    description = "Output Infos about the Guests for generating ansible inventory"
    value = merge(
        { ci_worker = module.ci_worker.host_info },
        { docker = module.docker.host_info },
        { docs_monitoring = module.docs_monitoring.host_info },
        { home_assistant = module.home_assistant.host_info },
        { media = module.media.host_info },
        { truenas = module.truenas.host_info },
        { whprinter = module.whprinter.host_info },
        { cloudflare_ddns = module.cloudflare_ddns.host_info },
        { network_ups = module.network_ups.host_info },
        { wireguard = module.wireguard.host_info }
    )
}