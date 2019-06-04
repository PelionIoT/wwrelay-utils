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

toggler=0;
TIP="$1"
TNM="$2"
TB="$3"
GW="$4"
SLEEPTIME="$5"


getIP(){
	theipis=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
	echo "$theipis"
}

if [[ $TIP != "" && TNM != "" && TB != "" && GW != "" && SLEEPTIME != "" ]]; then
	echo "IPRIP: starting the IPRIP loop"
	while(true); do
		sleep "$SLEEPTIME"
		if [[ $toggler -eq 0 ]]; then
			udhcpc -qn;
			ip=$(getIP)
			echo "IPRIP: switched IP addresses using udhcpc to: $ip"
			toggler=1;
		else
			ifconfig eth0 "$TIP" netmask "$TNM" broadcast "$TB"
			ip=$(getIP)
			echo "IPRIP: switched IP address using ifconfig to: $ip"
			toggler=0;
		fi
	done
else
	echo "IPRIP: Wont start, missing configuration"
fi

