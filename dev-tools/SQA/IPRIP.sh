#!/bin/bash
toggler=0;
TIP="$1"
TNM="$2"
TB="$3"
GW="$4"
SLEEPTIME="$5"


getIP(){
	theipis=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
	echo "$theipis"
}

if [[ $TIP != "" && TNM != "" && TB != "" && GW != "" && SLEEPTIME != "" ]]; then
	echo "IPRIP: starting the IPRIP loop"
	while(true); do
		sleep "$SLEEPTIME"
		if [[ $toggler -eq 0 ]]; then
			udhcpc -qn;
			ip=$(getIP)
			echo "IPRIP: switched IP addresses using udhcpc to: $ip"
			toggler=1;
		else
			ifconfig eth0 "$TIP" netmask "$TNM" broadcast "$TB"
			ip=$(getIP)
			echo "IPRIP: switched IP address using ifconfig to: $ip"
			toggler=0;
		fi
	done
else
	echo "IPRIP: Wont start, missing configuration"
fi

