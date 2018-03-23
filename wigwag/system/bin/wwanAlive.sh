#!/bin/bash

start_network(){
	qmi-network /dev/cdc-wdm0 start
	dhclient -v $(qmicli -d /dev/cdc-wdm0 -w)
	echo nameserver 8.8.8.8 > /etc/resolv.conf
}

stop_network(){
	qmi-network /dev/cdc-wdm0 stop
	killall -9 dhclient
	sleep 2

}
while true; do
	sleep 3
	status=$(qmicli -d /dev/cdc-wdm0 --wds-get-packet-service-status --device-open-proxy | awk -F ' ' '{print $4}')
	if [[ "$status" = "'disconnected'" ]]; then
		echo "starting network"
		stop_network;
		start_network;
	else
		echo "network is ok"
	fi
done
