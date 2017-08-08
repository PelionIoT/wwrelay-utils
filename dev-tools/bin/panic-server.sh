#!/bin/bash
lc=0;
fire_every=1000;

announce(){
	msg="$1"
	local slstart='/usr/local/bin/slack chat send --channel "#sqabot" --author "Panic Watcher" --author-icon "http://piq.codeus.net/static/media/userpics/piq_8583_400x400.png" '"\"$msg\""
	#echo "$slstart"
	eval "$slstart" &> /dev/null
}

check() {
	incount="$1"
	#echo "my incount = $incount"
	olc=$lc;
	lc=$(( $incount / $fire_every ));
	#echo "my lc=$lc, my olc=$olc"
	if [[ $lc != $olc ]]; then
		#echo announce "Watchdog Panics: $1"
		digitcount=$(( ${#incount} -1 ))
		nines=""
		for (( iq = 0; iq < $digitcount; iq++ )); do
			if [[ $iq -eq 2 ]]; then
				nines="$nines".
			fi
			nines="$nines""9"
		done
		nines="$nines""% reliability"
		#echo announce "Watchdog Panics w/o devicejs: $incount ($nines) *note, in reality we have not failed yet! :)"
		announce "Watchdog Panics w/o devicejs: $incount ($nines) *note, in reality we have not failed yet! :)"
	fi
}

ncloop(){
	while true; do
		catch=$(netcat -l -p 2233)
		#echo "I caought $catch"
		check "$catch"
	done
}

qloop(){
	for (( i = 0; i < 2000; i++ )); do
		check "$i"
	done
}


ncloop