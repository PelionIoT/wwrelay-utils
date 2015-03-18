#!/bin/bash
BAUD_BASE=1500000
DEV=/dev/ttyS2
DIVISOR=10
UART=16550A
#UART=16450
CUSTOMBAUD=38400
setserial -a $DEV baud_base $BAUD_BASE divisor $DIVISOR UART $UART spd_cust
stty -F $DEV $CUSTOMBAUD

echo "now the values"
setserial -a $DEV
stty -F $DEV -a
echo "now sending a U"
echo -n "U" > /dev/ttyS2
