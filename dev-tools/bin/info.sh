#!/bin/bash
#---------------Configuration-------------#
. ccommon.sh nofunc
LogToTerm=1
loglevel=info;

	

version(){
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
	echo -e "Build Version Info"
	echo -e "- Overlay Partition:\t${CYAN}$currentV${NORM}"
	echo -e "- User Partition:\t${CYAN}$userV${NORM}"
	echo -e "- Upgrade Partition:\t${CYAN}$upgradeV${NORM}"
	echo -e "- Factory Partition:\t${CYAN}$factoryV${NORM}\n"
}

main(){
	version
}
main