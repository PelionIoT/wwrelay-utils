#!/bin/bash
#---------------Configuration-------------#
. ccommon.sh nofunc
version="1.5"
LogToTerm=1
loglevel=info;
tab1="\t"
tab2="\t\t"
tab3="\t\t\t"

#run eetool
ret(){
	/wigwag/wwrelay-utils/I2C/eetool.sh get "$1"
}

firmware(){
	currentV=$(grep -ne 'version' /wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $8}')
	userV=$(grep -ne 'version' /mnt/.overlay/user/slash/wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $8}')
	upgradeV=$(grep -ne 'version' /mnt/.overlay/upgrade/wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $8}')
	factoryV=$(grep -ne 'version' /mnt/.overlay/factory/wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $8}')
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
	echo -e "${YELLOW}Firmware Version Information${NORM}"
	echo -e "  - Overlay Partition:$tab2${CYAN}$currentV${NORM}"
	echo -e "  - User Partition:$tab2${CYAN}$userV${NORM}"
	echo -e "  - Upgrade Partition:$tab2${CYAN}$upgradeV${NORM}"
	echo -e "  - Factory Partition:$tab2${CYAN}$factoryV${NORM}"
	echo -e "  - Partition Schema:$tab2${CYAN}$Pschema${NORM}"
}

account(){
	SN=$(ret relayID)
	PAIRINGCODE=$(ret pairingCode)
	CLOUDURL=$(ret cloudURL)
	echo -e "\n${YELLOW}Account Infomation${NORM}"
	echo -e "  - Serial Number:$tab2${CYAN}$SN${NORM}"
	echo -e "  - Pairing Code:$tab2${CYAN}$PAIRINGCODE${NORM}"
	echo -e "  - Cloud Server:$tab2${CYAN}$CLOUDURL${NORM}"
}
hardware(){
	LEDTYPE="RBG"
	LEDCONFIG=$(ret ledConfig)
	HWV=$(ret hardwareVersion)
	ETHERNETMAC=$(/wigwag/wwrelay-utils/I2C/eetool.sh -t hex-colon get ethernetMAC)
	if [[ $LEDCONFIG = "01" ]]; then
		LEDTYPE="RGB"
	fi
	echo -e "\n${YELLOW}Hardware Infomation${NORM}"
	echo -e "  - Hardware Version:$tab2${CYAN}$HWV${NORM}"
	echo -e "  - Ethernet Mac:$tab2${CYAN}$ETHERNETMAC${NORM}"
	echo -e "  - LED Type installed:$tab2${CYAN}$LEDTYPE ($LEDCONFIG)${NORM}"
	curspeed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
  	maxspeed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)
  	minspeed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
  	echo -e "  - CPU0 speed (cur/min/max):$tab1${CYAN}$curspeed/$minspeed/$maxspeed${NORM}"
  	curspeed=$(cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq)
  	maxspeed=$(cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq)
  	minspeed=$(cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq)
  	echo -e "  - CPU1 speed (cur/min/max):$tab1${CYAN}$curspeed/$minspeed/$maxspeed${NORM}"
}

manufacturing(){
	echo -e "\n${YELLOW}Factory Manufacturing Infomation${NORM}"
	echo -e "  - Build Date:$tab3${CYAN}$YEAR-$MONTH-$BATCH ${NORM}"
}

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
	echo -e "\n${YELLOW}System Infomation${NORM}"
	echo -e "  - Uptime:$tab3${CYAN}$UPTIME${NORM}"
	echo -e "  - Users:$tab3${CYAN}$USERS${NORM}"
	echo -e "  - Load (1,5,15-min avg):$tab1${CYAN}$MIN1, $MIN5, $MIN15${NORM}"
	echo -e "  - Queued Tasks:$tab2${CYAN}$TASKS${NORM}"
	echo -e "  - IP Address:$tab3${CYAN}$IPADDRESS${NORM}"
}

header(){
	echo -e "\n${RED}Relay Information utility version $version ${NORM}"
}
	


main(){
	header
	system
	firmware
	hardware
	account
	manufacturing

}
main