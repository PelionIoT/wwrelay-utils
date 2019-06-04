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

echo "Stopping edge-core..."
kill `ps -ef | grep edge-core | awk '{print $2}'`
sleep 2
echo "Restarting edge-core"
/etc/init.d/mbed-edge-core start
sleep 2

echo "Stopping mbed-devicejs-bridge..."
kill `ps -ef | grep mbed-devicejs-bridge | awk '{print $2}'`
echo "Maestro will restart mbed-devicejs-bridge..."
echo "Work done. Good Bye!"
