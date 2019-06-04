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

kill `ps -ef | grep serialviapingpong | awk '{print $2}'`
sleep 2

FAIL=0

echo 'Starting Client'
NODE_PATH=/wigwag/devicejs-core-modules/node_modules/:node_modules/ node test-serialviapingpong.js /dev/ttyUSB1 115200 client &
client_pid=$!

sleep 2

echo 'Starting Server'
NODE_PATH=/wigwag/devicejs-core-modules/node_modules/:node_modules/  node test-serialviapingpong.js /dev/ttyUSB0 115200 server &
server_pid=$?


for job in `jobs -p`
do
echo $job
    wait $job || let "FAIL+=1"
done

echo $FAIL

if [ "$FAIL" == "0" ];
then
echo "YAY!"
else
echo "FAIL! ($FAIL)"
fi
