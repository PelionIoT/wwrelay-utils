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

MY_THISDIR=$(getScriptDir "${BASH_SOURCE[0]}")
. $MY_THISDIR/../common/common.sh

INIT_DIR="/etc/init.d"

INITS="devicejs sixlowpan"

for S in $INITS; do
    if [ ! -e $INIT_DIR/$S ]; then
	eval $COLOR_BOLD
	echo "Adding init script: $S"
	eval $COLOR_NORMAL
	cp $MY_THISDIR/$S $INIT_DIR
	chkconfig --add $S
    else
	echo "Init script $S already installed"
    fi
done

echo "Done."
