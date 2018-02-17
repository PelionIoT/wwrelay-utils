#!/bin/bash
let PSSTOT=0;

_memperf(){
	pup="90min"
	pid="$1"
	if [[ $pid != "" ]]; then
		et=$(ps -o etime= -p "$pid");
		if [[ "$et" = *"-"* ]]; then 
			pupd=$(echo $et | awk -F '-' '{print $1}')
		else
			pupd=0
		fi
		puph=$(echo $et | awk -F ':' '{print $1}');
		pupm=$(echo $et | awk -F ':' '{print $2}');
		pups=$(echo $et | awk -F ':' '{print $3}');
		upSeconds=$(ps -o etimes= -p "$pid");
		let secs=$((${upSeconds}%60))
		let mins=$((${upSeconds}/60%60))
		let hours=$((${upSeconds}/3600%24))
		let days=$((${upSeconds}/86400))
		UPTIME=""
		if [[ "${days}" -ne "0" ]]; then
			UPTIME="${days}d ";
		fi
		UPTIME="$UPTIME${hours}h ${mins}m ${secs}s"
		Share=$(_div1024 $(echo 0 $(awk '/Shared/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		Priv=$(_div1024 $(echo 0 $(awk '/Private/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		Swap=$(_div1024 $(echo 0 $(awk '/Swap/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		Size=$(_div1024 $(echo 0 $(awk '/Size/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		Ref=$(_div1024 $(echo 0 $(awk '/Referenced/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		Pss=$(_div1024 $(echo 0 $(awk '/Pss/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		Rss=$(_div1024 $(echo 0 $(awk '/Rss/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		PSSTOT=$(bc <<< "scale=1; $PSSTOT + $Pss")
		#_placeLine "  - $name ($pid):" "$Pss\t$Rss\t$Share\t$Priv\t$Size\t$Ref"
		echo -e "$pid:\t$UPTIME\t$Pss\t$Rss\t$Share\t$Size"
	fi
}
pid=$1
if [[ $pid = "" ]]; then
	echo "USEAGE meminfo <pid>"
else
	_memperf "$pid"
fi