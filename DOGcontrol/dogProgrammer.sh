#!/bin/bash
pinctl wdog_reset 0;
cat /sys/class/gpio/gpio99/value
sleep 1;
pinctl wdog_reset 1;
cat /sys/class/gpio/gpio99/value
tsb -s /dev/ttyS3 -b 9600 flash /mnt/.boot/AT841WDOG.hex
if [[ $? -eq 0  ]]; then
	if [[ $1 = "minicom" ]]; then
		minicom
	fi
else
	echo "error programming"
fi
