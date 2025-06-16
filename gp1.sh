h rate
REFRESH_RATE=2

# Function to get CPU usage
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2+$4}'
}

# Function to get memory usage
get_mem_usage() {
    free | grep Mem | awk '{print $3/$2 * 100.0}'
}

# Function to get network usage
get_network_usage() {
    ifstat -T 1 1 | tail -n 1 | awk '{print $1, $2}'
}

# Function to display the graphical UI
display_ui() {
    while true; do
        CPU=$(get_cpu_usage)
        MEM=$(get_mem_usage)
        NET=$(get_network_usage)

        dialog --title "System Resource Monitor" --gauge "CPU Usage: $CPU%\nMemory Usage: $MEM%\nNetwork Usage: $NET" 10 50 $CPU

        sleep $REFRESH_RATE
    done
}

# Function to set refresh rate
set_refresh_rate() {
    REFRESH_RATE=$(dialog --inputbox "Enter refresh rate (seconds):" 8 40 $REFRESH_RATE 3>&1 1>&2 2>&3)
}

# Main menu
while true; do
    CHOICE=$(dialog --menu "Choose an option:" 15 50 4 \
        1 "Start Monitoring" \
        2 "Set Refresh Rate" \
        3 "Exit" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) display_ui ;;
        2) set_refresh_rate ;;
        3) break ;;
    esac
done

clear
echo "Exiting System Resource Monitor."
