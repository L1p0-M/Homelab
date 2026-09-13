import os
from pathlib import Path as pathlibpath
from argparse import ArgumentParser
import hashlib
from shutil import move as movefile


def build_dict_for_stacks(search_path):
    stacks = {}
    for files in sorted(pathlibpath(search_path).rglob("docker-compose.*")):
        base_name = pathlibpath(files).parent.parts
        if len(base_name) >= 3: #NODE/VM/CONFIGS/SERVICE
            node = base_name[0]
            vm = base_name[1]
            service = base_name[-1]
            print(f"NODE: {node} VM: {vm} SERVICE: {service}")

            if vm not in stacks.keys():
                stacks[vm] = {
                    "services": [],
                    "node": ""
                }

            stacks[vm]["services"].append(service)
            stacks[vm]["node"] = node

    return stacks if stacks else None

def build_files_from_stacks(stacks:dict, output_location):
    change_count = 0

    if not stacks and output_location:
        return False, change_count
    
    for vm, data in stacks.items():
        lines = []
        output_dir = pathlibpath(output_location)
        output_dir.mkdir(parents=True, exist_ok=True)

        if os.path.exists(output_location) and len(data["services"]) >= 1:
            filename = output_dir.joinpath(f"{vm.replace("_", "-")}.yml.tmp")
            output_name = output_dir.joinpath(f"{vm.replace("_", "-")}.yml")
            lines.append("app_stacks:")

            for service in data["services"]:
                lines.append(f'  - "../{data.get("node")}/{vm}/Configs/{service}"')

            text = "\n".join(lines)
            print(text)

            try:
                with open(filename, "w") as f:
                    f.write(text)
                    f.write("\n") #Needed to pass the yaml linter :)
                if check_if_file_changed(file_path=output_name, new_file_path=filename):
                    print(f"{filename} changed! Moving it to the output location!")
                    movefile(src=filename, dst=output_name)
                    change_count += 1
                else:
                    print(f"No changes detected in file: {filename}")
                    os.remove(path=filename)

            except Exception as e:
                print(f"Error while writing to file: {e}")
                if os.path.exists(filename):
                    os.remove(path=filename)
                return False, change_count
    return True, change_count

def check_if_file_changed(file_path, new_file_path):
    if os.path.exists(file_path):
        with open(file_path, "rb") as existing_file:
            exiting_digest = hashlib.file_digest(existing_file, "sha256")
        with open(new_file_path, "rb") as new_file:
            new_digest = hashlib.file_digest(new_file, "sha256")
        return exiting_digest.hexdigest() != new_digest.hexdigest()
    return True

def set_github_output(change_count):
    pr_title=f"CI(ansible): Auto-update for {change_count} Ansible app-stacks"
    pr_body = [
        "### Automated Ansible App-Stacks Update\n",
        f"GitOps Pipeline successfully processed and updated **{change_count} Ansible App-Stacks** based on the latest configuration changes.\n",
        "\n---",
        "> 🤖 *Generated automatically via CI/CD Pipeline. Please review and merge.*"
    ]
    content = "\n".join(pr_body)
    github_output = os.getenv('GITHUB_OUTPUT')
    if github_output:
        with open(github_output, 'a') as f:
            f.write(f"has_changes={True if change_count >= 1 else False}\n")
            f.write(f"pr_title={pr_title}\n")
            f.write(f"pr_branch=app-stacks\n")
            f.write("pr_body<<EOF\n")
            f.write(f"{content}\n")
            f.write("EOF\n")

if __name__ == "__main__":
    arg_parser = ArgumentParser(description="Generate Ansible app stacks.")
    arg_parser.add_argument("--output", type=str, default="ansible/host_vars/", help="Output path for the generated app stacks files.")
    arg_parser.add_argument("--search", type=str, default=".", help="Search path for docker stacks.")
    args = arg_parser.parse_args()
    try:
        if args.search:
            stacks = build_dict_for_stacks(args.search)
            if stacks:
                sucess, change_count = build_files_from_stacks(stacks=stacks, output_location=args.output)
                if sucess:
                    print("App stacks generation completed successfully!")
                    set_github_output(change_count)
                    exit(0)
                else:
                    print("App stacks generation encountered errors.")
                    exit(1)

    except Exception as e:
        print(f"An error occurred: {e}")
        exit(1)
