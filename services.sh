#!/bin/bash
SERVICES=("apache2" "ssh" "mysql")

LOG_FILE="/var/log/service_monitor.log"

monitor_services() {
    for SERVICE in "${SERVICES[@]}"; do
        if ! service "$SERVICE" status > /dev/null 2>&1; then
            echo "$(date) - $SERVICE is down. Restarting..." | tee -a "$LOG_FILE"
            sudo service "$SERVICE" restart
        fi
    done
}
echo "Monitoring services..."

while true; do
    echo "$(date) - Checking services..."
    monitor_services
    sleep 60
done


