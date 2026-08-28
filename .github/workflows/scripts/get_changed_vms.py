import os
import argparse
import json
from pathlib import Path as pathlibpatch

def get_changed_services(changed_dirs):
    vms = {}
    for dir in changed_dirs:
        print(f"Changed directory: {dir}")
        structure = remove_trailing_slashes(dir.split("/"))
        print(structure)

        if pathlibpatch(dir).joinpath("terraform.tfvars").exists():
            vm_name = structure[len(structure) - 1]
        else:
            print(f"Directory {dir} does not contain a terraform.tfvars file. Skipping...")
            set_github_output(False, {})
            return

        name = vm_name
        if vm_name in vms:
            name = f"{vm_name}_{structure[0]}"

        vms[name] = {
            "NODE": structure[0],
            "VM": vm_name,
        }
    print(f"Service: {vms}")

    if vms:
        print(f"Changed VM/LXC: {vms}")
        json_output = convert_to_json(vms)
        set_github_output(True, json_output)
        return
    
    print("No changed services detected.")
    set_github_output(False, {})

def remove_trailing_slashes(structure):
    while any(to_remove in structure for to_remove in ["..", "."]):
        for i in range(len(structure)):
            if structure[i] in ["..", "."]:
                structure.pop(i)
                break
    return structure


def convert_to_json(service):
    if isinstance(service, dict):
        list_object = list(service.values())
        json_string = json.dumps(list_object)
        return json_string
    return "{}"

def set_github_output(has_changes, vms):
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as f:
            f.write(f"has_changes={str(has_changes).lower()}\n")
            f.write(f"services={vms}\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Get changed files from changed directories.")
    parser.add_argument("changed_dirs", nargs="+", help="List of changed directories.")
    args = parser.parse_args()
    print(f"Changed directories: {args.changed_dirs}")
    if args.changed_dirs != []:
        get_changed_services(args.changed_dirs)
    else:
        print("No changed directories provided or no changes detected.")
        set_github_output(False, {})
