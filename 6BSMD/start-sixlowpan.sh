#!/bin/bash


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

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [start|stop]"
    
fi


GPIO_PATH=/sys/class/gpio
TR=$GPIO_PATH/gpio2_pc21


TUNSLIP_SERIAL=/dev/ttyS1
TUNSLIP=$THISDIR/tunslip6
TUNSLIP_LOG=$THISDIR/../../log/tunslip6.log

IP6_ROUTE="aaaa::1/64"

# supports 1-5 or nothing for basic
TUNSLIP_LOG_LEVEL="5"

if [ "$1" == "start" ]; then
    killall tunslip6
    eval $COLOR_BOLD
    echo "Starting SixLowPAN services."
    eval $COLOR_NORMAL
    if [ ! -e $TR ]; then
	eval $COLOR_BOLD
	echo "GPIO not ready - setting up."
	eval $COLOR_NORMAL
	modprobe_gpiodriver
	exportGPIOs
	setdirection    
    fi

    if [ ! -e $TR ]; then
	eval $COLOR_RED
	echo "GPIO not setup! Failing."
	eval $COLOR_NORMAL    
    fi
    
    if [ -e $TUNSLIP_LOG ]; then
	# some trivial log rotation
	mv $TUNSLIP_LOG $TUNSLIP_LOG.1
    fi
    echo "CMD: $TUNSLIP -v$TUNSLIP_LOG_LEVEL -s $TUNSLIP_SERIAL $IP6_ROUTE > $TUNSLIP_LOG 2>&1 &"
    $TUNSLIP -v$TUNSLIP_LOG_LEVEL -s $TUNSLIP_SERIAL $IP6_ROUTE > $TUNSLIP_LOG 2>&1 &
    sleep 3
    echo "Resetting 6BSMD"
    $THISDIR/6Bcontrol.sh reset
fi

if [ "$1" == "stop" ]; then
    echo "Killing tunslip6 process"
    killall tunslip6
fi

