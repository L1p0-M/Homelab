#!/bin/bash

set -e

check_current_dir() {
        if [ "$PWD" != "/dockerconfig" ]; then
                echo "We are not in the right directory... Changing to it now.."
                cd /dockerconfig || { echo "Error: The /dockerconfig directory not found!"; exit 1; }
                return 0
        fi
	echo "We are in the right directory... Starting..."
	return 0
}

check_dir() {
        if [ ! -d "/GITREPO/Docker/Configs/$1" ]; then
		echo "Directory not exist... Creating it now..."
        	mkdir -p "/GITREPO/Docker/Configs/$1"
        fi
}

copy_to_git_dir() {
	find ./ -name "docker-compose.*" 2>/dev/null | while IFS= read -r composefile; do
		composedir="$(dirname "$composefile")"
                composefilename="$(basename "$composefile")"
                composelinkdir="${composedir#./}"

		echo "Copying: $composelinkdir/$composefilename ..."
		check_dir "$composelinkdir"
		cp /dockerconfig/"$composelinkdir"/"$composefilename" /GITREPO/Docker/Configs/"$composelinkdir"/"$composefilename"

		find "$composedir" -name ".env.enc" 2>/dev/null | while IFS= read -r file; do
			basedirname="$(dirname "$file")"
			linkdirname="${basedirname#./}"

			echo "Copying: $linkdirname/.env.enc ..."
			check_dir "$linkdirname"
			cp /dockerconfig/"$linkdirname"/.env.enc /GITREPO/Docker/Configs/"$linkdirname"/.env.enc
		done
	done
}

check_current_dir
copy_to_git_dir
