#!/bin/bash

declare -a PGdummies=(PG0 PG1 PG2 PG3 PG4 PG4 PG5 PG8 PG9 PG10 PG11)
declare -a PGuart=(PG6 PG7)

function set_port {
port=$1
mux=$2
pull=$3
drive=$4
out=$5
pio -m $port\<$mux\>\<$pull\>\<$drive\>\<$out\> 
}

function looper_dummies {
 for id in "${PGdummies[@]}"
do
   set_port $id $1 $2 $3 $4
done
}

function looper_pgs {
 for ig in "${PGuart[@]}"
do
   set_port $ig $1 $2 $3 $4
done
}


function convert_PG {
	conversion=$1
	case $conversion in
		"uart") echo "setting uart"
		looper_dummies 0 0 0 0
		looper_pgs 4 1 0 1
		;;
		"gpio") echo "gpio"
		looper_dummies 1 1 1 1
		looper_pgs 1 1 1 1
		;;
		"rapid") echo "rapid"
		for ((i=1;i<=100;i++));
do
		looper_dummies 1 1 1 1
		looper_pgs 1 1 1 1
		looper_pgs 2 0 0 0
		looper_pgs 3 0 0 0
		looper_pgs 4 0 0 0
		looper_pgs 5 0 0 0
		looper_pgs 6 0 0 0
		looper_pgs 7 0 0 0
		looper_pgs 1 1 1 1
		looper_pgs 2 0 0 1
		looper_pgs 3 0 0 1
		looper_pgs 4 0 0 1
		looper_pgs 5 0 0 1
		looper_pgs 6 0 0 1
		looper_pgs 7 0 0 1
		looper_dummies 0 0 0 0
		looper_pgs 4 1 0 1
		looper_pgs 4 0 0 0
		looper_pgs 4 0 1 0	
		looper_pgs 4 1 2 1	
		looper_pgs 4 1 3 1
		looper_pgs 4 0 0 0
			
		echo -e "$i"
done

		;;
	esac	
}


if [ $# -ne 1 ] || [ "$1" != "gpio" ] && [ "$1" != "uart" ] && [ "$1" != "rapid" ]; then 
	echo -e "USEAGE ./shock uart|gpio|rapid"
	exit
else
	convert_PG $1
fi