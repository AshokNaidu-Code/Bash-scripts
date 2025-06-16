onfiguration ---
refresh_rate=1       # Default refresh rate in seconds
display_mode="bars"  # Default display mode

# --- Functions ---

get_cpu_usage() {
  local cpu_idle=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)% id.*/\1/")
  echo "$(echo "100 - $cpu_idle" | bc)"
}

get_memory_usage() {
  local total=$(free -m | awk '/Mem:/{print $2}')
  local used=$(free -m | awk '/Mem:/{print $3}')
  echo "$used $total"
}

get_network_usage() {
  local interface=$(ip route | grep default | awk '{print $5}')
  if [ -z "$interface" ]; then
    echo "0.00 0.00" # Return 0 if no default interface found
    return
  fi
  local rx_before=$(ifstat -i "$interface" 1 1 | tail -n 1 | awk '{print $1}')
  local tx_before=$(ifstat -i "$interface" 1 1 | tail -n 1 | awk '{print $2}')
  sleep "$refresh_rate"
  local rx_after=$(ifstat -i "$interface" 1 1 | tail -n 1 | awk '{print $1}')
  local tx_after=$(ifstat -i "$interface" 1 1 | tail -n 1 | awk '{print $2}')
  local rx_rate=$(echo "scale=2; ($rx_after - $rx_before) / $refresh_rate" | bc)
  local tx_rate=$(echo "scale=2; ($tx_after - $tx_before) / $refresh_rate" | bc)
  echo "$(printf "%.2f %.2f" "$rx_rate" "$tx_rate")"
}

draw_bars() {
  local cpu_percent="$1"
  local mem_used="$2"
  local mem_total="$3"
  local rx_rate="$4"
  local tx_rate="$5"

  local term_width=$(tput cols)
  local cpu_bar_width=$((cpu_percent * term_width / 100))
  local mem_percent=$((mem_used * 100 / mem_total))
  local mem_bar_width=$((mem_percent * term_width / 100))

  local i=1
  local cpu_bar=""
  while [ "$i" -le "$cpu_bar_width" ]; do
    cpu_bar+="="
    i=$((i + 1))
  done
  local cpu_space=""
  while [ "$i" -le "$term_width" ]; do
    cpu_space+=" "
    i=$((i + 1))
  done
  echo "CPU: [$cpu_bar$cpu_space] ${cpu_percent}%"

  i=1
  local mem_bar=""
  while [ "$i" -le "$mem_bar_width" ]; do
    mem_bar+="="
    i=$((i + 1))
  done
  local mem_space=""
  while [ "$i" -le "$term_width" ]; do
    mem_space+=" "
    i=$((i + 1))
  done
  echo "Mem: [$mem_bar$mem_space] ${mem_percent}% (${mem_used}M/${mem_total}M)"

  echo "Net RX: ${rx_rate} KB/s"
  echo "Net TX: ${tx_rate} KB/s"
}

# --- Main Loop ---
while true; do
  cpu_usage=$(get_cpu_usage)
  mem_info=$(get_memory_usage)
  mem_used=$(echo "$mem_info" | awk '{print $1}')
  mem_total=$(echo "$mem_info" | awk '{print $2}')
  network_info=$(get_network_usage)
  rx=$(echo "$network_info" | awk '{print $1}')
  tx=$(echo "$network_info" | awk '{print $2}')

  clear  # Clear the terminal for each update

  case "$display_mode" in
    "bars")
      draw_bars "$cpu_usage" "$mem_used" "$mem_total" "$rx" "$tx"
      ;;
    # Add other display modes here (gauges would be more complex with pure bash)
    *)
      echo "Display mode '$display_mode' not supported."
      ;;
  esac

  sleep "$refresh_rate"
done

# --- Cleanup (not strictly needed for this simple loop) ---
