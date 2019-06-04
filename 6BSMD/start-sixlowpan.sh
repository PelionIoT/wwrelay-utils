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

# Use like this:
# 
# THISDIR=$(getScriptDir "${BASH_SOURCE[0]}")
function getScriptDir() {
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
local __SOURCE=$1
while [ -h "$__SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  local __MYDIR="$( cd -P "$( dirname "$__SOURCE" )" && pwd )"
  local __SOURCE="$(readlink "$__SOURCE")"
  [[ $__SOURCE != /* ]] && local __SOURCE="$__MYDIR/$__SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
local __MYDIR="$( cd -P "$( dirname "$__SOURCE" )" && pwd )"
echo "$__MYDIR"
}

THISDIR=$(getScriptDir "${BASH_SOURCE[0]}")
. $THISDIR/../common/common.sh

# bring GPIO functions and the important varriables
. $THISDIR/../GPIO/setup-gpio.sh funcsonly
SCRIPT=`basename ${BASH_SOURCE[0]}`

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [start|stop|debug (ttyport baud)]"
    
fi


TUNSLIP_SERIAL=/dev/ttyS2
TUNSLIP=$THISDIR/tunslip6
TUNSLIP_LOG=$THISDIR/../../log/tunslip6.log

IP6_ROUTE="aaaa::1/64"

# supports 1-5 or nothing for basic
TUNSLIP_LOG_LEVEL="5"

if [ "$1" == "start" ]; then
    echo "Starting Developer mode stuff (inside start-sixlowpan.sh)"
    /wigwag/wwrelay-utils/dev-tools/bin/devinits.sh
    killall tunslip6
    eval $COLOR_BOLD
    echo "Starting SixLowPAN services."
    eval $COLOR_NORMAL
    if [ ! -e $SBMC_RESET ]; then
	eval $COLOR_BOLD
	echo "GPIO not ready - setting up."
	eval $COLOR_NORMAL
	modprobe_gpiodriver
	exportGPIOs
	setdirection    
    fi

    if [ ! -e $TR ]; then
	eval $COLOR_RED
	echo "GPIO not setup! Failing."
	eval $COLOR_NORMAL    
    fi
    
    if [ -e $TUNSLIP_LOG ]; then
	# some trivial log rotation
	mv $TUNSLIP_LOG $TUNSLIP_LOG.1
    fi
    echo "CMD: $TUNSLIP -v$TUNSLIP_LOG_LEVEL -s $TUNSLIP_SERIAL $IP6_ROUTE > $TUNSLIP_LOG 2>&1 &"
    $TUNSLIP -v$TUNSLIP_LOG_LEVEL -s $TUNSLIP_SERIAL $IP6_ROUTE > $TUNSLIP_LOG 2>&1 &
    sleep 3
    echo "Resetting 6BSMD"
    $THISDIR/6Bcontrol.sh reset
fi

if [ "$1" == "stop" ]; then
    echo "Killing tunslip6 process"
    killall tunslip6
fi

if [ "$1" == "debug" ]; then
    killall tunslip6
    eval $COLOR_BOLD
    echo "Starting SixLowPAN services on command line with -t $1"
    eval $COLOR_NORMAL
    if [ -z "$2" ]; then
        port=$SBMC_TTY
    else
        port="$2"
    fi
    if [ -z "$3" ]; then
        baudrate=1152300
    else
        baudrate="$3"
    fi
    echo "CMD: $TUNSLIP -v$TUNSLIP_LOG_LEVEL -s $port -B $baudrate $IP6_ROUTE"
    #sleep 5 && echo "donesleep" &
    echo "Resetting 6BSMD"
    $THISDIR/6bee-reset.sh 2 &
    $TUNSLIP -v$TUNSLIP_LOG_LEVEL -s $port -B $baudrate $IP6_ROUTE 
fi

