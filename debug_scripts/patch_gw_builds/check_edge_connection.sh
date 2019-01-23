#!/bin/bash

RUN_SCRIPT="/wigwag/wwrelay-utils/debug_scripts/create-new-eeprom-with-self-signed-certs.sh"

function check_connnection() {
	while true; do
        $RUN_SCRIPT
        if [ $? == 0 ]; then
            exit 0
        fi
        sleep 5
	done
}

check_connnection