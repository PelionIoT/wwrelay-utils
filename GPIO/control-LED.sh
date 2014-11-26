#!/bin/bash
Relay_LED_CONFIG=1 #1 = just top led, 2= just front led, 3=both
COLORS="red green blue cyan magenta yellow white off black nochange"
MODES="heartbeat mmc0 none timer"
errormsg1="Enter one color for the Top LED.\nEnter the mode for Top LED.\nExmaple: ./control-LED red heartbeat\nValid colors: $COLORS\nValid modes: $MODES"
errormsg2="you must enter two colors.  One color for the Front LED, and One for the Top LED.\nExample [./control-LED red blue]\nValid colors: $COLORS"

if [ "$Relay_LED_CONFIG" = 1 ]
then
	Top_Color=$1
	Top_Mode=$2
	[[ $MODES =~ $Top_Mode ]] || Top_Mode="none"
	Front_Color="nochange"
	Front_mode="nochange"
	if [ -z $1 ]
	then
    	echo -e $errormsg1;
    	exit;
	fi
else
	#future, figure out what to do with a two LED system here.
	Top_Color=$1		
	Top_Mode=$2
	Front_Color=$3
	Front_Mode=$4
fi


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

# bring GPIO functions most importantly the array
. $THISDIR/../GPIO/setup-gpio.sh funcsonly


fail=0
#make sure the Front Color is valid
[[ $COLORS =~ $Front_Color ]] || fail=1

if [ "$fail" -eq 1 ]
then
    echo "[$Front_Color] not a valid color.  Use one of the following: [$COLORS]"
    exit
fi


fail=0
#make sure the top color is valid
[[ $COLORS =~ $Top_Color ]] || fail=1

if [ "$fail" -eq 1 ]
then
    echo "[$Top_Color] not a valid color.  Use one of the following: [$COLORS]"
    exit
fi


function setcolor(){
	r=$1
	g=$2
	b=$3
	rm=$4
	gm=$5
	bm=$6
	type=$7
	if [ "$type" = "front" ]
	then
	    echo $r > $FrontRed/value
	    echo $g > $FrontGreen/value
	    echo $b > $FrontBlue/value
	else
	    echo $r 	> $TopRed/brightness
	    echo $rm 	> $TopRed/trigger
	    echo $g 	> $TopGreen/brightness
	    echo $gm	> $TopGreen/trigger
	    echo $b 	> $TopBlue/brightness
		echo $bm	> $TopBlue/trigger
	fi
}


for i in front top
do
    if [ "$i" = "front" ]
    then
	Color=$Front_Color
    else
		Color=$Top_Color
		m=$Top_Mode
    fi
    case "$Color" in
	'red')
	    setcolor 1 0 0 $m "none" "none" $i
	    ;;
	'green')
	    setcolor 0 1 0 "none" $m "none" $i
	    ;;
	'blue')
	    setcolor 0 0 1 "none" "none" $m $i
	    ;;
	'yellow')
	    setcolor 1 1 0 $m $m "none" $i
	    ;;
	'magenta')
	    setcolor 1 0 1 $m "none" $m $i
	    ;;
	'cyan')
	    setcolor 0 1 1 "none" $m $m $i
	    ;;
	'white')
	    setcolor 1 1 1 $m $m $m $i
	    ;;
	'black')
	    setcolor 0 0 0 "none" "none" "none" $i
	    ;;
	'off')
	    setcolor 0 0 0 $m $m $m $i
	    ;;
	'nochange')
	;;
    esac
done




