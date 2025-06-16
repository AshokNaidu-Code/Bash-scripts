#!/bin/bash

# Mapping: process_name=service_name
declare -A SERVICE_MAP=( 
    [apache2]=apache2
    [sshd]=ssh
    [mysqld]=mysql
)

LOG_FILE="$HOME/service_monitor.log"
INTERVAL=60

trap "echo 'Stopping service monitor'; exit" SIGINT SIGTERM

monitor_services() {
    for PROCESS in "${!SERVICE_MAP[@]}"; do
        SERVICE="${SERVICE_MAP[$PROCESS]}"
        if ! pidof "$PROCESS" > /dev/null; then
            echo "$(date) - $SERVICE ($PROCESS) is down. Restarting..." | tee -a "$LOG_FILE"
            sudo service "$SERVICE" start
        else
            echo "$(date) - $SERVICE ($PROCESS) is running." | tee -a "$LOG_FILE"
        fi
    done
}

echo "Monitoring services: ${!SERVICE_MAP[@]}"
echo "Logging to: $LOG_FILE"

while true; do
    echo "$(date) - Checking services..." | tee -a "$LOG_FILE"
    monitor_services
    sleep "$INTERVAL"
done

