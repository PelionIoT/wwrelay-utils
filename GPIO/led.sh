#!/bin/bash
echo 37 > /sys/class/gpio/export 2>&1 > /dev/null
echo 38 > /sys/class/gpio/export  2>&1 > /dev/null
echo out > /sys/class/gpio/gpio38/direction  2>&1 > /dev/null
echo out > /sys/class/gpio/gpio37/direction  2>&1 > /dev/null
SCLK=/sys/class/gpio/gpio38/value
SDATA=/sys/class/gpio/gpio37/value

#SCLK=/sys/class/gpio/gpio12_pb6/value
#SDATA=/sys/class/gpio/gpio11_pb5/value	


re='^[0-9]+$'


function dec2hex() {
  out=$(echo "obase=16;ibase=10; $1" | bc)
  echo "0x$out"
}

function dec2bin() {
  out=$(echo "obase=2;ibase=10; $1" | bc)
  echo "0x$out"
}


color() {
	red=$1
	blue=$3
	green=$2
#	echo "red: $red green $green blue $blue"
	for i in `seq 0 31`; do
		echo 1 > $SCLK
		echo 0 > $SCLK
	done

	for i in `seq 0 0`; do
		echo 1 > $SDATA
		echo 1 > $SCLK
		echo 0 > $SCLK
		Mask=16
		for j in `seq 0 4`; do
			maskfilter=$(( $Mask & $red ))
			if [[ $maskfilter -eq 0 ]]; then
				echo 0 > $SDATA
			else 
				echo 1 > $SDATA
			fi
			echo 1 > $SCLK
			echo 0 > $SCLK	
			let "Mask >>= 1"
		done
		Mask=16
		for j in `seq 0 4`; do
			maskfilter=$(( $Mask & $blue ))
			if [[ $maskfilter -eq 0 ]]; then
				echo 0 > $SDATA
			else 
				echo 1 > $SDATA
			fi
			echo 1 > $SCLK
			echo 0 > $SCLK	
			let "Mask >>= 1"
		done
		Mask=16
		for j in `seq 0 4`; do
			maskfilter=$(( $Mask & $green ))
			if [[ $maskfilter -eq 0 ]]; then
				echo 0 > $SDATA
			else 
				echo 1 > $SDATA
			fi
			echo 1 > $SCLK
			echo 0 > $SCLK	
			let "Mask >>= 1"
		done
	done
	echo 0 > $SDATA
	for j in [0-1]; do
		echo 1 > $SCLK
		echo 0 > $SCLK	
	done
}

if [[ "$#" -ne 3 ]]; then 
	echo -e "Useage:\t./led.sh R G B, where RGB is an integer 0-31 \n\twhere 0 = off, 31 = max bright\n\twhere R=Red G=Green B=Blue" 
else
color $1 $2 $3
fi



