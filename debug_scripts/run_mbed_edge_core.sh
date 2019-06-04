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

START_EDGE_CORE="/etc/init.d/mbed-edge-core start"

function run_edge_core() {
	while true; do
        if ! pgrep -x "edge-core" > /dev/null
        then
            # Only start edge-core if maestro is running
            if pgrep "maestro" > /dev/null; then
                sleep 30
                $START_EDGE_CORE &
                sleep 5
                kill $(ps aux | grep 'mbed-devicejs-bridge' | awk '{print $2}');
                kill $(ps aux | grep '/wigwag/mbed/pt-example' | awk '{print $2}');
                sleep 5
                /wigwag/mbed/pt-example -n pt-example --endpoint-postfix=-$(cat /sys/class/net/eth0/address) >> /var/log/pt-example.log 2>&1
                # kill $(ps aux | grep '/wigwag/mbed/blept-example' | awk '{print $2}');
                # sleep 5
                # /etc/init.d/mept-ble start
            fi
        else
            #edge-core is running, check if pt-example is, if not start it
            if ! pgrep -x "pt-example" > /dev/null
            then
                sleep 30
                /wigwag/mbed/pt-example -n pt-example --endpoint-postfix=-$(cat /sys/class/net/eth0/address) >> /var/log/pt-example.log 2>&1
            fi
        fi
        sleep 5
	done
}

run_edge_core