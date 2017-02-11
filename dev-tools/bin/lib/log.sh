#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------
# logging utilities
#---------------------------------------------------------------------------------------------------------------------------

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