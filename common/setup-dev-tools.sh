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

#################


TOOLS="/usr/bin/arm-poky-linux-gnueabi-"

pushd /usr/bin

for VAR in `ls $TOOLS*`; do
if [ ! -e "${VAR/\/usr\/bin\/arm\-poky\-linux\-gnueabi\-/}" ]; then
    eval $COLOR_BOLD
    echo "softlink $VAR -> ${VAR/\/usr\/bin\/arm\-poky\-linux\-gnueabi\-/}"
    eval $COLOR_NORMAL
    ln -s $VAR ${VAR/\/usr\/bin\/arm\-poky\-linux\-gnueabi\-/}
else
    eval $COLOR_YELLOW
    echo "softlink for ${VAR/\/usr\/bin\/arm\-poky\-linux\-gnueabi\-/} exists already"
    eval $COLOR_NORMAL
fi
done

if [ ! -e "cc" ]; then
    eval $COLOR_BOLD
    echo "softlink ${TOOLS}gcc -> cc"
    eval $COLOR_NORMAL
    ln -s ${TOOLS}gcc cc
else
    eval $COLOR_YELLOW
    echo "softlink for 'cc' exists already"
    eval $COLOR_NORMAL
fi    

popd