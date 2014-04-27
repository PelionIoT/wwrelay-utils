#!/bin/bash


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

eval $COLOR_BOLD
echo "Setting up WWRelay (rev 5) GPIO ports"
eval $COLOR_NORMAL


### add here


GP[1]=gpio1_ph12
GP[2]=gpio2_pc21
GP[3]=gpio3_pc20
GP[4]=gpio4_pc19
GP[5]=gpio5_pb8
GP[6]=gpio6_pb13
GP[7]=gpio7_ph8
GP[8]=gpio8_pb4
GP[9]=gpio9_pb2
GP[10]=gpio10_pi12



function modprobe_driver() {
modprobe gpio-sunxi
}


function exportGPIOs () {
    for i in 1 2 3 4 5 6 7 8 9 10
    do
	echo $i > /sys/class/gpio/export
    done
}

function setdirection () {
GP_PATH=/sys/class/gpio/

#outputs
for i in  2 3 4 5 6 7 8 9 10
do
    GP_D=$GP_PATH${GP[$i]}/direction
    echo $GP_D
    echo out > $GP_D    
done

#inputs
GP_D=$GP_PATH${GP[1]}/direction
echo in > $GP_D
}

modprobe_driver
exportGPIOs
setdirection
