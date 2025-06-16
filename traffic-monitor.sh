#!/bin/bash

# Configuration
API_KEY="youmailgun_api_key"
DOMAIN="sandbox4b818b692de14ee2baffc415eb0cfc40.mailgun.org"
RECIPIENT="ashoknallam03@gmail.com"
SUBJECT="Network Traffic Alert"
MESSAGE="High network traffic detected on your EC2 instance."

# Network interface to monitor (e.g., eth0)
INTERFACE="eth0"

# Threshold in bytes (e.g., 1000000 for ~1MB)
THRESHOLD=100

# File to store previous RX bytes
PREV_FILE="/tmp/prev_rx_bytes"

# Get current RX bytes
RX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)

# Read previous RX bytes
if [ -f $PREV_FILE ]; then
    PREV_RX_BYTES=$(cat $PREV_FILE)
else
    PREV_RX_BYTES=$RX_BYTES
fi

# Calculate difference
DIFF=$((RX_BYTES - PREV_RX_BYTES))

# Save current RX bytes for next check
echo $RX_BYTES > $PREV_FILE

# Check if difference exceeds threshold
if [ $DIFF -gt $THRESHOLD ]; then
    curl -s --user "api:$API_KEY" \
      https://api.mailgun.net/v3/$DOMAIN/messages \
      -F from="Alert System <postmaster@$DOMAIN>" \
      -F to="$RECIPIENT" \
      -F subject="$SUBJECT" \
      -F text="$MESSAGE"
fi

