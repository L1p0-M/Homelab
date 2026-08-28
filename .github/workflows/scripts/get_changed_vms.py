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
        return 
    return

    #     if pathlibpatch(dir).joinpath("terraform.tfvars").exists() or pathlibpatch(dir).joinpath("terraform.tfvars").exists():
    #         service_name = structure[len(structure) - 1]
    #         subdir_structure = "/".join(structure[3:-1]) if len(structure) > 3 else "config"

    #     else:

    #         print(f"Directory {dir} does not contain a docker-compose file. Searching for docker-compose file in parent directories.")
    #         basedir_path = dir.split("/")
    #         basedir_path.pop(len(basedir_path) - 1)
    #         compose_files = ["docker-compose.yml", "docker-compose.yaml"]

    #         while not any(pathlibpatch("/".join(basedir_path)).joinpath(compose_file).exists() for compose_file in compose_files):
    #             if len(basedir_path) == 0:
    #                 print(f"No docker-compose file found in the directory hierarchy for {dir}. Skipping.")
    #                 set_github_output(False, {})
    #                 return
                
    #             basedir_path.pop(len(basedir_path) - 1)
    #             print(f"Checking parent directory: {"/".join(basedir_path)}")

    #         print(f"Found docker-compose file in directory: {"/".join(basedir_path)}")
    #         structure = basedir_path
    #         structure = remove_trailing_slashes(structure)
    #         service_name = structure[len(structure) - 1]
    #         subdir_structure = "/".join(structure[3:-1]) if len(structure) > 3 else "config"

    #     name = service_name
    #     if service_name in service:
    #         name = f"{service_name}_{structure[1]}"

    #     changed_vms[name] = {
    #         "NODE": structure[0],
    #         "VM": structure[1],
    #     }
    # print(f"Service: {vms}")

    # if changed_vms:
    #     print(f"Changed vms: {vms}")
    #     json_output = convert_to_json(changed_vms)
    #     set_github_output(True, json_output)
    #     return
    
    # print("No changed services detected.")
    # set_github_output(False, {})

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

def set_github_output(has_changes, services):
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as f:
            f.write(f"has_changes={str(has_changes).lower()}\n")
            f.write(f"services={services}\n")


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
