#!/bin/bash
kill `ps -ef | grep serialviapingpong | awk '{print $2}'`
sleep 2

FAIL=0

echo 'Starting Client'
NODE_PATH=/wigwag/devicejs-core-modules/node_modules/:node_modules/ node test-serialviapingpong.js /dev/ttyUSB1 115200 client &
client_pid=$!

sleep 2

echo 'Starting Server'
NODE_PATH=/wigwag/devicejs-core-modules/node_modules/:node_modules/  node test-serialviapingpong.js /dev/ttyUSB0 115200 server &
server_pid=$?


for job in `jobs -p`
do
echo $job
    wait $job || let "FAIL+=1"
done

echo $FAIL

if [ "$FAIL" == "0" ];
then
echo "YAY!"
else
echo "FAIL! ($FAIL)"
fi
