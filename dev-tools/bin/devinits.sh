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

COMMAND=$1

#----------------------------CONFIG-----------------------------
#SOFTLINKS
#format (linkpath1 linktarget1 linkpath2 linktarget2 ...)
declare -a links=("/usr/bin/gcc" "/usr/bin/arm-poky-linux-gnueabi-gcc" "/usr/bin/cc" "/usr/bin/arm-poky-linux-gnueabi-gcc" "/usr/\
bin/g++" "/usr/bin/arm-poky-linux-gnueabi-g++" "/usr/bin/cpp" "/usr/bin/arm-poky-linux-gnueabi-cpp")



#-----------------------------END CONFIG-------------------------



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
. $THISDIR/../../common/common.sh

function add-softlink (){
    newname=$2
    target=$1
    ln -s $1 $2
}


function fixProcessorSpeed () {
  echo "Fixing CPU Speed"
  speed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
  echo -e "\tcurrent frequency speed:\t\t\t\t\t\t$speed"
  cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
  speed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
  echo -e "\tnew frequency speed:\t\t\t\t\t\t\t$speed"
}

function buildlinks () {
  echo "Buidling Links"
  raylength="${#links[@]}"
  for i in $(seq 0 2 $((raylength-1))) 
  do 
    link="${links[i]}"
    link_target="${links[$((i+1))]}"
    if [ ! -f $link ]; then
      add-softlink $link_target $link
      echo -e "\t$link --> $link_target\t\t\tADDED"
    else
      echo -e "\t$link --> $link_target\t\t\tEXISTS"
    fi
  done
}

function tattletale(){
  echo -e "\nKernel Configs\n---------------------------------\n"
  zcat /proc/config.gz | grep CONFIG_GPIO_SUNXI
  zcat /proc/config.gz | grep CONFIG_LEDS_SUNXI
    zcat /proc/config.gz | grep CONFIG_SERIAL_8250_SUNXI
  echo -e "\nCPU Speeds\n---------------------------------\n"
  echo -e "current CPU0 speed: " `cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq`
  echo -e "current CPU1 speed: " `cat /sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_cur_freq`
  echo -e "\nUART_Assignments\n---------------------------------\n"
  echo -e "\t${C_BOLD}U1 Assign:\t${C_GREEN} /dev/"`ls /sys/devices/platform/sunxi-uart.1/tty/`"${C_NORM}"
 echo -e "\t${C_BOLD}U2 Assign:\t${C_GREEN} /dev/"`ls /sys/devices/platform/sunxi-uart.2/tty/`"${C_NORM}"
 echo -e "\t${C_BOLD}U3 Assign:\t${C_GREEN} /dev/"`ls /sys/devices/platform/sunxi-uart.3/tty/`"${C_NORM}"
 echo -e "\t${C_BOLD}U4 Assign:\t${C_GREEN} /dev/"`ls /sys/devices/platform/sunxi-uart.4/tty/`"${C_NORM}"
 echo -e "\t${C_BOLD}U5 Assign:\t${C_GREEN} /dev/"`ls /sys/devices/platform/sunxi-uart.5/tty/`"${C_NORM}"
 echo -e "\t${C_BOLD}U6 Assign:\t${C_GREEN} /dev/"`ls /sys/devices/platform/sunxi-uart.6/tty/`"${C_NORM}"
 echo -e "\t${C_BOLD}U7 Assign:\t${C_GREEN} /dev/"`ls /sys/devices/platform/sunxi-uart.7/tty/`"${C_NORM}"

}

function main () {
    buildlinks
    tattletale
    fixProcessorSpeed
}

main
