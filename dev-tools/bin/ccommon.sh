
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


#/	Desc:	determines if a url is currently being served by a server
#/	$1:		url
#/	$2:		name1
#/	$3:		name1
#/	Out:	1 or 0 echo
#/	Expl:	up=$(isURLUp "http:/google.com")
isURLUp(){
	url="$1"
	curl -k --output /dev/null --silent --fail -r 0-0 "$url"
	outtest=$?
	if [[ "$outtest" -eq 0 ]]; then
	  echo 1
	else
	  echo 0
	fi
} #end_isURLUp

#/	Desc:	prints a warning banner
#/	Out:	text to the screen
#/	Expl:	UIwarning
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
