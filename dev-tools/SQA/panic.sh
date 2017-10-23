#!/bin/bash
#loops and loops the upgrade
starttime="$1"
if [[ $starttime = ""  ]]; then
	echo "panic loop is not going to begin.  useage: panic.sh <starttime>"
	echo "failed to provide: starttime: $starttime"
else
	sleep "$starttime"
	/etc/init.d/deviceOS-watchdog panic
fi


