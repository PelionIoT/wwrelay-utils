#!/bin/bash
echo -en "ATTINY OFF: "
pinctrl wdog_reset 0;
cat /sys/class/gpio/gpio99/value
sleep 1;
pinctrl wdog_reset 1;
echo -en "ATTINY ON: "
cat /sys/class/gpio/gpio99/value
if [[ $1 != "" ]]; then
	hexfile=/mnt/.boot/AT841WDOG.hex
else
	hexfile=$1
fi
tsb -s /dev/ttyS3 -b 9600 flash $hexfile
if [[ $? -eq 0  ]]; then
	if [[ $1 = "minicom" || $2 = "minicom" ]]; then
		minicom
	fi
else
	echo "error programming"
fi
