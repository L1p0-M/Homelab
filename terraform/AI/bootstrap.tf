module "bootstrap" {
    source = "../modules/proxmox-bootstrap"
    node_config = var.node_config

    user_data = templatefile("../modules/proxmox-bootstrap/user_data.yaml.tftpl", {
        my_ssh_pub_key   = data.sops_file.secrets.data["users.my_user.ssh_key"]
        deploy_ssh_pub_key = data.sops_file.secrets.data["users.deploy_user.ssh_key"]
        my_user = data.sops_file.secrets.data["users.my_user.username"]
        deploy_user = data.sops_file.secrets.data["users.deploy_user.username"]
        })

    lxc_key = data.sops_file.secrets.data["users.bootstrap_user.ssh_key"]

}