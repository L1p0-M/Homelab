#!/bin/bash

set -e

check_current_dir() {
        echo "Changing to the repo directory..."
        cd /GITREPO/Docker/Configs || { echo "Error: The /GITREPO/Docker/Configs directory not found!"; exit 1; }
    	echo "We are in the right directory... Starting..."
  	return 0
}

check_dir() {
	if [ ! -d "/dockerconfig/$1" ]; then
        	echo "Directory does not exist in /dockerconfig... Creating it now..."
        	mkdir -p "/dockerconfig/$1"
    	fi
}

check_files() {
	local target_file="/dockerconfig/$1/$2"
	if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
		echo "Physical file found. Creating backup: $target_file.bak"
		mv "$target_file" "$target_file.bak"
	fi
}

symlinker() {
	find ./ -name "docker-compose.*" 2>/dev/null | while IFS= read -r composefile; do
		composedir="$(dirname "$composefile")"
		composefilename="$(basename "$composefile")"
		composelinkdir="${composedir#./}"

		echo "Symlinking to: /dockerconfig/$composelinkdir/$composefilename ..."
		check_dir "$composelinkdir"
		check_files "$composelinkdir" "$composefilename"

		ln -sf "/GITREPO/Docker/Configs/$composelinkdir/$composefilename" "/dockerconfig/$composelinkdir/$composefilename"

		find "$composedir" -name ".env.enc" 2>/dev/null | while IFS= read -r file; do
			basedirname="$(dirname "$file")"
            		linkdirname="${basedirname#./}"

            		echo "Symlinking to: /dockerconfig/$linkdirname/.env.enc ..."
            		check_dir "$linkdirname"
                	check_files "$linkdirname" ".env.enc"

            		ln -sf "/GITREPO/Docker/Configs/$linkdirname/.env.enc" "/dockerconfig/$linkdirname/.env.enc"
        	done
    	done
}

check_current_dir
symlinker
