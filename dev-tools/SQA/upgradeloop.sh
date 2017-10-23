#!/bin/bash
#loops and loops the upgrade
starttime="$1"
upgradenum="$2"
if [[ $starttime = "" || upgradenum = "" ]]; then
	echo "upgradeloop is not going to begin.  useage: upgradeloop <starttime> <upgradenum>"
	echo "failed to provide: starttime: $starttime, upgradenum: $upgradenum"
else
	sleep "$starttime"
	upgrade -r "$upgradenum"	
fi
