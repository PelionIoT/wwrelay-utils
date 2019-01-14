#!/bin/bash
echo "Stopping edge-core..."
kill `ps -ef | grep edge-core | awk '{print $2}'`
sleep 2
echo "Restarting edge-core"
/etc/init.d/mbed-edge-core start
sleep 2

echo "Stopping mbed-devicejs-bridge..."
kill `ps -ef | grep mbed-devicejs-bridge | awk '{print $2}'`
echo "Maestro will restart mbed-devicejs-bridge..."
echo "Work done. Good Bye!"
