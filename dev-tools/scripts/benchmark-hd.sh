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

device="$1"
fname="$2"
size="$3"

bon=$(which bonnie++)
if [[ $bon = "" ]]; then 
	echo "Install bonnie++"
	echo "sudo apt-get install bonnie++"
	exit
fi

wami=$(whoami)
if [[ $wami != "root" ]]; then
	echo "You must be root"
	exit
fi


USEAGE(){
	echo "USEAGE: $0 <hd dev> <filename (no space)> <size in GB (just number)>"
	echo "note on size.  It should be 2x the size of your ram.  So for 2GB Ram, put 4"
	exit
}

if [[ "$device" = "" || $1 = "-h" || $1 = "--help" || "$fname" = "" || "$size" = "" ]]; then 
	USEAGE
fi


temp=$(mktemp -d)
mount "$device" $temp
speed=$(lsusb -t | grep Mass | awk '{print $11}')
echo "Your usb is connected at: $speed"
cmd="bonnie++ -d $temp -s $size"G" -n 0 -m $fname -f -b -u root:root"
echo "$cmd"
ou=$(eval "$cmd" | tail -1 | bon_csv2html > $fname.html)
umount $1 >> /dev/null
umount $temp >> /dev/null
echo "looking for: $fname.html"
ls -al
