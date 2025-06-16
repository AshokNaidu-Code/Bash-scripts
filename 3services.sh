#!/bin/bash

SERVICES=("apache2" "ssh" "mysql")
LOG_FILE="$HOME/service_monitor.log"
INTERVAL=60

trap "echo 'Stopping service monitor'; exit" SIGINT SIGTERM

monitor_services() {
    for SERVICE in "${SERVICES[@]}"; do
        if ! pidof "$SERVICE" > /dev/null; then
            echo "$(date) - $SERVICE is down. Restarting..." | tee -a "$LOG_FILE"
            sudo service "$SERVICE" start
        else
            echo "$(date) - $SERVICE is running." | tee -a "$LOG_FILE"
        fi
    done
}

echo "Monitoring services: ${SERVICES[*]}"
echo "Logging to: $LOG_FILE"

while true; do
    echo "$(date) - Checking services..." | tee -a "$LOG_FILE"
    monitor_services
    sleep "$INTERVAL"
done

