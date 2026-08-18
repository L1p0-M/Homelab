#!/bin/ash
PUID=${PUID:-1000}
PGID=${PGID:-1000}
export CONFIGDIR=${CONFIGDIR:-/app/config}
export DRY_RUN=${DRY_RUN:-true}
CRON_SCHEDULE=${CRON_SCHEDULE:-"0 23 * * mon"}

if ! id -u watcher >/dev/null 2>&1; then
    addgroup -g "$PGID" watcher 2>/dev/null || true
    adduser -u "$PUID" -G watcher -D -h /home/watcher -s /bin/ash watcher
fi

{
    echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    echo "${CRON_SCHEDULE} su-exec watcher /usr/local/bin/python /app/app.py >> /var/log/cron.log 2>&1"
    echo ""
} > /var/spool/cron/crontabs/root
chmod 0600 /var/spool/cron/crontabs/root

chown watcher:watcher /app
chown watcher:watcher /app/trash
chown watcher:watcher /app/app.py
mkdir -p "$CONFIGDIR"

touch /var/log/cron.log
crond -b -l 2

cat << EOF
#############################
#       Watcher-Agent       #            
#############################
EOF
su-exec watcher python /app/app.py >> /var/log/cron.log 2>&1
cat /var/log/cron.log
exec su-exec watcher "$@"

