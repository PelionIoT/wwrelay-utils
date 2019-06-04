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

timing=10
fsize=48M;

#/etc/init.d/wdogreporter.sh &

starttime="$1"
if [[ $starttime = "" || upgradenum = "" ]]; then
	echo "oom nodefiller is not going to begin.  useage: nodefiller.sh <starttime>"
	echo "failed to provide: starttime: $starttime"
else

	echo -e "-----\nstarting a new session\n" 
	echo -e "   sleeping $starttime"
	sleep $starttime
	for i in {1..5}; do
		echo -e "  fake$i created"
		fallocate -l $fsize /var/log/fake$i
		df -h 
		echo "   sleeping $timing"
		sleep $timing
	done
	echo -e "done filling var/log"
	while true; do
		echo -e "   firing up node " 
		node &
		npid1=$!
		sleep $timing
		echo "   my node: $npid1" 
		sleep $timing
		kill -9 $npid1
		sleep 10
	done
fi