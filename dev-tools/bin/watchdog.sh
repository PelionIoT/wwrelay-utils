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