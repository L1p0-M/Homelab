terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.60.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.1"
    }
  }
}

provider "proxmox" {
  endpoint = data.sops_file.secrets.data["nodes.ai.endpoint"]
  api_token = data.sops_file.secrets.data["nodes.ai.api_token"]
  insecure = true
  ssh {
    password = data.sops_file.secrets.data["nodes.ai.password"]
    username = data.sops_file.secrets.data["nodes.ai.username"]
  }
}
