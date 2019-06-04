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

username=$(whoami)
IP=$(ifconfig | grep -A 2 -E 'wlan|eth|wlp|enp' | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
ARP=$(which arp-scan)
EXPECT=$(which expect)
ARP=$(which arp-scan)
if [[ $ARP == "" ]];then
    echo "arp-scan is not installed in your system so installing it..."
    sudo apt-get install arp-scan
    # testmystring does not contain c0
fi
EXPECT=$(which expect)
if [[ $EXPECT == "" ]];then
    echo "arp-scan is not installed in your system so installing it..."
    sudo apt-get install expect
    # testmystring does not contain c0
fi
echo "Your IP is -- $IP"
sudo ./utils/start.sh $IP $username 