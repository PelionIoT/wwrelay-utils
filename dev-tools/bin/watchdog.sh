#!/bin/bash
source ccommon.sh

KEEPALIVE="/var/deviceOSkeepalive"
PID=/var/run/deviceOSWD.pid




main(){
	case "$1" in
		"stop") SOCATCMD="echo -e \"stop\" | socat unix-sendto:$KEEPALIVE STDIO;killall deviceOSWD;rm $PID"; ;;
		#
		"update") SOCATCMD="echo -e \"up $t\" | socat unix-sendto:$KEEPALIVE STDIO"; ;;
		#
	esac
	eval "$SOCATCMD"
}



declare -A hp=(
	[description]="Controls the Watchdog dameon for developers"
	[useage]="-options <update|stop>"
	[tt]="sets the ceiling to <time> if below <time> DEFAULT 90"
	[e1]="\t${BOLD}${UND}sets the watchdog to 80 seconds${NORM}\n\t\t$0 -t 80 update ${NORM}\n"
	[e2]="\t${BOLD}${UND}stops the daemon (no reboot will happen)${NORM}\n\t\t$0 stop ${NORM}\n"
	)

t=90;
argprocessor(){
	switch_conditions=$(COMMON_MENU_SWITCH_GRAB)
	while getopts "$switch_conditions" flag; do
		case $flag in
			t)  t=$OPTARG; ;;
			#
			\?) echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed.";COMMON_MENU_HELP;exit; ;;
			#
		esac
	done
	shift $(( OPTIND - 1 ));
	echo hey my $1
	if [[ $1 = "" ]]; then
		COMMON_MENU_HELP
		exit
	else
		main "$@"
	fi
} 

argprocessor "$@"