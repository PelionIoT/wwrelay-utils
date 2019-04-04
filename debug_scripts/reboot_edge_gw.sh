#!/bin/bash

SCRIPT_DIR="/wigwag/wwrelay-utils/debug_scripts"
# SCRIPT_DIR="/home/yashgoyal/workspace/wwrelay-utils/debug_scripts"
restart_services() {
	cd $SCRIPT_DIR
	chmod 755 detect_platform.sh
	source ./detect_platform.sh
	# if [ $hardwareversion == "RP200" ] || [ $hardwareversion == "RP100" ]; then
        echo "Rebooting the GW!"
		# reboot
    # elif [ $hardwareversion == "SOFT_GW" ]; then
        # echo "On SOFT_GW! Restarting the services."
	    echo "Stopping maestro processes..."
		killall maestro
		killall maestro

		echo "Stopping edge core..."
		killall edge-core
		/etc/init.d/wwrelay start
		/etc/init.d/maestro.sh start
    # else
        # echo "Unknown platform! Do not know how to restart the edge services..."
	# fi
}

restart_services
