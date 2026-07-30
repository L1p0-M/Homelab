#!/bin/bash

set -e

check_current_dir() {
	if [ "$PWD" != "/dockerconfig" ]; then
		echo "We are not in the right directory... Changing to it now.."
		cd /dockerconfig || { echo "Error: The /dockerconfig directory not found!"; exit 1; }
		return 0
	fi
}
regenerate_encrypted_envs() {
	echo "Regenerating .env.enc files..."
	find ./ -name .env 2>/dev/null | while read -r file; do
		dir=$(dirname "$file")
		if [ -f "$dir/.env.enc" ]; then
			rm "$dir/.env.enc"
			echo "Removing old $dir/.enc.enc..."
		fi
		if sops -e "$file" > "$dir/.env.enc"; then
			echo "Generated: "$dir"/.env.enc"
		else
			echo "Error while generating $dir/.env.enc!"
		fi
	done
}

check_current_dir
regenerate_encrypted_envs

echo "Encrypt completed! :)"
