#!/bin/bash
baud=9600


rebootTiny(){
	echo -en "ATTINY OFF: "
	pinctrl wdog_reset 0;
	cat /sys/class/gpio/gpio99/value
	sleep 1;
	pinctrl wdog_reset 1;
	echo -en "ATTINY ON: "
	cat /sys/class/gpio/gpio99/value
	
}

programTiny(){
	if [[ $1 = "" ]]; then
		hexfile=/mnt/.boot/AT841WDOG.hex
	else
		hexfile=$1
	fi
	echo "calling tiny safe boot: tsb -s /dev/ttyS3 -b $baud flash $hexfile"
	tsb -s /dev/ttyS3 -b $baud flash $hexfile
	if [[ $? -eq 0  ]]; then
		if [[ $1 = "minicom" || $2 = "minicom" ]]; then
			minicom
		fi
	else
		exit 1
	fi
	exit 0
}

if [[ $1 = "" ]]; then
	rebootTiny
	programTiny
elif [[ $1 = "-h" || $1 = "--help" ]]; then
	echo "Useage: $0 [-b baud] [hexfile]"
	echo "defaults to baud 9600 and /mnt/.boot/AT841WDOG.hex"
elif [[ $1 = "-b" ]]; then
	baud=$2
	rebootTiny
	programTiny $3
else
	rebootTiny
	programTiny $1
fi


	#statements
