#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------
# logging utilities
#---------------------------------------------------------------------------------------------------------------------------

logtest(){
	log error "should be red"
	log warn "should be yellow"
	log info "should be black"
	log verbose "should be Blue"
	log debug "should be magenta"
	log silly "should be green"
} #end_logtest

_setLogLevelID(){
	for i in "${!colorRay[@]}"; do
		if [[ "${colorRay[$i]}" = "${loglevel}" ]]; then
			loglevelid=${i};
		fi
	done
}

getLogLevelID(){
	echo $loglevelid;
}

#/	Desc:	common bash logger
#/	global:	LogToTerm 	[0|*1] uses the terminal number instead of echo to post messages.  this gets around degubbing functions that return data via echo
#/	global:	LogToSerial [*0|1] logs to both kmesg and ttyS0, good for relay debugging
#/	global: LogToecho 	[*0|1] logs to stdout.  disabled by default
#/	global: LogToFile 	<file> logs to a file
#/ 	global:	loglevel 	suppresses output for anything below the level spefied.  Levels are: ["none", "error", "warn", "info", "verbose", "debug", "silly","func"],
#/	$1:		message level within these options: ["none", "error", "warn", "info", "verbose", "debug", "silly","func"],
#/	$2:		"the message"
#/	$3:		lineinfo... We can overide the internally generated filename and line number, with this... e.g.: log debug "the call: $1" "${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}" sets a different line number, indirectly
#/	Out:	debug info on your screen
#/	Expl:	log "debug" "oh snarks, i got a problem"
THISTERM=$(tty)
	#echo "hi this term is $THISTERM"
	if [[ $THISTERM = "not a tty" ]]; then
		NORM="\u001b[0m"
		BOLD="\u001b[1m"
		REV="\u001b[7m"
		UND="\u001b[4m"
		BLACK="\u001b[30m"
		RED="\u001b[31m"
		GREEN="\u001b[32m"
		YELLOW="\u001b[33m"
		BLUE="\u001b[34m"
		MAGENTA="\u001b[35m"
		MAGENTA1="\u001b[35m"
		MAGENTA2="\u001b[35m"
		MAGENTA3="\u001b[35m"
		CYAN="\u001b[36m"
		WHITE="\u001b[37m"
		ORANGE="$YELLOW"
		ERROR="${REV}Error:${NORM}"
	else
		NORM="$(tput sgr0)"
		BOLD="$(tput bold)"
		REV="$(tput smso)"
		UND="$(tput smul)"
		BLACK="$(tput setaf 0)"
		RED="$(tput setaf 1)"
		GREEN="$(tput setaf 2)"
		YELLOW="$(tput setaf 3)"
		BLUE="$(tput setaf 4)"
		MAGENTA="$(tput setaf 90)"
		MAGENTA1="$(tput setaf 91)"
		MAGENTA2="$(tput setaf 92)"
		MAGENTA3="$(tput setaf 93)"
		CYAN="$(tput setaf 6)"
		WHITE="$(tput setaf 7)"
		ORANGE="$(tput setaf 172)"
		ERROR="${REV}Error:${NORM}"
	fi
	LogToTerm=1
	LogToSerial=0
	LogToecho=0
	LogToFile=""
	loglevel=func;
	log_withFileName=1;
	log_withLineNo=1;
	log_withFullPath=0;
	log_execuiteecho=1
	colorRay=(none error warn info verbose debug debug1 debug2 debug3 silly func func2);
	_setLogLevelID
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
	_setLogLevelID
	if [[ "$log_withFileName" -eq 1 ]]; then
		if [[ "$log_withFullPath" -eq 1 ]]; then
			BS=${BASH_SOURCE[1]}
		elif [[ "$log_with_HOSTmarker" != "" ]]; then
			echo "BS0: ${BASH_SOURCE[0]}"
			echo "BS1: ${BASH_SOURCE[1]}"
			echo "BS2: ${BASH_SOURCE[2]}"
			echo "BS3: ${BASH_SOURCE[3]}"
			BS=":$log_with_HOSTmarker:"${BASH_SOURCE[1]##*/}
		else
			BS=${BASH_SOURCE[1]##*/}
		fi
	fi
	if [[ "$log_withLineNo" -eq 1 ]]; then
		BS=$BS:${BASH_LINENO[0]}
	else
		BS=$BS
	fi
	if [[ $lineinfo != "" ]]; then
		BS="$lineinfo"
	fi
	if [[ "$log_execuiteecho" -eq 1 ]]; then
		LoGee="-e"
	else 
		LoGee=""
	fi
	if [[ "$LogToecho" -eq 1 ]]; then
		case $level in
			#
			"none") ;;
			#
			"error") if [[ $loglevelid -ge 1 ]]; then echo $LoGee "${RED}error${NORM}\t$message"; fi; ;;
			#
			"warn")  if [[ $loglevelid -ge 2 ]]; then echo $LoGee "${YELLOW}warn${NORM}\t$message"; fi ;;
			#
			"info")  if [[ $loglevelid -ge 3 ]]; then echo $LoGee "${WHITE}info${NORM}\t$message"; fi ;;
			#
			"verbose") if [[ $loglevelid -ge 4 ]]; then echo $LoGee "${CYAN}verbose${NORM}\t$message"; fi ;;
			#
			"debug") if [[ $loglevelid -ge 5 ]]; then echo $LoGee "${MAGENTA}debug [$BS]${NORM}\t$message"; fi ;;
			#
			"debug1")  if [[ $loglevelid -ge 6 ]]; then echo $LoGee "${MAGENTA1}debug1 [$BS]${NORM}\t$message"; fi ;;
			#
			"debug2")  if [[ $loglevelid -ge 7 ]]; then echo $LoGee "${MAGENTA2}debug2 [$BS]${NORM}\t$message"; fi ;;
			#
			"debug3")  if [[ $loglevelid -ge 8 ]]; then echo $LoGee "${MAGENTA3}debug3 [$BS]${NORM}\t$message"; fi ;;
			#
			"silly")  if [[ $loglevelid -ge 9 ]]; then echo $LoGee "${GREEN}silly [$BS]:${NORM}\t$message"; fi ;;
			#	
			"func")	if [[ $loglevelid -ge 10 ]]; then echo $LoGee "${BLUE}func [$BS]:${NORM}\t$message"; fi ;;
			#	
			"func2")	if [[ $loglevelid -ge 10 ]]; then echo $LoGee "${BLUE}func2 ${line}info${NORM}\t$message"; fi ;;
			#	
		esac
	fi
	if [[ "$LogToTerm" -eq 1 ]]; then
		#echo "logging to term"
		case $level in
			"none") ;;
			#
			"error")	if [[ $loglevelid -ge 1 ]]; then echo $LoGee "${RED}error${NORM}\t$message" > "$THISTERM"; fi; ;;
			#
			"warn")  	if [[ $loglevelid -ge 2 ]]; then echo $LoGee "${YELLOW}warn${NORM}\t$message" > "$THISTERM"; fi ;;
			#
			"info")  	if [[ $loglevelid -ge 3 ]]; then echo $LoGee "${ORANGE}info${NORM}\t$message" > "$THISTERM"; fi ;;
			#
			"verbose")  if [[ $loglevelid -ge 4 ]]; then echo $LoGee "${CYAN}verbose${NORM}\t$message" > "$THISTERM"; fi ;;
			#
			"debug")  if [[ $loglevelid -ge 5 ]]; then echo $LoGee "${MAGENTA}debug [$BS]${NORM}\t$message" > "$THISTERM"; fi ;;
			#
			"debug1")  if [[ $loglevelid -ge 6 ]]; then echo $LoGee "${MAGENTA1}debug1[$BS]${NORM}\t$message" > "$THISTERM"; fi ;;
			#
			"debug2")  if [[ $loglevelid -ge 7 ]]; then echo $LoGee "${MAGENTA2}debug2[$BS]${NORM}\t$message" > "$THISTERM"; fi ;;
			#
			"debug3")  if [[ $loglevelid -ge 8 ]]; then echo $LoGee "${MAGENTA3}debug3[$BS]${NORM}\t$message" > "$THISTERM"; fi ;;
			#
			"silly")  if [[ $loglevelid -ge 9 ]]; then echo $LoGee "${GREEN}silly [$BS]${NORM}\t$message" > "$THISTERM"; fi ;;
			#	
			"func")  	if [[ $loglevelid -ge 10 ]]; then echo $LoGee "${BLUE}func[$BS]${NORM}\t$message" > "$THISTERM"; fi ;;
			#	
			"func2") 	if [[ $loglevelid -ge 10 ]]; then echo $LoGee "${BLUE}func2${line}info${NORM}\t$message" > "$THISTERM"; fi ;;
			#	
		esac
	fi
	if [[ "$LogToSerial" -eq 1 ]]; then
		case $level in
			"none") ;;
			#
			"error")		if [[ $loglevelid -ge 1 ]]; then echo $LoGee "${RED}error${NORM}\t$message" > "$devK"; fi; ;;
			#
			"warn")  		if [[ $loglevelid -ge 2 ]]; then echo $LoGee "${YELLOW}warn${NORM}\t$message" > "$devK"; fi ;;
			#
			"info")  		if [[ $loglevelid -ge 3 ]]; then echo $LoGee "${ORANGE}info${NORM}\t$message" > "$devK"; fi ;;
			#
			"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo $LoGee "${CYAN}verbose${NORM}\t$message" > "$devK"; fi ;;
			#
			"debug")  		if [[ $loglevelid -ge 5 ]]; then echo $LoGee "${MAGENTA}debug [$BS]:${NORM}\t$message" > "$devK"; fi ;;
			#
			"debug1")  		if [[ $loglevelid -ge 6 ]]; then echo $LoGee "${MAGENTA1}debug1 [$BS]:${NORM}\t$message" > "$devK"; fi ;;
			#
			"debug2")  		if [[ $loglevelid -ge 7 ]]; then echo $LoGee "${MAGENTA2}debug2 [$BS]:${NORM}\t$message" > "$devK"; fi ;;
			#
			"debug3")  		if [[ $loglevelid -ge 8 ]]; then echo $LoGee "${MAGENTA3}debug3 [$BS]:${NORM}\t$message" > "$devK"; fi ;;
			#
			"silly")  		if [[ $loglevelid -ge 9 ]]; then echo $LoGee "${GREEN}silly [$BS]:${NORM}\t$message" > "$devK"; fi ;;
			#	
			"func")  	if [[ $loglevelid -ge 10 ]]; then echo $LoGee "${BLUE}func [$BS]:${NORM}\t$message" > "$devK"; fi ;;
			#	
			"func2") 	if [[ $loglevelid -ge 10 ]]; then echo $LoGee "${BLUE}func2 ${line}info${NORM}\t$message" > "$devK"; fi ;;
			#	
		esac
		case $level in
			"none") ;;
			#
			"error")		if [[ $loglevelid -ge 1 ]]; then echo $LoGee "${RED}error${NORM}\t$message" > "$devS0"; fi; ;;
			#
			"warn")  		if [[ $loglevelid -ge 2 ]]; then echo $LoGee "${YELLOW}warn${NORM}\t$message" > "$devS0"; fi ;;
			#
			"info")  		if [[ $loglevelid -ge 3 ]]; then echo $LoGee "${ORANGE}info${NORM}\t$message" > "$devS0"; fi ;;
			#
			"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo $LoGee "${CYAN}verbose${NORM}\t$message" > "$devS0"; fi ;;
			#
			"debug")  		if [[ $loglevelid -ge 5 ]]; then echo $LoGee "${MAGENTA}debug [$BS]:${NORM}\t$message" > "$devS0"; fi ;;
			#
			"debug1")  		if [[ $loglevelid -ge 6 ]]; then echo $LoGee "${MAGENTA1}debug1 [$BS]:${NORM}\t$message" > "$devS0"; fi ;;
			#
			"debug2")  		if [[ $loglevelid -ge 7 ]]; then echo $LoGee "${MAGENTA2}debug2 [$BS]:${NORM}\t$message" > "$devS0"; fi ;;
			#
			"debug3")  		if [[ $loglevelid -ge 8 ]]; then echo $LoGee "${MAGENTA3}debug3 [$BS]:${NORM}\t$message" > "$devS0"; fi ;;
			#
			"silly")  		if [[ $loglevelid -ge 9 ]]; then echo $LoGee "${GREEN}silly [$BS]:${NORM}\t$message" > "$devS0"; fi ;;
			#	
			"func")  	if [[ $loglevelid -ge 10 ]]; then echo $LoGee "${BLUE}func [$BS]:${NORM}\t$message" > "$devS0"; fi ;;
			#	
			"func2") 	if [[ $loglevelid -ge 10 ]]; then echo $LoGee "${BLUE}func2 ${line}info${NORM}\t$message" > "$devS0"; fi ;;
			#	
		esac
	fi
	if [[ "$LogToFile" != "" ]]; then
		case $level in
			"none") ;;
			#
			"error")		if [[ $loglevelid -ge 1 ]]; then echo $LoGee "${RED}error${NORM}\t$message" >> "$LogToFile"; fi; ;;
			#
			"warn")  		if [[ $loglevelid -ge 2 ]]; then echo $LoGee "${YELLOW}warn${NORM}\t$message" >> "$LogToFile"; fi ;;
			#
			"info")  		if [[ $loglevelid -ge 3 ]]; then echo $LoGee "${ORANGE}info${NORM}\t$message" >> "$LogToFile"; fi ;;
			#
			"verbose")  	if [[ $loglevelid -ge 4 ]]; then echo $LoGee "${CYAN}verbose${NORM}\t$message" >> "$LogToFile"; fi ;;
			#
			"debug")  		if [[ $loglevelid -ge 5 ]]; then echo $LoGee "5${MAGENTA}debug [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" >> "$LogToFile"; fi ;;
			#
			"debug1")  		if [[ $loglevelid -ge 6 ]]; then echo $LoGee "5${MAGENTA1}debug1 [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" >> "$LogToFile"; fi ;;
			#
			"debug2")  		if [[ $loglevelid -ge 7 ]]; then echo $LoGee "5${MAGENTA2}debug2 [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" >> "$LogToFile"; fi ;;
			#
			"debug3")  		if [[ $loglevelid -ge 8 ]]; then echo $LoGee "5${MAGENTA3}debug3 [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" >> "$LogToFile"; fi ;;
			#
			"silly")  		if [[ $loglevelid -ge 9 ]]; then echo $LoGee "${GREEN}silly [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" >> "$LogToFile"; fi ;;
			#	
			"func")  	if [[ $loglevelid -ge 10 ]]; then echo $LoGee "${BLUE}func [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]:${NORM}\t$message" >> "$LogToFile"; fi ;;
			#	
			"func2") 	if [[ $loglevelid -ge 10 ]]; then echo $LoGee "${BLUE}func2 ${line}info${NORM}\t$message" >> "$LogToFile"; fi ;;
			#	
		esac
	fi
} #end_log


_debug3(){
	#_setLogLevelID
	if [[ $loglevelid -ge 8 ]]; then
		thiscallingfunctionlinenumber="${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}"
		log debug3 "$2" "$thiscallingfunctionlinenumber"
		eval "$1"
	fi
}
_debug2(){
	#_setLogLevelID
	if [[ $loglevelid -ge 7 ]]; then
		thiscallingfunctionlinenumber="${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}"
		log debug2 "$2" "$thiscallingfunctionlinenumber"
		eval "$1"
	fi
}

_cmdLog(){
	log_depricated _cmdLog log_cmd
	log_cmd $@
}

cmdLog(){
	log_depricated cmdLog log_cmd
	log_cmd $@
}

log_varhighlight(){
    eval v=\$$1
    if [[ $2 != "" ]]; then
	tab="\t"
	for ((i=0; i<=$2; i++)); do 
	    tab="$tab\t"
	done
    fi
	echo -e "$1:${GREEN}${tab}${v}${NORM}"
}

log_cmd(){
	local startTime=$(date +%s)
	callingfunctionlinenumber="${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}"
	if [[ 0 -eq 1 ]]; then
		log debug "the call: $1" "$callingfunctionlinenumber"
	fi
	eval "$1"
	if [[ $? -ne 0 ]]; then
		log verbose "${RED}failure (${totaltime}s):$NORM $2"
		log debug "failed call: $1" "$callingfunctionlinenumber"
		exit
	else
		local endTime=$(date +%s)
		totaltime=$(($endTime - $startTime))
		log verbose "${GREEN}success (${totaltime}s):$NORM $2"
	fi
}

log_cmdExitFailure(){
	local startTime=$(date +%s)
	callingfunctionlinenumber="${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}"
	if [[ 0 -eq 1 ]]; then
		log debug "the call: $1" "$callingfunctionlinenumber"
	fi
	eval "$1"
	if [[ $? -ne 0 ]]; then
	    if [[ $2 = "2x" ]]; then
#		log error "[FAILED TO]: $1 "
		log verbose "${RED}failure (${totaltime}s):$NORM $1"
	    else
#		log error "[FAILED TO]: $2 "
		log verbose "${RED}failure (${totaltime}s):$NORM $2"
	    fi
		log debug "failure call: $1" "$callingfunctionlinenumber"
	    exit
	else
		local endTime=$(date +%s)
		totaltime=$(($endTime - $startTime))
		    if [[ $2 = "2x" ]]; then
		log verbose "${GREEN}success (${totaltime}s):$NORM $1"
		else
		log verbose "${GREEN}success (${totaltime}s):$NORM $2"
fi
	fi
}
cmdLog_ExitFailure(){
    log_depricated cmdLog_ExitFailure log_cmdExitFailure 
	log_cmdExitFailure $@
}

#log_depricated "renderList" "menusystem_renderlist [${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}]"
log_depricated(){
	log "warn" "Function ${ORANGE}$1${NORM} is depricated. Use ${ORANGE}$2${NORM} instead ${GREEN}$3${NORM}"
}

#/	Desc:	removed functions to display, this is harsher than depricated.  Have to do this sometimes
#/	Ver:	.1
#/	$1:		removed function
#/	$2:		new function
#/	$3:		reason
#/	Out:		
#/	Expl:	log_removed deadfunc newfunc "because we wanted to"
log_removed(){
	log "error" "Function ${ORANGE}$1${NORM} is removed. Use ${ORANGE}$2${NORM} reason: ${GREEN}$3${NORM}"
}
logn(){
	log_execuiteecho=0
	log "$@"
	log_execuiteecho=1
}




logger() {
	log "debug" "dumb"
	log "error" "depricated switch to log [${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}]-->$1: $2"
#	log "$1" "$2"
} #end_logger

logfunction() {
	log "function2" "$1" "[${BASH_SOURCE[1]##*/}:${BASH_LINENO[0]}]";
} #end_logfunction

alertc() { 
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
