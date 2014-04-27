#!/bin/bash
COMMAND=$1

AVAILABLE="reset erase RTSlow RTShigh"
fail=0
[[ $AVAILABLE =~ $COMMAND ]] || fail=1
if [ -z $1 ]
then
    fail=1
fi

if [ "$fail" -eq 1 ]
then
    echo "not a command.  Use one of the following [$AVAILABLE]"
    echo "When programming the 6B, RTS must be low, before reseting the 6B"
    echo "procedure to always be sucessful programming: 1) erase 2) RTSlow 3) start sending the build. 4) reset 6B"
    exit
fi


Reset=/sys/class/gpio/gpio5_pb8
RTS=/sys/class/gpio/gpio7_ph8
Erase=/sys/class/gpio/gpio6_pb13

echo "I got $COMMAND"

function 6Breset () {
echo 0 > $Reset/value
sleep 1
echo 1 > $Reset/value
}

function 6Berase () {
echo 1 > $Erase/value
6Breset
sleep 5
echo 0 > $Erase/value
}





if [ "$COMMAND" = "reset" ]
then
6Breset
fi

if [ "$COMMAND" = "erase" ]
then
6Berase
fi

if [ "$COMMAND" = "RTSlow" ]
then
echo 0 > $RTS/value
fi

if [ "$COMMAND" = "RTShigh" ]
then
echo 1 > $RTS/value
fi

