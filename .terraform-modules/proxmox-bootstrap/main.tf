terraform {
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
  ssh {
    password = data.sops_file.proxmox.data["PASSWORD"]
    username = data.sops_file.proxmox.data["USERNAME"]
  }
}

data "sops_file" "secrets" {
  source_file = "${path.module}/secrets.yaml.enc"
  input_type = "yaml"
}

data "sops_file" "proxmox" {
  source_file = var.node_config.secrets
  input_type = "dotenv"
}

variable "node_config" {
  type = object({
    node_name    = string
    gateway      = string
    storage_name = string
    secrets      = string
  })
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_config.node_name

  source_raw {
    file_name = "user-data.yaml"
    data = templatefile("${path.module}/user_data.yaml.tftpl", {
      my_ssh_pub_key   = data.sops_file.secrets.data["ssh_keys.my_user"]
      deploy_ssh_pub_key = data.sops_file.secrets.data["ssh_keys.deploy_user"]
      my_user = data.sops_file.secrets.data["users.my_user"]
      deploy_user = data.sops_file.secrets.data["users.deploy_user"]
    })
  }
}

resource "proxmox_download_file" "latest_ubuntu_26_vm" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.node_config.node_name
  url          = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
  file_name    = "resolute-server-cloudimg-amd64.qcow2"

}

resource "proxmox_download_file" "latest_debian_13_lxc" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = var.node_config.node_name
  url          = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.tar.xz"

}

resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  name      = "ubuntu-cloud-template"
  vm_id     = 999
  node_name = var.node_config.node_name
  template  = true
  description = "CloudInit template VM"
  tags        = ["terraform", "ubuntu", "cloudinit"]
  keyboard_layout = "hu"

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_download_file.latest_ubuntu_26_vm.id
    interface    = "scsi0"
    size         = 32
    ssd          = true
  }

  cpu {
    cores        = 2
    type         = "host"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  network_device {
    bridge = "vmbr0"
  }

}