import os
from argparse import ArgumentParser
from pathlib import Path as pathlibpath


def process_input(changed_dirs):
    if any(dirs.startswith("ansible/") for dirs in changed_dirs) or not changed_dirs:
        return ""
    
    hosts = set()
    for dir in changed_dirs:
        print(f"Processing directory: {dir}")
        parts = pathlibpath(dir).parts
        node = parts[0]
        if len(parts) >= 2: #NODE/VM/Configs/
            folder_name = parts[1]
            vm_name = folder_name.replace("_", "-")
            if vm_name:
                hosts.add(vm_name)
    if hosts:
        limits = ",".join(sorted(hosts))
        return f"--limit {limits} --tags docker_host"
    else:
        return f"--limit docker_hosts --tags docker_host"

def set_github_output(args):
    print(f"Setting github output to: {args}")
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as f:
            f.write(f"args={args}\n")
            print("Github output is set!")

if __name__ == "__main__":
    parser = ArgumentParser(description="Get changed ansible limits from changed directories.")
    parser.add_argument("changed_dirs", nargs="+", help="List of changed directories.")
    args = parser.parse_args()
    print(f"Changed directories: {args.changed_dirs}")
    if args.changed_dirs != []:
        output_args = process_input(args.changed_dirs)
        set_github_output(output_args)
        exit(0)
    else:
        print("No changed directories provided or no changes detected.")
        set_github_output("")
        exit(1)