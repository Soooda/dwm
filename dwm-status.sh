#!/usr/bin/env bash

function get_bytes {
    # Find active network interface accommodating for vpn switching on/off
    temp=$(ip route get 8.8.8.8 2>/dev/null)
    if [[ $temp == *"via"* ]]; then
        interface=$(echo $temp | awk '{print $5}')
    else
        interface=$(echo $temp | awk '{print $3}')
    fi
    line=$(grep $interface /proc/net/dev | cut -d ':' -f 2 | awk '{print "received_bytes="$1, "transmitted_bytes="$9}')
    eval $line
    now=$(date +%s%N)
}

function get_velocity {
	value=$1
	old_value=$2
	now=$3

	timediff=$(($now - $old_time))
	velKB=$(echo "1000000000*($value-$old_value)/1024/$timediff" | bc)
	if test "$velKB" -gt 1024
	then
		echo $(echo "scale=2; $velKB/1024" | bc)MB/s
	else
		echo ${velKB}KB/s
	fi
}

# Set initial values
get_bytes
old_received_bytes=$received_bytes
old_transmitted_bytes=$transmitted_bytes
old_time=$now

while true; do
    LOCALTIME=$(date '+%Y年%m月%d日  %H:%M')
    # DISK=$(df -Ph | grep "/dev/sda6" | awk {'print $5'})
    MEM=$(free -h --kilo | awk '/^Mem:/ {print $3 "/" $2}')
    CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
    # TOTALDOWN=$(ifconfig enp34s0 | grep "RX packets" | awk {'print $6 $7'})
    # TOTALUP=$(ifconfig enp34s0 | grep "TX packets" | awk {'print $6 $7'})
    # WEATHER=$(curl wttr.in?format="%l:+%m+%p+%w+%t+%c+%C")
    # WEATHER=$(curl wttr.in?format=1)

    # Calculates speeds
    get_bytes
    vel_recv=$(get_velocity $received_bytes $old_received_bytes $now)
    vel_trans=$(get_velocity $transmitted_bytes $old_transmitted_bytes $now)

    xsetroot -name "  $MEM  $CPU  $vel_recv  $vel_trans  $LOCALTIME"

    # Update old values to perform new calculations
    old_received_bytes=$received_bytes
    old_transmitted_bytes=$transmitted_bytes
    old_time=$now

    sleep 1s
done
