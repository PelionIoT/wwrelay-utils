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

lc=0;
fire_every=1000;

announce(){
	msg="$1"
	local slstart='/usr/local/bin/slack chat send --channel "#sqabot" --author "Panic Watcher" --author-icon "http://piq.codeus.net/static/media/userpics/piq_8583_400x400.png" '"\"$msg\""
	#echo "$slstart"
	eval "$slstart" &> /dev/null
}

check() {
	incount="$1"
	#echo "my incount = $incount"
	olc=$lc;
	lc=$(( $incount / $fire_every ));
	#echo "my lc=$lc, my olc=$olc"
	if [[ $lc != $olc ]]; then
		#echo announce "Watchdog Panics: $1"
		digitcount=$(( ${#incount} -1 ))
		nines=""
		for (( iq = 0; iq < $digitcount; iq++ )); do
			if [[ $iq -eq 2 ]]; then
				nines="$nines".
			fi
			nines="$nines""9"
		done
		nines="$nines""% reliability"
		#echo announce "Watchdog Panics w/o devicejs: $incount ($nines) *note, in reality we have not failed yet! :)"
		announce "Watchdog Panics w/o devicejs: $incount ($nines) *note, in reality we have not failed yet! :)"
	fi
}

ncloop(){
	while true; do
		catch=$(netcat -l -p 2233)
		#echo "I caought $catch"
		check "$catch"
	done
}

qloop(){
	for (( i = 0; i < 2000; i++ )); do
		check "$i"
	done
}


ncloop