#!/bin/bash
#---------------Configuration-------------#
. ccommon.sh nofunc
LogToTerm=1
loglevel=info;
thistarball="https://code.wigwag.com/ugs/ud.tar.gz"
manifestLocalhost="https://10.10.102.57:8080/builds/manifest.dat"
manifesturl="https://code.wigwag.com/ugs/manifest.dat"
upgrd="upgrade"
buildurl=""
wipeuser=0
wipedb=0
FUF=0;
FUU=0;
WU=0;
WF=0;
UU=1;
wipeeeprom=""
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
	echo -e "\n"
}

printRayTest(){
	printAssociativeArray DESCRIPTION
	printAssociativeArray DATE
	printAssociativeArray IMGTYPE
	printAssociativeArray RELEASETYPE
}


upgradethis(){
	pushd . >> /dev/null
	cd /wigwag/wwrelay-utils/dev-tools/bin/
	curl -o ud.tar.gz -k "$thistarball"
	tar -xf ud.tar.gz
	rm -rf ud.tar.gz
	popd >> /dev/null


}

interactive(){
	callstring="upgrade "
	buildurl="";

	#	Grab the manifest URL
	# clearpadding
	# PS3="${YELLOW}Use default mainfest ${CYAN}$manifesturl${YELLOW}: "
	# echo -n "${NORM}"
	# select yn in "Yes" "No"; do
	# 	break;
	# done
	# if [[ "$yn" = "No" ]]; then
	# 	echo "prefered manifesturl url: "
	# 	read -r manifesturl
	# 	callstring="$callstring -m $manifesturl"
	# fi
	
	# readmanifest "$manifesturl"
	
if [[ $advanced -eq 1 ]]; then
	#decide what to replace
	manifestChoices=("https://code.wigwag.com/ugs/manifest.dat" "Other")
	clearpadding
	PS3="${YELLOW}Manifset choice: ";
	echo -n "${NORM}"
	select manifsetd in "${manifestChoices[@]}"; do
	      break;
	done
	echo -n "${NORM}"
	if [[ "$manifsetd" != "${manifestChoices[0]}" ]]; then
		echo "prefered manifesturl url: "
		read -r manifesturl
		callstring="$callstring -m $manifesturl"
	fi

fi
	readmanifest "$manifesturl"



	#	List the builds
	clearpadding
	currentV=$(grep -ne 'version' /wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $8}')
	userV=$(grep -ne 'version' /mnt/.overlay/user/slash/wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $8}')
	upgradeV=$(grep -ne 'version' /mnt/.overlay/upgrade/wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $8}')
	factoryV=$(grep -ne 'version' /mnt/.overlay/factory/wigwag/etc/versions.json 2> /dev/null | xargs | awk -F ' ' '{print $8}')
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
	select upgrd in "${partitionDecision[@]}"; do
	      break;
	done
	if [[ "$upgrd" = "factory" ]]; then
		wupgradepart=1;
		callstring="$callstring -f"
	fi



	#decide to wipe the user or not
	testray=("Keep" "Erase");
	clearpadding
	PS3="${YELLOW}User Partition: ";
	echo -n "${NORM}"
	select userChoice in "${testray[@]}"; do
		break;
	done
	if [[ "$userChoice" = "${testray[1]}" ]]; then
		wipeuser=1
		callstring="$callstring -w"
	fi

	#decide to wipe the userdb
	testray=("Keep" "Erase");
	PS3="${YELLOW}User Database: ";
	clearpadding
	echo -n "${NORM}"
	select userChoice in "${testray[@]}"; do
		break;
	done
	if [[ "$userChoice" = "${testray[1]}" ]]; then
		wipedb=1
		callstring="$callstring -d"
	fi



	#decide to clear the factory settings
	testray=("Keep" "Erase");
	clearpadding
	PS3="${YELLOW}Factory EEPROM and WigWag Cloud SSL access keys: "
	echo -n "${NORM}"
	select userChoice in "${testray[@]}"; do
		break;
	done
	if [[ "$userChoice" = "${testray[1]}" ]]; then
		clearpadding
		UIwarning
		echo "${YELLOW}You have chosen to destroy your ability to connect to the WigWag cloud services."
		echo "${CYAN}Confirm that this is your desire by typing: \"ERASEIT\" in the next line:"
		echo -n "${NORM}"
		read -r response
		if [[ "$response" = "ERASEIT" ]]; then
			wipeeeprom="ERASEIT"
			callstring="$callstring -e ERASEIT"
		else 
			log "error" "Exiting now, incorrect wipe eeprom response provided: '$response'"
			exit
		fi
	fi
	echo -n "${NORM}"



	if [[ $advanced -eq 1 ]]; then
		clearpadding
		PS3="${YELLOW}Factory Partition update forced: "
		echo -n "${NORM}"
		select yn in "No Force" "Force"; do
			break;
		done
		if [[ "$yn" = "Force" ]]; then
			FUF=1
			callstring="$callstring -F"
		fi

		clearpadding
		PS3="${YELLOW}Upgrade Partition update forced: "
		echo -n "${NORM}"
		select yn in "No Force" "Force"; do
			break;
		done
		if [[ "$yn" = "Force" ]]; then
			FUU=1
			callstring="$callstring -U"
		fi

		clearpadding
		PS3="${YELLOW}Wipe the factory partition: "
		echo -n "${NORM}"
		select yn in "No wipe" "wipe"; do
			break;
		done
		if [[ "$yn" = "wipe" ]]; then
			WF=1
			callstring="$callstring -g"
		fi

		clearpadding
		PS3="${YELLOW}Wipe the upgrade partition: "
		echo -n "${NORM}"
		select yn in "No wipe" "wipe"; do
			break;
		done
		if [[ "$yn" = "wipe" ]]; then
			WU=1
			callstring="$callstring -v"
		fi

	fi

	#decide to reboot
	clearpadding
	PS3="${YELLOW}Reboot on completion?: ";
	echo -n "${NORM}"
	select yn in "Yes" "No"; do
		break;
	done
	if [[ "$yn" = "Yes" ]]; then
		rebootit=1
		callstring="$callstring -r"
	fi
	echo -n "${NORM}"





	clearpadding
	callstring="$callstring $mybuild"
	log "info" "Commandline Command: ${CYAN}$callstring${NORM}"
	main
}

main(){
	log "debug" "entered main with $upgradeDIR and $wipeeeprom <-- wipe eeprom"
	if [[ "$wipeeeprom" != "" && "$wipeeeprom" = "ERASEIT" ]]; then
		erasePage
		log "info" "erased eeprom"
		uninstallCloudKeys
	elif [[ "$wipeeeprom" != "" ]]; then
			log "error" "Exiting now, incorrect wipe eeprom response provided: '$wipeeeprom'"
			COMMON_MENU_HELP
	fi
	cd "$upgradeDIR"
	if [[ "$buildurl" != "" ]]; then
		downloadfile="$buildurl";
	else
		if [[ "$upgrd" = "factory" ]]; then
			UU=0;
			WU=1;
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
		log "info" "downloading: ${CYAN}$downloadfile${NORM} for installation"
		curl -o f.tar.gz -k "$downloadfile"
		log "info" "${YELLOW}unzipping the upgrade.  30 sec... ${NORM}"
		tar -xzf f.tar.gz
		rm -rf f.tar.gz
		rm -rf install.sh
		rm -rf post-install.sh


		SedGeneric upgrade.sh \"0,/WIPETHEUSER_PARTITION.*/s//WIPETHEUSER_PARTITION=$wipeuser/\"
		SedGeneric upgrade.sh \"0,/WIPETHEUSERDB.*/s//WIPETHEUSERDB=$wipedb/\"
		SedGeneric upgrade.sh \"0,/WIPETHEUPGRADE.*/s//WIPETHEUPGRADE=$WU/\"
		SedGeneric upgrade.sh \"0,/UPGRADETHEUPGRADE.*/s//UPGRADETHEUPGRADE=$UU/\"
		SedGeneric upgrade.sh \"0,/UPGRADETHEFACTORY.*/s//UPGRADETHEFACTORY=1/\"
		SedGeneric upgrade.sh \"0,/FORCEUPGRADETHEFACTORY.*/s//FORCEUPGRADETHEFACTORY=$FUF/\"
		SedGeneric upgrade.sh \"0,/FORCEUPGRADETHEUPGRADE.*/s//FORCEUPGRADETHEUPGRADE=$FUU/\"
		SedGeneric upgrade.sh \"0,/WIPETHEFACTORY.*/s//WIPETHEFACTORY=$WF/\"

		log "info" "configuration results"
		grep --color -m1 "UPGRADETHEFACTORY" upgrade.sh
		grep --color -m1 "FORCEUPGRADETHEFACTORY" upgrade.sh
		grep --color -m1 "WIPETHEFACTORY" upgrade.sh

		grep --color -m1 "UPGRADETHEUPGRADE" upgrade.sh
		grep --color -m1 "FORCEUPGRADETHEUPGRADE" upgrade.sh
		grep --color -m1 "WIPETHEUPGRADE" upgrade.sh

		grep --color -m1 "WIPETHEUSER_PARTITION" upgrade.sh
		grep --color -m1 "WIPETHEUSERDB" upgrade.sh


		#echo  "#!/bin/bash" > postUpgrade.sh
		#shellcheck disable=SC2129
		# echo  "replace=\$(grep -ne 'version' /wigwag/etc/versions.json | xargs | awk -F ' ' '{print \$6}')" >>	 postUpgrade.sh
		# echo  "replace=\${replace%%,*}" >> postUpgrade.sh
		# echo  "sed -i \"s/\$replace/$mybuild/\" /wigwag/etc/versions.json" >> postUpgrade.sh
		echo  "your build will be installed after a reboot.  To abort, delete /upgrades/ contents."	
		if [[ "$rebootit" -eq 1 ]]; then
			echo -en "rebooting in 5..."
			sleep 1
			echo -en "4..."
			sleep 1
			echo -en "3..."
			sleep 1
			echo -en "2..."
			sleep 1
			echo -en "1..."
			sleep 1
			echo -en "reboot!\n"
			init 6
		fi
}



declare -A hp=(
	[description]="Updates a relay with a different firmware version (up and down)"
	[useage]="-options <[buildNo|buildURL]>"
	[a]="advanced interactive mode"
	[d]="Erase User database.  Independant from -w"
	[ee]="erase eeprom and ssl keys, must enter it this way: -e <ERASEIT>"
	[f]="(re)factory. Write this build to the factory partition.  Upgrade will automatically be wiped."
	[F]="force upgrade the factory"
	[g]="wipe the factory"
	[h]="help"
	[i]="interactive (will ignore all other flags)"
	[mm]="url to manifest.dat -m <url>, defaults to: https://code.wigwag.com/ugs/"
	[r]="reboot after install is complete"
	[u]="fetch the latest version of this program and update it"
	[U]="force upgrade the upgrade"
	[v]="wipe the upgrade"
	[w]="erase User paritition.  Independant from -e"
	[e1]="\t${BOLD}${UND}Update a Relay factory partition to Build 1.1.1 ${NORM}\n\t\t$0 -u factory  1.1.1 ${NORM}\n"
	[e2]="\t${BOLD}${UND}Start interactive mode ${NORM}\n\t\t$0 -i ${NORM}\n"
	[e3]="\t${BOLD}${UND}Update an Upgrade patitition to Build 1.0.23 and wipe user ${NORM}\n\t\t$0 -w 1.0.23 ${NORM}\n"
	[e4]="\t${BOLD}${UND}Update an Upgrade patitition using an URL ${NORM}\n\t\t$0 http://code.wigwag.com/path/to/image.tar.gz ${NORM}\n"
)


argprocessor(){
	switch_conditions=$(COMMON_MENU_SWITCH_GRAB)
	while getopts "$switch_conditions" flag; do
		case $flag in
			a)  advanced=1; interactive; exit; ;;
			d)  wipedb=1; ;;
			e)	wipeeeprom=$OPTARG; ;;
			f)	upgrd="factory"; wupgradepart=1; ;;
			F)  FUF=1; ;;
			g)  WF=1; ;;
			h) 	COMMON_MENU_HELP; ;;
			i) 	interactive; exit;;
			m)	manifesturl=$OPTARG; ;;
			r)	rebootit=1; ;;
			u)	upgradethis; exit;;
			U)  FUU=1; ;;
			v)  WU=1; ;;
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


