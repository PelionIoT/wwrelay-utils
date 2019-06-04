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

/etc/init.d/deviceOS-watchdog humanhalt
/etc/init.d/deviceOS-watchdog humanhalt

killall node
ledcontrol=/wigwag/system/bin/led
function grabip() {
    ifconfig > ifconfig.txt
}
function grabip2() {
    ifconfig > ifconfig2.txt
}
function dhcpthis(){
    udhcpc -n
}
$ledcontrol 5 5 5
udhcpc eth0
/etc/init.d/devjssupport start


#--------Commands go here

grabip
dhcpthis
grabip2
sleep 15
curl http://localhost:3000/start
/etc/init.d/relayterm start
rm -rf /userdata/etc/devicejs/db/
sleep 5
$ledcontrol 0 10 0
