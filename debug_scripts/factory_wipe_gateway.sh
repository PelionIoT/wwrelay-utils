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

echo "Stopping deviceOSWD"
/etc/init.d/deviceOS-watchdog humanhalt

echo "Stopping maestro processes..."
killall maestro
killall maestro
killall devicedb

echo "Stopping edge core..."
kill $(ps aux | grep -E 'edge-core|edge_core' | awk '{print $2}');

echo "Deleting gateway database"
rm -rf /userdata/etc/devicejs/db
echo "Deleting mcc_config. Will be restored from eeprom!"
rm -rf /userdata/mbed/mcc_config*
echo "Deleting maestro configuration database"
rm -rf /userdata/etc/maestroConfig.db

echo "Delete gateway_eeprom file"
rm -rf /userdata/edge_gw_config*
