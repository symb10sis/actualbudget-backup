#!/bin/bash

. /app/includes.sh

if [[ "$1" == "rclone" ]]; then
    $*
    exit 0
fi

function configure_timezone() {
    ln -sf "/usr/share/zoneinfo/${TIMEZONE}" "${LOCALTIME_FILE}"
}

function configure_cron() {
    mkdir -p "$(dirname "${CRON_CONFIG_FILE}")"
    local FIND_CRON_COUNT="$(grep -c 'backup.sh' "${CRON_CONFIG_FILE}" 2> /dev/null || echo 0)"
    if [[ "${FIND_CRON_COUNT}" -eq 0 ]]; then
        # Prepend 'cd /tmp &&' so relative paths write to a writable location
        echo "${CRON} cd /tmp && bash /app/backup.sh" > "${CRON_CONFIG_FILE}"
    fi
}

init_env
check_rclone_connection all
configure_timezone
configure_cron

# backup manually
if [[ "$1" == "backup" ]]; then
    color yellow "Manually triggering a backup will only execute the backup script once, and the container will exit upon completion."
    cd /tmp && bash "/app/backup.sh"
    exit 0
fi

# foreground run crond
exec /usr/bin/supercronic -passthrough-logs -quiet "${CRON_CONFIG_FILE}"
