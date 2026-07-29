#!/bin/bash
DEBUG=false

drive_is_mounted(){
	MOUNTED=$(df -h | grep -c 192.168.1.90:/mnt/backuppool)
	if [ "$DEBUG" == "true" ]; then
		echo "${MOUNTED}"
	fi
	return "${MOUNTED}"
}
backup_proc_check(){
	echo "Checking if the pool is mounted..."
	if [[ "$1" == 1 ]]; then
		echo "Backupdrive mounted"
		return 1
	else
		echo "Backupdrive not mounted... Mounting it now..."
		sudo mount -a
		sleep 10
		drive_is_mounted
		if [ $? == 1 ]; then
			echo "Mounted"
			return 1
		else
			return 0
		fi
	fi
}

drive_is_mounted
backup_proc_check $?
if [ $? == 1 ]; then
	echo "Starting Backup Process..."
	echo "Backing up Compose files..."
	mkdir /backuppool/Szerver/docker/compose/"$(date +"%Y-%m-%d")"
	find /dockerconfig -print | grep -i docker-compose.yml
	for i in /dockerconfig/*/docker-compose.yml; do
  		name=$(basename $(dirname "$i"))
  		cp "$i" "/backuppool/Szerver/docker/compose/"$(date +"%Y-%m-%d")"/$name-"$(date +"%Y-%m-%d")".yml"
	done
	for i in /dockerconfig/*/*/docker-compose.yml; do
  		name=$(basename $(dirname "$i"))
  		cp "$i" "/backuppool/Szerver/docker/compose/"$(date +"%Y-%m-%d")"/$name-"$(date +"%Y-%m-%d")".yml"
	done
	COUNT=$(ls /backuppool/Szerver/docker/compose/"$(date +"%Y-%m-%d")" | wc -w)
	echo "Backup of ${COUNT} Compose files successful :)"
else
	echo "Mounting failed :("
fi
BACKUPCOUNT=$(ls /backuppool/Szerver/docker/compose/ | wc -w)
if [[ ${BACKUPCOUNT} -gt 5 ]]; then
	cd /backuppool/Szerver/docker/compose/
	rm -r "$(ls -t | tail -1)"
	#git add .
	#git commit -m "Backup $(date +"%Y-%m-%d")"
	#git push
fi
