#!/bin/bash
#---------------Configuration-------------#
. ccommon.sh nofunc
LogToTerm=1
loglevel=info;

	

software(){
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
	echo "${NORM}"
	echo -e "${YELLOW}Firmware Version Information${NORM}"
	echo -e "- Overlay Partition:\t${CYAN}$currentV${NORM}"
	echo -e "- User Partition:\t${CYAN}$userV${NORM}"
	echo -e "- Upgrade Partition:\t${CYAN}$upgradeV${NORM}"
	echo -e "- Factory Partition:\t${CYAN}$factoryV${NORM}"
}

account(){
	echo -e "\n${YELLOW}Account Infomation${NORM}"
	echo -e "- Serial Number:\t${CYAN}$SN${NORM}"
	echo -e "- Pairing Code:\t\t${CYAN}$PAIRINGCODE${NORM}"
}
hardware(){
	LEDTYPE="RBG"
	if [[ $LEDCONFIG = "01" ]]; then
		LEDTYPE="RGB"
	fi
	echo -e "\n${YELLOW}Hardware Infomation${NORM}"
	echo -e "- Hardware Version:\t${CYAN}$HWV${NORM}"
	echo -e "- Ethernet Mac:\t\t${CYAN}$ETHERNETMAC${NORM}"
	echo -e "- LED Type installed:\t${CYAN}$LEDTYPE ($LEDCONFIG)${NORM}"
	curspeed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
  	maxspeed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)
  	minspeed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
  	echo -e "- CPU0 current speed:\t${CYAN}$curspeed${NORM}"
  	echo -e "- CPU0 min speed:\t${CYAN}$minspeed${NORM}"
  	echo -e "- CPU0 max speed:\t${CYAN}$maxspeed${NORM}"
  	curspeed=$(cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq)
  	maxspeed=$(cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq)
  	minspeed=$(cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq)
  	echo -e "- CPU1 current speed:\t${CYAN}$curspeed${NORM}"
  	echo -e "- CPU1 min speed:\t${CYAN}$minspeed${NORM}"
  	echo -e "- CPU1 max speed:\t${CYAN}$maxspeed${NORM}"
}

manufacturing(){
	echo -e "\n${YELLOW}Factory Manufacturing Infomation${NORM}"
	echo -e "- Build Date:\t\t${CYAN}$YEAR-$MONTH-$BATCH ${NORM}"
}


main(){
	software
	echo -e "\n${GREEN}scanning eeprom...\t${CYAN}5 seconds${NORM}"
	hardware
	logEEPROM "varibles"
	account
	manufacturing

}
main