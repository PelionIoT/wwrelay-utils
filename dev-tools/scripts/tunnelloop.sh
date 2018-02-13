#!/bin/bash
counter=0;
maxcount=$((60 * 12))
while (true); do
	counter=$(($counter + 1))
	if [[ counter -gt $maxcount ]]; then
		pid=$(pgrep -f support/index.js)
		kill -9 $pid
		kill -9 $pid
		kill -9 $pid
		counter=0;
		sleep 5;
	fi
	ops=$(cat /sys/class/net/eth0/operstate)
	if [[ $ops -eq 0 ]]; then
		udhcpc -n
	fi
	pgrep -f support/index.js
	if [[ $? -ne 0 ]]; then
		/etc/init.d/devjssupport start
		sleep 5
		/etc/init.d/devjssupport start
	fi
	sleep 60
done
