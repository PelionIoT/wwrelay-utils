#! /bin/bash

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

if [ ! -e /updater/relay-updater/downloads ]; then
   mkdir -p /updater/relay-updater/downloads
fi

if [ ! -e /updater/relay-updater/installs ]; then
   mkdir -p /updater/relay-updater/installs
fi

KHTun=`cat /home/root/.ssh/known_hosts | grep tunnel.wigwag.com`;
if [ "$KHTun" = "" ]
        then
        cat /wigwag/support/known_hosts >> /home/root/.ssh/known_hosts;
fi

if [ ! -e /home/support/.ssh ] ; then
    mkdir -p /home/support/.ssh
fi

if [ ! -e /home/root/.ssh ] ; then
    mkdir -p /home/root/.ssh
fi

if [ ! -e /home/root/.ssh/known_hosts ] ; then
    touch  /home/root/.ssh/known_hosts
fi



/wigwag/support/checkForUpdates.sh &
chmod 600 /wigwag/support/relay_support_key
chown -R support:support /home/support/.ssh
node /wigwag/support/index.js
