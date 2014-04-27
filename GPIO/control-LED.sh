#!/bin/bash
Front_Color=$1
Top_Color=$2

Mpath=/sys/class/gpio
TR=$Mpath/gpio2_pc21
TG=$Mpath/gpio3_pc20
TB=$Mpath/gpio4_pc19
FR=$Mpath/gpio8_pb4
FG=$Mpath/gpio9_pb2
FB=$Mpath/gpio10_pi12

COLORS="red green blue cyan magenta yellow white off black"
errrormsg="you must enter two colors.  One color for the Front LED, and One for the Top LED.\nExample [./control-LED red blue]\nValid colors: $COLORS"



if [ -z $1 ]
then
    echo -e $errrormsg;
    exit;
fi

if [ -z $2 ]
then
    echo -e $errrormsg;
    exit;
fi



fail=0
[[ $COLORS =~ $Front_Color ]] || fail=1

if [ "$fail" -eq 1 ]
then
    echo "[$Front_Color] not a valid color.  Use one of the following: [$COLORS]"
    exit
fi


fail=0
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
type=$4
if [ "$type" = "front" ]
then
    echo $r > $FR/value
    echo $g > $FG/value
    echo $b > $FB/value
else
    echo $r > $TR/value
    echo $g > $TG/value
    echo $b > $TB/value
fi
}


for i in front top
do
    if [ "$i" = "front" ]
    then
	Color=$Front_Color
    else
	Color=$Top_Color
    fi
    case "$Color" in
	'red')
	    setcolor 1 0 0 $i
	    ;;
	'green')
	    setcolor 0 1 0 $i
	    ;;
	'blue')
	    setcolor 0 0 1 $i
	    ;;
	'yellow')
	    setcolor 1 1 0 $i
	    ;;
	'magenta')
	    setcolor 1 0 1 $i
	    ;;
	'cyan')
	    setcolor 0 1 1 $i
	    ;;
	'white')
	    setcolor 1 1 1 $i
	    ;;
	'black')
	    setcolor 0 0 0 $i
	    ;;
	'off')
	    setcolor 0 0 0 $i
	    ;;
    esac
done




