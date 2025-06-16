#!/bin/bash

# Define the list of IPs or domain names to check
HOSTS=("192.168.255.255" "google.com" "1.1.1.1")

# Log file
LOGFILE="/var/log/network_health.log"


EMAIL="ashokkumar.cse.1@gmail.com"
SUBJECT="Network Health Alert"

# Function to check network health
check_network() {
    for HOST in "${HOSTS[@]}"; do
        if ! ping -c 2 "$HOST" > /dev/null 2>&1; then
            TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
            MESSAGE="[$TIMESTAMP] Ping failed for $HOST"
            echo "$MESSAGE" | tee -a "$LOGFILE"

            # Send email alert
            echo "$MESSAGE" | mail -s "$SUBJECT" "$EMAIL"
        fi
    done
}

# Run the network check
check_network
