#!/bin/bash
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
  zcat /proc/config.gz | grep CONFIG_GPIO_SUNXI
  echo -e "current CPU0 speed: " `cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq`
  echo -e "current CPU1 speed: " `cat /sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_cur_freq`
}

function main () {
    buildlinks
    tattletale
    fixProcessorSpeed
}

main
