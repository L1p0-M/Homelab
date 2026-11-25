import os
from pathlib import Path as pathlibpath
from argparse import ArgumentParser
import hashlib
from shutil import move as movefile
import json
import subprocess
from dataclasses import dataclass, field
from typing import Any, Dict
from datetime import datetime
from jinja2 import Template
import yaml


@dataclass()
class GithubOutputData:
    """Store Github Output vars"""
    inventory_changed: bool = False
    pull_request_body: list[str] = field(default_factory=list)
    pull_request_title: str = "ops(ansible): Auto-Update Ansible Inventory"
    commit_message: str = "ops(ansible): Auto-Update Ansible Inventory"


class GithubWorkflow:
    def __init__(self, dataclass):
        self.data = dataclass

    def write_to_github_output(self) -> bool:
        try:
            print(f"Inventory changed: {self.data.inventory_changed}, pr_title: {self.data.pull_request_title}")
            github_output = os.getenv('GITHUB_OUTPUT')
            content = "\n".join(self.data.pull_request_body)
            if github_output:
                with open(github_output, 'a') as f:
                    f.write(f"has_changes={self.data.inventory_changed}\n")
                    f.write("pr_body<<EOF\n")
                    f.write(f"{content}\n")
                    f.write("EOF\n")
                return True
            return False

        except Exception as e:
            print(f"{e}")
            return False


@dataclass(frozen=True)
class MetadataOutput:
    """Store metadatas"""
    output: Dict[str, Any] = field(default_factory=dict)


class HostReadme:
    def __init__(self, terraform_output: dict):
        self.workdir = os.environ.get("GITHUB_WORKSPACE") if os.environ.get("GITHUB_WORKSPACE", False)  else os.getcwd()
        self.terraform_output = terraform_output
        self.readme_template = self.get_readme_template()
        self.metadata = None
        self.terraform = Terraform()

    def generate(self) -> bool:
        try:
            print(f"generating readmes....")
            if isinstance(self.terraform_output.output, dict) and self.terraform_output.output != {}:
                self.metadata = MetadataOutput(output=self.get_data_from_metadata())
                if isinstance(self.metadata.output, dict) and self.metadata.output != {}:
                    success = self.generate_readme()

        except Exception as e:
            print(f"An error occurred: {e}")
            return False

    def get_data_from_metadata(self) -> dict:
        metadatas = {}
        for files in sorted(pathlibpath(self.workdir).rglob("metadata.yaml")):
            print(f"Found metadata at: {files}")
            with open(files, 'r') as f:
                yaml_data = yaml.load(f, Loader=yaml.FullLoader)
            if yaml_data:
                metadatas[str(pathlibpath(files).parent.name).replace("_", "-")] = yaml_data
        return metadatas

    def get_readme_template(self):
        template = sorted(pathlibpath(self.workdir).rglob("readme.template.j2"))[0]
        with open(str(template), 'r') as f:
            template_content = f.read()
            if not template_content:
                raise RuntimeError("Failed to read jinja2 template")
            return Template(template_content)
    
    def generate_readme(self) -> bool:
        try:
            tf_vars = self.terraform.process_output(output=self.terraform_output.output)
            metadata_vars = self.metadata.output

            for node, guests in tf_vars.items():
                for guest in guests.values():
                    if not any(guest.get("hostname", "") in str(pathlibpath(name).name) for name in metadata_vars.keys()):
                        continue
                    data = {
                        "metadata": metadata_vars.get(guest.get("hostname"), {}),
                        "terraform": guest,
                        "node": node
                    }

                    output = self.readme_template.render(
                        data=data,
                        generation_date=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                    )
                    print(output)
                    #with open(f'{node}-{guests.get("hostname")}_generated-README.md', 'w') as f:
                    #   f.write(output)
                    print("README.md successfully generated!")
            return True

        except Exception as e:
            print(f"Error while generating README.md: {e}")
            return False


class AnsibleInventory:
    def __init__(self, terraform_output: dict, inventory_path: str = "ansible/inventory.ini"):
        self.inventory_path = inventory_path
        self.terraform_output = terraform_output
        self.new_file = "./inventory.ini.new"
        self.terraform = Terraform()

    def generate(self) -> bool:
        try:
            if isinstance(self.terraform_output.output, dict) and self.terraform_output.output != {}:
                ansible_inv = self.generate_ansible_inventory(vars=self.terraform.process_output(output=self.terraform_output.output))
                if self.write_inventory_to_file(inventory_content=ansible_inv):
                    return self.check_if_file_changed()

        except Exception as e:
            print(f"An error occurred: {e}")
            if os.path.exists("inventory.ini.new"):
                os.remove("inventory.ini.new")
            return False


    def generate_ansible_inventory(self, vars: dict) -> list:
        try:
            lines = [
                "# ===================================================#",
                "# AUTOMATICALLY GENERATED BY CI/CD                   #",
                "# DO NOT EDIT MANUALLY - CHANGES WILL BE OVERWRITTEN #",
                "# ===================================================#\n",
                "[all:children]",
            ]
            if not vars:
                return []

            for node in vars.keys():
                lines.append(f"NODE_{node}")

            ansible_groups = {}
            for node, guests in vars.items():
                lines.append(f"\n[NODE_{node}]")

                for guest_details in guests.values():
                    if isinstance(guest_details, dict) and guest_details.get("hostname", None) and guest_details.get("ip", None):
                        hostname = guest_details.get("hostname")
                        ip = guest_details.get("ip")
                        roles = guest_details.get("roles", [])
                        if "excluded" not in roles:
                            lines.append(f"{hostname} ansible_host={ip}")

                        for role in roles:
                            if role not in ansible_groups:
                                ansible_groups[role] = []
                            ansible_groups[role].append(f"{hostname} ansible_host={ip}")

            if ansible_groups != {}:
                for role_name, role_entries in ansible_groups.items():
                    lines.append(f"\n[{role_name}]")
                    lines.extend(sorted(role_entries))

            lines.append("\n[all:vars]")
            lines.append('ansible_user="{{ deploy_user }}"')

            lines.append("")
            content = "\n".join(lines)

            print("Generating Ansible inventory file...")
            print(content)
            return content

        except Exception as e:
            print(f"Error while creating inventory: {e}")
            return []

    def check_if_file_changed(self) -> bool:
        if os.path.exists(self.inventory_path):
            try:
                with open(self.inventory_path, "rb") as e:
                    exiting_digest = hashlib.file_digest(e, "sha256")
                with open(self.new_file, "rb") as n:
                    new_digest = hashlib.file_digest(n, "sha256")
                if exiting_digest.hexdigest() != new_digest.hexdigest():
                    print("Detected changes in Inventory!")
                    movefile(src=self.new_file, dst=self.inventory_path)
                    return True
                print("No changes detected in Inventory!")
                return False

            except Exception as e:
                print(f"Failed to check old/new file digest: {e}")
                return False

        raise RuntimeError(f"{self.inventory_path} path not exist on host!")

    def write_inventory_to_file(self, inventory_content: list) -> bool:
        try:
            if inventory_content == []:
                return False

            output_path = pathlibpath(self.new_file)

            with open(output_path, "w") as inventory_file:
                inventory_file.write(inventory_content)
            print(f"Ansible inventory successfully written to {output_path}")
            return True

        except Exception as e:
            print(f"Error writing Ansible inventory to file: {e}")
            return False


@dataclass(frozen=True)
class TerraformOutput:
    """Store Terraform output"""
    output: Dict[str, Any] = field(default_factory=dict)


class Terraform:
    def __init__(self, terraform_path: str = "terraform", modules_path: str = "terraform/modules"):
        self.terraform_path = terraform_path
        self.modules_path = modules_path

    def process_output(self, output: dict) -> dict:
        inventory_vars = {}
        for key, values in output.items():
            if not isinstance(values, dict) or "host_info" not in values:
                continue

            node_name = pathlibpath(key).name
            guest_config = values["host_info"]["value"]

            inventory_vars[node_name] = guest_config
        return inventory_vars

    def get_outputs(self) -> dict:
        outputs = {}
        checked_dirs = []
        project_dir = os.getcwd()
        full_path = pathlibpath(project_dir).joinpath(self.modules_path)
        for files in sorted(pathlibpath(self.terraform_path).rglob("*.tf")):
            if full_path and pathlibpath(files).parent.is_relative_to(full_path):
                print(f"{files} Excluded")
                continue

            basedir = pathlibpath(files).parent

            if str(basedir) in checked_dirs:
                continue

            print(f"Found *.tf file at: {basedir}")
            if not os.path.exists(basedir):
                checked_dirs.append(str(basedir))
                continue

            os.chdir(basedir)

            try:
                subprocess.run(["terraform", "init"], shell=False, check=True)
                proc = subprocess.run(["terraform", "output", "-json"], shell=False, stdout=subprocess.PIPE, check=True)
            except subprocess.CalledProcessError:
                continue

            checked_dirs.append(str(basedir))

            cmd_output = json.loads(proc.stdout)
            if cmd_output and cmd_output != {}:
                outputs[str(basedir)] = cmd_output
            os.chdir(project_dir)

        return outputs


class MasterClass:
    def __init__(self, output_path, search_path, modules_path):
        self.output_path = output_path
        self.search_path = search_path
        self.modules_path = modules_path
        self.workdir = os.environ.get("GITHUB_WORKSPACE") if os.environ.get("GITHUB_WORKSPACE", False)  else os.getcwd()
        print(f"Working directory: {self.workdir}")

    def start(self) -> bool:
        try:
            terraform = Terraform(terraform_path=self.search_path, modules_path=self.modules_path)
            terraform_output = TerraformOutput(output=terraform.get_outputs())

            inventory = AnsibleInventory(inventory_path=self.output_path, terraform_output=terraform_output)
            os.chdir(self.workdir)
            readme = HostReadme(terraform_output=terraform_output)
            readme.generate()
            githubdata = GithubOutputData(inventory_changed=inventory.generate())

            githubworkflow = GithubWorkflow(dataclass=githubdata)
            return githubworkflow.write_to_github_output()

        except Exception as e:
            print(e)
            return False

        finally:
            if os.path.exists("inventory.ini.new"):
                os.remove("inventory.ini.new")


if __name__ == "__main__":
    arg_parser = ArgumentParser(description="Generate Ansible inventory+outputs.tf from Terraform files.")
    arg_parser.add_argument("--output", type=str, default="ansible/inventory.ini", help="Output path for the generated Ansible inventory file.")
    arg_parser.add_argument("--modules", type=str, default="terraform/modules/", help="The directory of your child modules, its going to be excluded while searching/generating")
    arg_parser.add_argument("--search", type=str, default="terraform/", help="Search path for Terraform files.")
    args = arg_parser.parse_args()
    main = MasterClass(output_path=args.output, search_path=args.search, modules_path=args.modules)
    if main.start():
        exit(0)
    exit(1)
