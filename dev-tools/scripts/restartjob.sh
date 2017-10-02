#!/bin/bash
killall -9 node
killall -9 devicedb
sleep 5
/etc/init.d/devicejs start
/etc/init.d/relayterm start
