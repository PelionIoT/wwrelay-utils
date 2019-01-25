#!/bin/bash
eeprog /dev/i2c-1 0x55 -f -r 0:10 2> /dev/null
if [[ $? -eq 0 ]]; then
	hardwareversion="relay"
else
	hardwareversion="RP200"
fi

if [[ $hardwareversion = "relay" ]]; then
	echo 37 > /sys/class/gpio/export 2>&1 > /dev/null
	echo 38 > /sys/class/gpio/export  2>&1 > /dev/null
	echo out > /sys/class/gpio/gpio38/direction  2>&1 > /dev/null
	echo out > /sys/class/gpio/gpio37/direction  2>&1 > /dev/null
	SCLK=/sys/class/gpio/gpio38/value
	SDATA=/sys/class/gpio/gpio37/value
else
	KEEPALIVE="/var/deviceOSkeepalive"
fi

#SCLK=/sys/class/gpio/gpio12_pb6/value
#SDATA=/sys/class/gpio/gpio11_pb5/value

RGB=01
RBG=02

re='^[0-9]+$'

function dec2hex() {
  out=$(echo "obase=16;ibase=10; $1" | bc)
  echo "0x$out"
}

function dec2bin() {
  out=$(echo "obase=2;ibase=10; $1" | bc)
  echo "0x$out"
}


#LED config grab functions
function grabOne(){
    a=$(i2cget -y 1 0x50 $1 b) 
    echo $a
}
function hex2dec() {
    printf "%d\n" $1
}
function hex2ascii() {
    a=$(echo "$1" | sed s/0/\\\\/1)
    echo -en "$a"
    #echo $b
}
#output can be "ascii decimal hex hex-stripped"
#$1 range start
#$2 range end
#$3 output: [ascii decimal hex hex-striped]
#$4 delimeter: append to the front of the return value
function grabRange() {
    start=$1
    end=$2
    output=$3
    delimeter=$4
    RET=""
    for ((i=$start; i<=$end; i=i+1)); do
        h=$(printf "%#x\n" $i)
        hex=$(grabOne $h)
        if [[ $output == "decimal" ]]; then
            var=$(hex2dec $hex)
        elif [[ $output == "ascii" ]]; then
            var=$(hex2ascii $hex)
        elif [[ $output == "hex-stripped" ]]; then
            var=`expr "$hex" : '^0x\([0-9a-zA-Z]*\)'`        
        else
            var=$hex
        fi
        if [[ $RET == "" ]]; then
             RET="$var"
        else
            RET+=$delimeter"$var"
        fi
    done
    echo $RET
}


color() {
	if [[ $hardwareversion = "relay" ]]; then
		LEDCONFIG=$(grabRange 96 97 "ascii" "")
		echo "Read EEPROM, Got LEDConfig " $LEDCONFIG
		if [[ $LEDCONFIG == $RGB ]]; then 
			red=$1
			green=$2
			blue=$3
		elif [[ $LEDCONFIG == $RBG ]]; then
			red=$1
			blue=$2
			green=$3
		else
			red=$1
			green=$2
			blue=$3
		fi

		echo "red: $red green $green blue $blue"
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
	else
		echo -e led $1 $2 $3\" | socat unix-sendto:$KEEPALIVE STDIO
	fi
}

if [[ "$#" -ne 3 ]]; then 
	echo -e "Useage:\t./led.sh R G B, where RGB is an integer 0-31 \n\twhere 0 = off, 31 = max bright\n\twhere R=Red G=Green B=Blue" 
else
	color $1 $2 $3
fi
