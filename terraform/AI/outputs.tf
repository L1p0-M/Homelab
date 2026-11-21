output "host_info" {
    description = "Output Infos about the Guests for generating ansible inventory"
    value = merge(
        { agent = module.agent.host_info },
        { cortana_model = module.cortana_model.host_info },
        { tts = module.tts.host_info },
        { stt = module.whisper.host_info }
    )
}