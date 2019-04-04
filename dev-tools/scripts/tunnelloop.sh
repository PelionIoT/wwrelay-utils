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

counter=0;
maxcount=$((60 * 12))
echo "$counter/$maxcount just now starting, waiting 180" > /tmp/timeloopcounter
sleep 180
while (true); do
	counter=$(($counter + 1))
	if [[ counter -gt $maxcount ]]; then
		pid=$(pgrep -f support/index.js)
		kill -9 $pid
		kill -9 $pid
		kill -9 $pid
		counter=0;
		sleep 5;
	fi
	ops=$(cat /sys/class/net/eth0/operstate)
	if [[ $ops -eq 0 ]]; then
		udhcpc -n
	fi
	pgrep -f support/index.js
	if [[ $? -ne 0 ]]; then
		/etc/init.d/devjssupport start
		sleep 5
	fi
	TIP=$(nslookup tunnel.wigwag.com | xargs | egrep -o tunnel.wigwag.com.* | awk '{ print $4 }')
	netstat -an | grep $TIP
	if [[ $? -ne 0 ]]; then
		curl http://localhost:3000/start
	fi
	echo $counter > /tmp/timeloopcounter
	echo "if this value gets to $maxcount, the tunnel will rebuild" >> /tmp/timeloopcounter
	sleep 60
done
