#!/bin/bash

EEPROG=$(which eeprog)
if [ "$EEPROG" == "" ]; then
	hardwareversion="SOFT_GW"
else
	eeprog /dev/i2c-1 0x55 -f -r 0:10 2> /dev/null
		if [[ $? -eq 0 ]]; then
			hardwareversion="RP100"
		else
			hardwareversion="RP200"
		fi
fi
echo "You are on platform="$hardwareversion