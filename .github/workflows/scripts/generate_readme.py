import re
import json
import os
import argparse
from jinja2 import Template
from pathlib import Path as pathlibpath
import yaml
import hcl2
from datetime import datetime
from shutil import move as movefile


def get_data_from_metadata(directory):
    metadata_path = pathlibpath(directory).joinpath("metadata.yaml")
    if os.path.exists(metadata_path):
        with open(metadata_path, 'r') as f:
            yaml_data = yaml.load(f, Loader=yaml.FullLoader)
        if yaml_data:
            return yaml_data
    return False

def get_data_from_tfvars(directory):
    tfvars_path = pathlibpath(directory).joinpath("terraform.tfvars")
    if os.path.exists(tfvars_path):
        with open(tfvars_path, "r") as f:
            tfvars_data = hcl2.load(f)
        if tfvars_data:
            return clean_vals(tfvars_data)
    return False

def get_readme_template():
    with open('.github/workflows/templates/readme.template.j2', 'r') as f:
        template_content = f.read()
        template = Template(template_content)
        return template

def get_data_from_node(directory):
    node_path = pathlibpath(directory).parent.joinpath("node.tfvars")
    if os.path.exists(node_path):
        with open(node_path, "r") as f:
            node_data = hcl2.load(f)
    if node_data:
        return node_data

def clean_vals(val):
    if isinstance(val, int):
        return val
    elif isinstance(val, str):
        return val.strip().strip('"').strip("'").strip()
    elif isinstance(val, list):
        return [clean_vals(item) for item in val]
    elif isinstance(val, dict):
        return {k: clean_vals(v) for k, v in val.items()}


def generate_data_for_readme(metadata, tfvars, node, dir):
    tfvars_config = tfvars.get("config", {})
    node_config = node.get("node_config", {})
    raw_ip = tfvars_config.get("ip_address", metadata.get("ip_address", "Unknown"))
    clean_ip = raw_ip.split("/")[0] if "/" in str(raw_ip) else raw_ip
    data = {
        "status": metadata.get("status", "Unknown"),
        "environment": metadata.get("environment", "Unknown"),
        "description": metadata.get("description", "No description provided"),
        "name": metadata.get("name", "Unknown"),
        "ports": metadata.get("ports", None),
        "docker": metadata.get("docker", None),
        "os": metadata.get("os", "Unknown"),
        "path": str(dir),

        "type": tfvars.get("target_type", "Unknown"),
        "ip_address": clean_ip,
        "ip_cidr": raw_ip,
        "network_bridge": tfvars_config.get("network_bridge", "Unknown"),
        "vmid": tfvars_config.get("vm_id", "Unkonwn"),
        "hostname": tfvars_config.get("vm_name", "Unknown"),
        "cores": tfvars_config.get("cpu_cores", "Unknown"),
        "memory_mb": tfvars_config.get("memory_mb", "Unknown"),
        "disk_size_gb": tfvars_config.get("disk_size_gb", "Unknown"),
        "storage_name": tfvars_config.get("storage_name", "Unknown"),
        "startup_order": tfvars_config.get("startup_order", "Unkonwn"),
        "tags": tfvars_config.get("tags", []),
        "proxmox_node": node_config.get("node_name").upper(),
    }
    return data

def generate_readme(template, data):
    try:
        output = template.render(
            data=data,
            generation_date=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        )
        with open('generated-README.md', 'w') as f:
            f.write(output)
        print("README.md successfully generated!")
        return True
    
    except Exception as e:
        print(f"Error while generating RADME.md: {e}")
        return False

def generate_pr_summary(readme_datas):
    readme_count = len(readme_datas)
    
    if readme_count == 1:
        readme = readme_datas[0]
        title = f"docs(gitops): Auto-update documentation for [{readme['name']}]"
        branch_name = f"docs/readme-update-{readme['name'].lower()}"
    else:
        title = f"docs(gitops): Auto-update documentation for {readme_count} VMs/LXCs"
        branch_name = "docs/readme-update-batch"

    pr_body_lines = [
        "### Automated Infrastructure Documentation Update\n",
        f"GitOps Pipeline successfully processed and updated **{readme_count} VM(s)/LXC(s)** based on the latest configuration changes.\n",
        "#### Updated Nodes Summary\n",
        "| Name | ID | IP Address | Directory Path |",
        "| :--- | :--- | :--- | :--- |"
    ]
    
    for vms in readme_datas:
        pr_body_lines.append(f"| **{vms['name']}** | `{vms['vmid']}` | `{vms['ip_address']}` | `{vms['path']}` |")
        
    pr_body_lines.extend([
        "\n---",
        "#### Updated Components per Node",
        "- [x] `README.md` *(rendered Jinja2 infrastructure documentation)*",
        "\n---",
        "> 🤖 *Generated automatically via CI/CD Pipeline. Please review and merge.*"
    ])
    
    pr_body = "\n".join(pr_body_lines)

    github_output = os.getenv('GITHUB_OUTPUT')
    if github_output:
        with open(github_output, 'a') as f:
            f.write(f"pr_title={title}\n")
            f.write(f"pr_branch={branch_name}\n")
            f.write("pr_body<<EOF\n")
            f.write(f"{pr_body}\n")
            f.write("EOF\n")

def move_readme(dir):
    dir_path = pathlibpath(dir)
    if os.path.exists(dir_path) and os.path.exists("generated-README.md"):
        name = dir_path.joinpath("README.md")
        movefile(src="generated-README.md", dst=name)
        print(f"README file saved as: {name}")
        return True
    return False



if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser(description="Generate readme for VMs/LXCs from metadata.yaml & terraform.tfvars.")
        parser.add_argument("changed_dirs", nargs="+", help="List of changed directories.")
        args = parser.parse_args()
        print(f"Changed directories: {args.changed_dirs}")

        if args.changed_dirs != []:
            readme_datas = []
            directory = args.changed_dirs
            for dir in directory:
                metadata_data = get_data_from_metadata(dir)
                tfvars_data = get_data_from_tfvars(dir)
                node_data = get_data_from_node(dir)
                if node_data and tfvars_data and metadata_data:
                    data = generate_data_for_readme(metadata=metadata_data, tfvars=tfvars_data, node=node_data, dir=dir)
                    readme_datas.append(data)
                    template = get_readme_template()
                    if generate_readme(template=template, data=data):
                        move_readme(dir=dir)
            if readme_datas:
                generate_pr_summary(readme_datas=readme_datas)

    except KeyboardInterrupt:
        print("Script interrupted by user. Exiting.")
        exit(0)
