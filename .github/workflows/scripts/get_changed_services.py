import os
import argparse
import json

def get_changed_services(changed_dirs):
    service = {}
    for dir in changed_dirs:
        print(f"Changed directory: {dir}")
        structure = dir.split("/")
        service_name = structure[len(structure) - 1]
        subdir_structure = "/".join(structure[3:-1]) if len(structure) > 3 else "config"

        service[service_name] = {
            "NODE": structure[0],
            "VM": structure[1],
            "Service": service_name,
            "Subdirs": subdir_structure
        }
        print(f"Service: {service}")

    if service:
        print(f"Changed services: {service}")
        json_output = convert_to_json(service)
        set_github_output(True, json_output)
        return
    
    print("No changed services detected.")
    set_github_output(False, {})

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
    parser = argparse.ArgumentParser(description="Get changed services from changed directories.")
    parser.add_argument("changed_dirs", nargs="+", help="List of changed directories.")
    args = parser.parse_args()
    print(f"Changed directories: {args.changed_dirs}")
    if args.changed_dirs != []:
        get_changed_services(args.changed_dirs)
    else:
        print("No changed directories provided or no changes detected.")
        set_github_output(False, {})