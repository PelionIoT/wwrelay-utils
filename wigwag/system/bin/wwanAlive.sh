#!/bin/bash

start_network(){
	echo "starting qmi"
	qmi-network /dev/cdc-wdm0 start
	if [[ $? -eq 0 ]]; then
		echo "start success, running dhclinet"
		dhclient -v $(qmicli -d /dev/cdc-wdm0 -w)
		echo nameserver 8.8.8.8 > /etc/resolv.conf
	else
		echo "start failed with non zero, stopping"
		stop_network;
	fi
}

stop_network(){
	echo "stopping network"
	qmi-network /dev/cdc-wdm0 stop
	killall -9 dhclient
	sleep 10

}

loop(){
	while true; do
		sleep 15
		status=$(qmicli -d /dev/cdc-wdm0 --wds-get-packet-service-status --device-open-proxy | awk -F ' ' '{print $4}')
		if [[ "$status" = "'connected'" ]]; then
			echo "network is ok"
		else
			if [[ -e /dev/cdc-wdm0 ]]; then
				echo "disconnected: starting network"
				stop_network;
				start_network;
			else
				"/dev/cdc-wdm0 does not exist"
			fi
		fi
	done
}


if [[ $1 = "" ]]; then
	loop
else
	$1
fi
