#!/bin/bash

echo "Updating... /etc/init.d/mbed-edge-core"
cp ./mbed-edge-core /etc/init.d/mbed-edge-core
chmod 755 /etc/init.d/mbed-edge-core

echo "Updating... edge-core to 0.7.1"
cp ./edge-core /wigwag/mbed/edge-core/build/bin

echo "Updating... logrotate"
cp ./logrotate.conf /etc/logrotate.conf

echo "Updating... led.sh"
cp ./led.sh /wigwag/system/bin/led
