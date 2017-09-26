#!/bin/bash

timing=10
fsize=48M;

#/etc/init.d/wdogreporter.sh &


echo -e "-----\nstarting a new session\n" 
echo -e "   sleeping 10"
sleep 90
for i in {1..5}; do
	echo -e "  fake$i created"
	fallocate -l $fsize /var/log/fake$i
	df -h 
	echo "   sleeping $timing"
	sleep $timing
done
echo -e "done filling var/log"
while true; do
	echo -e "   firing up node " 
	node &
	npid1=$!
	sleep $timing
	echo "   my node: $npid1" 
	sleep $timing
	kill -9 $npid1
	sleep 10
done