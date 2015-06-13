#!/bin/bash
BAUD_BASE=1500000
DEV=/dev/ttyS2
DIVISOR=10
UART=16550A
#UART=16450
CUSTOMBAUD=38400
# https://github.com/cbrake/linux-serial-test


function custom {
	setserial -a $DEV baud_base $BAUD_BASE divisor $DIVISOR UART $UART spd_cust
	stty -F $DEV $CUSTOMBAUD
	echo "now the values"
	setserial -a $DEV
	stty -F $DEV -a
	echo "now sending a U"
	echo -n "U" > /dev/ttyS2
}

function regular_set {
	setserial -a $DEV baud_base $BAUD_BASE divisor $DIVISOR UART $UART spd_normal
	stty -F $DEV 115200
	echo "now the values"
	setserial -a $DEV
	stty -F $DEV -a
	echo "now sending a U"
	echo -n "U" > /dev/ttyS2
}

function longsend {
	./linux-serial-test -s -p /dev/ttyS2 -b 115200
}

function shortsend {
	linux-serial-test -y 0x55 -z 0x0 -p /dev/ttyS2 -b 115200
}

if [[ "$1" = "regular" ]]; then
	regular_set
else
	longsend
fi