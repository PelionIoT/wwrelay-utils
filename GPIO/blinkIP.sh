#!/bin/bash
#
#
red="10 0 0"
green="0 10 0"
blue="0 0 10"
pink="0 10 10"

currentip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
IFS=. read ip1 ip2 ip3 ip4 <<< "$currentip"



function blink(){
	led 12 3 0
sleep 2
led 0 0 0
sleep 2
first=0;
x=$2
i=0
b=0;
while [ $i -lt ${#x} ]; do 
sleep 2
	s=${x:$i:1}; 
	size=${#x}  
		if [[ s -eq 0 ]]; then
			led 10 0 0
					sleep 1
					led 0 0 0
		else
					for (( b = 0; b < s; b++ )); do
						led 10 10 10
						sleep .2
						led 0 0 0
						sleep .2
					done
		fi


	i=$((i+1));
done
sleep 3

}


while [ 1 ]; do
blink "hi" $ip4
done
