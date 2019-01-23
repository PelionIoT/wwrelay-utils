#!/bin/bash

START_EDGE_CORE="/etc/init.d/mbed-edge-core start"

function run_edge_core() {
	while true; do
        if ! pgrep -x "edge-core" > /dev/null
        then
            $START_EDGE_CORE &
            sleep 5
            kill $(ps aux | grep 'mbed-devicejs-bridge' | awk '{print $2}');
        fi
        sleep 5
	done
}

run_edge_core