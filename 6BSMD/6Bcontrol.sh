#!/bin/bash
COMMAND=$1




# Use like this:
# 
# THISDIR=$(getScriptDir "${BASH_SOURCE[0]}")
function getScriptDir() {
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
local __SOURCE=$1
while [ -h "$__SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  local __MYDIR="$( cd -P "$( dirname "$__SOURCE" )" && pwd )"
  local __SOURCE="$(readlink "$__SOURCE")"
  [[ $__SOURCE != /* ]] && local __SOURCE="$__MYDIR/$__SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
local __MYDIR="$( cd -P "$( dirname "$__SOURCE" )" && pwd )"
echo "$__MYDIR"
}

THISDIR=$(getScriptDir "${BASH_SOURCE[0]}")
. $THISDIR/../common/common.sh

# bring GPIO functions
. $THISDIR/../GPIO/setup-gpio.sh funcsonly



AVAILABLE="reset erase RTSlow RTShigh program"
fail=0
[[ $AVAILABLE =~ $COMMAND ]] || fail=1
if [ -z $1 ]
then
    fail=1
fi

if [ "$COMMAND" = "program" ]
then
    if [ -z $2 ]
    then
	fail=1
    fi
fi

if [ "$fail" -eq 1 ]
then
    echo "Usage: ./6Bcontrol.sh [reset|erase|RTSlow|RTShigh|program [file]"]
    exit
fi


burner=$THISDIR/mc1322x-load
t=/dev/ttyS1
f=$THISDIR/flasher_redbee-econotag.bin
b=115200
burnercmd="$burner -t $t -f $f -b $b -s $2"

Reset=/sys/class/gpio/gpio5_pb8
RTS=/sys/class/gpio/gpio7_ph8
Erase=/sys/class/gpio/gpio6_pb13


function 6Breset () {
echo -e "Reseting 6Bee\n"
echo 0 > $Reset/value
sleep 1
echo 1 > $Reset/value
}

function 6Berase () {
echo -e "Erasing 6Bee\n"
echo 1 > $Erase/value
6Breset
sleep 5
echo 0 > $Erase/value
}

function toggleRTS() {
if [ "$1" = "0" ]
then
    echo -e "RTS set low\n"
    echo 0 > $RTS/value
else
    echo -e "RTS set high\n"
    echo 1 > $RTS/value
fi
}

burnpid=""
function burn() {
echo -e "burning with $burnercmd\n"
$burnercmd &
burnpid=$!
}

function 6Bprogram () {
echo -e "Programming the 6Bee\n"
6Berase
toggleRTS 0
burn
6Breset
sleep 1
wait $burnpid
toggleRTS 1
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
    toggleRTS 0
fi

if [ "$COMMAND" = "RTShigh" ]
then
    toggleRTS 1
fi
if [ "$COMMAND" = "program" ]
then
    6Bprogram
fi