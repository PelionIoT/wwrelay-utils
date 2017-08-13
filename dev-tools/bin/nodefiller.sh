#!/bin/bash
#
log=/wigwag/log/nodefiller.log
itterationcounter=/wigwag/log/nodefiller.cnt
timing=10
fsize=48M;

/etc/init.d/wdogreporter.sh &
num=$(cat $itterationcounter);num=$(( $num + 1 ));echo $num > $itterationcounter
echo "total restarts: $num " >> /dev/ttyS0

echo -e "-----\nstarting a new session\n" >> $log
echo -e "   sleeping 90"
sleep 90
for i in {1..5}; do
	echo -e "  fake$i created"
	fallocate -l $fsize /var/log/fake$i
	df -h >> $log 2>&1
	#~/info.sh >> $log 2>&1
	echo "   sleeping $timing"
	sleep $timing
done
echo -e "done filling var/log"
while true; do
	echo -e "   firing up node " >> $log 2>&1
	node &
	npid1=$!
	sleep $timing
	echo "   my node: $npid1" >> $log 2>&1
	sleep $timing
	kill -9 $npid1
	sleep 10
done