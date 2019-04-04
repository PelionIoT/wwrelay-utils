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

sleep 12h
while true; do
    echo "Sending update command to wigwagupdater..."
    response=$(curl -s -o /dev/null -w %{http_code} -X POST http://127.0.0.1:3000/updateAll)
    echo "Response from wigwagupdater = " $response

	if [ $response -eq 200 ]
	then
	  echo "Success sending updateAll to wigwagupdater - next check in 1h"
	  sleep 1h
	else
	  echo "Failure sending updateAll to wigwagupdater - next check in 1m"
	  sleep 1m
	fi
	echo "=========================================================================="
done
