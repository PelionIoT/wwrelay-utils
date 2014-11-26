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

# bring GPIO functions and the important varriables
. $THISDIR/../GPIO/setup-gpio.sh funcsonly



AVAILABLE="reset erase ramburn RTSlow RTShigh RTSstatus RESETlow RESEThigh RESETstatus ERASEstatus program debug"
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
    echo "Usage: ./6Bcontrol.sh [reset | erase | RTSlow | RTShigh | RTSstatus | RESETsatus | ERASEstatus | program [file]"]
    exit
fi


burner=$THISDIR/mc1322x-load
burner=$THISDIR/mctest
t=$SBMC_TTY
#t=/dev/ttyUSB0
#t=/dev/ttyS2
#t=/dev/ttyS0
#t=/dev/ttyUSB1
f=$THISDIR/flasher_redbee-econotag.bin
b=115200
#burnercmd="$burner -t $t -f $f -b $b -s $2"
burnercmd="$burner -v -t $t -f $f -s $2 -u 115200 -e"
ramburncmd="$burner -v -t $t -f $2 -u 115200 -e"

function setReset() {
    if [ "$1" = "0" ]
    then
        echo -e "setting Reset Pin low\n"
        echo 0 > $SBMC_RESET/value
    else
        echo -e "setting Reset Pin high\n"
        echo 1 > $SBMC_RESET/value
    fi
}

function 6Breset () {
    echo -e "Reseting 6Bee\n"
    if [ -z "$1" ]
    then
        sleeptime=1
    else
        sleeptime=$1
    fi
    setReset 0
    sleep $sleeptime
    setReset 1
}

function 6Berase () {
echo -e "Erasing 6Bee\n"
echo 1 > $SBMC_ERASE/value
6Breset
sleep 3
echo 0 > $SBMC_ERASE/value
}

function setRTS() {
if [ "$1" = "0" ]
then
    echo -e "setting RTS low\n"
    echo 0 > $SBMC_RTS/value
else
    echo -e "setting RTS high\n"
    echo 1 > $SBMC_RTS/value
fi
}

function getRTS() {
    val=$(cat $SBMC_RTS/value)
    echo "RTS is set to $val"
}

function getRESET() {
    val=$(cat $SBMC_RESET/value)
    echo "RESET is set to $val"
}

function getERASE() {
    val=$(cat $SBMC_ERASE/value)
    echo "ERASE is set to $val (1=ready to erase upon reset)"
}

burnpid=""
function burn() {
echo -e "burning with $burnercmd\n"
$1 &
burnpid=$!
}

function 6Bprogram () {
    echo -e "Programming the 6Bee\n"
    6Berase
    setRTS 0
    burn "$burnercmd"
    6Breset
    sleep 1
    wait $burnpid
    setRTS 1
}

function ramburn () {
    echo -e "Ramburn the 6Bee\n"
    6Berase
    setRTS 0
    burn "$ramburncmd"
    sleep 1
    wait $burnpid
    setRTS 1
}

function main () {
    echo "Command Received: $COMMAND"
    case "$COMMAND" in
        "reset") 6Breset
            ;;
        "ramburn") ramburn
            ;;

        "erase") 6Berase
            ;;
        "RTSlow") setRTS 0
            ;;
        "RTShigh") setRTS 1
            ;;
        "RESETlow") setReset 0
            ;;
        "RESEThigh") setReset 1
            ;;
        "program") 6Bprogram
            ;;
        "debug") if [ "$2" = "resetloop" ]
            then
                for i in  $(seq 1 10)
                    do
                        echo "$i) Reset"
                        6Breset 5
                    done
            fi
            ;;
        "RTSstatus") getRTS
            ;;
        "RESETstatus") getRESET
            ;;
        "ERASEstatus") getERASE
            ;;
        esac
}

main
























