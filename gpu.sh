EFRESH_RATE=2  # Default refresh rate (seconds)
DISPLAY_MODE="all"  # Default display mode (cpu, mem, net, all)

draw_screen() {
    clear
    echo "========================================="
    echo "      SYSTEM RESOURCE MONITOR (NCURSES)  "
    echo "========================================="
    echo "Refresh Rate: $REFRESH_RATE seconds | Mode: $DISPLAY_MODE"
    echo "========================================="
    
    if [[ "$DISPLAY_MODE" == "cpu" || "$DISPLAY_MODE" == "all" ]]; then
        echo "CPU Usage:"
        mpstat 1 1 | awk '/all/ {printf "Usage: %.2f%%\n", 100 - $12}'
    fi
    
    if [[ "$DISPLAY_MODE" == "mem" || "$DISPLAY_MODE" == "all" ]]; then
        echo "Memory Usage:"
        free -h | awk 'NR==2{printf "Used: %s / Total: %s\n", $3, $2}'
    fi
    
    if [[ "$DISPLAY_MODE" == "net" || "$DISPLAY_MODE" == "all" ]]; then
        echo "Network Traffic:"
        vnstat --live 1 | head -5
    fi
    
    echo "========================================="
}

# Main loop to continuously update system resources
while true; do
    draw_screen
    sleep "$REFRESH_RATE"
done
