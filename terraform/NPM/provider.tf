terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    nginxproxymanager = {
      source  = "Sander0542/nginxproxymanager"
      version = ">= 1.3.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.1"
    }
  }
}

provider "nginxproxymanager" {
  url      = data.sops_file.secrets.data["npm.url"]
  username = data.sops_file.secrets.data["npm.username"]
  password = data.sops_file.secrets.data["npm.password"]
}