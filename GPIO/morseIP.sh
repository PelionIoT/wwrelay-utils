#!/bin/bash
#
#
red="10 0 0"
green="0 10 0"
blue="0 0 10"
pink="0 10 10"

currentip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
IFS=. read ip1 ip2 ip3 ip4 <<< "$currentip"

tenWPM=.045
fifteenWPM=.01

len=.01
len=$tenWPM

len3=$(echo "$len * 3" | bc)
len7=$(echo "$len * 7" | bc)

echo "len $len $len3 $len7"



ledstr="15 15 15"
ledoff="0 0 0"

dahs(){
	echo "dahs start"
	led $ledstr
	sleep $len3
	led $ledoff
	sleep $len
	echo "dahs stop"
}

dit(){
	echo "dit start"
	led $ledstr
	sleep $len
	led $ledoff
	sleep $len
	echo "dit done"
}
newletter(){
	sleep $len3
}

newword(){
	sleep $len7
}



doletter(){
	letter="$1"
	case "$letter" in 
		a)  dit; dahs;  ;;
		#
		b)  dahs; dit; dit; dit;  ;;
		#
		c)  dahs; dit; dahs; dit;  ;;
		#
		d)  dahs; dit; dit;  ;;
		#
		e)  dit;  ;;
		#
		f)  dit; dit; dahs; dit;  ;;
		#
		g)  dahs; dahs; dit;  ;;
		#
		h)  dit; dit; dit; dit;  ;; 
		#
		i)  dit; dit;  ;;
		#
		j)  dit; dahs; dahs; dahs;  ;;
		#
		k)  dahs; dit; dahs;  ;;
		#
		l)  dit; dahs; dit; dit;  ;;
		#
		m)  dahs; dahs;  ;;
		#
		n)  dahs; dit;  ;;
		#
		o)  dahs; dahs; dahs;  ;;
		#
		p)  dit; dahs; dahs; dit;  ;;
		#
		q)  dahs; dahs; dit; dahs;  ;;
		#
		r)  dit; dahs; dit;  ;;
		#
		s)  dit; dit; dit;  ;;
		#
		t)  dahs;  ;;
		#
		u)  dit; dit; dahs;  ;;
		#
		v)  dit; dit; dit; dahs;  ;;
		#
		w)  dit; dahs; dahs;  ;;
		#
		x)  dahs; dit; dit; dahs;  ;;
		#
		y)  dahs; dit; dahs; dahs;  ;;
		#
		z)  dahs; dahs; dit; dit;  ;;
		#
		1)  dit; dahs; dahs; dahs; dahs;  ;;
		#
		2)  dit; dit; dahs; dahs; dahs;  ;;
		#
		3)  dit; dit; dit; dahs; dahs;  ;;
		#
		4)  dit; dit; dit; dit; dahs;  ;;
		#
		5)  dit; dit; dit; dit; dit;  ;;
		#
		6)  dahs; dit; dit; dit; dit;  ;;
		#
		7)  dahs; dahs; dit; dit; dit;  ;;
		#
		8)  dahs; dahs; dahs; dit; dit;  ;;
		#
		9)  dahs; dahs; dahs; dahs; dit;  ;;
		#
		0)  dahs; dahs; dahs; dahs; dahs;  ;;
		#
		.) dit; dahs; dit; dahs; dit; dahs; ;;
esac
}

doword(){
	word="$1"
	chrlen=${#word}
	for (( i = 0; i < $chrlen; i++ )); do
		l=$(($i - 1 ))
		#echo "$i) [word:$i:1] = ${word:$i:1}"
		doletter $(echo ${word:$i:1})
		newletter
	done
}

moresetest(){
	doletter ""

}

morse(){
	led 12 3 0
	sleep 3
	led 0 0 0
	sleep 3

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

paris(){
	timeing="$1"
	for (( tt = 0; tt < $timeing; tt++ )); do
		doword "paris"
		newword
		#echo $i
	done

}
#use time.  This should take 1 real minute to send.  If it does, your timing is set at 10 WPM
#http://www.nu-ware.com/NuCode%20Help/index.html?morse_code_structure_and_timing_.htm
#paris 10


#doword "$currentip"



while [ 1 ]; do
	doword $currentip 
	newword
done
