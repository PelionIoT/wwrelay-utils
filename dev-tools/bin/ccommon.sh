
#/	Desc:	does nothing.  Used when including the common script
#/	Expl:	source common.sh nofunc
nofunc(){
	:
} #end_nofunc\n

#/	Desc:	common bash logger
#/	global:	LogToTerm 	[0|*1] uses the terminal number instead of echo to post messages.  this gets around degubbing functions that return data via echo
#/	global:	LogToSerial [*0|1] logs to both kmesg and ttyS0, good for relay debugging
#/	global: Logtoecho 	[*0|1] logs to stdout.  disabled by default
#/	global: LogToFile 	<file> logs to a file
#/ 	global:	loglevel 	suppresses output for anything below the level spefied.  Levels are: ["none", "error", "warn", "info", "verbose", "debug", "silly","func"],
#/	$1:		message level within these options: ["none", "error", "warn", "info", "verbose", "debug", "silly","func"],
#/	$2:		"the message"
#/	$3:		<ignore> special for a depricated function function call
#/	Out:	debug info on your screen
#/	Expl:	log "debug" "oh snarks, i got a problem"
	THISTERM=$(tty)
	LogToTerm=1
	LogToSerial=0
	LogToecho=0
	LogToFile=""
	loglevel=func;
  	NORM="$(tput sgr0)"
  	BOLD="$(tput bold)"
  	REV="$(tput smso)"
  	UND="$(tput smul)"
  	BLACK="$(tput setaf 0)"
  	RED="$(tput setaf 1)"
  	GREEN="$(tput setaf 2)"
  	YELLOW="$(tput setaf 3)"
  	BLUE="$(tput setaf 4)"
  	MAGENTA="$(tput setaf 5)"
  	CYAN="$(tput setaf 6)"
  	WHITE="$(tput setaf 7)"
  	ERROR="${REV}Error:${NORM}"
log(){
	level=$1
	message=$2
	lineinfo=$3
	devK=/dev/kmesg
	devS0=/dev/ttyS0
	#echo -e "LogToEcho=$LogToEcho\nLogToTerm=$LogToTerm\nLogToSerial=$LogToSerial\nLogtoFile=$LogToFile"
	if [[ "$THISTERM" = "not a tty" ]]; then
		LogToTerm=0;
	fi
	colorRay=(none error warn info verbose debug silly func);
	for i in "${!colorRay[@]}"; do
		if [[ "${colorRay[$i]}" = "${loglevel}" ]]; then
			loglevelid=${i};
		fi
	done
	if [[ "$LogToecho" -eq 1 ]]; then
		case $level in
			"none") ;;
			"error") 		if [[ $loglevelid -ge 1 ]]; then echo -e "${RED}error:${NORM}\t$message"; fi; ;;
			"warn")  		if [[ $loglevelid -ge 2 ]]; then echo -e "${YELLOW}warn:${NORM}\t$message"; fi ;;
			"info")  		if [[ $loglevelid -ge 3 ]]; then echo -e "${WHITE}info:${NORM}\t$message"; fi ;;
			"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo -e "${CYAN}verbose:${NORM}\t$message"; fi ;;
			"debug")  		if [[ $loglevelid -ge 5 ]]; then echo -e "${MAGENTA}debug [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message"; fi ;;
			"silly")  		if [[ $loglevelid -ge 6 ]]; then echo -e "${GREEN}silly [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message"; fi ;;	
			"function")		if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message"; fi ;;	
			"function2")	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func2 $lineinfo:${NORM}\t$message"; fi ;;	
			esac
	fi
	if [[ "$LogToTerm" -eq 1 ]]; then
		case $level in
			"none") ;;
			"error")		if [[ $loglevelid -ge 1 ]]; then echo -e "${RED}error:${NORM}\t$message" > "$THISTERM"; fi; ;;
			"warn")  		if [[ $loglevelid -ge 2 ]]; then echo -e "${YELLOW}warn:${NORM}\t$message" > "$THISTERM"; fi ;;
			"info")  		if [[ $loglevelid -ge 3 ]]; then echo -e "${WHITE}info:${NORM}\t$message" > "$THISTERM"; fi ;;
			"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo -e "${CYAN}verbose:${NORM}\t$message" > "$THISTERM"; fi ;;
			"debug")  		if [[ $loglevelid -ge 5 ]]; then echo -e "${MAGENTA}debug [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$THISTERM"; fi ;;
			"silly")  		if [[ $loglevelid -ge 6 ]]; then echo -e "${GREEN}silly [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$THISTERM"; fi ;;	
			"function")  	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$THISTERM"; fi ;;	
			"function2") 	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func2 $lineinfo:${NORM}\t$message" > "$THISTERM"; fi ;;	
		esac
	fi
	if [[ "$LogToSerial" -eq 1 ]]; then
		case $level in
			"none") ;;
			"error")		if [[ $loglevelid -ge 1 ]]; then echo -e "${RED}error:${NORM}\t$message" > "$devK"; fi; ;;
			"warn")  		if [[ $loglevelid -ge 2 ]]; then echo -e "${YELLOW}warn:${NORM}\t$message" > "$devK"; fi ;;
			"info")  		if [[ $loglevelid -ge 3 ]]; then echo -e "${WHITE}info:${NORM}\t$message" > "$devK"; fi ;;
			"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo -e "${CYAN}verbose:${NORM}\t$message" > "$devK"; fi ;;
			"debug")  		if [[ $loglevelid -ge 5 ]]; then echo -e "${MAGENTA}debug [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$devK"; fi ;;
			"silly")  		if [[ $loglevelid -ge 6 ]]; then echo -e "${GREEN}silly [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$devK"; fi ;;	
			"function")  	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$devK"; fi ;;	
			"function2") 	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func2 $lineinfo:${NORM}\t$message" > "$devK"; fi ;;	
		esac
		case $level in
			"none") ;;
			"error")		if [[ $loglevelid -ge 1 ]]; then echo -e "${RED}error:${NORM}\t$message" > "$devS0"; fi; ;;
			"warn")  		if [[ $loglevelid -ge 2 ]]; then echo -e "${YELLOW}warn:${NORM}\t$message" > "$devS0"; fi ;;
			"info")  		if [[ $loglevelid -ge 3 ]]; then echo -e "${WHITE}info:${NORM}\t$message" > "$devS0"; fi ;;
			"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo -e "${CYAN}verbose:${NORM}\t$message" > "$devS0"; fi ;;
			"debug")  		if [[ $loglevelid -ge 5 ]]; then echo -e "${MAGENTA}debug [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$devS0"; fi ;;
			"silly")  		if [[ $loglevelid -ge 6 ]]; then echo -e "${GREEN}silly [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$devS0"; fi ;;	
			"function")  	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" > "$devS0"; fi ;;	
			"function2") 	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func2 $lineinfo:${NORM}\t$message" > "$devS0"; fi ;;	
		esac
	fi
	if [[ "$LogToFile" != "" ]]; then
		case $level in
			"none") ;;
			"error")		if [[ $loglevelid -ge 1 ]]; then echo -e "${RED}error:${NORM}\t$message" >> "$LogToFile"; fi; ;;
			"warn")  		if [[ $loglevelid -ge 2 ]]; then echo -e "${YELLOW}warn:${NORM}\t$message" >> "$LogToFile"; fi ;;
			"info")  		if [[ $loglevelid -ge 3 ]]; then echo -e "${WHITE}info:${NORM}\t$message" >> "$LogToFile"; fi ;;
			"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo -e "${CYAN}verbose:${NORM}\t$message" >> "$LogToFile"; fi ;;
			"debug")  		if [[ $loglevelid -ge 5 ]]; then echo -e "5${MAGENTA}debug [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" >> "$LogToFile"; fi ;;
			"silly")  		if [[ $loglevelid -ge 6 ]]; then echo -e "${GREEN}silly [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" >> "$LogToFile"; fi ;;	
			"function")  	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" >> "$LogToFile"; fi ;;	
			"function2") 	if [[ $loglevelid -ge 7 ]]; then echo -e "${BLUE}func2 $lineinfo:${NORM}\t$message" >> "$LogToFile"; fi ;;	
		esac
	fi
} #end_log\n

#/	Desc:	determines if a string of text is a url
#/	$1:		url
#/	$2:		name1
#/	$3:		name1
#/	Out:	1 or 0 echo
#/	Expl:	if [[ $(isURL $astring) -eq 1]]; then
isURL(){
	regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
string="$1"
if [[ $string =~ $regex ]]
then 
    echo 1
else
    echo 0
fi
} #end_isURL\n


#---------------------------------------------------------------------------------------------------------------------------
# utils Math
#---------------------------------------------------------------------------------------------------------------------------

#/	Desc:	Takes an integer and oupts hex
#/	$1:		decimal
#/	$2:		name1
#/	$3:		name1
#/	Out:	hex string
#/	Expl:	out=$(dec2hex 33)
dec2hex() {
	echo "obase=16;ibase=10; $1" | bc
} #end_dec2hex

#/	Desc:	Takes an hex and oupts integer
#/	$1:		hex
#/	Out:	dec string
#/	Expl:	out=$(hex2dec 0x22)
hex2dec() {
	printf "%d\n" $1
} #end_hex2dec

#/	Desc:	converts hex 2 ascii
#/	$1:		hex
#/	Out:	ascii
#/	Expl:	$out=(hex2ascii "0x20")
hex2ascii() {
	a=$(echo "$1" | sed s/0/\\\\/1)
	echo -en "$a"
	#echo $b
} #end_hex2ascii


#-----------------------------------------------------------------------------------------------------------------------
#  utils eeprom
#-----------------------------------------------------------------------------------------------------------------------

#/	Desc:	erases the page called
#/	$1:		page [0x50,0x51,0x52...]
#/	$2:		
#/	$3:		
#/	Out:	none
#/	Expl:	erasePage 0x50
erasePage(){
	for i in {0..255}; do 
		i2cset -y 1 0x50 $i 0xff b; 
	done
} #end_erasePage


#/	Desc:	grabs one character from the Eerpom
#/	$1:		postion
#/	$2:		
#/	$3:		
#/	Out:	outputs the character in native format
#/	Expl:	hex=(grabOne 2)
grabOne(){
	a=$(i2cget -y 1 0x50 $1 b) 
	echo $a
} #end_grabOne


#/	Desc:	pulls a range from the eeprom
#/	$1:		start (using position, e.g. 2=2nd character in eeprom)
#/	$2:		end (using position)
#/	Out:	output [ascii|decimal|hex|hex-stripped]
#/	Expl:	SN=$(grabRange 0 9 "ascii" "")
grabRange() {
	start=$1
	end=$2
	output=$3
	delimeter=$4
	RET=""
	for ((i=$start; i<=$end; i=i+1)); do
		h=$(printf "%#x\n" $i)
		hex=$(grabOne $h)
		if [[ $output == "decimal" ]]; then
			var=$(hex2dec $hex)
		elif [[ $output == "ascii" ]]; then
			var=$(hex2ascii $hex)
		elif [[ $output == "hex-stripped" ]]; then
			var=`expr "$hex" : '^0x\([0-9a-zA-Z]*\)'`		
		else
			var=$hex
		fi
		if [[ $RET == "" ]]; then
			RET="$var"
		else
			RET+=$delimeter"$var"
		fi
	done
	echo $RET
} #end_grabRange

#/	Desc:	reads the eeprom and then can take action with the varribles from the EEPROM
#/	$1:		action logitpapertrail:logs to papertrail, print:prints,none:just grabs the varribles for use in your script
#/	$2:		name1
#/	$3:		name1
#/	Out:	print,varribles, or paprertail
#/	Expl:	logEEPROM "none"
function logEEPROM(){
	action="$1"
	actionType="$2"
	if [[ "$action" == "" ]]; then
		action="logitPapertrail"
	fi
	SN=$(grabRange 0 9 "ascii" "")
	HWV=$(grabRange 10 14 "ascii" "")
	FWV=$(grabRange 15 19 "ascii" "")
	RC=$(grabRange 20 21 "ascii" "")
	YEAR=$(grabRange 22 22 "ascii" "")
	MONTH=$(grabRange 23 23 "ascii" "")
	BATCH=$(grabRange 24 24 "ascii" "")
	ETHERNETMAC=$(grabRange 25 30 "hex-stripped" ":")
	ETHERNETMACd=$(grabRange 25 30 "decimal" ",")
	SIXBMAC=$(grabRange 31 38 "hex-stripped" ":")
	SIXBMACd=$(grabRange 31 38 "decimal" ",")
	RELAYSECRET=$(grabRange 39 70 "ascii" "")
	PAIRINGCODE=$(grabRange 71 95 "ascii" "")
	LEDCONFIG=$(grabRange 96 97 "ascii" "")
	# logitp "EEPROM_Serial: $SN"
 # 	logitp "EEPROM_hardwareVersion: $HWV"
	# logitp "EEPROM_firmwareVersion: $FWV"
	# logitp "EEPROM_radioConfig $RC"
	# logitp "EEPROM_year $YEAR"
	# logitp "EEPROM_month $MONTH"
	# logitp "EEPROM_batch $BATCH"
	# logitp "EEPROM_ethernetMAC $ETHERNETMAC"
	# logitp "EEPROM_sixBMAC $SIXBMAC"
	# logitp "EEPROM_relaySecret $RELAYSECRET"
	# logitp "EEPROM_pairingCode $PAIRINGCODE"
	# logitp "EEPROM_ledConfig $LEDCONFIG"
	if [[ "$action" = "print" ]]; then
		echo "print here"
	elif [[ "$action" = "logitPapertrail" ]]; then
		logitp "{\"batch\":\"$BATCH\",\"month\":\"$MONTH\",\"year\":\"$YEAR\",\"radioConfig\":\"$RC\",\"hardwareVersion\":\"$HWV\",\"firmwareVersion\":\"$FWV\",\"realyID\":\"$SN\",\"ethernetMAC\":[$ETHERNETMACd],\"sixBMAC\":[$SIXBMACd],\"relaySecret\":\"$RELAYSECRET\",\"pairingCode\":\"$PAIRINGCODE\",\"ledConfig\":\"$LEDCONFIG\"}"
	fi
} #end_logEEPROM



#/	Description: Tests an array of files for existance
#/	1 - array referenced by name
#/	Output:0
#/	Example: filesExist array[@]
filesExist(){
	local array="$1[@]"
	countExisting=0;
	for element in "${!array}"; do
		#echo "analyzing element $element"
		if [[ $(fileExists "$element") -eq 1 ]]; then
			countExisting=$((countExisting+1))
		fi
	done
	if [[ "$countExisting" -eq 0 ]]; then
		echo 0
	else 
		echo 1
	fi
} #end_filesExist


#/	Desc:	removes the sslkeys from the storage point
#/	Out:	just login
#/	Expl:	uninstallCloudKeys
uninstallCloudKeys(){
sslmp=/mnt/.boot
storage=/mnt/.boot/.ssl
ssl_client_key="client.key.pem";
ssl_client_cert="client.cert.pem";
ssl_server_key="server.key.pem";
ssl_server_cert="server.cert.pem";
ssl_ca_cert="ca.cert.pem";
ssl_ca_intermediate="intermediate.cert.pem";

umount /dev/mmcblk0p1 >> /dev/null 2>&1
sync
umount /mnt/.boot/ >> /dev/null 2>&1
sync
mkdir -p /mnt/.boot/ 2> /dev/null
mount /dev/mmcblk0p1 /mnt/.boot >> /dev/null 2>&1
sync
outputtest=$(mount 2>/dev/null)
#log "info" "$outputtest"
# lightLog "bash cmd: mountOrError /dev/mmcblk0p1 $sslmp"
# output=$(mountOrError /dev/mmcblk0p1 $sslmp)
# lightLog "we got from the mount '$output'"
# sync
mkdir -p $storage/
sync
touch $storage/$ssl_ca_intermediate
sync
sleep 1
rm -rf "$storage/"
mkdir "$storage/"
sync
sync
sync
#touch "$storage/$ssl_ca_intermediate"
theyAreAlive=("$storage/$ssl_client_key" "$storage/$ssl_client_cert" "$storage/$ssl_server_cert" "$storage/$ssl_server_key" "$storage/$ssl_ca_intermediate" "$storage/$ssl_ca_cert");
dotheyexist=$(filesExist theyAreAlive[@])
if [[ "$dotheyexist" = 1 ]]; then
	log "info" "ssl files not removed properly...try again"
else
	log "info" "ssl keys are removed"
fi
} #end_uninstallCloudKeys

#/	Desc:	determines if a url is currently being served by a server
#/	$1:		url
#/	$2:		name1
#/	$3:		name1
#/	Out:	1 or 0 echo
#/	Expl:	up=$(isURLUp "http:/google.com")
isURLUp(){
	url="$1"
	curl -k --output /dev/null --silent --fail --connect-timeout 2 -r 0-0 "$url"
	outtest=$?
	if [[ "$outtest" -eq 0 ]]; then
	  echo 1
	else
	  echo 0
	fi
} #end_isURLUp

#/	Desc:	prints a warning banner
#/	Out:	text to the screen
#/	Expl:	UIwarning done in figlet
UIwarning(){
	echo "${RED}"
echo "__        __     _      ____    _   _   ___   _   _    ____ "
echo "\ \      / /    / \    |  _ \  | \ | | |_ _| | \ | |  / ___|"
echo " \ \ /\ / /    / _ \   | |_) | |  \| |  | |  |  \| | | |  _ "
echo "  \ V  V /    / ___ \  |  _ <  | |\  |  | |  | |\  | | |_| |"
echo "   \_/\_/    /_/   \_\ |_| \_\ |_| \_| |___| |_| \_|  \____|"
echo "${NORM}"  
} #end_UIwarning\n

#/	Desc:	clears the screen and puts the cursor at the bottom for interactive scripts
#/	$1:		
#/	$2:		name1
#/	$3:		name1
#/	Out:	blank screen, currsor at the bottom
#/	Expl:	clearpadding
clearpadding(){
	clear; echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
} #end_clearpadding\n

#/	Desc:	tests if a string is contained within anouther
#/	$1:		string to test
#/	$2:		seek string
#/	Out:	1 or 0 based on result
#/	Expl:	out=$(sContains "string te test" "seekstring")
sContains(){
	log "function" "sContains(str=$1,seek=$2)"
	local str="$1"
	local seek="$2"
	local tem="$(echo "$str" | grep "$seek")"
	 if [[ "$tem" != "" ]]; then
	 	echo 1
	 else
	 	echo 0
	 fi
} #end_sContains\n

#/	Desc:	runs sed on a file changing out the line
#/	$1:		file to run sed on
#/	$2:		name1
#/	$3:		name1
#/	Out:	xxx
#/	Expl:	xxx
#SedGeneric file "\"s/\\\"oRSSI_THRESHOLD.*/\\\"oRSSI_THRESHOLD\\\": $RSMI,/g\""
SedGeneric(){
	changeFile=$1
	changeSed="$2"
		sedline="sed -i $changeSed $changeFile"
	#echo $sedline
	eval "$sedline"
	sync
} #end_SedGeneric


#/	Desc:	strips trailing and or front white space tabs and spaces
#/	$1:		side to strip from [left|right|both]
#/	$2:		the string to strip from
#/	Out:	the string striped
#/	Expl:	tag="$(stripWhiteSpace "both" "${lineR[1]}")"		
stripWhiteSpace(){
	side="$1"
	str="$2"
	if [[ "$side" = "left" || "$side" = "both" ]]; then
		#log "debug" "left one: $side"
		 a="$(echo -e "${str}" | sed -e 's/^[[:space:]]*//')"
	else
		a="$str"
	fi
	if [[ "$side" = "right" || "$side" = "both" ]]; then
		#log "debug" "right one: $side"
		a="$(echo -e "${a}" | sed -e 's/[[:space:]]*$//')"
	fi
	echo "$a"
} #end_stripWhiteSpace\n

#/	Desc:	prints an assoicative array
#/	$1: 	the array passed via just its name
#/	Expl:	printAssociativeAray myray  #<-- no $ @
printAssociativeArray(){
	declare -n theArray=$1
	echo ${#theArray[@]} is the size	
	for KEY in "${!theArray[@]}"; do
  	echo "key  : $KEY"
  	echo "value: ${theArray[$KEY]}"
	done
} #end_printAssociativeArray\n

#/	Desc:	tests if a file exists
#/	$1:		file
#/	$2:		name1
#/	$3:		name1
#/	Out:	1 or 0 echo
#/	Expl:	out=$(fileExists afile.txt)
fileExists(){
	if [[ -e "$1" ]]; then
		echo 1
	else
		echo 0
	fi
} #end_fileExists\n


#/	Desc:	Gathers all the keys from the menu system and builds a proper string for getopts	
#/	Out:	echo - switch_conditions
#/	Expl:	switch_conditions=$(COMMON_MENU_SWITCH_GRAB)
COMMON_MENU_SWITCH_GRAB(){
	#shellcheck disable=SC2154
	for KEY in "${!hp[@]}"; do
		:
		VALUE=${hp[$KEY]}
		numcheck="${KEY:1:1}"
		skip=false
		if [[ "$numcheck" =~ ^[0-9]+$ ]]; then
			skip=true
		fi
		double=""
		if [[ ${#KEY} -gt 1 ]]; then
			double=":"
			dKEY="${KEY:0:1}"
		else
			dKEY=$KEY
		fi
		if [[ $KEY != "description" && $KEY != "useage" && $skip != true ]]; then
			myline=$myline$dKEY$double
		fi
	done
	echo "$myline"
} #end_COMMON_MENU_SWITCH_GRAB\n

#/	Desc:	Generates a menu based on a named template system
#/  Global: declare -A hp=() assoiative array of switches
#/			exects an associateve array named hp.
#/			hp nomenclature hp[x] where x represents a switch
#/			and where hp[xx] represents a switch and varriable
#/	$1:		name1
#/	$2:		name1
#/	$3:		name1
#/	Out:	a help text for the cli
#/	Expl:	COMMON_MENU_HELP
COMMON_MENU_HELP(){
	echo -e \\n"Help documentation for ${BOLD}$0${NORM}"
	echo -e "${hp[description]}"
	echo -e "----------------------------------------------------------------------------------------"
	echo -e "${BOLD}Basic usage:${NORM}${BOLD} $0 ${NORM} ${hp[useage]}"
	etext=""
	for KEY in "${!hp[@]}"; do
		:
		VALUE=${hp[$KEY]}
		numcheck="${KEY:1:1}"
		skip=false
		if [[ "$numcheck" =~ ^[0-9]+$ ]]; then
			skip=true
			if [[ ${KEY:0:1} = "e" ]]; then
				etext=$etext"${UND}${BOLD} Example:${NORM} $VALUE\n"
			fi
		fi
		if [[ ${#KEY} -gt 1 ]]; then
			dKEY="${KEY:0:1}"
		else
			dKEY=$KEY
		fi
		if [[ $KEY != "description" && $KEY != "useage" && $skip != true ]]; then
			switches=$switches"${BOLD}-$dKEY${NORM} $VALUE\n"
		fi
	done  
	echo -e "$switches"  | sort -n -k1
	echo -e "$etext\n"
	exit 1
} #end_COMMON_MENU_HELP\n
