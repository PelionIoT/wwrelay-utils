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

WIGWAGROOT="/wigwag"
DEVICEDB_CMD="/usr/bin/devicedb"
DEVICEDB_LOG="${WIGWAGROOT}/log/devicedb.log"
DEVICEDB_CONF="${WIGWAGROOT}/etc/devicejs/devicedb.yaml"

function run_devicedb() {
	while true; do
		$DEVICEDB_CMD start -conf=$DEVICEDB_CONF >> $DEVICEDB_LOG 2>&1
		sleep 1
	done
}

run_devicedb