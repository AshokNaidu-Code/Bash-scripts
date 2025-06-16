#!/bin/bash

# Default refresh rate
REFRESH_RATE=2

# Check for required dependencies
if ! command -v dialog >/dev/null 2>&1; then
   echo "Error: 'dialog' is not installed. Please install it and try again."
   exit 1
fi

# Optional: check for ifstat (used for network stats)
USE_IFSTAT=true
if ! command -v ifstat >/dev/null 2>&1; then
   echo "Warning: 'ifstat' not found. Network usage will be unavailable."
   USE_IFSTAT=false
fi

# Function to get CPU usage
get_cpu_usage() {
    LANG=C top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}'
}

# Function to get memory usage
get_mem_usage() {
    free | grep Mem | awk '{print $3 / $2 * 100.0}'
}

# Function to get network usage
get_network_usage() {
        if [ "$USE_IFSTAT" = true ]; then
                NET_OUTPUT=$(ifstat -T 1 1 2>/dev/null | tail -n 1)
                if [[ -z "$NET_OUTPUT" ]]; then
                        echo "Unavailable"
                else
                        echo "$NET_OUTPUT" | awk '{print "In: " $1 " KB/s | Out: " $2 " KB/s"}'
                fi
        else
                echo "Unavailable"
        fi
}
# Function to display system stats
display_ui() {
        TEMPFILE=$(mktemp)
        trap "rm -f $TEMPFILE; clear; exit" SIGINT SIGTERM
        trap "rm -f $TEMPFILE; clear" EXIT

        while true; do
                CPU=$(printf "%.1f" "$(get_cpu_usage)")
                MEM=$(printf "%.1f" "$(get_mem_usage)")
                NET=$(get_network_usage)

                {
                        echo "50"
                        echo "# CPU Usage   : $CPU %"
                        echo "# Memory Usage: $MEM %"
                        echo "# Network     : $NET"
                        echo "# Press Ctrl+C to exit."
                } > "$TEMPFILE"
        dialog --title "System Resource Monitor" --gauge "$(cat "$TEMPFILE")" 10 60 0
        sleep "$REFRESH_RATE"
done
}
# Function to set refresh rate
set_refresh_rate() {
        REFRESH_RATE=$(dialog --inputbox "Enter refresh rate (seconds):" 8 40 "$REFRESH_RATE" 3>&1 1>&2 2>&3
)
        if ! [[ "$REFRESH_RATE" =~ ^[0-9]+$ ]]; then
                REFRESH_RATE=2
        fi
}

# Main menu
while true; do
            CHOICE=$(dialog --menu "Choose an option:" 15 50 4 \
                    1 "Start Monitoring" \
                    2 "Set Refresh Rate" \
                    3 "Exit" 3>&1 1>&2 2>&3)
            case "$CHOICE" in
                    1) display_ui ;;
                    2) set_refresh_rate ;;
                    3) break ;;
            esac
done

clear

echo "Exiting System Resource Monitor."

