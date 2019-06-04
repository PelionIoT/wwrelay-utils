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

mountdir="/run/media/WWUPDATE"
disk="/dev/WWUPDATEp1"
initscript="wwupdate.sh"
initball="wwupdate.tar.gz"
initzip="wwupdate.zip"
logfile="/wigwag/log/update.log"


function logit() {
	if [[ $1 != "" ]]; then
		echo $(date)": $1 ">> $logfile
	fi
}

#mounts the usb key
function mounter() {
	logit "mounting media $disk "
	mkdir -p $mountdir
	mount -o rw $disk $mountdir
}

#unoumnts the usb key
function umounter() {
	logit "unmounting the directory $mountdir"
	cd /
	out=$(umount $mountdir)
	logit "$out"
	logit "unmounting the directory $disk"
	out=$(umount $disk)
	logit "$out"
}

#runs an init.sh script from the usb key
function runinit() {
	logit "inspecting the USB Key for $initscript or $initball"
cd $mountdir
if [[ -e $initscript ]]; then
	logit "runing the $initscript"
	. $initscript
elif [[ -e $initball ]]; then
	logit "untaring $initball to /tmp/"
	tar -xzf $initball -C /tmp/
	cd /tmp/
	. $initscript
fi
}

#deviceJS Update code
function updater() {
	date > /tmp/newdatetest
#jordan your code here....
#x
#y
#z
}

function stamp() {
	date > /tmp/newdate
}




if [ $# -eq 0 ]
  then
    pushd .
mounter
runinit
updater
popd
umounter
else
	umounter
fi
