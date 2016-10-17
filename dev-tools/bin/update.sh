#!/bin/bash
#---------------Configuration-------------#
. ccommon.sh nofunc
LogToTerm=1
loglevel=debug;

manifestLocalhost="https://10.10.102.57:8080/builds/manifest.dat"
manifesturl="https://code.wigwag.com/ugs/manifest.dat"
upgrd="upgrade"
buildurl=""
wipeuser=0
wipeeeprom=0
declare -A DESCRIPTION
declare -A DATE
declare -A IMGTYPE
declare -A RELEASETYPE
declare -A FACTORYURL
declare -A UPGRADEURL
declare -A LFACTORYURL
declare -A LUPGRADEURL
RELEASEDB=()
DEVB=()
ALLDB=()
thisRelease="1.0.20"
# upgradeDIR="/tmp/upgrades"
# rm -rf $upgradeDIR
# mkdir -p $upgradeDIR
upgradeDIR="/upgrades"

localhostAvailable(){
	if [[ $(isURLUp "$manifestLocalhost") -eq 1 ]]; then
		echo 1
	else
		echo 0
	fi
}

readmanifest(){
	src="$1"
	#shellcheck disable=SC2086
	log debug "your url is $src"
	if [[ "$(isURL "$src")" -eq 1 ]]; then
		#curl -o /tmp/.mft -k "$src"
		readarray -t bigR /tmp/<<<"$(curl -s -k "$src" | tac )"	
		log "debug" "done reading"
	elif [[ $(fileExists "$1") -eq 1 ]]; then
		readarray -t bigR <<<"$(tail -r "$src")"
	else
		log error "did not receive manifest directive"
		exit 1
	fi
	out="$(echo ${bigR[@]})"
	#echo "my  out is $out"
	if [[ $(sContains "$out" "MANIFESTVERSION4STABLETHISTEXTMUSTBEPRESENT") -ne 1 ]]; then
		log error "the url manifest does not exist at $src or is missing the tag MANIFESTVERSION4STABLETHISTEXTMUSTBEPRESENT"
		exit 1
	fi
	log "debug" "entering the lines"
	temp=0;
	echo -n "Crunching."
	for line in "${bigR[@]}"; do  
	temp=$((temp+1))
	log "debug" "at temp $temp"
	echo -n "."
	#echo -e "theline\t --> $line "
		IFS="|" read -r -a lineR <<< "$line"
		#shellcheck disable=SC2086
	#	build="$(stripWhiteSpace "both" "${lineR[0]}")"
		#shellcheck disable=SC2086
	#	tag="$(stripWhiteSpace "both" "${lineR[1]}")"
		#shellcheck disable=SC2086
		#echo "${lineR[2]}"
	#	message="$(stripWhiteSpace "both" "${lineR[2]}")"
		#echo "'$build' '$tag' '$message'"
		build="${lineR[0]}"
		tag="${lineR[1]}"
		message="${lineR[2]}"
		case "$tag" in
			"DESCRIPTION") 
				#shellcheck disable=SC2034
				#DESCRIPTION["$build"]="$message";
				;;
			"DATE") 
				#shellcheck disable=SC2034
				#DATE["$build"]="$message";
				;;
			"IMGTYPE") 
				#shellcheck disable=SC2034
				#IMGTYPE["$build"]="$message";
				;;
			"RELEASETYPE") 
				#shellcheck disable=SC2034
				#RELEASETYPE["$build"]="$message"; 
				;;
			"FACTORYURL") 
				#shellcheck disable=SC2034
				FACTORYURL["$build"]="$message";
				;;
			"UPGRADEURL") 
				#shellcheck disable=SC2034
				UPGRADEURL["$build"]="$message"; 
				;;
			"LFACTORYURL") 
				#shellcheck disable=SC2034
				LFACTORYURL["$build"]="$message";
				;;
			"LUPGRADEURL") 
				#shellcheck disable=SC2034
				LUPGRADEURL["$build"]="$message"; 
				;;
		esac
		case "$message" in
			"RELEASED")
				RELEASEDB+=("$build");
				ALLDB+=("$build");
				;;
			"DEVELOPER")
				DEVB+=("$build");
				ALLDB+=("$build");
				;;
		esac
	done
}

printRayTest(){
	printAssociativeArray DESCRIPTION
	printAssociativeArray DATE
	printAssociativeArray IMGTYPE
	printAssociativeArray RELEASETYPE
}

interactive(){
	callstring="$0"
	buildurl="";

	#	Grab the manifest URL
	clearpadding
	PS3="${YELLOW}Use default mainfest ${CYAN}$manifesturl${YELLOW}: "
	echo -n "${NORM}"
	select yn in "Yes" "No"; do
		break;
	done
	if [[ "$yn" = "No" ]]; then
		echo "prefered manifesturl url: "
		read -r manifesturl
		callstring="$callstring -m $manifesturl"
	fi
	
	readmanifest "$manifesturl"
	

	

	#	List the builds
	clearpadding
	currentV=$(grep -ne 'version' /wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $6}')
	userV=$(grep -ne 'version' /mnt/.overlay/user/slash/wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $6}')
	upgradeV=$(grep -ne 'version' /mnt/.overlay/upgrade/wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $6}')
	factoryV=$(grep -ne 'version' /mnt/.overlay/factory/wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $6}')
	currentV=${currentV%%,*}
	userV=${userV%%,*}
	upgradeV=${upgradeV%%,*}
	factoryV=${factoryV%%,*}
	if [[ "$userV" = "" ]]; then
		userV="N/A"
	fi
	if [[ "$upgradeV" = "" ]]; then
		upgradeV="N/A"
	fi
	if [[ "$factoryV" = "" ]]; then
		factoryV="N/A"
	fi
	echo "${NORM}"
	echo -e "Your User Partition reports version:\t${CYAN}$userV${NORM}"
	echo -e "Your Upgrade Partition reports version:\t${CYAN}$upgradeV${NORM}"
	echo -e "Your Factory Partition reports version:\t${CYAN}$factoryV${NORM}\n"
	PS3="${YELLOW}Change your current running version ${CYAN}$currentV${YELLOW} to: ";
	echo -n "${NORM}"
	select mybuild in "${ALLDB[@]}";
	   do break;
	done




# #	Grab the manifest URL
# 	clearpadding
# 	RELEASEDRepo="Released Build"
# 	devRepo="Developer Build"
# 	Repos=("$devRepo" "$RELEASEDRepo")
# 	PS3="${YELLOW}Upgrade to the latest: ";
# 	echo -n "${NORM}"
# 	select UpgradeTo in "${Repos[@]}";
# 	      do break;
# 	done
# if [[ $UpgradeTo = "$RELEASEDRepo" ]]; then
# 	    select mybuild in "${RELEASEDB[@]}";
# 	      do break;
# 	    done
# 	elif [[ $UpgradeTo = "$devRepo" ]]; then
# 	    select mybuild in "${DEVB[@]}";
# 	      do break;
# 	    done
# 	fi


	#decide what to replace
	partitionDecision=("upgrade" "factory")
	clearpadding
	PS3="${YELLOW}Upgrade partition: ";
	echo -n "${NORM}"
	select upgrd in "${partitionDecision[@]}";
	      do break;
	done
	if [[ "$upgrd" = "factory" ]]; then
		callstring="$callstring -r"
	fi



	#decide to wipe the user or not
	clearpadding
	PS3="${YELLOW}Preserve all user settings (No = Nuke the db and user parition): ";
	echo -n "${NORM}"
	select yn in "Yes" "No"; do
		break;
	done
	if [[ "$yn" = "No" ]]; then
		wipeuser=1
		callstring="$callstring -w"
	fi


	#decide to clear the factory settings
	clearpadding
	PS3="${YELLOW}Preserve the factory EEPROM memory, Pairing Code, and SSL keys: "
	echo -n "${NORM}"
	select yn in "Yes" "No"; do
		break;
	done
	if [[ "$yn" = "No" ]]; then
		clearpadding
		UIwarning
		echo "${YELLOW}You have chosen to destroy your factory keys that enable the relay to work with the cloud."
		echo "${CYAN}Confirm that this is your desire by typing: \"ERASETHEEEPROMANDSSLKEYS\" in the next line:"
		echo -n "${NORM}"
		read -r response
		if [[ "$response" = "ERASETHEEEPROMANDSSLKEYS" ]]; then
			wipeeeprom=1
			callstring="$callstring -f ERASETHEEEPROMANDSSLKEYS"
		fi
	fi
	echo -n "${NORM}"
	clearpadding
	callstring="$callstring $mybuild"
	log "info" "Your useage this time: ${CYAN}$callstring${NORM}"
	main
}

main(){
	log "debug" "entered main with $upgradeDIR and $buildurl"
	cd "$upgradeDIR" ||  exit
	if [[ "$buildurl" != "" ]]; then
		downloadfile="$buildurl";
	else
		if [[ "$upgrd" = "factory" ]]; then
			if [[ "$(localhostAvailable)" -eq 1 ]]; then
				downloadfile="${LFACTORYURL[$mybuild]}"
			else
				downloadfile="${FACTORYURL[$mybuild]}"
			fi
		else
			if [[ "$(localhostAvailable)" -eq 1 ]]; then
				downloadfile="${LUPGRADEURL[$mybuild]}"
			else
				downloadfile="${UPGRADEURL[$mybuild]}"
			fi
			
		fi
	fi
		log "info" "downloading ${CYAN}$downloadfile${NORM} for installation"
		curl -o f.tar.gz -k "$downloadfile"
		tar -xzf f.tar.gz
		rm -rf f.tar.gz
		rm -rf install.sh
		rm -rf post-install.sh
		if [[ $wipeuser -eq 1 ]]; then
			mv wipeuserupgrade.sh upgrade.sh
		else
			rm wipeuserupgrade.sh
		fi
		#echo  "#!/bin/bash" > postUpgrade.sh
		#shellcheck disable=SC2129
		# echo  "replace=\$(grep -ne 'version' /wigwag/etc/versions.json | xargs | awk -F ' ' '{print \$6}')" >>	 postUpgrade.sh
		# echo  "replace=\${replace%%,*}" >> postUpgrade.sh
		# echo  "sed -i \"s/\$replace/$mybuild/\" /wigwag/etc/versions.json" >> postUpgrade.sh
		echo  "your build will be installed after a reboot.  To abort, delete /upgrades/ contents."	
}


declare -A hp=(
	[description]="Updates a relay with a different firmware version (up and down)"
	[useage]="-options <[buildNo|buildURL]>"
	[ee]="erase eeprom and ssl keys, must enter it this way: -f <ERASETHEEEPROMANDSSLKEYS>"
	[h]="help"
	[i]="interactive (will ignore all other flags)"
	[mm]="url to manifest.dat -m <url>, defaults to: https://code.wigwag.com/ugs/"
	[f]="refactory, write to the factory partition instead of the upgrade"
	[w]="wipe user"
	[e1]="\t${BOLD}${UND}Update a Relay factory partition to Build 1.1.1 ${NORM}\n\t\t$0 -u factory  1.1.1 ${NORM}\n"
	[e2]="\t${BOLD}${UND}Start interactive mode ${NORM}\n\t\t$0 -i ${NORM}\n"
	[e3]="\t${BOLD}${UND}Update an Upgrade patitition to Build 1.0.23 and wipe user ${NORM}\n\t\t$0 -w 1.0.23 ${NORM}\n"
	[e4]="\t${BOLD}${UND}Update an Upgrade patitition using an URL ${NORM}\n\t\t$0 http://code.wigwag.com/path/to/image.tar.gz ${NORM}\n"
)


argprocessor(){
	switch_conditions=$(COMMON_MENU_SWITCH_GRAB)
	while getopts "$switch_conditions" flag; do
		case $flag in
			e)	wipeeeprom=1; ;;
			h) 	COMMON_MENU_HELP; ;;
			i) 	interactive; exit;;
			m)	manifesturl=$OPTARG; ;;
			f)	upgrd="factory"; ;;
			w)	wipeuser=1; ;;
			\?) echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed.";COMMON_MENU_HELP;exit; ;;
		esac
	done
	shift $(( OPTIND - 1 ));
	#echo "whats left: $@"
	if [[ $(isURL "$1") -eq 1 ]]; then
		buildurl="$1"
		mybuild=${buildurl##*/}
		mybuild=${mybuild%%-*}
	else
		mybuild="$1"
	fi
	readmanifest "$manifesturl"
	main
} 

if [[ "$#" -lt 1 ]]; then
	interactive; exit;
else
argprocessor "$@"
fi


