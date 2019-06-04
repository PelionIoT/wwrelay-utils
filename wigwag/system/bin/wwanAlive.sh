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

start_network(){
	echo "starting qmi"
	qmi-network /dev/cdc-wdm0 start
	if [[ $? -eq 0 ]]; then
		echo "start success, running dhclinet"
		dhclient -v $(qmicli -d /dev/cdc-wdm0 -w)
		echo nameserver 8.8.8.8 > /etc/resolv.conf
	else
		echo "start failed with non zero, stopping"
		stop_network;
	fi
}

stop_network(){
	echo "stopping network"
	qmi-network /dev/cdc-wdm0 stop
	killall -9 dhclient
	sleep 10

}

loop(){
	while true; do
		sleep 15
		status=$(qmicli -d /dev/cdc-wdm0 --wds-get-packet-service-status --device-open-proxy | awk -F ' ' '{print $4}')
		if [[ "$status" = "'connected'" ]]; then
			echo "network is ok"
		else
			if [[ -e /dev/cdc-wdm0 ]]; then
				echo "disconnected: starting network"
				stop_network;
				start_network;
			else
				"/dev/cdc-wdm0 does not exist"
			fi
		fi
	done
}


if [[ $1 = "" ]]; then
	loop
else
	$1
fi
