
resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_config.node_name

  source_raw {
    file_name = "user-data.yaml"
    data = var.user_data
  }
}

resource "proxmox_download_file" "latest_ubuntu_26_vm" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.node_config.node_name
  url          = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
  file_name    = "resolute-server-cloudimg-amd64.qcow2"

}

resource "proxmox_download_file" "latest_alpine_vm" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.node_config.node_name
  url          = "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/cloud/alpine-3.24.2-x86_64-cloudinit-metal-r0.qcow2"
  file_name    = "alpine-cloudimg-amd64.qcow2"

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

resource "proxmox_virtual_environment_vm" "alpine_template" {
  name      = "alpine-cloud-template"
  vm_id     = 998
  node_name = var.node_config.node_name
  template  = true
  description = "CloudInit template VM"
  tags        = ["terraform", "alpine", "cloudinit"]
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
    import_from  = proxmox_download_file.latest_alpine_vm.id
    interface    = "scsi0"
    size         = 8
    ssd          = true
  }

  cpu {
    cores        = 1
    type         = "host"
  }

  memory {
    dedicated = 512
    floating  = 512
  }

  network_device {
    bridge = "vmbr0"
  }
}