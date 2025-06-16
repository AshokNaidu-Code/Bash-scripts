#!/bin/bash

# Map process_name to service_name
declare -A SERVICE_MAP=(
    [apache2]=apache2
    [mysqld]=mysql
    [sshd]=ssh
)

LOG_FILE="$HOME/service_monitor.log"
INTERVAL=60

trap "echo 'Stopping service monitor'; exit" SIGINT SIGTERM

# Function to check if service is truly running
is_service_running() {
    service "$1" status 2>/dev/null | grep -q "start/running"
}

monitor_services() {
    for PROCESS in "${!SERVICE_MAP[@]}"; do
        SERVICE="${SERVICE_MAP[$PROCESS]}"
        
        if ! is_service_running "$SERVICE"; then
            echo "$(date) - $SERVICE is down. Restarting..." | tee -a "$LOG_FILE"
            sudo service "$SERVICE" start
        else
            echo "$(date) - $SERVICE is running." | tee -a "$LOG_FILE"
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

