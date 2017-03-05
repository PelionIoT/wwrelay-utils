#!/bin/bash
#---------------Configuration-------------#
. ccommon.sh nofunc
LogToTerm=1
loglevel=verbose;
#loglevel=debug;
thistarball="https://code.wigwag.com/ugs/ud.tar.gz"
manifestLocalhost="https://10.10.102.57:8080/builds/manifest.dat"
manifesturl="https://code.wigwag.com/ugs/manifest.dat"
upgrd="upgrade"
buildurl=""
setting_user_upgrade=0;
setting_user_force=0;
setting_user_wipe=0;

setting_boot_upgrade=0;
setting_boot_force=0;
setting_boot_wipe=0;

setting_userdata_upgrade=0;
setting_userdata_force=0;
setting_userdata_wipe=0;

setting_factory_upgrade=0;
setting_factory_force=0;
setting_factory_wipe=0;

setting_upgrade_force=0;
setting_upgrade_upgrade=1;
setting_upgrade_wipe=0;

purefactory=0;

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
    isTHEURLup=$(isURLUp "$manifestLocalhost")
    log "debug" "isURLUp($manifestLocalhost): '$isTHEURLup'"
    if [[ $isTHEURLup -eq 1 ]]; then
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
	log "silly" "processing line: $temp"
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

pdec(){
	local title="$1"
	local choice="$2"
	local flag="$3"
	varname="$4"
		clearpadding
		PS3="${YELLOW}$title: "
		echo -n "${NORM}"
		select yn in "Enable" "Disable"; do
			break;
		done
		if [[ "$yn" = "$choice" ]]; then
			eval ${varname}=1
			callstring="$callstring -$flag"
		fi
}


interactive(){
	callstring="upgrade "
	buildurl="";
	
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

	#decide to wipe the user or not (w)
	testray=("Keep" "Erase");
	clearpadding
	PS3="${YELLOW}User Partition: ";
	echo -n "${NORM}"
	select userChoice in "${testray[@]}"; do
		break;
	done
	if [[ "$userChoice" = "${testray[1]}" ]]; then
		setting_user_wipe=1
		callstring="$callstring -w"
	fi

	#decide to wipe the userdb (x)
	testray=("Keep" "Erase");
	PS3="${YELLOW}User Database: ";
	clearpadding
	echo -n "${NORM}"
	select userChoice in "${testray[@]}"; do
		break;
	done
	if [[ "$userChoice" = "${testray[1]}" ]]; then
		setting_userdata_upgrade=1
		callstring="$callstring -x"
	fi

#decide what to replace (G)
	if [[ $advanced -eq 1 ]]; then
		partitionDecision=("upgrade" "factory")
		clearpadding
		PS3="${YELLOW}Upgrade partition: ";
		echo -n "${NORM}"
		select upgrd in "${partitionDecision[@]}"; do
		      break;
		done
		if [[ "$upgrd" = "factory" ]]; then
			purefactory=1;
			callstring="$callstring -G"
		fi

#decide to erase the eeprom
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
		fi
		#decide to disable the automatic factory upgrade when newer version is avaiable
		pdec "factory partition automatic update when update is newer" 'Disable' "f" "setting_factory_update"
		pdec "factory partition forced update" "Enalbe" "F" "setting_factory_force"
		pdec "factory partition forced wipe" "Enable" "t" "setting_factory_wipe"

		pdec "upgrade partition automatic update when update is newer" 'Disable' "u" "setting_upgrade_update"
		pdec "upgrade partition forced update" "Enalbe" "U" "setting_upgrade_force"
		pdec "upgrade partition forced wipe" "Enable" "v" "setting_upgrade_wipe"

		pdec "user partition automatic update when update is newer" 'Enable' "s" "setting_user_partition_update"
		pdec "user partition forced update" "Enalbe" "S" "setting_user_partition_force"

		pdec "userdata partition automatic update when update is newer" 'Enable' "d" "setting_userdata_update"
		pdec "userdata partition forced update" "Enalbe" "D" "setting_userdata_force"

		pdec "boot partition automatic update when update is newer" 'Enable' "b" "setting_boot_update"
		pdec "boot partition forced update" "Enalbe" "B" "setting_boot_force"
		pdec "boot partition forced wipe" "Enable" "z" "setting_boot_wipe"
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

sedit(){
	tag="$1"
	data="$2"
	SedGeneric upgrade.sh \"0,/$tag.*/s//$tag=$data/\"
}

colorgrep(){
	grep --color -m1 $1 upgrade.sh
}

main(){
        log "debug" "entered main with $upgradeDIR and $wipeeeprom <-- wipe eeprom"
        if [[ "$wipeeeprom" != "" && "$wipeeeprom" = "ERASEIT" ]]; then
                /wigwag/wwrelay-utils/I2C/eetool.sh erase all
                log "info" "erased eeprom"               
        elif [[ "$wipeeeprom" != "" ]]; then
                        log "error" "Exiting now, incorrect wipe eeprom response provided: '$wipeeeprom'"
                        COMMON_MENU_HELP
        fi
        cd "$upgradeDIR"
        if [[ "$buildurl" != "" ]]; then
                downloadfile="$buildurl";
                log "debug" "setting download file to $downloadfile"
        else
                lha=$(localhostAvailable)
                log "debug" "upgrade type: $upgrd, localhostAvailable: $lha"
                if [[ "$upgrd" = "factory" ]]; then
                        setting_upgrade_upgrade=0;
                        setting_upgrade_force=0;
                        setting_upgrade_wipe=1;
                        if [[ "$lha" -eq 1 ]]; then
                                downloadfile="${LFACTORYURL[$mybuild]}"
                        else
                                downloadfile="${FACTORYURL[$mybuild]}"
                        fi
                else
                        if [[ "$lha" -eq 1 ]]; then
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
		#b,B,z
		sedit "UPGRADETHEBOOT" $setting_boot_upgrade
		sedit "FORCEUPGRADETHEBOOT" $setting_boot_force
		sedit "WIPETHEBOOT" $setting_boot_wipe

		#d,D,x
		sedit "UPGRADETHEUSERDATA" $setting_userdata_upgrade
		sedit "FORCEUPGRADETHEUSERDATA" $setting_userdata_force
		sedit "WIPETHEUSERDATA" $setting_userdata_wipe

		#f,F,t
		sedit "UPGRADETHEFACTORY" $setting_factory_upgrade
		sedit "FORCEUPGRADETHEFACTORY" $setting_factory_force
		sedit "WIPETHEFACTORY" $setting_factory_wipe			

		#s,S,w
		sedit "UPGRADETHEUSER_PARTITION" $setting_user_upgrade
		sedit "FORCEUPGRADETHEUSER_PARTITION" $setting_user_force
		sedit "WIPETHEUSER_PARTITION" $setting_user_wipe

		#u,U,v 
		sedit "UPGRADETHEUPGRADE" $setting_upgrade_upgrade
		sedit "FORCEUPGRADETHEUPGRADE" $setting_upgrade_force
		sedit "WIPETHEUPGRADE" $setting_upgrade_wipe
		log "info" "configuration results"
		colorgrep "UPGRADETHEBOOT"
		colorgrep "FORCEUPGRADETHEBOOT"
		colorgrep "WIPETHEBOOT"
		colorgrep "UPGRADETHEUSERDATA"
		colorgrep "FORCEUPGRADETHEUSERDATA"
		colorgrep "WIPETHEUSERDATA"
		colorgrep "UPGRADETHEFACTORY"
		colorgrep "FORCEUPGRADETHEFACTORY"
		colorgrep "WIPETHEFACTORY"
		colorgrep "UPGRADETHEUSER_PARTITION"
		colorgrep "FORCEUPGRADETHEUSER_PARTITION"
		colorgrep "WIPETHEUSER_PARTITION"
		colorgrep "UPGRADETHEUPGRADE"
		colorgrep "FORCEUPGRADETHEUPGRADE"
		colorgrep "WIPETHEUPGRADE"
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
	[b]="boot parittion:\tENABLE upgrade if newer version avaiable"
	[B]="boot partition:\tforce upgrade regardless"
	[d]="userdata partition:\ENABLE upgrade if newer version avialable"
	[D]="userdata partition:\tforce upgrade regardless"
	[ee]="erase eeprom and ssl keys, must enter it this way: -e <ERASEIT>"
	[f]="factory partition:\tDISABLE upgrade if newer version avaiable"
	[F]="factory partition:\tforce upgrade regardless"
	[G]="factory partition:\t this build, with a true factory version only.  (internal development only)"
	[h]="help"
	[i]="interactive (will ignore all other flags)"
	[mm]="url to manifest.dat -m <url>, defaults to: https://code.wigwag.com/ugs/"
	[r]="reboot after install is complete"
	[s]="user paritition:\tENABLE upgrade if newer version avaiable"
	[S]="user paritition:\tforce upgrade regardless"
	[t]="wipe the factory partition"
	[u]="upgrade paritition:\tDISABLE upgrade if newer version avaiable"
	[U]="upgrade paritition:\tforce upgrade regardless"
	[v]="wipe the upgrade partition"
	[w]="wipe the user partition"
	[x]="wipe the userdata partition"
	[z]="wipe the boot partition"
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
			b)	setting_boot_upgrade=1; ;;
			B)	setting_boot_force=1; ;;
			d)  setting_userdata_upgrade=1; ;;
			D)  setting_userdata_force=1; ;;
			e)	wipeeeprom=$OPTARG; ;;
			f)	setting_factory_update=1; ;;
			F)  setting_factory_force=1; ;;
			G)	purefactory=1;
			h) 	COMMON_MENU_HELP; ;;
			i) 	interactive; exit;;
			m)	manifesturl=$OPTARG; ;;
			r)	rebootit=1; ;;
			s) 	setting_user_upgrade=1;
			S) 	setting_user_force=1;
			t)  setting_factory_wipe=1; ;;
			u)	setting_upgrade_upgrade; exit;;
			U)  setting_upgrade_force=1; ;;
			v)  setting_upgrade_wipe=1; ;;
			w)	setting_user_wipe=1; ;; 
			x) 	setting_userdata_wipe=1; ;;
			z) 	setting_boot_wipe=1; ;;
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

lha=$(localhostAvailable)

if [[ "$lha" = "1" ]]; then
		manifesturl="$manifestLocalhost"
fi

if [[ "$#" -lt 1 ]]; then
	interactive; exit;
else
argprocessor "$@"
fi


