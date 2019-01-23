#!/bin/bash

echo "Updating... /etc/init.d/mbed-edge-core"
cp ./mbed-edge-core /etc/init.d/mbed-edge-core
chmod 755 /etc/init.d/mbed-edge-core

echo "Updating... edge-core to 0.7.1"
killall edge-core
rm /wigwag/mbed/edge-core/build/bin/edge-core
cp ./edge-core /wigwag/mbed/edge-core/build/bin

echo "Updating... logrotate"
cp ./logrotate.conf /etc/logrotate.conf

echo "Updating... led.sh"
cp ./led.sh /wigwag/system/bin/led

echo "Burning new firmware to AT841 micro..."
/etc/init.d/deviceOS-watchdog humanhalt
dogProgrammer ./AT841WDOG_v1.2.hex
/etc/init.d/deviceOS-watchdog start

echo "Update writeEEPROM.js"
cp ./writeEEPROM.js /wigwag/wwrelay-utils/I2C/

echo "Adding check_edge_connection.sh"
cp ./check_edge_connection.sh /wigwag/wwrelay-utils/debug_scripts/
chmod 755 /wigwag/wwrelay-utils/debug_scripts/check_edge_connection.sh

echo "Adding run_mbed_edge_core.sh"
cp ./run_mbed_edge_core.sh /wigwag/wwrelay-utils/debug_scripts/
chmod 755 /wigwag/wwrelay-utils/debug_scripts/run_mbed_edge_core.sh

echo "Update create-new-eeprom with self-signed certs"
cp ./create-new-eeprom-with-self-signed-certs.sh /wigwag/wwrelay-utils/debug_scripts/
chmod 755 /wigwag/wwrelay-utils/debug_scripts/create-new-eeprom-with-self-signed-certs.sh

echo "Updating wwrelay init.d"
cp ./wwrelay /etc/init.d/wwrelay
chmod 755 /etc/init.d/wwrelay

echo "Updating get-eeprom scritps"
cp ./fetch* /wigwag/wwrelay-utils/debug_scripts/tools/
chmod 755 /wigwag/wwrelay-utils/debug_scripts/tools/fetcheeprom.sh

echo "Updating factory reset script"
cp ./factory_wipe_gateway.sh /wigwag/wwrelay-utils/debug_scripts/
chmod 755 /wigwag/wwrelay-utils/debug_scripts/factory_wipe_gateway.sh
