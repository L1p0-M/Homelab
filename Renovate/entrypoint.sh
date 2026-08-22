#!/bin/bash
PUID=${PUID:-1000}
PGID=${PGID:-1000}
CRON_SCHEDULE=${CRON_SCHEDULE:-"0 * * * *"}

export TZ=${TZ:-Europe/Budapest}
if [ -f "/usr/share/zoneinfo/$TZ" ]; then
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
fi

if ! getent group renovatebot >/dev/null; then
    groupadd -g "$PGID" renovatebot
fi

if ! id -u renovatebot >/dev/null 2>&1; then
    useradd -u "$PUID" -g "$PGID" -m -s /bin/bash renovatebot
fi

rm -f /var/run/crond.pid /var/run/cron.pid

# Needed to pass env vars to the cronjob,otherwise the job fails with missing token...
printenv | sed 's/=/="/;s/$/"/' > /etc/environment
chmod 644 /etc/environment

chown -R renovatebot:renovatebot /usr/local/renovate
chown renovatebot:renovatebot /usr/local/sbin/renovate
chmod -R 755 /usr/local/renovate
chmod 755 /usr/local/sbin/renovate

{
    echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    echo "${CRON_SCHEDULE} . /etc/environment; su -s /usr/bin/bash renovatebot -c 'cd /home/renovatebot && /usr/local/sbin/renovate-entrypoint.sh' > /proc/1/fd/1 2>&1"
    echo ""
} > /var/spool/cron/crontabs/root

chown root:crontab /var/spool/cron/crontabs/root
chmod 0600 /var/spool/cron/crontabs/root


cat << EOF
#############################
#     RenovateBot-Cron      #            
#############################
EOF
echo "INFO: Running initial Renovate check on startup..."
su -s /usr/bin/bash renovatebot -c 'cd /home/renovatebot && /usr/local/sbin/renovate-entrypoint.sh' > /proc/1/fd/1 2>&1 || true
echo "INFO: Initial run finished. Starting cron daemon..."
exec "$@"

