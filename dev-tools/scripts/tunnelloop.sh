#!/bin/bash
counter=0;
maxcount=$((60 * 12))
echo "$counter/$maxcount just now starting, waiting 180" > /tmp/timeloopcounter
sleep 180
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
	fi
	TIP=$(nslookup tunnel.wigwag.com | xargs | egrep -o tunnel.wigwag.com.* | awk '{ print $4 }')
	netstat -an | grep $TIP
	if [[ $? -ne 0 ]]; then
		curl http://localhost:3000/start
	fi
	echo $counter > /tmp/timeloopcounter
	echo "if this value gets to $maxcount, the tunnel will rebuild" >> /tmp/timeloopcounter
	sleep 60
done
