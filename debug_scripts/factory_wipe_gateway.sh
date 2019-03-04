#!/bin/bash
echo "Stopping deviceOSWD"
/etc/init.d/deviceOS-watchdog humanhalt

echo "Stopping maestro processes..."
killall maestro
killall maestro

echo "Stopping edge core..."
kill $(ps aux | grep -E 'edge-core|edge_core' | awk '{print $2}');

echo "Stopping node processes..."
killall node

echo "Deleting gateway database"
rm -rf /userdata/etc/devicejs/db
echo "Deleting mcc_config. Will be restored from eeprom!"
rm -rf /userdata/mbed/mcc_config*
echo "Deleting maestro configuration database"
rm -rf /userdata/etc/maestroConfig.db


echo "Delete gateway_eeprom file"
rm -rf /userdata/edge_gw_config*
