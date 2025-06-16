#!/bin/bash

# Define list of hosts to check
HOSTS=("8.8.8.8" "1.1.1.1" "google.com" "invalid.domain.test" "example.com")

# Log file location
LOG_FILE="/var/log/network_health.log"

# Mailgun credentials and settings
MAILGUN_DOMAIN="sandbox4b818b692de14ee2baffc415eb0cfc40.mailgun.org"           # e.g., sandbox12345.mailgun.o
MAILGUN_API_KEY="your_mailgun_api_key"              # e.g., key-xxxxxxxxxxxxxxx
MAILGUN_FROM="Network Monitor <monitor@sandbox4b818b692de14ee2baffc415eb0cfc40.mailgun.org>"
MAILGUN_TO="ashoknallam03@gmail.com"

# Timestamp function
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Ensure log file exists
touch "$LOG_FILE"

# Log start
echo "[$(timestamp)] Starting network health check..." >> "$LOG_FILE"

# Flag to track failures
FAILED_HOSTS=()

# Check each host
for HOST in "${HOSTS[@]}"; do
    if ping -c 2 -W 2 "$HOST" > /dev/null; then
        echo "[$(timestamp)] SUCCESS: $HOST is reachable." >> "$LOG_FILE"
    else
        echo "[$(timestamp)] FAILURE: $HOST is not reachable!" >> "$LOG_FILE"
        FAILED_HOSTS+=("$HOST")
    fi
done

# Send alert if any host failed
if [ ${#FAILED_HOSTS[@]} -gt 0 ]; then
    MESSAGE="Network Health Alert:\n\nThe following hosts are unreachable as of $(timestamp):\n"
    for HOST in "${FAILED_HOSTS[@]}"; do
        MESSAGE+="- $HOST\n"
    done

    # Send alert via Mailgun
    curl -s --user "api:$MAILGUN_API_KEY" \
        https://api.mailgun.net/v3/$MAILGUN_DOMAIN/messages \
        -F from="$MAILGUN_FROM" \
        -F to="$MAILGUN_TO" \
        -F subject="⚠️ Network Health Alert: Host Unreachable" \
        -F text="$MESSAGE"

    echo "[$(timestamp)] ALERT sent via Mailgun for failed hosts." >> "$LOG_FILE"
fi

echo "[$(timestamp)] Network health check completed." >> "$LOG_FILE"

