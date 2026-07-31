#!/bin/bash
set -e

git config --global --add safe.directory /home/l1p0/Homelab/PVE/Docker 2>/dev/null || true
echo "==== 1. Pulling latest code from Git ===="
cd /GITREPO/Docker
git pull

echo "==== 2. Running symlinker script for new folders ===="
if [ -f "/dockerconfig/symlinker.sh" ]; then
    /dockerconfig/symlinker.sh
fi

echo "==== 3. Decrypting .env secrets ===="
find /GITREPO/Docker/Configs -name ".env.enc" 2>/dev/null | while IFS= read -r enc_file; do
    rel_path="${enc_file#/GITREPO/Docker/Configs/}"

    rel_dir="$(dirname "$rel_path")"
    target_env="/dockerconfig/$rel_dir/.env"

    echo "Decrypting $rel_path -> $target_env"
    sops --input-type dotenv --output-type dotenv -d "$enc_file" > "$target_env"

    #chmod 600 "$target_env"
done

echo "==== 4. Recreating Docker containers ===="
cd /dockerconfig

find . -maxdepth 2 -mindepth 1 -type d 2>/dev/null | while IFS= read -r dir; do
    if [ -f "$dir/docker-compose.yml" ] || [ -f "$dir/docker-compose.yaml" ]; then
        echo "Updating stack in: $dir"
        (cd "$dir" && docker compose up -d)
    fi
done

echo "==== Deployment successfully finished! ===="
