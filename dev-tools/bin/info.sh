#!/bin/bash
#https://github.com/longsleep/build-pine64-image/blob/master/simpleimage/platform-scripts/pine64_health.sh
#---------------Configuration-------------#
source ccommon.sh nofunc
version="1.5"
LogToTerm=1
loglevel=info;


#run eetool
_ret(){
	eetool get "$1"
}

_placeTitle(){
	TITLE="$1"
	echo -e "\n${YELLOW}$TITLE${NORM}"
}
_placeLine(){
	SUBJECT="$1"
	BODY="$2"
	len="${#SUBJECT}"
	#echo "$len"
	echo -en "$SUBJECT"
	if [[ $len -lt 8 ]]; then
		echo -en "\t\t\t\t"
	 elif [[ $len -lt 16 ]]; then
	 	echo -en "\t\t\t"
	 elif [[ $len -lt 24 ]]; then
	 	echo -en "\t\t"
	 elif [[ $len -lt 32 ]]; then
	 	echo -en "\t"
	 else
	 	echo -en "";
	fi
	echo -e "${CYAN}$BODY${NORM}"
}

_placeHeader(){
	echo -e "\n\n${RED}$1 ${NORM}"
}

_div1000(){
	out=$(bc <<< "scale=1; $1 / 1000")
	if [[ "$out" = *".0" ]]; then
		out=$(bc <<< "scale=0; $1 / 1000")
	fi
		echo "$out"
}
_div1000b(){
	out=$(bc <<< "scale=0; $1 / 1000")
	if [[ "$out" = *".0" ]]; then
		out=$(bc <<< "scale=0; $1 / 1000")
	fi
		echo "$out"
}
_div1024(){
	out=$(bc <<< "scale=1; $1 / 1024")
	echo "$out"
}

	MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
	MEM=$(_div1000b "$MEM")
	USED=$(free -m | awk 'NR==2{printf $3}')
	UMP=$(bc <<< "scale=2; $USED*100/$MEM")
	AVAILABLE=$(free -m | awk 'NR==2{printf $7}')

system(){	
	let upSeconds=$(cat /proc/uptime | cut -d ' ' -f1 | cut -d '.' -f1);
	let secs=$((${upSeconds}%60))
	let mins=$((${upSeconds}/60%60))
	let hours=$((${upSeconds}/3600%24))
	let days=$((${upSeconds}/86400))
	if [[ "${days}" -ne "0" ]]; then
		UPTIME="${days}d ";
	fi
	
	UPTIME="$UPTIME${hours}h ${mins}m ${secs}s"
	USERS="$(who | cut -d ' ' -f1 | sort | uniq | wc -l) users"
	LOAD="$(cat /proc/loadavg)"
	MIN1="$(echo $LOAD | awk '{ print $1}')"
	MIN5="$(echo $LOAD | awk '{ print $2}')"
	MIN15="$(echo $LOAD | awk '{ print $3}')"
	TASKS="$(echo $LOAD | awk '{ print $4}')"
	IPADDRESS=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
	WDOGPID=$(/etc/init.d/deviceOS-watchdog status | awk '{print $3}' | sed 's/)//')
	if [[ "$WDOGPID" = 'running.' ]]; then
		WDOGPID="not enabled"
	else
		WDOGPID="Enabled (PID: $WDOGPID)"
	fi
	_placeTitle "System Infomation"
	_placeLine "  - Uptime:" "$UPTIME"
	_placeLine "  - Users:" "$USERS"
	_placeLine "  - System Memory Useage:" "$USED/$MEM MB (used/total) ($UMP%)"
	_placeLine "  - True Available Mem:" "$AVAILABLE MB"
	_placeLine "  - Load (1,5,15-min avg):" "$MIN1, $MIN5, $MIN15"
	_placeLine "  - Queued Tasks:" "$TASKS"
	_placeLine "  - IP Address:" "$IPADDRESS"
	_placeLine "  - Watdog:" "$WDOGPID"
}

firmware(){
	currentV=$(grep -ne 'version' /wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $8}')
	userV=$(grep -ne 'version' /mnt/.overlay/user/slash/wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $8}')
	upgradeV=$(grep -ne 'version' /mnt/.overlay/upgrade/wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $8}')
	factoryV=$(grep -ne 'version' /mnt/.overlay/factory/wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $8}')
	dd if=/dev/mmcblk0 of=/tmp/uboot.img seek=8 bs=1024 count=100 >> /dev/null 2>&1
	ubootV=$(grep -a "WigWag-U-boot-version_id" /tmp/uboot.img | tail -1 | awk '{print $2}')
	if [[ -e /mnt/.boot/version ]]; then
		source /mnt/.boot/version
		bootV=$bootversion 
	else
		bootV=0
	fi
	rm -rf /tmp/uboot.img
	currentV=${currentV%%,*}
	userV=${userV%%,*}
	upgradeV=${upgradeV%%,*}
	factoryV=${factoryV%%,*}
	if [[ "$userV" = "" ]]; then
		userV="  ^  "
	fi
	if [[ "$upgradeV" = "" ]]; then
		upgradeV="  ^  "
	fi
	if [[ "$factoryV" = "" ]]; then
		factoryV="  ^  "
	fi
	out=$(fdisk -l /dev/mmcblk0p1 | xargs | awk '{print $3}');
	Pschema="4Gb"
	if [[ $out -eq 50 ]]; then
		Pschema="8Gb"
	fi
	echo "${NORM}"
	_placeTitle "Firmware Version Information"
	_placeLine "  - Overlay Partition:" "$currentV"
	_placeLine "  - User Partition:" "$userV"
	_placeLine "  - Upgrade Partition:" "$upgradeV"
	_placeLine "  - Factory Partition:" "$factoryV"
	_placeLine "  - Partition Schema:" "$Pschema"
	_placeLine "  - Boot Version:" "$bootV"
	_placeLine "  - U-Boot Version:" "$ubootV"

}

account(){
	SN=$(_ret relayID)
	PAIRINGCODE=$(_ret pairingCode)
	CLOUDURL=$(_ret cloudURL)
	_placeTitle "Account Infomation"
	_placeLine "  - Serial Number:" "$SN"
	_placeLine "  - Pairing Code:" "$PAIRINGCODE"
	_placeLine "  - Cloud Server:" "$CLOUDURL"
}

hardware(){
	LEDTYPE="RBG"
	LEDCONFIG=$(_ret ledConfig)
	HWV=$(_ret hardwareVersion)
	ETHERNETMAC=$(eetool -t hex-colon get ethernetMAC)
	if [[ $LEDCONFIG = "01" ]]; then
		LEDTYPE="RGB"
	fi
	local CPUCOUNT=$(grep -c processor /proc/cpuinfo)
	local DIETEMP=$(cat /sys/devices/virtual/thermal/thermal_zone0/temp)
	DIETEMP=$(_div1000 $DIETEMP)" C"
	_placeTitle "Hardware Infomation"
	_placeLine "  - Hardware Version:" "$HWV"
	_placeLine "  - Ethernet Mac:" "$ETHERNETMAC"
	_placeLine "  - LED Type installed:" "$LEDTYPE ($LEDCONFIG)"
	_placeLine "  - Physical Memory:" "$MEM MB"
	_placeLine "  - SOC die tempurature:" "$DIETEMP"
	_placeLine "  - CPU Count:" "$CPUCOUNT"
	_placeLine "  - CPU Stats:" "Current\tMinimum\tMaximum  "
	for (( i = 0; i < $CPUCOUNT; i++ )); do
		curspeed=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq)
		maxspeed=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq)
		minspeed=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq)
		curspeed=$(_div1000 $curspeed)"Mhz"
		maxspeed=$(_div1000 $maxspeed)"Mhz"
		minspeed=$(_div1000 $minspeed)"Mhz"
	_placeLine "    - CPU$i:" "$curspeed\t$minspeed\t$maxspeed"
	done
}

manufacturing(){
	_placeTitle "Factory Manufacturing Infomation"
	_placeLine "  - Build Date:" "$YEAR-$MONTH-$BATCH"
}



# manufacturing
# #echo "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
# for (( x = 1; x < 42; x++ )); do
# 	txt=""
# 	for (( i = 1; i < $x; i++ )); do
# 		txt="$txt".
# 	done
# 	_placeLine "$txt"
# 	echo "${CYAN}-${NORM}"
# done
# exit


let PSSTOT=0;
_memperf(){
	name="$1"
	pgr="$2"
	pid=$(pgrep -f "$2")
	if [[ $pid != "" ]]; then
		Share=$(_div1024 $(echo 0 $(awk '/Shared/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		Priv=$(_div1024 $(echo 0 $(awk '/Private/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		Swap=$(_div1024 $(echo 0 $(awk '/Swap/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		Size=$(_div1024 $(echo 0 $(awk '/Size/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		Ref=$(_div1024 $(echo 0 $(awk '/Referenced/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		Pss=$(_div1024 $(echo 0 $(awk '/Pss/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		Rss=$(_div1024 $(echo 0 $(awk '/Rss/ {print "+", $2}' /proc/$pid/smaps) | bc) )
		PSSTOT=$(bc <<< "scale=1; $PSSTOT + $Pss")
		_placeLine "  - $name ($pid):" "$Pss\t$Rss\t$Share\t$Priv\t$Size\t$Ref"
	fi
}


performance(){
	_placeTitle "Key Process Performance Infomation"
	_placeLine "  Memory in Mb" "Pss\tRss\tShared\tPrivte\tVirtual\tReferenced"
	_memperf "devicedb" "devicedb"
	_memperf "djs devicejs.conf" "devicejs.conf"
	_memperf "djs relay.config" "node /wigwag/devicejs-core-modules/Runner/start.js"
	_memperf "devicejs-user" "=user"
	_memperf "devicejs-modbus" "=modbus"
	_memperf "devicejs-modules" "=all-modules"
	_memperf "support-node" "support/index"
	_memperf "relay-term" "relay-term/src"
	_memperf "Watchdog" "deviceOS"
	_placeLine "  Key Proccess/System Used:" "$PSSTOT/$USED MB"
}



Stats(){
	_placeHeader "Relay Information utility version $version"
}

_placeAbout(){
	echo -e "$1" "${CYAN}$2 ${NORM}"
}

about(){
	_placeHeader "About"
	_placeTitle "System Memory"
	_placeAbout "  Read about memory allocation:" "http://www.linuxatemyram.com/"
	_placeAbout "  - Physcial Memory:" "How much installed physical ram the system has"
	_placeAbout "  - Memory Useage:" "MemoryUsed/MemoryAvaiable (as a percentage)"
	_placeAbout "  - True Available Mem:" "How much mem can go to processes (minus cache)"
	_placeTitle "Process Memory"
	_placeAbout "  Read about process memory:" "https://goo.gl/wvUhBi"
	_placeAbout "  - Pss:" " Proportional Set Size, overall memory indicator (Rss adjusted for sharing)"
	_placeAbout "  - Rss:" " resident memory useage, all memory the process ueses (includes shared mem)"
	_placeAbout "  - Shared:" " memory that this process shares with other processes"
	_placeAbout "  - Privte:" " private memory used by this process, check for mem leaks here"
	_placeAbout "  - Virtual:" " practically useless, total virtual space for the process"
	_placeAbout "  - Referenced: " " ammount of memory current marked as referenced or accessed"
}

main(){
	Stats
	system
	firmware
	hardware
	account
	manufacturing
	performance
}
if [[ $1 = "" ]]; then
main
elif [[ $1 = "-h" || $1 = "--help" ]]; then
	about
else
	echo -e "Usege $0"
fi