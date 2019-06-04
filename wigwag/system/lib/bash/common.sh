#!/bin/bash

# Copyright (c) 2018, Arm Limited and affiliates.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
#Varriables
scpNO="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
export RSYNC_RSH="ssh -c aes128-ctr $scpNO"
rsyncstart="rsync -rLtvz --whole-file --exclude='.git/' --exclude='common.sh'"
rsyncstart="rsync -rLtvz --whole-file --exclude='.git/'"
 




  	THISIP="see end"



#varraibles#shellcheck disable=
#
whichOS() {
	if [[ "$(uname)" == "Darwin" ]]; then
		OS="mac"
	else
		OS="linux"
	fi
	echo $OS
} #end_whichOS

#/	Desc:	does nothing.  Used when including the common script
#/	Expl:	source common.sh nofunc
nofunc(){
	:
} #end_nofunc


rmWWupdate(){
	rm -rf /run/media/WWUPDATE/wwupdate.sh
} #end_rmWWupdate

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

randNum(){
	start=$1
	end=$2
	echo $[ $start + $[ RANDOM % $end ]]
} #end_randNum


#/	Desc:	grabs all the common used functions and builds a new common
#/	$1:		path to common.sh to strip from
#/	$2:		path to shell.sh needing common functions
#/	$3:		newcommon file output e.g. ccommon.shell
#/	Out:	a file only containing the common functions needed
#/	Expl:	./common.sh streamlineCommon common.sh ../../devicejs2.0-compatibility/wwrelay-utils/dev-tools/bin/upgrade.sh ../../devicejs2.0-compatibility/wwrelay-utils/dev-tools/bin/ccommon.sh
streamlineCommon(){
	didwork=0;
	pass=1;
	commonpath="$1"
	comparepath="$2"
	outputpath="$3"
	out=$(grep -ne "()" $commonpath)
	nout=();
	readarray -t outR <<<"$out"
	for val in "${outR[@]}"; do
		val=${val##*:}
		val=${val%%(*}
			val="$val"
		if [[ $(sContains "$val" " " ) -ne 1 ]]; then
			if [[ $(findLineNo "$comparepath" "$val") != "" ]]; then
				didwork=1;
				log "warn" "P$pass $val"
				extractFunction "$val" "$commonpath" "$outputpath"
				# extractFunction "$val" "$commonpath" "stdout"
				# read givme
			else
				noutR+=($val);
			fi
		fi
	done
	while [[ "$didwork" -eq 1 ]]; do
		echo "got in"
		didwork=0;
		echo "got out?"
		pass=$((pass+1))
		noutR2=();
		for val in "${noutR[@]}"; do
			val="$val"
			if [[ $(findLineNo "$comparepath" "$val") != "" ]]; then
				didwork=1;
				log "warn" "P$pass $val"
				extractFunction "$val" "$commonpath" "$outputpath"
			else
				noutR2+=($val);
			fi
		done
		unset noutR;
		noutR=("${noutR2[@]}");
		unset noutR2;
	done
} #end_streamlineCommon

#Utils LOGGING 
#-----------------------------------------------------------------------------------------------------------------------

#/	Desc:	common bash logger
#/	global:	LogToTerm 	[0|*1] uses the terminal number instead of echo to post messages.  this gets around degubbing functions that return data via echo
#/	global:	LogToSerial [*0|1] logs to both kmesg and ttyS0, good for relay debugging
#/	global: LogToecho 	[*0|1] logs to stdout.  disabled by default
#/	global: LogToFile 	<file> logs to a file
#/ 	global:	loglevel 	suppresses output for anything below the level spefied.  Levels are: ["none", "error", "warn", "info", "verbose", "debug", "silly","func"],
#/	$1:		message level within these options: ["none", "error", "warn", "info", "verbose", "debug", "silly","func"],
#/	$2:		"the message"
#/	$3:		<ignore> special for a depricated function function call
#/	Out:	debug info on your screen
#/	Expl:	log "debug" "oh snarks, i got a problem"
	THISTERM=$(tty)
	#echo "hi this term is $THISTERM"
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
	#echo -e "LogToEcho=$LogToecho\nLogToTerm=$LogToTerm\nLogToSerial=$LogToSerial\nLogtoFile=$LogToFile\n"
	#echo "log called: $level $message $lineinfo"
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
} #end_log

logtest(){
	log error "should be red"
	log warn "should be yellow"
	log info "should be black"
	log verbose "should be Blue"
	log debug "should be magenta"
	log silly "should be green"
} #end_logtest



logger() {
	log "debug" "dumb"
	log "error" "depricated switch to log [${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}]-->$1: $2"
#	log "$1" "$2"
} #end_logger

logfunction() {
	log "function2" "$1" "[${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}]"
} #end_logfunction



alert(){
	echo "${REV}$1${NORM}"
} #end_alert


logit() {
	echo $1 >> $2
} #end_logit

Lecho(){
	echo "$1"
} #end_Lecho

Lkmesg(){
	echo "$1" > /dev/kmesg
} #end_Lkmesg

LttyS0(){
	echo "$1" > /dev/ttyS0
} #end_LttyS0

Lpaper(){
	logitPapertrailDetail "$1"
} #end_Lpaper


lightLog(){
	echo "$1" "$2"
	echo "$1" "$2"> /dev/ttyS0
	echo "$1" "2"> /dev/kmesg
	logitp "$1 $2"
} #end_lightLog

logitPapertrailDetail() {
	host="$1"
	program="$2"
	message="$3"
	mdate=$(date +"%Y-%m-%dT%H:%M:%SZ")
	mdate="2014-06-18T09:56:21Z"
	echo "<22>1 $mdate $1 $2 - - - $3" | nc logs4.papertrailapp.com 42965
} #end_logitPapertrailDetail

logitp(){
	logitPapertrailDetail "$HOST" "$PROGRAM" "$1"
} #end_logitp

#Utils LED 
#-----------------------------------------------------------------------------------------------------------------------
ledstart() {
	$ledcontrol 0 0 0
	sleep 1
	$ledcontrol 5 5 5
} #end_ledstart

ledstop(){
	$ledcontrol 0 5 0
} #end_ledstop


#UTILS NETWORK
#-----------------------------------------------------------------------------------------------------------------------
dhcpthis(){
	udhcpc --now || ifconfig -a eth0 192.168.3.199 netmask 255.255.255.0
	sync
	sleep 3
	killall udhcpc
} #end_dhcpthis

dhcpthisSmart(){
	if [[ $(getPublicIP) == "" ]]; then
		dhcpthis
	else
		return 0
	fi
	if [[ $(getPublicIP) == "" ]]; then
		dhcpthis
	else
		return 0
	fi
		if [[ $(getPublicIP) == "" ]]; then
		dhcpthis
	else
		return 0
	fi

} #end_dhcpthisSmart

updateThisIP(){
	THISIP=$(getCurrentIP)
} #end_updateThisIP 

grabip() {
	ifconfig > ifconfig.txt
	logitp "$THISIP"
	THISIP="$THISIP"
} #end_grabip

#Utils Mounting
#Utils disk
#
#---------------------------------------------------------------------------------------------------------------------------
# utils json
# https://github.com/fkalis/bash-json-parser/blob/master/bash-json-parser
#---------------------------------------------------------------------------------------------------------------------------
function JSON_output_entry() {
	echo "$1=\"$2\"" >> "$JSON_OUTFILE"
}

function JSON_parse_array() {
	local current_path="${1:+$1$JSON_DELINATION}$2"
	local current_scope="root"
	local current_index=0

	while [ "$chars_read" -lt "$JSON_INPUT_LENGTH" ]; do
		[ "$preserve_current_char" == "0" ] && chars_read=$((chars_read+1)) && read -r -s -n 1 c
		preserve_current_char=0
		c=${c:-' '}

		case "$current_scope" in
			"root") # Waiting for new object or value
				case "$c" in
					'{')
						JSON_parse_object "$current_path" "$current_index"
						current_scope="entry_separator"
						;;
					']')
						return
						;;
					[\"tfTF\-0-9])
						preserve_current_char=1 # Let the parse value function decide what kind of value this is
						JSON_parse_value "$current_path" "$current_index"
						preserve_current_char=1 # Parse value has terminated with a separator or an array end, but we can handle this only in the next while iteration
						current_scope="entry_separator"
						;;
						
				esac
				;;
			"entry_separator")
				[ "$c" == "," ] && current_index=$((current_index+1)) && current_scope="root"
				[ "$c" == "]" ] && return
				;;
		esac
	done
}

function JSON_parse_value() {
	local current_path="${1:+$1$JSON_DELINATION}$2"
	local current_scope="root"

	while [ "$chars_read" -lt "$JSON_INPUT_LENGTH" ]; do
		[ "$preserve_current_char" == "0" ] && chars_read=$((chars_read+1)) && read -r -s -n 1 c
		preserve_current_char=0
		c=${c:-' '}

		case "$current_scope" in
			"root") # Waiting for new string, number or boolean
				case "$c" in
					'"') # String begin
						current_scope="string"
						current_varvalue=""
						;;
					[\-0-9]) # Number begin
						current_scope="number"
						current_varvalue="$c"
						;;
					[tfTF]) # True or false begin
						current_scope="boolean"
						current_varvalue="$c"
						;;
					"[") # Array begin
						JSON_parse_array "" "$current_path"
						return
						;;
					"{") # Object begin
						JSON_parse_object "" "$current_path"
						return
				esac
				;;
			"string") # Waiting for string end
				case "$c" in
					'"') # String end if not in escape mode, normal character otherwise
						[ "$current_escaping" == "0" ] && JSON_output_entry "$current_path" "$current_varvalue" && return
						[ "$current_escaping" == "1" ] && current_varvalue="$current_varvalue$c"
						;;
					'\') # Escape character, entering or leaving escape mode
						current_escaping=$((1-current_escaping))
						current_varvalue="$current_varvalue$c"
						;;
					*) # Any other string character
						current_escaping=0
						current_varvalue="$current_varvalue$c"
						;;
				esac
				;;
			"number") # Waiting for number end
				case "$c" in
					[,\]}]) # Separator or array end or object end
						JSON_output_entry "$current_path" "$current_varvalue"
						preserve_current_char=1 # The caller needs to handle this char
						return
						;;
					[\-0-9.]) # Number can only contain digits, dots and a sign
						current_varvalue="$current_varvalue$c"
						;;
					# Ignore everything else
				esac
				;;
			"boolean") # Waiting for boolean to end
				case "$c" in
					[,\]}]) # Separator or array end or object end
						JSON_output_entry "$current_path" "$current_varvalue"
						preserve_current_char=1 # The caller needs to handle this char
						return
						;;
					[a-zA-Z]) # No need to do some strict checking, we do not want to validate the incoming json data
						current_varvalue="$current_varvalue$c"
						;;
					# Ignore everything else
				esac
				;;
		esac
	done
} #end_JSON_parse_value

function JSON_parse_object() {
	local current_path="${1:+$1$JSON_DELINATION}$2"
	local current_scope="root"

	while [ "$chars_read" -lt "$JSON_INPUT_LENGTH" ]; do
		[ "$preserve_current_char" == "0" ] && chars_read=$((chars_read+1)) && read -r -s -n 1 c
		preserve_current_char=0
		c=${c:-' '}

		case "$current_scope" in
			"root") # Waiting for new field or object end
				[ "$c" == "}" ]  && return
				[ "$c" == "\"" ] && current_scope="varname" && current_varname="" && current_escaping=0
				;;
			"varname") # Reading the field name
				case "$c" in
					'"') # String end if not in escape mode, normal character otherwise
						[ "$current_escaping" == "0" ] && current_scope="key_value_separator"
						[ "$current_escaping" == "1" ] && current_varname="$current_varname$c"
						;;
					'\') # Escape character, entering or leaving escape mode
						current_escaping=$((1-current_escaping))
						current_varname="$current_varname$c"
						;;
					*) # Any other string character
						current_escaping=0
						current_varname="$current_varname$c"
						;;
				esac
				;;
			"key_value_separator") # Waiting for the key value separator (:)
				[ "$c" == ":" ] && JSON_parse_value "$current_path" "$current_varname" && current_scope="field_separator"
				;;
			"field_separator") # Waiting for the field separator (,)
				[ "$c" == ',' ] && current_scope="root"
				[ "$c" == '}' ] && return
				;;
		esac
	done
} #end_JSON_parse_object

function JSON_STARTparse() {
	echo -e "#!/bin/bash\n" > .jsonOut
	chars_read=0
	preserve_current_char=0

	while [ "$chars_read" -lt "$JSON_INPUT_LENGTH" ]; do
		read -r -s -n 1 c
		c=${c:-' '}
		chars_read=$((chars_read+1))

		# A valid JSON string consists of exactly one object
		[ "$c" == "{" ] && JSON_parse_object "" "" && return
        # ... or one array
        [ "$c" == "[" ] && JSON_parse_array "" "" && return
        
	done
}

JSON_INPUT=""
JSON_INPUT_LENGTH=""
JSON_DELINATION="_"
JSON_OUTFILE=""

#/	Desc:	xxx
#/	$1:	name1
#/	$2:	name1
#/	$3:	name1
#/	Output:	xxx
#/	Example:	xxx


#/	Desc:		parses a json file to something sourceable
#/	$1:			file.json
#/	$2:			output file
#/	Output: 	just the file specified in $2
#/	Example: 	parseJSON ./wigwag/FACTORY/QRScan/cfg.json .jsn
#/				source .jsn
function parseJSON(){
	JSON_OUTFILE="$2"
	echo "" > $JSON_OUTFILE
	log "debug" "myoutfile is $JSON_OUTFILE"
	JSON_INPUT=$(cat "$1")
    JSON_INPUT_LENGTH="${#JSON_INPUT}"
	JSON_STARTparse "" "" <<< "${JSON_INPUT}"
} #end_parseJSON



#---------------------------------------------------------------------------------------------------------------------------
# utils web
#---------------------------------------------------------------------------------------------------------------------------
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
} #end_isURL

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

#---------------------------------------------------------------------------------------------------------------------------
# utils disk
# utils Mounting
#---------------------------------------------------------------------------------------------------------------------------
osxRdisktoDisk(){
	echo ${1/rdisk/disk}	
} #end_osxRdisktoDisk

osxDisktoRdisk(){
	echo ${1/disk/rdisk}	
} #end_osxDisktoRdisk






getDiskInfo(){
	local d=","
	local ret=$1"$d"
	local dnum
	local pnum
	temp=${1/dev\/}
	temp2=${temp/\//}

    #good bash regex infos
    #http://www.tldp.org/LDP/abs/html/bashver3.html#REGEXMATCHREF
    #http://www.tldp.org/LDP/abs/html/x17129.html
    #
    #if [[ $temp2 =~ sd ]]; then
    if [[ $temp2 =~ ^sd([a-z]*)([0-9]*) ]]; then
    	ret=$ret"$temp2$d"sd${BASH_REMATCH[1]}$d${BASH_REMATCH[1]}$d${BASH_REMATCH[2]}
    	if [[ ${BASH_REMATCH[2]} = 	"" ]]; then
    		ret=$ret"0"
    	fi
    fi
    if [[ $temp2 =~ ^disk([0-9]*)s*([0-9]*) ]]; then
    	ret=$ret"$temp2$d"disk${BASH_REMATCH[1]}$d${BASH_REMATCH[1]}$d${BASH_REMATCH[2]}
    	if [[ ${BASH_REMATCH[2]} = 	"" ]]; then
    		ret=$ret"0"
    	fi
    fi
    if [[ $temp2 =~ ^rdisk([0-9]*)s*([0-9]*) ]]; then
    	ret=$ret"$temp2$d"rdisk${BASH_REMATCH[1]}$d${BASH_REMATCH[1]}$d${BASH_REMATCH[2]}
    	if [[ ${BASH_REMATCH[2]} = 	"" ]]; then
    		ret=$ret"0"
    	fi
    fi
    if [[ $temp2 =~ ^mmcblk([0-9]*)p*([0-9]*) ]]; then
    	ret=$ret"$temp2$d"mmcblk${BASH_REMATCH[1]}$d${BASH_REMATCH[1]}$d${BASH_REMATCH[2]}
    	if [[ ${BASH_REMATCH[2]} = 	"" ]]; then
    		ret=$ret"0"
    	fi
    fi
    	# dnum=${temp2/sd/}
    	# if [[ $dnum =~[0-9] ]]; then
    	# echo $dnum
   # fi
    #ret=$ret$temp
    #list_printTabed "$ret"
    echo "$ret"
} #end_getDiskInfo


#
#/	Desc:	finds disks with certain properties 
#/	$1:		mode [removable|all]
#/			- removeable:attempts to: grab all removable storage (seeing some flaws with usb keys that report that they are not removable)
#/			- all: grabs all disks available
#/	$2:		mode for optional list [omit]
#	$3:		list
#/	Out:	xxx
#/	Expl:	xxx
getUsbDisks(){
	mainmode="$1"
	listmode="$2"
	thelist="$3"
	if [[ $THISOS = "linux" ]]; then
		if [[ "$mainmode" = "" || "$mainmode" = "removeable" ]]; then
			list=$(grep -Hv ^0$ /sys/block/*/removable | sed s/removable:.*$/device\\/uevent/ | xargs grep -H ^DRIVER=sd | sed s/device.uevent.*$/size/ | xargs grep -Hv ^0$ | cut -d / -f 4 | xargs -n 1 echo "/dev/" | sed s/\ // | sed s/\n// | xargs)
		elif [[ "$mainmode" = "all" ]]; then
			list=$(lsblk -d -n -oNAME,RO | grep '0$' | awk {'print $1'} | xargs -n 1 echo "/dev/" | sed "s/\ //" | xargs)
		fi
	fi
	echo "$list"
} #end_getUsbDisks



umountNOW(){
	outfile=$1
	logfunction "unmountOrError(outfile=$1)"
	if [[ $THISOS == "mac" ]]; then
		if [[ $(ismounted $outfile) -eq 1 ]]; then
        #log debug "diskutil umountDisk force $outfile"
        output=$(diskutil umountDisk force $outfile)
        diskID=$(list_returnElement 2 , $(getDiskInfo $(osxRdisktoDisk $outfile)))
        #echo "$output=output"
        if [[ "$output" != "Forced unmount of all volumes on $diskID was successful" ]]; then
        	echo "ERROR: Could not unmount disk"
        fi
    fi
else
	echo "ERROR: must implement linux unmountOrError"
fi
} #end_umountNOW

unmountOrError(){
	log "error" "unmountOrError is depricated.  Use unmountDiskOrError or unmountMpOrError"
	outfile=$(osxRdisktoDisk $1)
	logfunction "unmountOrError(outfile=$1)"
	if [[ $THISOS == "mac" ]]; then
		if [[ $(ismounted $outfile) -eq 1 ]]; then
			log debug "diskutil umountDisk force $outfile"
			output=$(diskutil umountDisk force $outfile)
			diskID=$(list_returnElement 2 , $(getDiskInfo $outfile))
			log debug "$output=output"
			if [[ "$output" != "Forced unmount of all volumes on $diskID was successful" ]]; then
				echo "ERROR: Could not unmount disk"
			fi	
		fi
	else
    	if [[ $(ismounted $outfile) -eq 1 ]]; then
    		log debug  "for n in $outfile* ; do sudo umount $n >> /dev/null 2>&1; done"
    		for n in $outfile* ; do 
	    		log debug "sudo umount -f $n >> /dev/null 2>&1;"
    				sudo umount -f $n >> /dev/null 2>&1; 
    			done
    		if [[ $(ismounted $outfile) -eq 1 ]]; then
				echo "ERROR: Could not unmount disk $outfile"
			fi	
    	fi   
	fi
} #end_unmountOrError

unmountMpOrError(){
	mountp=$1
	logfunction "unmountMpOrError(mountp=$1)"
	if [[ $THISOS == "mac" ]]; then
		if [[ $(ismounted $mountp) -eq 1 ]]; then
			log debug "diskutil umountDisk force $mountp"
			output=$(diskutil umountDisk force $mountp)
			diskID=$(list_returnElement 2 , $(getDiskInfo $mountp))
			log debug "$output=output"
			if [[ "$output" != "Forced unmount of all volumes on $diskID was successful" ]]; then
				echo "ERROR: Could not unmount disk"
			fi	
		fi
	else
    	if [[ $(ismounted $mountp) -eq 1 ]]; then
    		log debug  "for n in $mountp* ; do sudo umount $n >> /dev/null 2>&1; done"
    		for n in $mountp* ; do 
	    		log debug "sudo umount -f $n >> /dev/null 2>&1;"
    				sudo umount -f $n >> /dev/null 2>&1; 
    			done
    		if [[ $(ismounted $mountp) -eq 1 ]]; then
				echo "ERROR: Could not unmount disk $mountp"
			fi	
    	fi   
	fi
} #end_unmountMpOrError

unmountDiskOrError(){
	outfile=$(osxRdisktoDisk $1)
	logfunction "unmountDiskOrError(outfile=$1)"
	if [[ $THISOS == "mac" ]]; then
		if [[ $(ismounted $outfile) -eq 1 ]]; then
			log debug "diskutil umountDisk force $outfile"
			output=$(diskutil umountDisk force $outfile)
			diskID=$(list_returnElement 2 , $(getDiskInfo $outfile))
			log debug "$output=output"
			if [[ "$output" != "Forced unmount of all volumes on $diskID was successful" ]]; then
				echo "ERROR: Could not unmount disk"
			fi	
		fi
	else
    	if [[ $(ismounted $outfile) -eq 1 ]]; then
    		log debug  "for n in $outfile* ; do sudo umount $n >> /dev/null 2>&1; done"
    		for n in $outfile* ; do 
	    		log debug "sudo umount -f $n >> /dev/null 2>&1;"
    				sudo umount -f $n >> /dev/null 2>&1; 
    			done
    		if [[ $(ismounted $outfile) -eq 1 ]]; then
				echo "ERROR: Could not unmount disk $outfile"
			fi	
    	fi   
	fi
} #end_unmountDiskOrError


#mounts or throws an error code...
#error code 252 is couldn't mount
mountOrError(){
	local disk=$(osxRdisktoDisk $1)
	local mountp=$2
	local goodToMount=1;
	logfunction "mountOrError(disk=$disk,mountp=$mountp)"
	if [[ $THISOS == "mac" ]]; then
		if [[ $(ismounted $disk) -eq 1 ]]; then
			log debug "diskutil umountDisk force $disk"
			output=$(diskutil umountDisk force $disk)
			diskID=$(list_returnElement 2 , $(getDiskInfo $(osxRdisktoDisk $disk)))
			if [[ "$output" != "Forced unmount of all volumes on $diskID was successful" ]]; then
				echo "ERROR: Could not unmount disk and thus could not remount"
				goodToMount=0;
			fi
		fi
		if [[ $goodToMount -eq 1 ]]; then
			sudo fuse-ext2 $disk $mountp -o force > /dev/null 2>&1
			ec=$?
			#echo myerrc $ec
			if [[ ! $ec -eq 0 ]]; then
				echo "ERROR: $ec"
			fi
		else
			echo "ERROR couldn't mount proper in darwin"
		fi
	else
		log "debug" "linux portion"
		if [[ $(ismounted $disk) -eq 1 ]]; then
			output=$(unmountDiskOrError $disk)
			log "debug" "unmountDiskOrError returned $output"
			if [[ $output != "" ]]; then
				log "error" "stuff is found "
				goodToMount=0;
			fi
		fi
		log "debug" "goodToMount $goodToMount"
		if [[ $goodToMount -eq 1 ]]; then
			log debug "bash cmd: sudo mount $disk $mountp > /dev/null 2>&1"
			sudo mount $disk $mountp > /dev/null 2>&1
			ec=$?
			if [[ ! $ec -eq 0 ]]; then
				echo "ERROR: $ec"
			fi
		else
			echo "ERROR couldn't mount proper in linux"
		fi
	fi
} #end_mountOrError



ismounted(){
	mp=$(osxRdisktoDisk $1)
	logfunction "ismounted("mp=$mp")"
	local outstring=$(mount | grep $mp)
	log debug "ismounted outstring: '$outstring'"
	if [[ $outstring != "" ]]; then
		echo 1
	else
		echo 0
	fi
} #end_ismounted

PART1=4096;
PART2=45056;
PART3=2502656;
PART5=4552704;
PART6=6602752;

createLoopbacks(){
	imgfile=$1
	losetup /dev/loop1 $imgfile -o $(($PART1 *512))
	losetup /dev/loop2 $imgfile -o $(($PART2 *512))
	losetup /dev/loop3 $imgfile -o $(($PART3 *512))
	losetup /dev/loop5 $imgfile -o $(($PART5 *512))
	losetup /dev/loop6 $imgfile -o $(($PART6 *512))
} #end_createLoopbacks

destroyLoopbacks(){
	losetup -d /dev/loop1
	losetup -d /dev/loop2
	losetup -d /dev/loop3
	losetup -d /dev/loop5
	losetup -d /dev/loop6
} #end_destroyLoopbacks

mountLoopbacks(){
	local $MP=$1
	mkidr -p $MP/{1,2,3,5,6}
	mount /dev/loop1 $MP/1
	mount /dev/loop2 $MP/2
	mount /dev/loop3 $MP/3
	mount /dev/loop5 $MP/5
	mount /dev/loop6 $MP/6
} #end_mountLoopbacks

umountLoopbacks(){
	local MP=$1
	umount $MP/1
	umount $MP/2
	umount $MP/3
	umount $MP/5
	umount $MP/6
} #end_umountLoopbacks


#creates a mountpoint at
#1: <path>
#2: [0|1] to use a random directory name e.g. path/RAND/p1..p2..p3
createMountPoint(){
	path=$1
	useRandomizer=$2
	r=$( randNum 1 1000 )
	if [[ $useRandomizer -eq 1 ]]; then
		mp=$path/mp_$r
	else
		mp=$path/
	fi
	mkdir -p $mp
	mkdir -p $mp/p1
	mkdir -p $mp/p2
	mkdir -p $mp/p3
	mkdir -p $mp/p5
	mkdir -p $mp/p6
	echo $mp
} #end_createMountPoint

destroyMountPoint(){
	if mount|grep $1; then
		echo "$1 is still mounted somehow.  Not destroying anything inside common/destroMountPoint"
	else
		rm -rf $1
	fi
} #end_destroyMountPoint



mounter(){
	pt=$1
	case $pt in
		1) spot=4096; ;;
2) spot=45056; ;;
3) spot=2502656; ;;
5) spot=4552704; ;;
6) spot=6602752; ;;
esac

losetup /dev/loop$pt $file -o $(($spot *512))
mount /dev/loop$pt ./mnt/p$pt
} #end_mounter

umounter() {
	pt=$1
	umount ./mnt/p$pt
	losetup -d /dev/loop$pt
} #end_umounter


#---------------------------------------------------------------------------------------------------------------------------
# utils file manipulation
#---------------------------------------------------------------------------------------------------------------------------
#/	Desc:	finds a line number of matched text in a file
#/	$1:		fil
#/	$2:		search string
#/	Out:	line number
#/	Expl:	out=$(findLineNo test.txt "somestring")
findLineNo(){
	afile="$1"
	str="$2"
	line=$(grep -ne "$str" "$afile");
	line=${line%%:*};
	echo "$line"
} #end_findLineNo

#/	Desc:	removes lines from start point to end point
#	$1:		file
#/	$2:		starting line
#/	$3:		ending line (or blank = bottom of file)
#/	Out:	same file is written on the call
#/	Expl:	removeLinesDownward file 5 10
removeLinesDownward(){
    local ffile="$1"
    local start="$2"
    local end="$3"
    if [[ "$end" = "" ]]; then
        end="\$d"
        fi
    #log debug sed -i.bak -e "'$start,$end'" "$ffile"
   sed -i.bak -e "$start,$end" "$ffile"
} #end_removeLines



#/	Desc:	exacts a single line or range from a file
#/	$1:		start line no
#/	$2:		end line no
#/	$3:		file to extract from
#/	Out:	the lines via echo
#/	Expl:	out=$(extractLine 10 11 common.sh)
extractLine(){
	start="$1"
	stop="$2"
	input="$3"
	sed -n -e "$start,$stop"p "$input"
} #end_extractLine

findblankStop(){
	start="$1"
	input="$2"
	itterate=$((start-1))
	testing=""
	while [[ $itterate -gt 0 ]]; do
		#echo $itterate
		check=$(extractLine "$itterate" "$itterate" "$input")
		if [[ "$check" = "" ]]; then
			echo $itterate
			break;
		fi
		itterate=$((itterate-1))
	done
} #end_findblankStop

#/	Desc:	extracts functions from afile that has proper markings.  Must contain a #end_funcname
#/	$1:		function name
#/	$2:		input file <-- where to extract from
#/	$3:		[<filename>|"stdout"] <-- were to extract to
#/	$4:		[0|1] don't grab comments
#/	Out:	xxx
#/	Expl:	xxx
extractFunction(){
	log "function" "extractFunction(func=$1,input=$2,output=$3,nocoments=$4)"
	func="$1()"
	input="$2"
	output="$3"
	nocomments="$4"
	startLineNo="$(findLineNo "$input" "$func")"
	if [[ $startLineNo == "" ]]; then
		log error "$t does not exist inside $input"
	fi
	if [[ "$nocomments" -ne 1 ]]; then
		log "debug" "startline is currnetly $startLineNo"
		startLineNo="$(findblankStop "$startLineNo" "$input")"
	fi
	local t="#end_$1"
	#echo "grep -ne \"$t\" common.sh"
	endLineNo=$(grep -ne "$t" "$input");
	endLineNo=${endLineNo%%:*}
	if [[ $endLineNo == "" ]]; then
		log error "$t does not exist inside $input"
	fi
	#endLineNo=$endLineNo"p"
	#echo "sed -n -e \"$startLineNo,$endLineNo\" "$input""
	log "debug" "chopping from $startLineNo to $endLineNo"
	out=$(extractLine $startLineNo $endLineNo $input)
	if [[ "$output" != "stdout" ]]; then 	
	 	echo "$out\n" >> "$output"
	else
		echo  "$out"
	fi
} #end_extractFunction


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
} #end_fileExists

#/	Desc:	checks if a file has size
#/	$1:		<file>
#/	Out:	echo 1 or 0
#/	Expl:	out=$(fileHasSize /path/to/file)
fileHasSize(){
	if [[ -s "$1" ]]; then
		echo 1
	else
		echo 0
	fi
} #end_fileHasSize


#/	Description: Tests an array of files for existance
#/	1 - array referenced by name
#/	Output:0
#/	Example: output=$(filesExist array[@])
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


#/	Description: Tests an array of files for all files having a non 0 size
#/	1 - array referenced by name
#/	Output:0
#/	Example: filesHaveSize array[@]
filesHaveSize(){
	local array="$1[@]"
	for element in "${!array}"; do
		if [[ $(fileHasSize "$element") -ne 1 ]]; then
			echo 0
			return
		fi
	done
	echo 1
} #end_filesHaveSize


#Utils FS 
#-----------------------------------------------------------------------------------------------------------------------
diffCopy(){
	from=$1
	to=$2
	if [[ -e $1 && -e $2 ]]; then
		echo both exist $1 and $2
		DIFF=$(diff $1 $2)
		if [[ "$DIFF" != "" ]]; then
			cp $1 $2
		fi
	else

		cp $1 $2
	fi
} #end_diffCopy

#arg1: filepath
getfilesize(){
	if [[ $THISOS == "mac" ]]; then
		stat -f '%z' $1
	else
		stat -c '%s' $1
	fi
} #end_getfilesize

#arg1: filepath
#arg2: multiple
getPVSize(){
	logfunction "getPVSize(file=$1,mul=$2)"
	if [[ $2 = "" ]]; then
		mul=1
	else
		mul=$2
	fi
	s=$(getfilesize $1)
	log "debug" "echo "$s*$mul" | bc "
	t=$(echo "$s*$mul" | bc )
	t="${t%%.*}"
	echo $t
} #end_getPVSize



#Gets a list of files from a directory with a grep filter
#basically runs ls | grep Arg2
#arg1: path to directory
#arg2: grep filter
#returns a global named readDirArray
#example: reads the local dir, filter  "node" returns ray
#	readDirectoryToArray_withGrep . "node"
#	printf '%s\n' "${readDirArray[@]}"
readDirArray=();
readDirectoryToArray_withGrep(){
	log silly "readDirectoryToArray_withGrep($1,$2)"
	path=$1
	if [[ $2 = "" ]]; then
		grepfilter="";
	fi
	grepfilter=$2
	i=0
	pushd . >> /dev/null
	cd $path
	while read line
	do
		readDirArray[ $i ]="$line"        
		(( i++ ))
	done < <(ls | grep "$grepfilter")
	popd >> /dev/null
} #end_readDirectoryToArray_withGrep


 #finds the sd disk to to write to...
 function find_disk() {
	#regex parsing
#list='"'`diskutil list | grep / | xargs echo | sed 's/ /" "/g'`'"'
#list=`diskutil list | grep / | xargs echo | sed 's/ / /g'`
list=""
#echo $COMMON_OS
if [[ $COMMON_OS == "mac" ]]; then
	for i in {0..15}; do
		tempvar=$(diskutil list /dev/disk$i)
    #echo $i $tempvar
    if [[ ! $tempvar == Could* ]]; then
    	if $(echo $tempvar | xargs | grep -q "GUID") ; then
    		echo "hi" >>/dev/null
    	else
    		diskutil list /dev/disk$i
    		list="$list /dev/disk$i"
    	fi
    fi
done
fi

echo "which disk (sd card) do you want to work with?"
select diskno in $list; do
	rdiskno=`echo $diskno | sed 's/disk/rdisk/g'`
	echo $rdiskno
	break
done
} #end_find_disk

function selectafile() {
	path="$1"
	greper="$2"
	files=`ls $path | grep $greper | xargs echo`
	select selectAFileChoice in $files; do 
	break; done
} #end_selectafile


#---------------------------------------------------------------------------------------------------------------------------
# utils user interaction
# utils UI
#---------------------------------------------------------------------------------------------------------------------------

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
} #end_UIwarning

#/	Desc:	clears the screen and puts the cursor at the bottom for interactive scripts
#/	$1:		
#/	$2:		name1
#/	$3:		name1
#/	Out:	blank screen, currsor at the bottom
#/	Expl:	clearpadding
clearpadding(){
	clear; echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
} #end_clearpadding

#---------------------------------------------------------------------------------------------------------------------------
# utils String
#---------------------------------------------------------------------------------------------------------------------------

#/	Desc:	gets String Length
#/	$1:		the string
#/	Out:	the length echoed
#/	Expl:	out=$(sLength "some string")
sLength(){
	echo "${#1}"
} #end_sLength

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
} #end_sContains

#Returns the numbers in a string
function extract_numbers(){
	echo "${1//[!0-9]/}"
} #end_extract_numbers

#/	Desc:	calls a generic sed on a file
#/	$1:		<file>
#/	$2:		<sed replacementline>
#/	$3:		name1
#/	Out:	what the sed line looks like
#/	Expl:	SedGeneric file "\"s/\\\"oRSSI_THRESHOLD.*/\\\"oRSSI_THRESHOLD\\\": $RSMI,/g\""
SedGeneric(){
	changeFile=$1
	changeSed="$2"
	if [[ $COMMON_OS == "mac" ]]; then
		sedline="sed -i '' $changeSed $changeFile"
	else
		sedline="sed -i $changeSed $changeFile"
	fi
	echo $sedline
	eval "$sedline"
	sync
} #end_SedGeneric

fixsshlogin(){
	SedGeneric /etc/ssh/sshd_config \"s/PermitRootLogin.*/PermitRootLogin\ yes/g\"
	/etc/init.d/sshd restart
} #end_fixsshlogin

installSSHkey(){
	mkdir -p ~/.ssh/
	cp id_rsa ~/.ssh/
	chomd 600 ~/.ssh/id_rsa
	cat id_rsa.pub >> ~/.ssh/authorized_keys
} #end_installSSHkey

installWWrelayInitScript(){
	cp wwrelay /etc/init.d/
	chmod 777 /etc/init.d/wwrelay
} #installWWrelayInitScript

#/	Desc:	gets Characters from a string
#/	$1:		string
#/	$2:		type [start|end]
#/	$3:		type=end
#/           - number of charcters in from the end
#/          type=start
#/           - number of charcters in from the start
#/ 	$4:	    type=end
#/  		 - number of characters to grab
#/	Out:	string
#/	Expl:	xxx
getChar(){
	str="$1"
	typein="$2"
	if [[ "$typein" = "end" ]]; then
		echo "${str:$((${#str}-$3)):$4}"
	fi
} #_end_getChar

#/	Desc:	strips trailing and or front white space tabs and spaces
#/	$1:		side to strip from [left|right|both]
#/	$2:		the string to strip from
#/	Out:	the string striped
#/	Expl:	tag="$(stripWhiteSpace "both" "${lineR[1]}")"	
#/	Notes:	this is very time expensive functon avoid or attempt to rewrite	
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
} #end_stripWhiteSpace

#---------------------------------------------------------------------------------------------------------------------------
# utils array
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#/	Desc:	gets array length (number of elements)
#/	$1:		array passed as a name
#/	Out:	the length
#/	Expl:	out=$(aLength ray[@])
aLength(){
	local array="$1[@]"
	echo "${#array[@]}"
}
#tests if a value is in an array.
#arg1: array name
#arg2: seeking value
array_contains () { 
local array="$1[@]"
local seeking=$2
local in=0
for element in "${!array}"; do
	if [[ $element == $seeking ]]; then
		in=1
		break
	fi
done
echo $in
} #end_array_contains

#/http://stackoverflow.com/questions/10586153/split-string-into-an-array-in-bash
#splits a string wwith commas into an array
#arg1: the string
#returns an array by name 
#newliens must be written IFS=$'\n'
array_split(){
	IFS=", " read -r -a array <<< "$1"
} #end_array_split

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
} #end_printAssociativeArray

#/	Desc:	prints a normal array
#/	$1:		array passed via name only
#/	Expl:	printArray array[@]
printArray(){
	local array="$1[@]"
	for element in "${!array}"; do
		echo "$element"
	done
} #end_printArray

#---------------------------------------------------------------------------------------------------------------------------
# utils list
# utils manulist
#---------------------------------------------------------------------------------------------------------------------------

list_printTabed(){
	#echo "$1"
	#echo "---"
	pad=20
	IFS="," read -ra TESTRAY <<< "$1"
	for mye in "${TESTRAY[@]}"; do
		a=b
	done
	printf "%-$pad"s" %-$pad"s" %-$pad"s" %-$pad"s" %-$pad"s"\n" ${TESTRAY[0]} ${TESTRAY[1]} ${TESTRAY[2]} ${TESTRAY[3]} ${TESTRAY[4]} ${TESTRAY[5]}
} #end_list_printTabed

#get the postiional element of a list
#arg1: postion
#arg2: delination
#arg3: list
list_returnElement(){
	local postion="$1"
	local deliniation="$2"
	local str="$3"
	IFS="$deliniation" read -ra TESTRAY <<< "$str"
	echo ${TESTRAY[postion]}
} #end_list_returnElement

#/	Desc:	Tests if a value is found in a list
#/	$1:		list
#/	$2:		string
#/	Out:	1 or 0 echo
#/	Expl:	out=$(inlist list str)
inList(){
	local LIST="$1"
	local str="$2"
	IFS=" " read -ra TESTRAY <<< "$LIST"
	out=$(array_contains TESTRAY[@] "$str")
	echo "$out"
} #end_inList


#-----------------------------------------------------------------------------------------------------------------------
#  utils upgrade
#-----------------------------------------------------------------------------------------------------------------------
#arg1: path to save to
getCloudFactoryUpgrade(){
	url="$1"
	curl -o /upgrades/upgradePackage.tar.gz "$url"
} #end_getCloudFactoryUpgrade

#/	Desc:	installs an upgrade tarball file handling multiple switch options
#/	$1:		tarball name
#/ 	#2:		if its set to 1, it will set the WIPETHEUSER_PARTITION to true (1)
#/	Expl:	xxx
installUpgrade(){
   	tar -xzf $1 -C /upgrades/
   	lightLog "info" "my fileis $1"
   	lightLog "info" "my wipe is $2"
   	if [[ $2 = 1 ]]; then
   		SedGeneric /upgrades/upgrade.sh \"0,/WIPETHEUSER_PARTITION.*/s//WIPETHEUSER_PARTITION=1/\"
   	fi
     rm -rf /upgrades/upgradePackage.tar.gz
     rm -rf /upgrades/install.sh
     rm -rf /upgrades/post-install.sh
} #end_installUpgrade






#arg1 tarball.tar.gz file with all the cloud keys in the root directory
#returns 0 if it failed to work
#returns 1 if it succeed to work
installCloudKeys(){
sslmp=/mnt/.boot
storage=/mnt/.boot/.ssl
tarball=$1
ssl_client_key="client.key.pem";
ssl_client_cert="client.cert.pem";
ssl_server_key="server.key.pem";
ssl_server_cert="server.cert.pem";
ssl_ca_cert="ca.cert.pem";
ssl_ca_intermediate="intermediate.cert.pem";
sslFiles=("$storage/$ssl_client_key" "$storage/$ssl_client_cert" "$storage/$ssl_server_cert" "$storage/$ssl_server_key" "$storage/$ssl_ca_intermediate" "$storage/$ssl_ca_cert")

umount /dev/mmcblk0p1
sync
umount /mnt/.boot/
sync
mkdir -p /mnt/.boot/ 2> /dev/null
mount /dev/mmcblk0p1 /mnt/.boot
sync
outputtest=$(mount)
lightLog "info" "$outputtest"
# lightLog "bash cmd: mountOrError /dev/mmcblk0p1 $sslmp"
# output=$(mountOrError /dev/mmcblk0p1 $sslmp)
# lightLog "we got from the mount '$output'"
# sync
mkdir -p $storage/
sync
tar -xzf $tarball -C $storage
sync
sync
badfile=0
goodsize=$(filesHaveSize sslFiles[@])
lightLog "info" "the good size $goodsize"
if [[ "$goodsize" -eq 1  ]]; then
	lightLog "info" "ssl keys are installed"
else
	lightLog "info" "we didn't install the ssl_certs properly"
fi
} #end_installCloudKeys


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


function runit() {
	eval "$1"
} #end_runit



#-----------------------------------------------------------------------------------------------------------------------
#  utils kill
#-----------------------------------------------------------------------------------------------------------------------
killalldevicejs() {
	log "debug" "killing all devicejs programs"
	killall runUpdater.sh
	killall checkForUpdates.sh
	killall devicedbd
	killall node
	killall slipcomms-arm
	killall cc2530prog-arm
} #end_killalldevicejs

killallnode(){
	killall node
} #end_killallnode

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







#functions
#-----------------------------------------------------------------------------------------------------------------------
# Installs soft links and changes file permissions based on two arrays
#SOFTLINKS=( "/mnt/.overlay/factory/wigwag/devicejs-ng/node_modules/npm/bin/npm" "/usr/bin/npm" "/mnt/.overlay/factory/wigwag/devicejs-ng/node_modules/npm/bin/npm-cli.js" "/usr/bin/npm-cli.js" )
#CHMODS=( permission "target" permission "target" )
links_chmods(){
	#do this associative arroy for all SOFTLINKS
	linkexe=""
	linkcheckexe=""
	chmodexe=""
	for (( i=0; i<${#SOFTLINKS[@]}; i=i+2 )); do 
	sFile="${SOFTLINKS[$i+1]}"

	rFile="${SOFTLINKS[$i]}"
	linkexe=$linkexe"ln -s ${SOFTLINKS[$i]} ${SOFTLINKS[$i+1]};"
	linkcheckexe=$linkcheckexe"if ( ! -e ln -s ${SOFTLINKS[$i]} ${SOFTLINKS[$i+1]};"
done  
for ((i=0; i<${#CHMODS[@]}; i=i+2)); do 
chmodexe=$chmodexe"chmod ${CHMODS[$i]} ${CHMODS[i+1]};"
done 
#echo "ssh root@$THISIP $linkexe$chmodexe"
ssh root@$THISIP "$linkexe$chmodexe"
} #end_links_chmods



getCurrentIP(){
	if [[ "$OS" == "mac" ]]; then
		for (( i = 0; i < 10; i++ )); do
			currentip=$(ifconfig en$i 2>/dev/null | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' 2>/dev/null) 2> /dev/null
			if [[ $currentip != "" ]]; then
				break;
			fi
		done
	else
		currentip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
	fi
	echo $currentip
} #end_getCurrentIP

getPublicIP(){
	curl icanhazip.com 2> /dev/null
} #end_getPublicIP

updatePublicIP(){
	THISPUBLICIP=$(getPublicIP)
} #end_updatePublicIP

md5sig(){
	if [[ "$OS" = "mac" ]]; then
		md5 -q $1
	else
		md5sum -q $1
	fi
} #end_md5sig


#parameters
#1 doit? [0|1] if 1, build the pushback, if 0 dont
#2 user@IP for the pushback
PUSHBACK(){
	log error "PUSBACK is Depricated.  Rename your function COMMON_DEVELOPER_PUSHBACK_SCRIPT"
	doit=$1
	whereto=$2
	if [[ $doit -eq 1 ]]; then
		currentip=$(getCurrentIP)
		currentuser=$(whoami);
		currentdir=$(pwd);
		echo -e "#!/bin/bash\nputitnow(){\n\tscp -r \$1 $whereto:$currentdir\n}\nif [[ ! \$1 = \"nodestuff\" ]];then\nputitnow \$1\nelse\nputitnow \"package.json node_modules\"\nfi\n" > pushback.sh
		chmod 777 pushback.sh
	fi
} #end_PUSHBACK



file_available() {
	if [[ -e $1 ]]; then
		return 0
	else
		return 1
	fi
} #end_file_available


#/	Desc:	Returns path information about a string
#/	$1:		str
#/	$2:		type [1|2|3|4]
#/	Out:	type=1: just the file name
#/	Out:	type=2: just the file extension
#/	Out:	type=3: just the file name without extension
#/	Out:	type=4: just the directory path
#/	Expl:	out=$(pathanalysis file 2)
pathanalysis(){
	fullfile=/$1
	filename=$(basename "$fullfile")
	extension="${filename##*.}"
	filenameminus="${filename%.*}"
	DIR=$(dirname "${fullfile}")
	if [[ $2 -eq 1 ]]; then
		echo "$filename"
	elif [[ "$2" -eq 2 ]]; then
		echo "$extension"
	elif [[ "$2" -eq 3 ]]; then
		echo "$filenameminus"
	elif [[ "$2" -eq 4 ]]; then
		echo "$DIR"
	else
		echo "your not specifying the command properly"
	fi
} #end_pathanalysis

#paramters
#1 an array of files
#2 where to copy the file to
#3 ["true"|"false"] vailidate and print an error if the file does not exist
#4 ["true"|"false"] exit if any of the files doesn't exit (checks all files first)
copy_files() {
	name=$1[@]
	ray=("${!name}")
	path_to_copy_to=$2
	check_if_file_exists=$3
	exit_if_file_does_not_exist=$4
	if [[ $check_if_file_exists = true ]]; then
		files_avaiable ray[@] $exit_if_file_does_not_exist
	fi
	failure=0
	for ((i=0; i<${#ray[@]}; i=i+1)); do
		m1=$( md5sig ${ray[$i]} )
		m2=$( md5sig $(pathanalysis ${ray[$i]} 1 ))
		if [[ $m2 != $m1 ]]; then
			cp ${ray[$i]} $2	
			if [[ $? -gt 0 ]]; then
				(( failure++ ))
			fi
		fi
	done
	return $failure
} #end_copy_files

putIntoWwupdate(){
	echo $1 >> wwupdate.sh
} #end_putIntoWwupdate


COMMON_DEBUG() {
	log "debug" "$1"
} #end_COMMON_DEBUG


COMMON_ARRAY_PASS_TEST() {
	name=$1[@]
	ray=("${!name}")
	for ((i=0; i<${#ray[@]}; i=i+1)); do
		#f1=$(pathanalysis ${ray[$i]} 1 )
		echo $i
	done
} #end_COMMON_ARRAY_PASS_TEST

COMMMON_BUILD_WWUPDATE(){
	cp $manutoolsroot/misc/USB_key_scripts/wwupdate-shell.sh wwupdate.sh
	cmds=$1[@]
	ray=("${!cmds}")
	for ((i=0; i<${#ray[@]}; i=i+1)); do
		putIntoWwupdate "${ray[$i]}"
	done
} #end_COMMON_BUILD_WWUPDATE




#/	Desc:	Exits if a valid IP has not been provided
#/	$1:		IP
#/	Expl:	COMMON_EXIT_NON_VALID_IP "10.10.102.X"
COMMON_EXIT_ON_NON_VALID_IP() {
	if [[ $1 == "" ]]; then
		echo You must enter a valid IP
		COMMON_MENU_HELP
	fi
} #end_COMMON_EXIT_ON_NON_VALID_IP

COMMON_CHECK_USB_INSTALLED() {
	ismounted=$(ssh root@$IP "if mount | grep $remote_work_dir > /dev/null; then     echo 1; else     echo 0; fi")
	echo $ismounted
} #end_COMMON_CHECK_USB_INSTALLED

COMMON_DEVELOPER_PUSHBACK_SCRIPT(){
	doit=$1
	whereto=$2
	if [[ $doit -eq 1 ]]; then
		currentip=$(getCurrentIP)
		currentuser=$(whoami);
		currentdir=$(pwd);
		echo -e "#!/bin/bash\nputitnow(){\n\tscp -r \$1 $whereto:$currentdir\n}\nif [[ \$1 == \"\" ]];then \necho 'Usage ./putitnow [<file>|nodestuff]'\nexit\nfi\n if [[ ! \$1 = \"nodestuff\" ]];then\nputitnow \$1\nelse\nputitnow \"package.json node_modules\"\nfi\n" > pushback.sh
		chmod 777 pushback.sh
	fi
} #end_COMMON_DEVELOPER_PUSHBACK_SCRIPT

#paramters
#1 tempfile1 for checking against tempfile2. 
#2 tempfile2 for checking against tempfile1.
#3 Only Transfer if new [0|1] 1=true, meaning don't execute the ssh command if it has not changed since last time (uses tempfile1 and tempfile2 to validate.)  0 meaning ignore the check, always transfer
#4 ssh command string

COMMON_REMOTESSHCMD() {
	doit=$1
	name_lite=$2
	name=$name_lite[@]
	cmdray=("${!name}")
	name2=$3[@]
	doray=("${!name2}")
	tempfile1=/tmp/.$1"1"
	tempfile2=/tmp/.$1"2"
	forcetransfer=$4
	sshline=""
	debug "doit ($doit) name_lite ($name_lite) forcetransfer ($forcetransfer) doray ($doray)"
	if [[ $doit -eq 1 ]]; then
		for ((t=0; t<${#doray[@]}; t=t+1)); do
			for ((i=0; i<${#cmdray[@]}; i=i+2)); do
				ckey=${cmdray[$i]}
				cdata=${cmdray[(( $i + 1 )) ]}
				ukey=${doray[$t]}
				if [[ $ckey == $ukey ]]; then
					sshline=$sshline"$cdata";
				fi
			done
		done
		echo "$sshline" > $tempfile2
		if [[ ! -e $tempfile1 ]]; then
			echo "$sshline" > $tempfile1
			forcetransfer=1
		else
			diff $tempfile1 $tempfile2
			if [[ $? -eq 1 ]]; then
				forcetransfer=1
				cp $tempfile2 $tempfile1
			fi
		fi
		debug "force the ssh transfer: $forcetransfer"
		if [[ $forcetransfer -eq 1 ]]; then
			ssh root@$THISIP "$sshline"
			debug "Executing the ssh line ($name_lite)"
		else
			debug "Not executing the ssh line ($name_lite)"
			echo "Not executing the ssh line to save time, try -f"
		fi
	fi
} #end_COMMON_REMOTESSHCMD

		# if [[ ! -e $(pathanalysis ${cmdray[$i]} 1 ) ]]; then
		# 	ln -s ${cmdray[$i]} $2
		# 	#echo NOW: ln -s ${cmdray[$i]} $2
		# fi
		# if [[ $? -gt 0 ]]; then
		# 	(( failure++ ))
		# fi

# 	done

# }

COMMON_PUSH_WWMANUMODULES(){
	log debug "copying the ww-manu_modules wherever they go"
	cp -R FACTORY/node_modules/ww-manu_modules/* ../../manu-FTDS/node_modules/ww-manu_modules/
} #end_COMMON_PUSH_WWMANUMODULES


COMMON_MENU_ARG_CHECKER() {
	local valids="$1"
	local checking="$2"
	if [[ $(array_contains $valids "$2") -eq 0 ]]; then
		echo ${ERROR} $checking is not a member of $valids
		COMMON_MENU_HELP
	fi
} #end_COMMON_MENU_ARG_CHECKER

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
} #end_COMMON_MENU_SWITCH_GRAB

#/	Desc:	Generates a menu based on a named template system
#/  Global: declare -A hp=() assoiative array of switches
#/			exects an associateve array named hp.
#/			hp nomenclature hp[x] where x represents a switch
#/			and where hp[xx] represents a switch and varriable
#/	$1:		[error text]  OPTIONAL
#/	$2:		name1
#/	$3:		name1
#/	Out:	a help text for the cli
#/	Expl:	COMMON_MENU_HELP
COMMON_MENU_HELP(){
	if [[ $1 != "" ]]; then
		echo -e "\nERROR: ${REV}${BOLD}$1${NORM}"
	fi
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
} #end_COMMON_MENU_HELP



#paramters
#1 doit 0|1 #1 doit? [0|1] if 1, build the pushback, if 0 dont
#1 an array of files
#2 where to copy the file to
#3 ["true"|"false"] vailidate and print an error if the file does not exist
#4 ["true"|"false"] exit if any of the files doesn't exit (checks all files first)
COMMON_LINKLOCALFILES(){
	doit=$1
	name=$2[@]
	ray=("${!name}")
	path_to_copy_to=$3
	check_if_file_exists=$4
	exit_if_file_does_not_exist=$5
	if [[ $doit -eq 1 ]]; then
		if [[ $check_if_file_exists = true ]]; then
			files_avaiable ray[@] $exit_if_file_does_not_exist
		fi
		failure=0
		for ((i=0; i<${#ray[@]}; i=i+1)); do

			if [[ ! -e $(pathanalysis ${ray[$i]} 1 ) ]]; then
				ln -s ${ray[$i]} $path_to_copy_to
			 	#echo ln -s ${ray[$i]} $path_to_copy_to
			 fi
			 if [[ $? -gt 0 ]]; then
			 	(( failure++ ))
			 fi

			done
			return $failure
		fi
} #end_COMMON_LINKLOCALFILES


CLEANFORGIT(){
	doit=$1
	name=$2[@]
	ray=("${!name}")
	check_if_file_exists=$3
	exit_if_file_does_not_exist=$4
	if [[ $check_if_file_exists = true ]]; then
		files_avaiable ray[@] $exit_if_file_does_not_exist
	fi
	failure=0
	for ((i=0; i<${#ray[@]}; i=i+2)); do
		thefile=${ray[$i]}
		path_to_copy_to=${ray[$i+1]}
		echo $thefile $path_to_copy_to 
			# if [[ ! -e $(pathanalysis $thefile 1 ) ]]; then
			# 	ln -s $thefile $path_to_copy_to
			# 	echo ln -s ${ray[$i]} $path_to_copy_to
			# fi
			# if [[ $? -gt 0 ]]; then
			# 	(( failure++ ))
			# fi

		done
		return $failure
} #end_CLEANFORGIT



#---eventually fix this function to validate down a path
#paramters
#1 doit 0|1  if 1, build the pushback, if 0 dont
#1 an array of files
#2 where to copy the file to
#3 ["true"|"false"] vailidate and print an error if the file does not exist
#4 ["true"|"false"] exit if any of the files doesn't exit (checks all files first)
COMMON_LINKLOCALFILES2(){
	log silly "function:\tCOMMON_LINKLOCALFILES2(doit='$1', name=$2, check_if_file_exists=$3, exit_if_file_does_not_exist=$4)"
	doit=$1
	name=$2[@]
	ray=("${!name}")
	check_if_file_exists=$3
	exit_if_file_does_not_exist=$4
	if [[ $doit -eq 1 ]]; then
		if [[ $check_if_file_exists = true ]]; then
			files_avaiable ray[@] $exit_if_file_does_not_exist
		fi
		failure=0
		for ((i=0; i<${#ray[@]}; i=i+2)); do
			thefile=${ray[$i]}
			path_to_copy_to=${ray[$i+1]}
			fp=$path_to_copy_to"/"$(pathanalysis $thefile 1 )
			if [[ ! -e $fp ]]; then
				ln -s $thefile $path_to_copy_to
				echo ln -s ${ray[$i]} $path_to_copy_to
			fi
			if [[ $? -gt 0 ]]; then
				(( failure++ ))
			fi

		done
		return $failure
	fi
} #end_COMMON_LINKLOCALFILES2

del_local_files() {
	name=$1[@]
	ray=("${!name}")
	for ((i=0; i<${#ray[@]}; i=i+1)); do
		f1=$(pathanalysis ${ray[$i]} 1 )
		rm -rf $f1
	done

} #end_del_local_files

#paramters
#1 an array of files
#["true"|"false"] to exit on error (first checks all files and prints an error if non-existant)
#
#Call this: files_avaiable array[@]
#output=$?
files_avaiable() {
	name=$1[@]
	ray=("${!name}")
	exit_if_file_does_not_exist=$2
	failure=0
	for ((i=0; i<${#ray[@]}; i=i+2)); do
		pushd . >> /dev/null
		#echo $i ${ray[$i]} vs ${ray[$i+1]}
		cd ${ray[$i+1]}
		if [[ ! -e ${ray[$i]} ]]; then
			(( failure++ ))
			echo $ERROR ${ray[$i]} does not exist 
		fi
		popd >> /dev/null
	done
	if [[ $exit_if_file_does_not_exist = true ]]; then
		if [[ $failure -gt 0 ]]; then
	#		echo "exiting because $failure files do not exist"
	exit
fi
fi
return $failure
} #end_files_avaiable




#--------------------------------------------------------------------------
#utils Relay
#--------------------------------------------------------------------------




getThisTerm(){
	echo tty
} #end_getThisTerm

COMMON_OS=$(whichOS)
THISOS=$COMMON_OS
THISPUBLICIP=$(getPublicIP)
THISIP=$(getCurrentIP)
THISDIR=$(pwd)
WHOAMI=$(whoami)



if [[ $1 != "" ]]; then
	cmd=$1
	shift
	$cmd "$@"
fi